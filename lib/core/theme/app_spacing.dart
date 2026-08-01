import 'package:flutter/material.dart';

/// Échelle d'espacement et de rayons homogène pour toute l'app.
abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
}

abstract final class AppRadius {
  static const double card = 16;
  static const double chip = 100;
  static const double sheet = 24;

  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}
