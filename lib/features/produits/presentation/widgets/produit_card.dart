import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/produit_entity.dart';
import '../providers/produit_providers.dart';

/// Carte produit — maquette Zuri : vignette, nom, catégorie, prix rouge, stock.
class ProduitCard extends ConsumerWidget {
  const ProduitCard({super.key, required this.produit, required this.canManage});

  final ProduitEntity produit;
  final bool canManage;

  IconData get _icon {
    final category = produit.categoryName?.toLowerCase() ?? '';
    if (category.contains('boisson')) return Icons.local_cafe_outlined;
    if (category.contains('dessert')) return Icons.cake_outlined;
    if (category.contains('plat')) return Icons.ramen_dining_outlined;
    if (category.contains('accompagn')) return Icons.fastfood_outlined;
    if (category.contains('ingr')) return Icons.kitchen_outlined;
    return Icons.inventory_2_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final priceLabel = CurrencyFormatter.formatWithCode(
      produit.price,
      currency: produit.currency,
    );

    return Material(
      color: AppColors.zuriWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: canManage
            ? () => context.push(Routes.produitEditPath(produit.id))
            : null,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.zuriWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEFF5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.zuriNavy.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.zuriPink.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_icon, color: AppColors.zuriRed, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.zuriNavy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      if (produit.categoryName != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          produit.categoryName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8A90A5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              priceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.zuriRed,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (produit.stockTrackingEnabled) ...[
                            const SizedBox(width: 8),
                            _StockBadge(produit: produit, l10n: l10n),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (canManage)
                  PopupMenuButton<_ProduitMenuAction>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Color(0xFF8A90A5),
                    ),
                    onSelected: (action) async {
                      switch (action) {
                        case _ProduitMenuAction.edit:
                          context.push(Routes.produitEditPath(produit.id));
                        case _ProduitMenuAction.delete:
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(l10n.deleteProduct),
                              content: Text(l10n.deleteProductConfirm),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: Text(l10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: Text(l10n.deleteProduct),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await ref
                                .read(produitControllerProvider.notifier)
                                .deleteProduit(id: produit.id);
                          }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _ProduitMenuAction.edit,
                        child: Text(l10n.editProduct),
                      ),
                      PopupMenuItem(
                        value: _ProduitMenuAction.delete,
                        child: Text(l10n.deleteProduct),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ProduitMenuAction { edit, delete }

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.produit, required this.l10n});

  final ProduitEntity produit;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (produit.stockStatus) {
      ProductStockStatus.outOfStock => (
        l10n.productOutOfStockLabel,
        AppColors.zuriRed,
        AppColors.zuriRed.withValues(alpha: 0.10),
      ),
      ProductStockStatus.low => (
        l10n.productStockLowShort,
        const Color(0xFFB76E00),
        const Color(0xFFFFF4E5),
      ),
      ProductStockStatus.inStock => (
        l10n.productInStockShort,
        const Color(0xFF15803D),
        const Color(0xFFDCFCE7),
      ),
      ProductStockStatus.notTracked => (null, null, null),
    };

    if (label == null || fg == null || bg == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
