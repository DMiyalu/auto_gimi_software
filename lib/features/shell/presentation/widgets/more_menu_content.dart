import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/business_category.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/utils/confirm_sign_out.dart';
import '../../../establishment/domain/models/establishment.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';

/// Contenu partagé entre l'onglet "Plus" ([MoreMenuScreen]) et le [Drawer]
/// ouvert depuis le menu hamburger du header — même liste, deux points
/// d'entrée différents.
class MoreMenuContent extends ConsumerWidget {
  const MoreMenuContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(primaryModuleConfigProvider);
    final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
    final canInviteMembers = ref.watch(canInviteMembersProvider);
    final pendingInvitationCount =
        ref.watch(pendingInvitationsProvider).valueOrNull?.length ?? 0;

    final metierItems = [
      for (final item in config.moreMenuItems)
        _MenuEntry(
          icon: item.icon,
          title: item.label,
          subtitle: _subtitleForRoute(item.route, item.label),
          onTap: () => context.push(item.route),
        ),
    ];

    final organisationItems = <_MenuEntry>[
      if (canInviteMembers)
        _MenuEntry(
          icon: Icons.groups_outlined,
          title: 'Équipe',
          subtitle: 'Gérez les membres de votre équipe',
          onTap: () => context.push(Routes.team),
        ),
      _MenuEntry(
        icon: Icons.mail_outline_rounded,
        title: 'Invitations',
        subtitle: 'Invitations en attente',
        badgeCount: pendingInvitationCount,
        onTap: () => context.push(Routes.invitations),
      ),
    ];

    final techniqueItems = [
      _MenuEntry(
        icon: Icons.print_outlined,
        title: 'Configuration imprimante',
        subtitle: 'Connectez et configurez votre imprimante',
        onTap: () => context.push(Routes.printerSettings),
      ),
      _MenuEntry(
        icon: Icons.settings_outlined,
        title: l10n.settings,
        subtitle: 'Langue, thème et préférences',
        onTap: () => context.push(Routes.settings),
      ),
    ];

    final compteItems = [
      _MenuEntry(
        icon: Icons.logout_rounded,
        title: l10n.logout,
        subtitle: 'Se déconnecter de l’application',
        onTap: () => confirmAndSignOut(context, ref),
      ),
    ];

    return ColoredBox(
      color: AppColors.zuriWhite,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
        children: [
          if (establishment != null) ...[
            _EstablishmentCard(
              establishment: establishment,
              categoryLabel: establishment.category.label(l10n),
              onTap: () => context.push(Routes.establishmentSettings),
            ),
            const SizedBox(height: 22),
          ],
          if (metierItems.isNotEmpty) ...[
            _MenuSection(title: 'Métier', items: metierItems),
            const SizedBox(height: 18),
          ],
          if (organisationItems.isNotEmpty) ...[
            _MenuSection(title: 'Organisation', items: organisationItems),
            const SizedBox(height: 18),
          ],
          _MenuSection(title: 'Technique', items: techniqueItems),
          const SizedBox(height: 18),
          _MenuSection(title: 'Compte', items: compteItems),
        ],
      ),
    );
  }

  static String _subtitleForRoute(String route, String label) {
    return switch (route) {
      Routes.inventories => 'Gérez vos stocks et comptages',
      Routes.services => 'Gérez vos services et catégories',
      Routes.produits => 'Gérez vos produits et catégories',
      Routes.prestationScan => 'Scannez le QR code d’un client',
      Routes.jetonScan => 'Scannez un jeton de prestation',
      Routes.alertes => 'Consultez les alertes d’entretien',
      _ => label,
    };
  }
}

class _MenuEntry {
  const _MenuEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badgeCount;
}

class _EstablishmentCard extends StatelessWidget {
  const _EstablishmentCard({
    required this.establishment,
    required this.categoryLabel,
    required this.onTap,
  });

  final Establishment establishment;
  final String categoryLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _categoryAccent(establishment.category);

    return Material(
      color: const Color(0xFFFFF0F4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  establishment.category.icon,
                  color: Colors.white,
                  size: 24,
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
                        fontSize: 16,
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
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A90A5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});

  final String title;
  final List<_MenuEntry> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF8A90A5),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        Container(
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
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _MenuTile(entry: items[i]),
                if (i != items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 66,
                    endIndent: 14,
                    color: Color(0xFFF0F1F5),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.entry});

  final _MenuEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: entry.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.zuriPink.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(entry.icon, color: AppColors.zuriRed, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      color: AppColors.zuriNavy,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8A90A5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (entry.badgeCount > 0) ...[
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
                  '${entry.badgeCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A90A5)),
          ],
        ),
      ),
    );
  }
}

Color _categoryAccent(BusinessCategory category) => AppColors.zuriRed;
