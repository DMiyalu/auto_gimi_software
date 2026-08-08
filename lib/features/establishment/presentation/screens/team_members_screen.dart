import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/business_category.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/establishment.dart';
import '../../domain/models/establishment_member.dart';
import '../../domain/models/establishment_role.dart';
import '../providers/establishment_providers.dart';
import '../widgets/member_management_permission_gate.dart';

class TeamMembersScreen extends ConsumerStatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  ConsumerState<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends ConsumerState<TeamMembersScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  EstablishmentRole? _roleFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MemberManagementPermissionGate(
      builder: (context) => _buildMembers(context),
    );
  }

  Widget _buildMembers(BuildContext context) {
    final membersAsync = ref.watch(establishmentMembersProvider);
    final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.zuriWhite,
      body: SafeArea(
        child: Column(
          children: [
            _TeamHeader(onInvite: () => context.push(Routes.invitationNew)),
            Expanded(
              child: membersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(error.toString())),
                data: (items) {
                  final filtered = _filterMembers(items);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                    children: [
                      if (establishment != null) ...[
                        _EstablishmentBanner(
                          establishment: establishment,
                          categoryLabel: establishment.category.label(l10n),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _SearchRow(
                        controller: _searchController,
                        roleFilterActive: _roleFilter != null,
                        onQueryChanged: (value) =>
                            setState(() => _query = value),
                        onFilterTap: () => _openRoleFilter(context),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Membres (${filtered.length})',
                        style: const TextStyle(
                          color: AppColors.zuriNavy,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (items.isEmpty)
                        const _EmptyMembers(
                          title: 'Aucun membre trouvé',
                          subtitle:
                              'Invitez des collaborateurs pour démarrer votre équipe.',
                        )
                      else if (filtered.isEmpty)
                        const _EmptyMembers(
                          title: 'Aucun résultat',
                          subtitle:
                              'Aucun membre ne correspond à votre recherche.',
                        )
                      else
                        for (var i = 0; i < filtered.length; i++) ...[
                          _MemberCard(
                            member: filtered[i],
                            onTap: () =>
                                _showMemberDetails(context, filtered[i]),
                          ),
                          if (i != filtered.length - 1)
                            const SizedBox(height: 10),
                        ],
                      const SizedBox(height: 20),
                      const _RolesInfoCard(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<EstablishmentMember> _filterMembers(List<EstablishmentMember> items) {
    final query = _query.trim().toLowerCase();
    return items.where((member) {
      if (_roleFilter != null && member.role != _roleFilter) return false;
      if (query.isEmpty) return true;
      final name = member.fullName.toLowerCase();
      final phone = member.phone.toLowerCase();
      return name.contains(query) || phone.contains(query);
    }).toList();
  }

  Future<void> _openRoleFilter(BuildContext context) async {
    final selected = await showModalBottomSheet<Object>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Filtrer par rôle',
                  style: TextStyle(
                    color: AppColors.zuriNavy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  _roleFilter == null
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _roleFilter == null
                      ? AppColors.zuriRed
                      : const Color(0xFF8A90A5),
                ),
                title: const Text('Tous les rôles'),
                onTap: () => Navigator.of(sheetContext).pop('all'),
              ),
              for (final role in EstablishmentRole.values)
                ListTile(
                  leading: Icon(
                    _roleFilter == role
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _roleFilter == role
                        ? AppColors.zuriRed
                        : const Color(0xFF8A90A5),
                  ),
                  title: Text(role.label),
                  onTap: () => Navigator.of(sheetContext).pop(role),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) return;
    setState(() {
      _roleFilter = selected == 'all' ? null : selected as EstablishmentRole;
    });
  }

  void _showMemberDetails(BuildContext context, EstablishmentMember member) {
    final name = member.fullName.trim().isEmpty
        ? 'Utilisateur'
        : member.fullName;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5D8E2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                _MemberAvatar(name: name, role: member.role, size: 56),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.zuriNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                _RoleBadge(role: member.role),
                const SizedBox(height: 12),
                if (member.phone.trim().isNotEmpty)
                  Text(
                    member.phone,
                    style: const TextStyle(
                      color: Color(0xFF8A90A5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (!member.phoneVerified) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Téléphone non vérifié',
                    style: TextStyle(
                      color: AppColors.zuriRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.onInvite});

  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.zuriNavy,
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Équipe',
                  style: TextStyle(
                    color: AppColors.zuriNavy,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Utilisateurs ayant accès à cet établissement.',
                  style: TextStyle(
                    color: Color(0xFF8A90A5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: FilledButton.icon(
              onPressed: onInvite,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Inviter'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.zuriRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstablishmentBanner extends StatelessWidget {
  const _EstablishmentBanner({
    required this.establishment,
    required this.categoryLabel,
  });

  final Establishment establishment;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _categoryAccent(establishment.category),
              shape: BoxShape.circle,
            ),
            child: Icon(
              establishment.category.icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  establishment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.zuriNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  categoryLabel,
                  style: const TextStyle(
                    color: Color(0xFF8A90A5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.roleFilterActive,
    required this.onQueryChanged,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final bool roleFilterActive;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onQueryChanged,
            style: const TextStyle(
              color: AppColors.zuriNavy,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Rechercher un membre...',
              hintStyle: const TextStyle(
                color: Color(0xFF8A90A5),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF8A90A5),
              ),
              filled: true,
              fillColor: AppColors.zuriWhite,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.zuriRed,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: roleFilterActive
              ? AppColors.zuriPink.withValues(alpha: 0.14)
              : const Color(0xFFF4F5F9),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                Icons.tune_rounded,
                color: roleFilterActive
                    ? AppColors.zuriRed
                    : AppColors.zuriNavy,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.onTap});

  final EstablishmentMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = member.fullName.trim().isEmpty
        ? 'Utilisateur'
        : member.fullName;

    return Material(
      color: AppColors.zuriWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EAF0)),
            boxShadow: [
              BoxShadow(
                color: AppColors.zuriNavy.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _MemberAvatar(name: name, role: member.role),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.zuriNavy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (member.phone.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        member.phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8A90A5),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (!member.phoneVerified) ...[
                      const SizedBox(height: 2),
                      const Text(
                        'Téléphone non vérifié',
                        style: TextStyle(
                          color: AppColors.zuriRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RoleBadge(role: member.role),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.zuriNavy,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.name,
    required this.role,
    this.size = 44,
  });

  final String name;
  final EstablishmentRole role;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final colors = _avatarColors(role);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.$1,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: colors.$2,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final EstablishmentRole role;

  @override
  Widget build(BuildContext context) {
    final colors = _roleColors(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.label,
        style: TextStyle(
          color: colors.$2,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RolesInfoCard extends StatelessWidget {
  const _RolesInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.zuriPink.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.zuriRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'À propos des rôles',
                  style: TextStyle(
                    color: AppColors.zuriNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Propriétaire > Gérant > Agent',
                  style: TextStyle(
                    color: Color(0xFF8A90A5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Le propriétaire a tous les droits sur l’établissement.',
                  style: TextStyle(
                    color: Color(0xFF8A90A5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.zuriWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.zuriPink.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: AppColors.zuriRed,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.zuriNavy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8A90A5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

(Color, Color) _roleColors(EstablishmentRole role) {
  return switch (role) {
    EstablishmentRole.owner => (
      const Color(0xFFFFE4EF),
      AppColors.zuriMagenta,
    ),
    EstablishmentRole.manager => (
      const Color(0xFFFFF3E0),
      const Color(0xFFEF6C00),
    ),
    EstablishmentRole.agent => (
      const Color(0xFFE8F5E9),
      const Color(0xFF2E7D32),
    ),
  };
}

(Color, Color) _avatarColors(EstablishmentRole role) {
  return switch (role) {
    EstablishmentRole.owner => (
      const Color(0xFFFFE4EF),
      AppColors.zuriMagenta,
    ),
    EstablishmentRole.manager => (
      const Color(0xFFFFE0B2),
      const Color(0xFFEF6C00),
    ),
    EstablishmentRole.agent => (
      const Color(0xFFC8E6C9),
      const Color(0xFF2E7D32),
    ),
  };
}

Color _categoryAccent(BusinessCategory category) {
  return switch (category) {
    BusinessCategory.restaurant => AppColors.zuriRed,
    BusinessCategory.garageAuto => const Color(0xFFF57C00),
    BusinessCategory.sanitation => const Color(0xFF2E7D32),
    BusinessCategory.pharmacy => const Color(0xFF7B1FA2),
    BusinessCategory.pressing => const Color(0xFF1565C0),
    BusinessCategory.gym => const Color(0xFF00897B),
  };
}
