import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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

    return ListView(
      children: [
        if (establishment != null)
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
            title: Text(establishment.name),
            subtitle: Text(establishment.category.label(l10n)),
          ),
        const Divider(),
        for (final item in config.moreMenuItems)
          ListTile(
            leading: Icon(item.icon),
            title: Text(item.label),
            onTap: () => context.push(item.route),
          ),
        if (canInviteMembers)
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Équipe'),
            onTap: () => context.push(Routes.team),
          ),
        ListTile(
          leading: const Icon(Icons.mail_outline),
          title: const Text('Invitations'),
          trailing: pendingInvitationCount == 0
              ? null
              : Badge(label: Text('$pendingInvitationCount')),
          onTap: () => context.push(Routes.invitations),
        ),
        ListTile(
          leading: const Icon(Icons.print_outlined),
          title: const Text('Configuration imprimante'),
          onTap: () => context.push(Routes.printerSettings),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(l10n.settings),
          onTap: () => context.push(Routes.settings),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(l10n.logout),
          onTap: () => ref.read(authControllerProvider.notifier).signOut(),
        ),
      ],
    );
  }
}
