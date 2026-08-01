import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_spacing.dart';
import '../config/business_module_config.dart';
import '../controllers/primary_module_providers.dart';

/// Bouton flottant unique dont les actions proviennent entièrement de la
/// configuration métier active.
class ModuleFab extends ConsumerWidget {
  const ModuleFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(primaryModuleConfigProvider);

    return FloatingActionButton(
      backgroundColor: config.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      onPressed: () => _openActionsSheet(context, config),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _openActionsSheet(BuildContext context, BusinessModuleConfig config) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final action in config.fabActions)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: config.primaryColor.withValues(alpha: 0.12),
                      child: Icon(action.icon, color: config.primaryColor),
                    ),
                    title: Text(action.label),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      if (action.route != null) {
                        context.push(action.route!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.comingSoon)),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
