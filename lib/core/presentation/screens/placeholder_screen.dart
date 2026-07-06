import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Écran placeholder en attendant l'implémentation d'une feature.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.icon = Icons.construction,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(l10n.comingSoon, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
