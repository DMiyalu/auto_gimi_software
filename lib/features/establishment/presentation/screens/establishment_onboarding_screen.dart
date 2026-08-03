import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/establishment_providers.dart';

class EstablishmentOnboardingScreen extends ConsumerWidget {
  const EstablishmentOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitations = ref.watch(pendingInvitationsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konnect One'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    profile == null
                        ? 'Bienvenue'
                        : 'Bienvenue, ${profile.fullName}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre premier établissement ou acceptez une invitation pour rejoindre une équipe existante.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => context.push(Routes.establishmentNew),
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Créer mon premier établissement'),
                  ),
                  const SizedBox(height: 24),
                  invitations.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const _EmptyInvitations();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Invitations reçues',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          for (final invitation in items)
                            Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.mail_outline),
                                ),
                                title: Text(invitation.establishmentName),
                                subtitle: Text(
                                  'Rôle proposé : ${invitation.role.label}',
                                ),
                                trailing: FilledButton(
                                  onPressed: () => ref
                                      .read(
                                        establishmentControllerProvider
                                            .notifier,
                                      )
                                      .acceptInvitation(invitation),
                                  child: const Text('Accepter'),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text(error.toString()),
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

class _EmptyInvitations extends StatelessWidget {
  const _EmptyInvitations();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.mail_outline)),
      title: const Text('Aucune invitation en attente'),
      subtitle: Text(
        'Si quelqu’un vous invite, l’invitation apparaîtra ici automatiquement.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
