import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../shell/presentation/widgets/primary_scaffold.dart';
import '../theme/report_colors.dart';
import '../widgets/product_sales_breakdown_card.dart';
import '../widgets/report_date_range_selector.dart';
import '../widgets/restaurant_report_kpi_grid.dart';
import '../widgets/revenue_evolution_chart.dart';

/// Écran Rapports — établissement Restaurant (maquette).
class RestaurantReportsScreen extends ConsumerWidget {
  const RestaurantReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSystemTopInset = MediaQuery.paddingOf(context).top > 0;

    return PrimaryScaffold(
      header: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          hasSystemTopInset ? 22 : 8,
          18,
          8,
        ),
        child: const Text(
          'Rapports',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: ReportColors.textPrimary,
            height: 1.15,
          ),
        ),
      ),
      body: ColoredBox(
        color: ReportColors.pageBackground,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            120,
          ),
          children: const [
            ReportDateRangeSelector(),
            SizedBox(height: AppSpacing.sm),
            RestaurantReportKpiGrid(),
            SizedBox(height: AppSpacing.sm),
            RevenueEvolutionChart(),
            SizedBox(height: AppSpacing.sm),
            ProductSalesBreakdownCard(),
          ],
        ),
      ),
    );
  }
}
