import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../../restaurant/presentation/providers/commande_providers.dart';
import '../../data/services/restaurant_report_pdf_builder.dart';
import '../../domain/entities/report_date_range.dart';
import '../../domain/services/restaurant_report_aggregator.dart';
import '../../../shell/presentation/widgets/primary_scaffold.dart';
import '../providers/restaurant_report_providers.dart';
import '../theme/report_colors.dart';
import '../widgets/product_sales_breakdown_card.dart';
import '../widgets/report_date_range_selector.dart';
import '../widgets/restaurant_report_kpi_grid.dart';
import '../widgets/revenue_evolution_chart.dart';

/// Écran Rapports — établissement Restaurant (maquette Zuri).
class RestaurantReportsScreen extends ConsumerStatefulWidget {
  const RestaurantReportsScreen({super.key});

  @override
  ConsumerState<RestaurantReportsScreen> createState() =>
      _RestaurantReportsScreenState();
}

class _RestaurantReportsScreenState
    extends ConsumerState<RestaurantReportsScreen> {
  var _sharing = false;

  @override
  Widget build(BuildContext context) {
    final sending = ref.watch(sendRestaurantReportProvider).isLoading;

    ref.listen(sendRestaurantReportProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
        return;
      }
      final wasLoading = prev?.isLoading ?? false;
      if (wasLoading && next.hasValue && !next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rapport envoyé par e-mail.')),
        );
      }
    });

    return PrimaryScaffold(
      body: ColoredBox(
        color: ReportColors.pageBackground,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Aperçu des activités',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: ReportColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),
                FilledButton.icon(
                  key: const Key('send_report_button'),
                  onPressed: sending
                      ? null
                      : () => _onSendPressed(context, ref),
                  icon: sending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_outlined, size: 16),
                  label: Text(sending ? 'Envoi…' : 'Envoyer'),
                  style: FilledButton.styleFrom(
                    backgroundColor: ReportColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  key: const Key('share_report_button'),
                  onPressed: _sharing ? null : () => _onSharePressed(context),
                  icon: _sharing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share_outlined, size: 16),
                  label: Text(_sharing ? 'Export…' : 'Partager'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ReportColors.accent,
                    side: const BorderSide(color: ReportColors.accent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const ReportDateRangeSelector(),
            const SizedBox(height: AppSpacing.sm),
            const RestaurantReportKpiGrid(),
            const SizedBox(height: AppSpacing.sm),
            const RevenueEvolutionChart(),
            const SizedBox(height: AppSpacing.sm),
            const ProductSalesBreakdownCard(),
          ],
        ),
      ),
    );
  }

  Future<void> _onSendPressed(BuildContext context, WidgetRef ref) async {
    final option = await _pickReportOption(
      context: context,
      title: 'Envoyer le rapport',
      subtitle: 'Le rapport sera envoyé à l’e-mail du propriétaire.',
    );

    if (option == null || !context.mounted) return;
    await ref
        .read(sendRestaurantReportProvider.notifier)
        .send(kind: option.kind);
  }

  Future<void> _onSharePressed(BuildContext context) async {
    final option = await _pickReportOption(
      context: context,
      title: 'Partager le rapport',
      subtitle: 'Un PDF sera généré sur ce mobile puis partagé.',
    );
    if (option == null || !context.mounted) return;

    setState(() => _sharing = true);
    try {
      final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
      if (establishment == null) {
        throw StateError('Aucun établissement actif.');
      }

      final range = option.resolveRange(DateTime.now());
      final commandes = await ref.read(commandesProvider.future);
      final kpis = RestaurantReportAggregator.computeKpis(
        commandes: commandes,
        range: range,
      );
      final revenueEvolution =
          RestaurantReportAggregator.computeRevenueEvolution(
            commandes: commandes,
            range: range,
          );
      final productSales = await ref
          .read(restaurantReportingRepositoryProvider)
          .watchProductSales(
            establishmentId: establishment.id,
            range: range,
            categoryId: null,
            limit: null,
          )
          .first;

      final bytes = await const RestaurantReportPdfBuilder().build(
        establishmentName: establishment.name,
        periodLabel: option.title,
        range: range,
        kpis: kpis,
        revenueEvolution: revenueEvolution,
        productSales: productSales,
      );

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'rapport-zuri-${option.kind}.pdf',
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AuthErrorMapper.message(error))));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<_ReportShareOption?> _pickReportOption({
    required BuildContext context,
    required String title,
    required String subtitle,
  }) {
    return showModalBottomSheet<_ReportShareOption>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5D8E2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ReportColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: ReportColors.textMuted),
                ),
                const SizedBox(height: 12),
                for (final option in _ReportShareOption.values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(option.icon, color: ReportColors.accent),
                    title: Text(option.title),
                    subtitle: Text(option.subtitle),
                    onTap: () => Navigator.of(sheetContext).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _ReportShareOption {
  daily(
    kind: 'daily',
    title: 'Rapport du jour',
    subtitle: 'Aujourd’hui',
    icon: Icons.today_outlined,
  ),
  weeklyCurrent(
    kind: 'weekly_current',
    title: 'Rapport hebdo semaine en cours',
    subtitle: 'Du lundi à aujourd’hui',
    icon: Icons.date_range_outlined,
  ),
  weeklyPrevious(
    kind: 'weekly',
    title: 'Rapport hebdo de la semaine précédente',
    subtitle: 'Semaine calendaire précédente',
    icon: Icons.history_outlined,
  ),
  monthlyPrevious(
    kind: 'monthly',
    title: 'Rapport mensuel du mois précédent',
    subtitle: 'Mois calendaire précédent',
    icon: Icons.calendar_month_outlined,
  );

  const _ReportShareOption({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String kind;
  final String title;
  final String subtitle;
  final IconData icon;

  ReportDateRange resolveRange(DateTime now) {
    final today = ReportDateRange.today(now);
    return switch (this) {
      _ReportShareOption.daily => today,
      _ReportShareOption.weeklyCurrent => ReportDateRange(
        start: today.start.subtract(Duration(days: today.start.weekday - 1)),
        end: today.end,
        preset: ReportPeriodPreset.custom,
      ),
      _ReportShareOption.weeklyPrevious => ReportDateRange(
        start: today.start.subtract(
          Duration(days: today.start.weekday - 1 + 7),
        ),
        end: today.start.subtract(Duration(days: today.start.weekday - 1)),
        preset: ReportPeriodPreset.custom,
      ),
      _ReportShareOption.monthlyPrevious => _previousMonth(today.start),
    };
  }

  static ReportDateRange _previousMonth(DateTime todayStart) {
    final currentMonthStart = DateTime(todayStart.year, todayStart.month);
    final previousMonthStart = DateTime(
      currentMonthStart.year,
      currentMonthStart.month - 1,
    );
    return ReportDateRange(
      start: previousMonthStart,
      end: currentMonthStart,
      preset: ReportPeriodPreset.custom,
    );
  }
}
