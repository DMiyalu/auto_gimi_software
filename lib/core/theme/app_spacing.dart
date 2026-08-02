import 'package:flutter/material.dart';

/// Échelle d'espacement et de rayons homogène pour toute l'app.
abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
}

abstract final class AppRadius {
  /// Rayon unique des boutons de l'app, aligné sur le floating action
  /// button de l'écran d'accueil : toute forme de bouton doit s'y référer.
  static const double button = 16;
  static const double card = 8;
  static const double chip = 100;
  static const double sheet = 24;

  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(button));
  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}
