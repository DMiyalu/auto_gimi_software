import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Couleurs d'accent stables pour les cartes "domaine" (produits,
/// catégories...) qui doivent rester dans la palette Zuri Business — contrairement à
/// [AvatarColors], jamais de vert/rouge/orange arbitraires.
abstract final class DomainAccentColors {
  static const _palette = [
    AppColors.violetPrincipal,
    AppColors.bleuRoyal,
    AppColors.cyan,
    AppColors.violetClair,
    AppColors.bleuSaas,
    AppColors.cyanClair,
  ];

  /// Couleur stable pour un identifiant donné : la même catégorie/le même
  /// produit garde toujours la même couleur.
  static Color forId(String id) =>
      _palette[id.hashCode.abs() % _palette.length];
}
