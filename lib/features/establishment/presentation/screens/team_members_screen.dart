import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../domain/models/establishment_member.dart';
import '../providers/establishment_providers.dart';
import '../widgets/member_management_permission_gate.dart';

class TeamMembersScreen extends ConsumerWidget {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MemberManagementPermissionGate(
      builder: (context) => _buildMembers(context, ref),
    );
  }

  Widget _buildMembers(BuildContext context, WidgetRef ref) {
    final members = ref.watch(establishmentMembersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Équipe')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.invitationNew),
        icon: const Icon(Icons.person_add_alt_outlined),
        label: const Text('Inviter'),
      ),
      body: members.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Aucun membre trouvé'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _MemberTile(member: items[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final EstablishmentMember member;

  @override
  Widget build(BuildContext context) {
    final name = member.fullName.trim().isEmpty
        ? 'Utilisateur'
        : member.fullName;
    final subtitle = [
      member.phone,
      if (!member.phoneVerified) 'Téléphone non vérifié',
    ].where((value) => value.trim().isNotEmpty).join(' · ');

    return ListTile(
      leading: CircleAvatar(child: Text(name[0].toUpperCase())),
      title: Text(name),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: Chip(label: Text(member.role.label)),
    );
  }
}
