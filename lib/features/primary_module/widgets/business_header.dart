import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_error_mapper.dart';
import '../../../core/domain/business_category.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../establishment/domain/models/establishment.dart';
import '../../establishment/domain/models/establishment_member.dart';
import '../../establishment/domain/models/establishment_role.dart';
import '../../establishment/domain/models/user_profile.dart';
import '../../establishment/presentation/providers/establishment_providers.dart';
import '../controllers/primary_module_providers.dart';

/// En-tête commun : identité établissement (switcher) + avatar profil utilisateur.
class BusinessHeader extends ConsumerWidget {
  const BusinessHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
    final config = ref.watch(primaryModuleConfigProvider);
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
        ).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    final name = establishment?.name ?? '…';
    final userName = profile?.fullName.trim() ?? '';
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isRestaurant ? 18 : AppSpacing.sm,
        isRestaurant ? (hasSystemTopInset ? 22 : 8) : AppSpacing.xs,
        isRestaurant ? 18 : AppSpacing.sm,
        isRestaurant ? 16 : AppSpacing.xs,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isRestaurant ? 32 : 22,
            backgroundColor: isRestaurant
                ? AppColors.violetPrincipal
                : config.primaryColor.withValues(alpha: 0.12),
            child: Icon(
              isRestaurant ? Icons.room_service_outlined : config.activityIcon,
              color: isRestaurant ? AppColors.cyanClair : config.primaryColor,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showUserProfileSheet(
              context,
              ref,
              profile: profile,
              establishment: establishment,
              role: role,
            ),
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

  void _showUserProfileSheet(
    BuildContext context,
    WidgetRef ref, {
    required UserProfile? profile,
    required Establishment? establishment,
    required EstablishmentRole? role,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (sheetContext) {
        return _UserProfileSheet(
          profile: profile,
          establishment: establishment,
          role: role,
        );
      },
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
                      _roleFor(item.id, memberships, profile).label,
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

class _UserProfileSheet extends ConsumerStatefulWidget {
  const _UserProfileSheet({
    required this.profile,
    required this.establishment,
    required this.role,
  });

  final UserProfile? profile;
  final Establishment? establishment;
  final EstablishmentRole? role;

  @override
  ConsumerState<_UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends ConsumerState<_UserProfileSheet> {
  late final TextEditingController _nameController;
  var _editing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile?.fullName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await ref
        .read(establishmentControllerProvider.notifier)
        .updateUserFullName(name);
    if (!mounted) return;
    final state = ref.read(establishmentControllerProvider);
    if (!state.hasError) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nom mis à jour.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull ?? widget.profile;
    final establishment =
        ref.watch(currentEstablishmentProvider).valueOrNull ??
        widget.establishment;
    final role =
        ref.watch(activeEstablishmentRoleProvider) ?? widget.role;
    final loading = ref.watch(establishmentControllerProvider).isLoading;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD5D8E2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mon profil',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          if (_editing) ...[
            TextField(
              controller: _nameController,
              enabled: !loading,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom d’utilisateur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: loading
                        ? null
                        : () {
                            _nameController.text = profile?.fullName ?? '';
                            setState(() => _editing = false);
                          },
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: loading ? null : _saveName,
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ] else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text(
                  (profile?.fullName.trim().isNotEmpty ?? false)
                      ? profile!.fullName.trim()[0].toUpperCase()
                      : '?',
                ),
              ),
              title: Text(
                profile?.fullName.trim().isNotEmpty == true
                    ? profile!.fullName
                    : 'Utilisateur',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(profile?.phone ?? '—'),
              trailing: IconButton(
                tooltip: 'Modifier le nom',
                onPressed: () => setState(() => _editing = true),
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
          ],
          const Divider(height: 28),
          Text(
            'Établissement en cours',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF7B819B),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              child: Icon(Icons.storefront_outlined),
            ),
            title: Text(establishment?.name ?? '—'),
            subtitle: Text(
              role?.label ?? 'Rôle non défini',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
