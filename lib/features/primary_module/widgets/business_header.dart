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
