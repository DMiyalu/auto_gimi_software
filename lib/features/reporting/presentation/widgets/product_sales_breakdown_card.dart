import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../produits/domain/entities/product_category_entity.dart';
import '../../../produits/presentation/providers/produit_providers.dart';
import '../providers/restaurant_report_providers.dart';
import '../theme/report_colors.dart';
import 'all_category_products_sheet.dart';
import 'product_sales_list.dart';

/// Carte « Répartition des ventes par catégorie » (top 5 + lien voir tous).
class ProductSalesBreakdownCard extends ConsumerWidget {
  const ProductSalesBreakdownCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(effectiveReportCategoryProvider);
    final salesAsync = ref.watch(topProductSalesProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: ReportColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Répartition des ventes par catégorie',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ReportColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Consommations par produit',
                      style: TextStyle(
                        fontSize: 13,
                        color: ReportColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CategoryPickerChip(
                category: categoryAsync.valueOrNull,
                enabled: categoryAsync.hasValue,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          salesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Impossible de charger les ventes.',
                style: TextStyle(color: ReportColors.textMuted),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(
                      'Aucune vente pour cette catégorie.',
                      style: TextStyle(color: ReportColors.textMuted),
                    ),
                  ),
                );
              }
              return ProductSalesList(items: items);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: () => showAllCategoryProductsSheet(context),
              style: TextButton.styleFrom(
                foregroundColor: ReportColors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Voir tous les produits de la catégorie',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPickerChip extends ConsumerWidget {
  const _CategoryPickerChip({
    required this.category,
    required this.enabled,
  });

  final ProductCategoryEntity? category;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: ReportColors.accentSoft,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? () => _openCategoryPicker(context, ref) : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.restaurant_rounded,
                size: 16,
                color: ReportColors.accent,
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 90),
                child: Text(
                  category?.name ?? 'Catégorie',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ReportColors.accent,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: ReportColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCategoryPicker(BuildContext context, WidgetRef ref) async {
    final categories =
        ref.read(productCategoriesProvider).valueOrNull ?? const [];
    if (categories.isEmpty) return;

    final selectedId = ref.read(selectedReportCategoryIdProvider) ??
        ref.read(effectiveReportCategoryProvider).valueOrNull?.id;

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
                  'Catégorie',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final cat in categories)
                ListTile(
                  leading: Icon(
                    selectedId == cat.id
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selectedId == cat.id
                        ? ReportColors.accent
                        : ReportColors.textMuted,
                  ),
                  title: Text(cat.name),
                  onTap: () {
                    ref.read(selectedReportCategoryIdProvider.notifier).state =
                        cat.id;
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        );
      },
    );
  }
}
