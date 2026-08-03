import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_spacing.dart';
import '../config/business_module_config.dart';
import '../controllers/primary_module_providers.dart';

/// Bouton flottant unique et réutilisable partout dans l'app : même
/// composant (forme, radius, feuille d'actions) pour tous les écrans, seules
/// les actions proposées changent. Sans override, les actions viennent de la
/// configuration métier active (écran principal) ; un écran commun comme
/// Clients peut fournir sa propre liste d'actions.
class ModuleFab extends ConsumerWidget {
  const ModuleFab({super.key, this.actions, this.color});

  final List<FabActionConfig>? actions;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(primaryModuleConfigProvider);
    final resolvedColor = color ?? config.primaryColor;
    final resolvedActions = actions ?? config.fabActions;

    return FloatingActionButton(
      backgroundColor: resolvedColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      onPressed: () =>
          _openActionsSheet(context, resolvedActions, resolvedColor),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _openActionsSheet(
    BuildContext context,
    List<FabActionConfig> actions,
    Color color,
  ) {
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
                for (final action in actions)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(action.icon, color: color),
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
