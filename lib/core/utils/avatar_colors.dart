import 'package:flutter/material.dart';

/// Couleurs de secours pour les avatars à initiales (pas de photo client).
/// Teintes foncées : utilisées comme couleur de texte sur un fond de la même
/// teinte en opacité (même principe que les icônes de statut).
abstract final class AvatarColors {
  static final _palette = [
    Colors.red.shade700,
    Colors.purple.shade700,
    Colors.indigo.shade700,
    Colors.lightBlue.shade700,
    Colors.teal.shade700,
    Colors.green.shade700,
    Colors.orange.shade900,
    Colors.brown.shade700,
    Colors.pink.shade700,
    Colors.deepPurple.shade700,
  ];

  /// Couleur stable pour un identifiant donné : le même client garde
  /// toujours la même couleur, contrairement à un vrai tirage aléatoire qui
  /// changerait à chaque reconstruction du widget.
  static Color forId(String id) => _palette[id.hashCode.abs() % _palette.length];
}
