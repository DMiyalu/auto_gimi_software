import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/primary_module_providers.dart';
import '../models/activity_item.dart';

/// Ouvre le menu d'actions d'une carte (appui long) — épingler, changer le
/// statut, imprimer la facture, annuler. Même mécanique que le BottomSheet
/// du bouton flottant : une feuille d'actions plutôt qu'un mode sélection
/// multiple façon WhatsApp, pour rester cohérent avec le reste de l'app.
void showActivityCardActions(
  BuildContext context,
  WidgetRef ref,
  ActivityItem item,
) {
  final l10n = AppLocalizations.of(context);

  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.title,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                item.pinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              title: Text(item.pinned ? 'Désépingler' : 'Épingler en haut'),
              onTap: () {
                ref.read(activityListProvider.notifier).togglePin(item.id);
                Navigator.of(sheetContext).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Changer le statut'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showStatusPicker(context, ref, item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: const Text('Imprimer la facture'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                printInvoiceFeedback(context, item);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.cancel_outlined,
                color: Theme.of(sheetContext).colorScheme.error,
              ),
              title: Text(
                l10n.cancel,
                style: TextStyle(color: Theme.of(sheetContext).colorScheme.error),
              ),
              onTap: () {
                ref.read(activityListProvider.notifier).cancel(item.id);
                Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showStatusPicker(BuildContext context, WidgetRef ref, ActivityItem item) {
  final config = ref.read(primaryModuleConfigProvider);
  final statuses = config.statusFilters.where((s) => s.key != 'all').toList();

  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Changer le statut',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
            ),
            for (final status in statuses)
              ListTile(
                leading: Icon(
                  status.key == item.statusKey
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(status.label),
                onTap: () {
                  ref
                      .read(activityListProvider.notifier)
                      .setStatus(item.id, status.key, status.label);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      );
    },
  );
}

void printInvoiceFeedback(BuildContext context, ActivityItem item) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Impression de la facture — ${item.title}')),
  );
}
