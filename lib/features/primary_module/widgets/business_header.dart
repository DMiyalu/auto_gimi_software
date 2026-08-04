import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/business_category.dart';
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
    final isRestaurant = config.category == BusinessCategory.restaurant;
    final hasSystemTopInset = MediaQuery.paddingOf(context).top > 0;

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
      padding: EdgeInsets.fromLTRB(
        isRestaurant ? 18 : AppSpacing.xs,
        isRestaurant ? (hasSystemTopInset ? 22 : 8) : AppSpacing.xs,
        isRestaurant ? 18 : AppSpacing.sm,
        isRestaurant ? 16 : AppSpacing.xs,
      ),
      child: Row(
        children: [
          _HeaderCircleButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            size: isRestaurant ? 56 : 48,
            backgroundColor: isRestaurant
                ? const Color(0xFFF4F5F9)
                : Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.menu_rounded,
                  size: isRestaurant ? 34 : 24,
                  color: const Color(0xFF101529),
                ),
                if (isRestaurant)
                  const Positioned(
                    right: -2,
                    top: -2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF7D56FF),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 9, height: 9),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: isRestaurant ? 18 : AppSpacing.xs),
          CircleAvatar(
            radius: isRestaurant ? 32 : 22,
            backgroundColor: isRestaurant
                ? const Color(0xFF0E6141)
                : config.primaryColor.withValues(alpha: 0.12),
            child: Icon(
              isRestaurant ? Icons.room_service_outlined : config.activityIcon,
              color: isRestaurant
                  ? const Color(0xFFE5A445)
                  : config.primaryColor,
              size: isRestaurant ? 34 : 24,
            ),
          ),
          SizedBox(width: isRestaurant ? 14 : AppSpacing.xs),
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
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: isRestaurant ? 23 : null,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF101529),
                                  height: 1.05,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: Color(0xFF101529),
                        ),
                      ],
                    ),
                    if (establishment != null)
                      Text(
                        establishment.category.label(l10n),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: isRestaurant ? 16 : null,
                          color: const Color(0xFF7B819B),
                        ),
                      ),
                    if (role != null && !isRestaurant)
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
          SizedBox(width: isRestaurant ? 14 : AppSpacing.xs),
          GestureDetector(
            onTap: () => context.go(Routes.settings),
            child: CircleAvatar(
              radius: isRestaurant ? 28 : 20,
              backgroundColor: const Color(0xFFEFF1F5),
              child: Text(
                initials,
                style: TextStyle(
                  color: isRestaurant ? const Color(0xFF101529) : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 34,
            color: Color(0xFF101529),
          ),
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
          top: 4,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            child: const Text(
              '3',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.child,
    required this.onPressed,
    required this.size,
    required this.backgroundColor,
  });

  final Widget child;
  final VoidCallback onPressed;
  final double size;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}
