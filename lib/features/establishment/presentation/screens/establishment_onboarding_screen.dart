import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/establishment_invitation.dart';
import '../providers/establishment_providers.dart';

class EstablishmentOnboardingScreen extends ConsumerWidget {
  const EstablishmentOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitations = ref.watch(pendingInvitationsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final controllerState = ref.watch(establishmentControllerProvider);

    ref.listen(establishmentControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZOLANA'),
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
        child: Align(
          alignment: Alignment.topCenter,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LandingIntro(fullName: profile?.fullName),
                      const SizedBox(height: AppSpacing.lg),
                      invitations.when(
                        data: (items) => _InvitationSection(
                          invitations: items,
                          loading: controllerState.isLoading,
                          onAccept: (invitation) async {
                            await ref
                                .read(establishmentControllerProvider.notifier)
                                .acceptInvitation(invitation);
                            if (!context.mounted) return;
                            final state = ref.read(
                              establishmentControllerProvider,
                            );
                            if (!state.hasError) context.go(Routes.dashboard);
                          },
                        ),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, _) => _InfoRow(
                          icon: Icons.error_outline,
                          title: 'Invitations indisponibles',
                          subtitle: AuthErrorMapper.message(error),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _CreateEstablishmentPanel(
                        onCreate: () => context.push(Routes.establishmentNew),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingIntro extends StatelessWidget {
  const _LandingIntro({required this.fullName});

  final String? fullName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = fullName?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'public/images/icon.png',
          width: 76,
          height: 76,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          name == null || name.isEmpty ? 'Bienvenue' : 'Bienvenue, $name',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'ZOLANA centralise commandes, prestations, clients, catalogue et rapports pour chaque établissement que vous gérez.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InvitationSection extends StatelessWidget {
  const _InvitationSection({
    required this.invitations,
    required this.loading,
    required this.onAccept,
  });

  final List<EstablishmentInvitation> invitations;
  final bool loading;
  final Future<void> Function(EstablishmentInvitation invitation) onAccept;

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return const _InfoRow(
        icon: Icons.mail_outline,
        title: 'Aucune invitation en attente',
        subtitle:
            'Les invitations liées à votre numéro apparaîtront ici automatiquement.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Invitations reçues',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final invitation in invitations)
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.mail_outline)),
              title: Text(invitation.establishmentName),
              subtitle: Text('Rôle proposé : ${invitation.role.label}'),
              trailing: FilledButton(
                key: Key('accept_invitation_${invitation.id}'),
                onPressed: loading ? null : () => onAccept(invitation),
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Accepter'),
              ),
            ),
          ),
      ],
    );
  }
}

class _CreateEstablishmentPanel extends StatelessWidget {
  const _CreateEstablishmentPanel({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 480;

            final icon = CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
              child: const Icon(Icons.add_business_outlined),
            );
            final text = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Créer un établissement',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Démarrez avec un restaurant, un garage automobile, une activité d’assainissement ou un autre métier disponible.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
            final button = FilledButton.icon(
              key: const Key('onboarding_create_establishment_button'),
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Créer'),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(alignment: Alignment.centerLeft, child: icon),
                  const SizedBox(height: AppSpacing.sm),
                  text,
                  const SizedBox(height: AppSpacing.md),
                  button,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: text),
                const SizedBox(width: AppSpacing.sm),
                button,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
