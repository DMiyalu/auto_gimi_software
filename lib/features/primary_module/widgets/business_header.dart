import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../establishment/domain/models/establishment.dart';
import '../../establishment/domain/models/establishment_member.dart';
import '../../establishment/domain/models/establishment_role.dart';
import '../../establishment/domain/models/user_profile.dart';
import '../../establishment/presentation/providers/establishment_providers.dart';
import '../controllers/primary_module_providers.dart';

/// En-tête réutilisable pour tous les métiers : menu hamburger (ouvre le
/// Drawer de navigation globale), identité de l'établissement, sélecteur
/// d'établissement, notifications et avatar
/// utilisateur. Doit être monté à l'intérieur d'un [Scaffold] qui définit
/// `drawer:` (ex. [PrimaryScaffold]).
class BusinessHeader extends ConsumerWidget {
  const BusinessHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
    final config = ref.watch(primaryModuleConfigProvider);
    final l10n = AppLocalizations.of(context);
    final role = ref.watch(activeEstablishmentRoleProvider);
    final establishments = ref.watch(userEstablishmentsProvider).valueOrNull;
    final memberships =
        ref.watch(userMembershipsProvider).valueOrNull ?? const [];
    final profile = ref.watch(userProfileProvider).valueOrNull;

    ref.listen(establishmentControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${next.error}')));
      }
    });

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
              onTap: () => _showEstablishmentSwitcher(
                context,
                ref,
                establishment: establishment,
                establishments: establishments,
                memberships: memberships,
                profile: profile,
              ),
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
                    if (role != null)
                      Text(
                        role.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
    WidgetRef ref, {
    required Establishment? establishment,
    required List<Establishment>? establishments,
    required List<EstablishmentMember> memberships,
    required UserProfile? profile,
  }) {
    final l10n = AppLocalizations.of(context);
    final controllerState = ref.read(establishmentControllerProvider);
    final activeId = establishment?.id;
    final items =
        establishments == null ||
            establishments.isEmpty && establishment != null
        ? [?establishment]
        : establishments;

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
                for (final item in items)
                  ListTile(
                    leading: CircleAvatar(child: Icon(item.category.icon)),
                    title: Text(item.name),
                    subtitle: Text(
                      '${item.category.label(l10n)} • '
                      '${_roleFor(item.id, memberships, profile).label}',
                    ),
                    trailing: item.id == activeId
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(dialogContext).colorScheme.primary,
                          )
                        : null,
                    onTap: item.id == activeId || controllerState.isLoading
                        ? null
                        : () {
                            Navigator.of(dialogContext).pop();
                            ref
                                .read(establishmentControllerProvider.notifier)
                                .switchEstablishment(item.id);
                          },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add_business_outlined),
                  title: const Text('Ajouter un établissement'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    context.push(Routes.establishmentNew);
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

  EstablishmentRole _roleFor(
    String establishmentId,
    List<EstablishmentMember> memberships,
    UserProfile? profile,
  ) {
    for (final membership in memberships) {
      if (membership.establishmentId == establishmentId) {
        return membership.role;
      }
    }
    return EstablishmentRole.fromFirestore(profile?.roleFor(establishmentId));
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
