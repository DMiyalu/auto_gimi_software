import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/domain/business_category.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/establishment.dart';
import '../../domain/models/establishment_invitation.dart';
import '../../domain/models/establishment_member.dart';
import '../../domain/models/establishment_role.dart';
import '../providers/establishment_providers.dart';

/// Landing post-auth : établissements accessibles + invitations en attente.
class EstablishmentOnboardingScreen extends ConsumerWidget {
  const EstablishmentOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitations = ref.watch(pendingInvitationsProvider);
    final establishments = ref.watch(userEstablishmentsProvider);
    final memberships =
        ref.watch(userMembershipsProvider).valueOrNull ?? const [];
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
      backgroundColor: AppColors.zuriWhite,
      body: SafeArea(
        child: Column(
          children: [
            const _LandingTopBar(),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _LandingIntro(fullName: profile?.fullName),
                            const SizedBox(height: 28),
                            establishments.when(
                              data: (items) => _EstablishmentsSection(
                                establishments: items,
                                memberships: memberships,
                                profileRoleFor: profile?.roleFor,
                                loading: controllerState.isLoading,
                                onOpen: (establishment) async {
                                  await ref
                                      .read(
                                        establishmentControllerProvider
                                            .notifier,
                                      )
                                      .switchEstablishment(establishment.id);
                                  if (!context.mounted) return;
                                  final state = ref.read(
                                    establishmentControllerProvider,
                                  );
                                  if (!state.hasError) {
                                    context.go(Routes.dashboard);
                                  }
                                },
                              ),
                              loading: () => const _SectionLoading(),
                              error: (error, _) => _EmptyStateCard(
                                icon: Icons.error_outline,
                                title: 'Établissements indisponibles',
                                subtitle: AuthErrorMapper.message(error),
                              ),
                            ),
                            const SizedBox(height: 24),
                            invitations.when(
                              data: (items) => _InvitationSection(
                                invitations: items,
                                loading: controllerState.isLoading,
                                onAccept: (invitation) async {
                                  await ref
                                      .read(
                                        establishmentControllerProvider
                                            .notifier,
                                      )
                                      .acceptInvitation(invitation);
                                },
                                onRefuse: (invitation) async {
                                  await ref
                                      .read(
                                        establishmentControllerProvider
                                            .notifier,
                                      )
                                      .refuseInvitation(invitation);
                                },
                              ),
                              loading: () => const _SectionLoading(),
                              error: (error, _) => _EmptyStateCard(
                                icon: Icons.error_outline,
                                title: 'Invitations indisponibles',
                                subtitle: AuthErrorMapper.message(error),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _CreateEstablishmentPanel(
                              onCreate: () =>
                                  context.push(Routes.establishmentNew),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandingTopBar extends ConsumerWidget {
  const _LandingTopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: [
          Image.asset(
            'public/images/logo.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Zuri',
                    style: TextStyle(
                      color: AppColors.zuriRed,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  TextSpan(
                    text: ' Business',
                    style: TextStyle(
                      color: AppColors.zuriNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Profil',
            onPressed: () => context.push(Routes.userProfile),
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.zuriPink.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.zuriRed,
                size: 23,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingIntro extends StatelessWidget {
  const _LandingIntro({required this.fullName});

  final String? fullName;

  @override
  Widget build(BuildContext context) {
    final name = fullName?.trim();

    return Column(
      children: [
        Image.asset(
          'public/images/logo.png',
          width: 72,
          height: 72,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Text(
          name == null || name.isEmpty ? 'Bienvenue' : 'Bienvenue, $name',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.zuriNavy,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choisissez un établissement pour démarrer, ou acceptez une invitation.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8A90A5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.zuriNavy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (count != null && count! > 0) ...[
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.zuriRed,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EstablishmentsSection extends StatelessWidget {
  const _EstablishmentsSection({
    required this.establishments,
    required this.memberships,
    required this.profileRoleFor,
    required this.loading,
    required this.onOpen,
  });

  final List<Establishment> establishments;
  final List<EstablishmentMember> memberships;
  final String Function(String establishmentId)? profileRoleFor;
  final bool loading;
  final Future<void> Function(Establishment establishment) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Mes établissements',
          count: establishments.isEmpty ? null : establishments.length,
        ),
        const SizedBox(height: 12),
        if (establishments.isEmpty)
          const _EmptyStateCard(
            icon: Icons.apartment_rounded,
            title: 'Aucun établissement pour l’instant',
            subtitle:
                'Créez le vôtre ou attendez qu’on vous invite dans une équipe.',
          )
        else
          for (final establishment in establishments) ...[
            _EstablishmentCard(
              establishment: establishment,
              categoryLabel: establishment.category.label(l10n),
              roleLabel: _roleLabel(establishment.id),
              loading: loading,
              onOpen: () => onOpen(establishment),
            ),
            if (establishment != establishments.last)
              const SizedBox(height: 10),
          ],
      ],
    );
  }

  String? _roleLabel(String establishmentId) {
    for (final membership in memberships) {
      if (membership.establishmentId == establishmentId) {
        return membership.role.label;
      }
    }
    final raw = profileRoleFor?.call(establishmentId);
    if (raw == null || raw.isEmpty) return null;
    return EstablishmentRole.fromFirestore(raw).label;
  }
}

class _EstablishmentCard extends StatelessWidget {
  const _EstablishmentCard({
    required this.establishment,
    required this.categoryLabel,
    required this.roleLabel,
    required this.loading,
    required this.onOpen,
  });

  final Establishment establishment;
  final String categoryLabel;
  final String? roleLabel;
  final bool loading;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = _categoryAccent(establishment.category);
    final meta = roleLabel == null || roleLabel!.isEmpty
        ? categoryLabel
        : '$categoryLabel • $roleLabel';

    return Material(
      color: AppColors.zuriWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: Key('open_establishment_${establishment.id}'),
        onTap: loading ? null : onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent,
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
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8A90A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.zuriRed),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvitationSection extends StatelessWidget {
  const _InvitationSection({
    required this.invitations,
    required this.loading,
    required this.onAccept,
    required this.onRefuse,
  });

  final List<EstablishmentInvitation> invitations;
  final bool loading;
  final Future<void> Function(EstablishmentInvitation invitation) onAccept;
  final Future<void> Function(EstablishmentInvitation invitation) onRefuse;

  static final _dateFormat = DateFormat('dd MMMM yyyy', 'fr');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Invitations reçues',
          count: invitations.isEmpty ? null : invitations.length,
        ),
        const SizedBox(height: 12),
        if (invitations.isEmpty)
          const _EmptyStateCard(
            icon: Icons.mail_outline_rounded,
            title: 'Aucune invitation en attente',
            subtitle:
                'Les invitations liées à votre numéro apparaîtront ici automatiquement.',
          )
        else
          for (var i = 0; i < invitations.length; i++) ...[
            _InvitationCard(
              invitation: invitations[i],
              accent: _invitationAccent(i),
              dateLabel:
                  'Invitée le ${_dateFormat.format(invitations[i].createdAt)}',
              loading: loading,
              onAccept: () => onAccept(invitations[i]),
              onRefuse: () => onRefuse(invitations[i]),
            ),
            if (i != invitations.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.accent,
    required this.dateLabel,
    required this.loading,
    required this.onAccept,
    required this.onRefuse,
  });

  final EstablishmentInvitation invitation;
  final Color accent;
  final String dateLabel;
  final bool loading;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  @override
  Widget build(BuildContext context) {
    final inviter = invitation.invitedByName.trim().isEmpty
        ? 'Un membre'
        : invitation.invitedByName;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.zuriWhite,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business_rounded,
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
                      invitation.establishmentName,
                      style: const TextStyle(
                        color: AppColors.zuriNavy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$inviter vous invite comme ${invitation.role.label}',
                      style: const TextStyle(
                        color: Color(0xFF8A90A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        color: Color(0xFF8A90A5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: Key('refuse_invitation_${invitation.id}'),
                  onPressed: loading ? null : onRefuse,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.zuriNavy,
                    side: const BorderSide(color: Color(0xFFE0E3EB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  child: const Text('Refuser'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  key: Key('accept_invitation_${invitation.id}'),
                  onPressed: loading ? null : onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.zuriRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Accepter'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateEstablishmentPanel extends StatelessWidget {
  const _CreateEstablishmentPanel({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;

          final icon = Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.zuriWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.zuriRed,
              size: 22,
            ),
          );
          final text = const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Créer un établissement',
                style: TextStyle(
                  color: AppColors.zuriNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Démarrez avec un restaurant, un garage automobile, une activité d’assainissement ou un autre métier disponible.',
                style: TextStyle(
                  color: AppColors.zuriNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          );
          final button = FilledButton(
            key: const Key('onboarding_create_establishment_button'),
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.zuriRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            child: const Text('Créer'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Expanded(child: text),
                  ],
                ),
                const SizedBox(height: 14),
                button,
              ],
            );
          }

          return Row(
            children: [
              icon,
              const SizedBox(width: 12),
              Expanded(child: text),
              const SizedBox(width: 12),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
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
            child: Icon(icon, color: AppColors.zuriRed, size: 26),
          ),
          const SizedBox(height: 14),
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

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

Color _categoryAccent(BusinessCategory category) {
  return switch (category) {
    BusinessCategory.restaurant => AppColors.zuriRed,
    BusinessCategory.shop => const Color(0xFF0F766E),
    BusinessCategory.terraceBarLounge => const Color(0xFFB45309),
    BusinessCategory.hairSalon => const Color(0xFFBE185D),
    BusinessCategory.beautyInstitute => const Color(0xFF9333EA),
    BusinessCategory.clinicMedicalCenter => const Color(0xFF2563EB),
    BusinessCategory.garageAuto => const Color(0xFFF57C00),
    BusinessCategory.sanitation => const Color(0xFF2E7D32),
    BusinessCategory.pharmacy => const Color(0xFF7B1FA2),
    BusinessCategory.pressing => const Color(0xFF1565C0),
    BusinessCategory.gym => const Color(0xFF00897B),
  };
}

Color _invitationAccent(int index) {
  const palette = [
    Color(0xFF7B1FA2),
    Color(0xFF1565C0),
    Color(0xFFF57C00),
    AppColors.zuriRed,
    Color(0xFF00897B),
  ];
  return palette[index % palette.length];
}
