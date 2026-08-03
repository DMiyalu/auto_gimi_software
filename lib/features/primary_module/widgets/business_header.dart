import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../establishment/domain/models/establishment.dart';
import '../../establishment/presentation/providers/establishment_providers.dart';
import '../controllers/primary_module_providers.dart';

/// En-tête réutilisable pour tous les métiers : menu hamburger (ouvre le
/// Drawer de navigation globale), identité de l'établissement, sélecteur
/// d'établissement (préparé, inerte pour l'instant), notifications et avatar
/// utilisateur. Doit être monté à l'intérieur d'un [Scaffold] qui définit
/// `drawer:` (ex. [PrimaryScaffold]).
class BusinessHeader extends ConsumerWidget {
  const BusinessHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
    final config = ref.watch(primaryModuleConfigProvider);
    final l10n = AppLocalizations.of(context);

    final name = establishment?.name ?? '…';
    final initials = (establishment?.managerName.isNotEmpty ?? false)
        ? establishment!.managerName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_outlined),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: config.primaryColor.withValues(alpha: 0.12),
            child: Icon(config.activityIcon, color: config.primaryColor),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.card),
              onTap: () =>
                  _showEstablishmentSwitcher(context, ref, establishment),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 20),
                      ],
                    ),
                    if (establishment != null)
                      Text(
                        establishment.category.label(l10n),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const _NotificationBell(),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: () => context.go(Routes.settings),
            child: CircleAvatar(radius: 20, child: Text(initials)),
          ),
        ],
      ),
    );
  }

  void _showEstablishmentSwitcher(
    BuildContext context,
    WidgetRef ref,
    Establishment? establishment,
  ) {
    final l10n = AppLocalizations.of(context);
    final establishments =
        ref.read(userEstablishmentsProvider).valueOrNull ?? const [];
    final activeId = establishment?.id;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Établissements'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in establishments)
                  ListTile(
                    leading: CircleAvatar(child: Icon(item.category.icon)),
                    title: Text(item.name),
                    subtitle: Text(item.category.label(l10n)),
                    trailing: item.id == activeId
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(dialogContext).colorScheme.primary,
                          )
                        : null,
                    onTap: item.id == activeId
                        ? null
                        : () {
                            Navigator.of(dialogContext).pop();
                            ref
                                .read(establishmentControllerProvider.notifier)
                                .switchEstablishment(item.id);
                          },
                  ),
                if (establishments.isEmpty && establishment != null)
                  ListTile(
                    leading: CircleAvatar(
                      child: Icon(establishment.category.icon),
                    ),
                    title: Text(establishment.name),
                    subtitle: Text(establishment.category.label(l10n)),
                    trailing: Icon(
                      Icons.check_circle,
                      color: Theme.of(dialogContext).colorScheme.primary,
                    ),
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add_business_outlined),
                  title: const Text('Ajouter un établissement'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    // Pas encore de flux multi-établissement côté backend
                    // (un compte = un établissement pour l'instant) — la
                    // vraie création sera branchée avec le reste de la
                    // logique métier au retour sur Firebase.
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications — bientôt disponible'),
              ),
            );
          },
        ),
        Positioned(
          right: 6,
          top: 6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: const Text(
              '3',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
