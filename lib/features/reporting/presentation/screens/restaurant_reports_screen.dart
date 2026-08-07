import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../shell/presentation/widgets/primary_scaffold.dart';
import '../theme/report_colors.dart';
import '../widgets/report_date_range_selector.dart';

/// Écran Rapports — établissement Restaurant (maquette).
class RestaurantReportsScreen extends ConsumerWidget {
  const RestaurantReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PrimaryScaffold(
      body: ColoredBox(
        color: ReportColors.pageBackground,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.lg,
          ),
          children: [
            const Text(
              'Rapports',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: ReportColors.textPrimary,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Aperçu de votre activité',
              style: TextStyle(
                fontSize: 14,
                color: ReportColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const ReportDateRangeSelector(),
            // Étapes suivantes : KPI grid, graphique CA, répartition ventes.
          ],
        ),
      ),
    );
  }
}
