import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/models/establishment_member.dart';
import '../providers/establishment_providers.dart';

class TeamMembersScreen extends ConsumerWidget {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(establishmentMembersProvider);
    final canInvite = ref.watch(canInviteMembersProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Équipe')),
      floatingActionButton: canInvite
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
              },
              icon: const Icon(Icons.person_add_alt_outlined),
              label: const Text('Inviter'),
            )
          : null,
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
