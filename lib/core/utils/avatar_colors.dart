import 'package:flutter/material.dart';

/// Couleurs de secours pour les avatars à initiales (pas de photo client).
abstract final class AvatarColors {
  static const _palette = [
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFF5C6BC0),
    Color(0xFF29B6F6),
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFF8D6E63),
    Color(0xFFEC407A),
    Color(0xFF7E57C2),
  ];

  /// Couleur stable pour un identifiant donné : le même client garde
  /// toujours la même couleur, contrairement à un vrai tirage aléatoire qui
  /// changerait à chaque reconstruction du widget.
  static Color forId(String id) => _palette[id.hashCode.abs() % _palette.length];
}
