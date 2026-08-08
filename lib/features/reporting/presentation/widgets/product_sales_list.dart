import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/product_sales_item.dart';
import '../theme/report_colors.dart';

/// Liste rangée des ventes produits (top N ou complète).
class ProductSalesList extends StatelessWidget {
  const ProductSalesList({super.key, required this.items});

  final List<ProductSalesItem> items;

  static final _qtyFormat = NumberFormat('#,##0', 'fr');
  static final _percentFormat = NumberFormat('#0', 'fr');

  @override
  Widget build(BuildContext context) {
    final maxQty = items.fold<int>(
      0,
      (max, item) => item.quantity > max ? item.quantity : max,
    );

    return Column(
      children: [
        for (final item in items) ...[
          _ProductSalesRow(item: item, maxQuantity: maxQty),
          if (item != items.last) const SizedBox(height: 14),
        ],
      ],
    );
  }

  static String formatQuantity(int qty) => _qtyFormat.format(qty);

  static String formatPercent(double percent) =>
      '${_percentFormat.format(percent.round())}%';
}

class _ProductSalesRow extends StatelessWidget {
  const _ProductSalesRow({
    required this.item,
    required this.maxQuantity,
  });

  final ProductSalesItem item;
  final int maxQuantity;

  @override
  Widget build(BuildContext context) {
    final fraction = maxQuantity == 0 ? 0.0 : item.quantity / maxQuantity;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ReportColors.accentSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.restaurant_menu_rounded,
            size: 18,
            color: ReportColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${item.rank}. ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ReportColors.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ReportColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF0F1F5),
                  color: ReportColors.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              ProductSalesList.formatQuantity(item.quantity),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: ReportColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              ProductSalesList.formatPercent(item.percentage),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ReportColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
