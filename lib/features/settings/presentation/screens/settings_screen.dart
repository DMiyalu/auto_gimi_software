import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(_languageLabel(l10n, locale)),
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.french),
            value: const Locale('fr'),
            groupValue: locale,
            onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v),
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.english),
            value: const Locale('en'),
            groupValue: locale,
            onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v),
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.systemDefault),
            value: null,
            groupValue: locale,
            onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.theme),
            subtitle: Text(_themeLabel(l10n, themeMode)),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeLight),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (v) =>
                ref.read(themeModeProvider.notifier).setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeDark),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (v) =>
                ref.read(themeModeProvider.notifier).setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.systemDefault),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (v) =>
                ref.read(themeModeProvider.notifier).setThemeMode(v!),
          ),
        ],
      ),
    );
  }

  String _languageLabel(AppLocalizations l10n, Locale? locale) {
    if (locale == null) return l10n.systemDefault;
    return locale.languageCode == 'fr' ? l10n.french : l10n.english;
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.systemDefault,
    };
  }
}
