import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/establishment_providers.dart';

class MemberManagementPermissionGate extends ConsumerWidget {
  const MemberManagementPermissionGate({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canInviteMembers = ref.watch(canInviteMembersProvider);
    if (canInviteMembers) return builder(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Accès limité')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48),
              SizedBox(height: 16),
              Text(
                'Gestion d’équipe réservée',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Seuls le propriétaire et les gérants peuvent gérer les membres et envoyer des invitations.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
