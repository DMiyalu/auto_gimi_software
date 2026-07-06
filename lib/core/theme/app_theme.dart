import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const seed = Color(0xFF1565C0);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
