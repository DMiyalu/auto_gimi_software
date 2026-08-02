import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Ossature visuelle commune à toutes les cartes de liste "domaine"
/// (activité, clients, produits...) : liseré coloré à gauche, coins
/// arrondis, ombre douce. Un seul look pour toute l'app — chaque écran ne
/// fournit que son contenu et sa couleur d'accent.
class DomainCard extends StatelessWidget {
  const DomainCard({
    super.key,
    required this.accentColor,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  final Color accentColor;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: AppRadius.cardRadius,
      child: InkWell(
        borderRadius: AppRadius.cardRadius,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardRadius,
            border: Border(left: BorderSide(color: accentColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: child,
        ),
      ),
    );
  }
}
