import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../providers/restaurant_report_providers.dart';
import '../theme/report_colors.dart';
import 'product_sales_list.dart';

/// Bottom sheet élargi listant tous les produits de la catégorie filtrée.
Future<void> showAllCategoryProductsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AllCategoryProductsSheet(),
  );
}

class _AllCategoryProductsSheet extends ConsumerWidget {
  const _AllCategoryProductsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(effectiveReportCategoryProvider);
    final salesAsync = ref.watch(allProductSalesProvider);
    final categoryName =
        categoryAsync.valueOrNull?.name ?? 'cette catégorie';
    final height = MediaQuery.sizeOf(context).height * 0.85;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: ReportColors.cardBackground,
        borderRadius: AppRadius.sheetRadius,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD5D8E2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produits — $categoryName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ReportColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Consommations sur la période sélectionnée',
                        style: TextStyle(
                          fontSize: 13,
                          color: ReportColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: salesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text(
                  'Impossible de charger les produits.',
                  style: TextStyle(color: ReportColors.textMuted),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun produit vendu dans cette catégorie.',
                      style: TextStyle(color: ReportColors.textMuted),
                    ),
                  );
                }
                final totalQty = items.fold<int>(
                  0,
                  (sum, item) => sum + item.quantity,
                );
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.lg,
                  ),
                  children: [
                    Text(
                      '${items.length} produit${items.length > 1 ? 's' : ''} · '
                      '${NumberFormat('#,##0', 'fr').format(totalQty)} vendus',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ReportColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ProductSalesList(items: items),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
