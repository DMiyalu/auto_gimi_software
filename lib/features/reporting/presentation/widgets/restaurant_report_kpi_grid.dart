import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/report_date_range.dart';
import '../../domain/entities/restaurant_report_kpis.dart';
import '../providers/restaurant_report_providers.dart';
import '../theme/report_colors.dart';

/// Grille 2×2 des KPIs restaurant (CA, commandes, panier, clients).
class RestaurantReportKpiGrid extends ConsumerWidget {
  const RestaurantReportKpiGrid({super.key});

  static final _amountFormat = NumberFormat('#,##0', 'fr');
  static final _percentFormat = NumberFormat('#0.0', 'fr');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(restaurantReportKpisProvider);
    final range = ref.watch(reportDateRangeProvider);
    final comparisonLabel = _comparisonLabel(range.preset);

    return kpisAsync.when(
      loading: () => const _KpiGridSkeleton(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          'Impossible de charger les indicateurs.',
          style: TextStyle(color: Colors.red.shade700),
        ),
      ),
      data: (kpis) => _KpiGrid(
        kpis: kpis,
        comparisonLabel: comparisonLabel,
      ),
    );
  }

  static String _comparisonLabel(ReportPeriodPreset preset) {
    return switch (preset) {
      ReportPeriodPreset.today => 'vs hier',
      ReportPeriodPreset.yesterday => 'vs avant-hier',
      ReportPeriodPreset.last7Days => 'vs 7 j. préc.',
      ReportPeriodPreset.last30Days => 'vs 30 j. préc.',
      ReportPeriodPreset.custom => 'vs période préc.',
    };
  }

  static String formatAmount(double amount) =>
      '${_amountFormat.format(amount)} CDF';

  static String formatPercent(double? change, String comparisonLabel) {
    if (change == null) return '— $comparisonLabel';
    final arrow = change >= 0 ? '↑' : '↓';
    final abs = change.abs();
    return '$arrow ${_percentFormat.format(abs)}% $comparisonLabel';
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.kpis,
    required this.comparisonLabel,
  });

  final RestaurantReportKpis kpis;
  final String comparisonLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.show_chart_rounded,
                iconColor: ReportColors.kpiRevenue,
                iconBackground: ReportColors.kpiRevenueSoft,
                value: RestaurantReportKpiGrid.formatAmount(kpis.revenue),
                label: "Chiffre d'affaires",
                trend: RestaurantReportKpiGrid.formatPercent(
                  kpis.revenueChangePercent,
                  comparisonLabel,
                ),
                trendUp: (kpis.revenueChangePercent ?? 0) >= 0,
                trendUndefined: kpis.revenueChangePercent == null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.shopping_bag_outlined,
                iconColor: ReportColors.kpiOrders,
                iconBackground: ReportColors.kpiOrdersSoft,
                value: '${kpis.ordersCount}',
                label: 'Commandes',
                trend: RestaurantReportKpiGrid.formatPercent(
                  kpis.ordersChangePercent,
                  comparisonLabel,
                ),
                trendUp: (kpis.ordersChangePercent ?? 0) >= 0,
                trendUndefined: kpis.ordersChangePercent == null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.shopping_basket_outlined,
                iconColor: ReportColors.kpiBasket,
                iconBackground: ReportColors.kpiBasketSoft,
                value: RestaurantReportKpiGrid.formatAmount(kpis.averageBasket),
                label: 'Panier moyen',
                trend: RestaurantReportKpiGrid.formatPercent(
                  kpis.averageBasketChangePercent,
                  comparisonLabel,
                ),
                trendUp: (kpis.averageBasketChangePercent ?? 0) >= 0,
                trendUndefined: kpis.averageBasketChangePercent == null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.people_alt_outlined,
                iconColor: ReportColors.kpiClients,
                iconBackground: ReportColors.kpiClientsSoft,
                value: '${kpis.clientsServed}',
                label: 'Clients servis',
                trend: RestaurantReportKpiGrid.formatPercent(
                  kpis.clientsServedChangePercent,
                  comparisonLabel,
                ),
                trendUp: (kpis.clientsServedChangePercent ?? 0) >= 0,
                trendUndefined: kpis.clientsServedChangePercent == null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendUp,
    required this.trendUndefined,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String value;
  final String label;
  final String trend;
  final bool trendUp;
  final bool trendUndefined;

  @override
  Widget build(BuildContext context) {
    final trendColor = trendUndefined
        ? ReportColors.textMuted
        : (trendUp ? ReportColors.trendUp : ReportColors.trendDown);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ReportColors.cardBackground,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ReportColors.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ReportColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trend,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiGridSkeleton extends StatelessWidget {
  const _KpiGridSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget box() => Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F7),
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: box()),
            const SizedBox(width: 12),
            Expanded(child: box()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: box()),
            const SizedBox(width: 12),
            Expanded(child: box()),
          ],
        ),
      ],
    );
  }
}
