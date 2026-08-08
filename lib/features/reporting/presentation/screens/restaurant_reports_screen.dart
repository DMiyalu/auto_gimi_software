import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../shell/presentation/widgets/primary_scaffold.dart';
import '../providers/restaurant_report_providers.dart';
import '../theme/report_colors.dart';
import '../widgets/product_sales_breakdown_card.dart';
import '../widgets/report_date_range_selector.dart';
import '../widgets/restaurant_report_kpi_grid.dart';
import '../widgets/revenue_evolution_chart.dart';

/// Écran Rapports — établissement Restaurant (maquette Zuri).
class RestaurantReportsScreen extends ConsumerWidget {
  const RestaurantReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final kind = await showModalBottomSheet<String>(
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
                  'Envoyer le rapport',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ReportColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Le rapport sera envoyé à l’e-mail du propriétaire.',
                  style: TextStyle(color: ReportColors.textMuted),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.today_outlined,
                    color: ReportColors.accent,
                  ),
                  title: const Text('Rapport du jour'),
                  subtitle: const Text('Aujourd’hui'),
                  onTap: () => Navigator.of(sheetContext).pop('daily'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.date_range_outlined,
                    color: ReportColors.accent,
                  ),
                  title: const Text('Rapport hebdo semaine en cours'),
                  subtitle: const Text('Du lundi à aujourd’hui'),
                  onTap: () =>
                      Navigator.of(sheetContext).pop('weekly_current'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.history_outlined,
                    color: ReportColors.accent,
                  ),
                  title: const Text(
                    'Rapport hebdo de la semaine précédente',
                  ),
                  subtitle: const Text('Semaine calendaire précédente'),
                  onTap: () => Navigator.of(sheetContext).pop('weekly'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_month_outlined,
                    color: ReportColors.accent,
                  ),
                  title: const Text(
                    'Rapport mensuel du mois précédent',
                  ),
                  subtitle: const Text('Mois calendaire précédent'),
                  onTap: () => Navigator.of(sheetContext).pop('monthly'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (kind == null || !context.mounted) return;
    await ref.read(sendRestaurantReportProvider.notifier).send(kind: kind);
  }
}
