import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/report_date_range.dart';
import '../providers/restaurant_report_providers.dart';
import '../theme/report_colors.dart';

/// Sélecteur de période (carte + bottom sheet de presets).
class ReportDateRangeSelector extends ConsumerWidget {
  const ReportDateRangeSelector({super.key});

  static final _dayFormat = DateFormat('dd MMMM yyyy', 'fr');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(reportDateRangeProvider);
    final lastInclusive = range.end.subtract(const Duration(microseconds: 1));

    return Material(
      color: ReportColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () => _openPeriodSheet(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ReportColors.border),
            boxShadow: [
              BoxShadow(
                color: ReportColors.textPrimary.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: ReportColors.accent,
              ),
              const SizedBox(width: 10),
              Text(
                _presetLabel(range.preset),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: ReportColors.accent,
                ),
              ),
              Container(
                width: 1,
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: ReportColors.border,
              ),
              Expanded(
                child: Text(
                  '${_dayFormat.format(range.start)} → ${_dayFormat.format(lastInclusive)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ReportColors.textMuted,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ReportColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _presetLabel(ReportPeriodPreset preset) {
    return switch (preset) {
      ReportPeriodPreset.today => "Aujourd'hui",
      ReportPeriodPreset.yesterday => 'Hier',
      ReportPeriodPreset.last7Days => '7 derniers jours',
      ReportPeriodPreset.last30Days => '30 derniers jours',
      ReportPeriodPreset.custom => 'Personnalisé',
    };
  }

  Future<void> _openPeriodSheet(BuildContext context, WidgetRef ref) async {
    final current = ref.read(reportDateRangeProvider);

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.xs,
                ),
                child: Text(
                  'Période',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ReportColors.textPrimary,
                  ),
                ),
              ),
              for (final preset in const [
                ReportPeriodPreset.today,
                ReportPeriodPreset.yesterday,
                ReportPeriodPreset.last7Days,
                ReportPeriodPreset.last30Days,
              ])
                ListTile(
                  leading: Icon(
                    current.preset == preset
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: current.preset == preset
                        ? ReportColors.accent
                        : ReportColors.textMuted,
                  ),
                  title: Text(_presetLabel(preset)),
                  onTap: () {
                    ref.read(reportDateRangeProvider.notifier).setPreset(preset);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ListTile(
                leading: Icon(
                  current.preset == ReportPeriodPreset.custom
                      ? Icons.radio_button_checked
                      : Icons.date_range_outlined,
                  color: current.preset == ReportPeriodPreset.custom
                      ? ReportColors.accent
                      : ReportColors.textMuted,
                ),
                title: const Text('Personnalisé'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _pickCustomRange(context, ref);
                },
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final current = ref.read(reportDateRangeProvider);
    final lastInclusive = current.end.subtract(const Duration(microseconds: 1));

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: current.start,
        end: DateTime(
          lastInclusive.year,
          lastInclusive.month,
          lastInclusive.day,
        ),
      ),
      helpText: 'Choisir une période',
      saveText: 'Appliquer',
      cancelText: 'Annuler',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ReportColors.accent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    ref
        .read(reportDateRangeProvider.notifier)
        .setCustomRange(start: picked.start, end: picked.end);
  }
}
