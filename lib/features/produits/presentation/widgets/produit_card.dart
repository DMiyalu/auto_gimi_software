import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/domain_card.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/domain_accent_colors.dart';
import '../../domain/entities/produit_entity.dart';

/// Carte produit de la liste — même ossature que les cartes clients/activité
/// (liseré coloré, coins arrondis, ombre douce), avec un contenu propre aux
/// produits (catégorie, prix, statut de stock).
class ProduitCard extends StatelessWidget {
  const ProduitCard({super.key, required this.produit, required this.canManage});

  final ProduitEntity produit;
  final bool canManage;

  Color get _accent => DomainAccentColors.forId(produit.categoryId ?? produit.id);

  IconData get _icon {
    final category = produit.categoryName?.toLowerCase() ?? '';
    if (category.contains('boisson')) return Icons.local_bar_outlined;
    if (category.contains('dessert')) return Icons.icecream_outlined;
    if (category.contains('plat')) return Icons.restaurant_menu_outlined;
    if (category.contains('ingr')) return Icons.kitchen_outlined;
    return Icons.inventory_2_outlined;
  }

  String _updateHint() {
    final isNew = produit.createdAt.isAtSameMomentAs(produit.updatedAt);
    final days = DateTime.now().difference(produit.updatedAt).inDays;
    final String when;
    if (days <= 0) {
      when = "aujourd'hui";
    } else if (days == 1) {
      when = 'hier';
    } else {
      when = 'il y a ${days}j';
    }
    return isNew ? 'Ajouté $when' : 'Modifié $when';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = _accent;

    return DomainCard(
      accentColor: accent,
      onTap: canManage
          ? () => context.push(Routes.produitEditPath(produit.id))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ProduitAvatar(icon: _icon, color: accent),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        produit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (produit.categoryName != null) ...[
                      const SizedBox(width: 6),
                      _CategoryTag(label: produit.categoryName!, color: accent),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.formatWithCode(
                        produit.price,
                        currency: produit.currency,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (produit.stockTrackingEnabled) ...[
                      const SizedBox(width: 8),
                      _StockStatusLabel(produit: produit, l10n: l10n),
                    ],
                    const Spacer(),
                    Text(
                      _updateHint(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _ProduitAvatar extends StatelessWidget {
  const _ProduitAvatar({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: color.withValues(alpha: 0.12),
      child: Icon(icon, color: color),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StockStatusLabel extends StatelessWidget {
  const _StockStatusLabel({required this.produit, required this.l10n});

  final ProduitEntity produit;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (produit.stockStatus) {
      ProductStockStatus.outOfStock => (
        l10n.productOutOfStockLabel,
        const Color(0xFFEF2E2E),
      ),
      ProductStockStatus.low => (
        l10n.productStockLowLabel(produit.stock),
        Colors.orange.shade800,
      ),
      ProductStockStatus.inStock => (
        l10n.productInStockLabel(produit.stock),
        AppColors.bleuRoyal,
      ),
      ProductStockStatus.notTracked => (null, null),
    };

    if (label == null || color == null) return const SizedBox.shrink();

    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w700),
    );
  }
}
