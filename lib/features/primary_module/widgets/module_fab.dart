import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/business_category.dart';
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
    final isRestaurant = config.category == BusinessCategory.restaurant;

    return SizedBox(
      width: isRestaurant ? 74 : null,
      height: isRestaurant ? 74 : null,
      child: FloatingActionButton(
        backgroundColor: resolvedColor,
        elevation: isRestaurant ? 12 : null,
        highlightElevation: isRestaurant ? 14 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            isRestaurant ? AppRadius.chip : AppRadius.button,
          ),
        ),
        mini: false,
        onPressed: () =>
            _openActionsSheet(context, resolvedActions, resolvedColor),
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: isRestaurant ? 42 : 28,
        ),
      ),
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
