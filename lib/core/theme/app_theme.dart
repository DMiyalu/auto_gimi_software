import 'package:flutter/material.dart';

import 'app_spacing.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFF1565C0);

  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadius.chip)),
  );

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.chip)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        selectedColor: ColorScheme.fromSeed(seedColor: _seed).primary,
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(shape: WidgetStatePropertyAll(_buttonShape)),
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(shape: WidgetStatePropertyAll(_buttonShape)),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(shape: WidgetStatePropertyAll(_buttonShape)),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(shape: WidgetStatePropertyAll(_buttonShape)),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.chip)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        selectedColor: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ).primary,
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(shape: WidgetStatePropertyAll(_buttonShape)),
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(shape: WidgetStatePropertyAll(_buttonShape)),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(shape: WidgetStatePropertyAll(_buttonShape)),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(shape: WidgetStatePropertyAll(_buttonShape)),
      ),
    );
  }
}
