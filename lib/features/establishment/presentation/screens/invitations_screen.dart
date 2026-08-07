import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/establishment_invitation.dart';
import '../providers/establishment_providers.dart';

class InvitationsScreen extends ConsumerWidget {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitations = ref.watch(pendingInvitationsProvider);
    final controllerState = ref.watch(establishmentControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Invitations')),
      body: invitations.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Aucune invitation en attente'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _InvitationTile(
                invitation: items[index],
                loading: controllerState.isLoading,
                onAccept: () => ref
                    .read(establishmentControllerProvider.notifier)
                    .acceptInvitation(items[index]),
                onRefuse: () => ref
                    .read(establishmentControllerProvider.notifier)
                    .refuseInvitation(items[index]),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _InvitationTile extends StatelessWidget {
  const _InvitationTile({
    required this.invitation,
    required this.loading,
    required this.onAccept,
    required this.onRefuse,
  });

  final EstablishmentInvitation invitation;
  final bool loading;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  @override
  Widget build(BuildContext context) {
    final invitedBy = invitation.invitedByName.trim().isEmpty
        ? 'Un membre'
        : invitation.invitedByName;

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.mail_outline)),
      title: Text(invitation.establishmentName),
      subtitle: Text('$invitedBy vous invite comme ${invitation.role.label}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: loading ? null : onRefuse,
            child: const Text('Refuser'),
          ),
          FilledButton(
            onPressed: loading ? null : onAccept,
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }
}
