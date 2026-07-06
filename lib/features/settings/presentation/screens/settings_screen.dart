import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

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
            title: const Text('System default'),
            value: null,
            groupValue: locale,
            onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v),
          ),
        ],
      ),
    );
  }

  String _languageLabel(AppLocalizations l10n, Locale? locale) {
    if (locale == null) return 'System default';
    return locale.languageCode == 'fr' ? l10n.french : l10n.english;
  }
}
