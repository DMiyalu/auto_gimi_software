import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_error_mapper.dart';
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
    final usesRestaurantWorkflow = config.category.usesRestaurantWorkflow;
    final hasSystemTopInset = MediaQuery.paddingOf(context).top > 0;

    ref.listen(establishmentControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    final name = establishment?.name ?? '…';
    final userName = profile?.fullName.trim() ?? '';
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        usesRestaurantWorkflow ? 18 : AppSpacing.sm,
        usesRestaurantWorkflow ? (hasSystemTopInset ? 22 : 8) : AppSpacing.xs,
        usesRestaurantWorkflow ? 18 : AppSpacing.sm,
        usesRestaurantWorkflow ? 16 : AppSpacing.xs,
      ),
      child: Row(
        children: [
          if (usesRestaurantWorkflow)
            _EstablishmentBrandLogo(establishment: establishment, size: 48)
          else
            CircleAvatar(
              radius: 22,
              backgroundColor: config.primaryColor.withValues(alpha: 0.12),
              child: Icon(
                config.activityIcon,
                color: config.primaryColor,
                size: 24,
              ),
            ),
          SizedBox(width: usesRestaurantWorkflow ? 14 : AppSpacing.xs),
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
                          fontSize: usesRestaurantWorkflow ? 20 : null,
                          fontWeight: FontWeight.w800,
                          color: usesRestaurantWorkflow
                              ? AppColors.zuriNavy
                              : const Color(0xFF101529),
                          height: 1.05,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: usesRestaurantWorkflow
                          ? AppColors.zuriNavy
                          : const Color(0xFF101529),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            key: const Key('user_profile_avatar'),
            onTap: () => _showUserProfileSheet(
              context,
              ref,
              profile: profile,
              establishment: establishment,
              role: role,
            ),
            child: CircleAvatar(
              radius: usesRestaurantWorkflow ? 24 : 20,
              backgroundColor: const Color(0xFFEFF1F5),
              child: Text(
                initials,
                style: TextStyle(
                  color: usesRestaurantWorkflow ? AppColors.zuriNavy : null,
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

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      isScrollControlled: true,
      builder: (sheetContext) => _EstablishmentsSheet(
        items: items,
        activeId: activeId,
        memberships: memberships,
        profile: profile,
        isLoading: controllerState.isLoading,
        roleFor: _roleFor,
        onSelected: (item) {
          Navigator.of(sheetContext).pop();
          ref
              .read(establishmentControllerProvider.notifier)
              .switchEstablishment(item.id);
        },
        onCreate: () {
          Navigator.of(sheetContext).pop();
          context.push(Routes.establishmentNew);
        },
        l10n: l10n,
      ),
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

class _EstablishmentsSheet extends StatelessWidget {
  const _EstablishmentsSheet({
    required this.items,
    required this.activeId,
    required this.memberships,
    required this.profile,
    required this.isLoading,
    required this.roleFor,
    required this.onSelected,
    required this.onCreate,
    required this.l10n,
  });

  final List<Establishment> items;
  final String? activeId;
  final List<EstablishmentMember> memberships;
  final UserProfile? profile;
  final bool isLoading;
  final EstablishmentRole Function(
    String establishmentId,
    List<EstablishmentMember> memberships,
    UserProfile? profile,
  )
  roleFor;
  final ValueChanged<Establishment> onSelected;
  final VoidCallback onCreate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 22),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E8EF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.violetPrincipal.withValues(
                            alpha: 0.10,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_business_outlined,
                          color: AppColors.violetPrincipal,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Établissements',
                              style: TextStyle(
                                color: Color(0xFF101529),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Choisissez la session de travail.',
                              style: TextStyle(
                                color: Color(0xFF707792),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 320),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6E8EF)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _EstablishmentOptionTile(
                            establishment: item,
                            selected: item.id == activeId,
                            subtitle:
                                '${item.category.label(l10n)} • '
                                '${roleFor(item.id, memberships, profile).label}',
                            index: index,
                            enabled: !isLoading,
                            onTap: () => onSelected(item),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onCreate,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Créer un établissement'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EstablishmentOptionTile extends StatelessWidget {
  const _EstablishmentOptionTile({
    required this.establishment,
    required this.selected,
    required this.subtitle,
    required this.index,
    required this.enabled,
    required this.onTap,
  });

  final Establishment establishment;
  final bool selected;
  final String subtitle;
  final int index;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 180 + (index.clamp(0, 5) * 34)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: Material(
        color: selected ? AppColors.violetPrincipal : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: selected || !enabled ? null : onTap,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    establishment.category.icon,
                    color: selected ? Colors.white : AppColors.violetPrincipal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          establishment.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF101529),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selected ? '$subtitle • En cours' : subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.78)
                                : const Color(0xFF707792),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo établissement s'il est renseigné, sinon logo Zuri Business par défaut.
class _EstablishmentBrandLogo extends StatelessWidget {
  const _EstablishmentBrandLogo({
    required this.establishment,
    required this.size,
  });

  final Establishment? establishment;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bytes = establishment?.logoBytes;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: size,
        height: size,
        child: bytes != null
            ? Image.memory(
                bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _defaultLogo(size),
              )
            : _defaultLogo(size),
      ),
    );
  }

  static Widget _defaultLogo(double size) {
    return Image.asset(
      'public/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
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
  late final TextEditingController _emailController;
  var _editingName = false;
  var _editingEmail = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile?.fullName ?? '',
    );
    _emailController = TextEditingController(text: widget.profile?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
      setState(() => _editingName = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nom mis à jour.')));
    }
  }

  Future<void> _saveEmail() async {
    final email = _emailController.text.trim();
    if (!UserProfile.isValidReportEmail(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Adresse e-mail invalide.')));
      return;
    }

    await ref
        .read(establishmentControllerProvider.notifier)
        .updateUserEmail(email);
    if (!mounted) return;
    final state = ref.read(establishmentControllerProvider);
    if (!state.hasError) {
      setState(() => _editingEmail = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('E-mail mis à jour.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        ref.watch(userProfileProvider).valueOrNull ?? widget.profile;
    final establishment =
        ref.watch(currentEstablishmentProvider).valueOrNull ??
        widget.establishment;
    final role = ref.watch(activeEstablishmentRoleProvider) ?? widget.role;
    final loading = ref.watch(establishmentControllerProvider).isLoading;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final hasReportEmail = profile?.hasReportEmail ?? false;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (!hasReportEmail) ...[
              const SizedBox(height: 12),
              Material(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.mark_email_unread_outlined,
                        color: Color(0xFFB76E00),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ajoutez votre e-mail pour recevoir le reporting '
                          'hebdomadaire et mensuel de vos activités.',
                          style: TextStyle(
                            color: Color(0xFF7A4E00),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_editingName) ...[
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
                              setState(() => _editingName = false);
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
                  onPressed: () => setState(() => _editingName = true),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (_editingEmail) ...[
              TextField(
                controller: _emailController,
                enabled: !loading,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  helperText:
                      'Utilisé pour le reporting hebdomadaire et mensuel '
                      'de vos activités.',
                  helperMaxLines: 3,
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
                              _emailController.text = profile?.email ?? '';
                              setState(() => _editingEmail = false);
                            },
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: loading ? null : _saveEmail,
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
                leading: Icon(
                  hasReportEmail
                      ? Icons.email_outlined
                      : Icons.mark_email_unread_outlined,
                  color: hasReportEmail ? null : const Color(0xFFB76E00),
                ),
                title: Text(
                  hasReportEmail ? profile!.email!.trim() : 'E-mail manquant',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: hasReportEmail ? null : const Color(0xFFB76E00),
                  ),
                ),
                subtitle: const Text(
                  'Utilisé pour le reporting hebdomadaire et mensuel '
                  'de vos activités.',
                ),
                trailing: IconButton(
                  tooltip: 'Modifier l’e-mail',
                  onPressed: () {
                    _emailController.text = profile?.email ?? '';
                    setState(() => _editingEmail = true);
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            ],
            const Divider(height: 28),
            Text(
              'Établissement en cours',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: const Color(0xFF7B819B)),
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
      ),
    );
  }
}
