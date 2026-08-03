import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Ligne de titre affichée juste au-dessus de la liste, sur tous les écrans
/// "domaine" (clients, produits, services...) : "Liste des X" à gauche, le
/// compte (déjà formaté/pluralisé par l'appelant) à droite.
class ModuleListHeader extends StatelessWidget {
  const ModuleListHeader({
    super.key,
    required this.title,
    required this.countLabel,
  });

  final String title;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            countLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
