import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';
import '../../../primary_module/widgets/business_header.dart';

/// Onglet "Plus" — regroupe les destinations qui ne tiennent pas dans les
/// 4 premiers onglets de la bottom navigation. Entièrement piloté par la
/// configuration métier active.
class MoreMenuScreen extends ConsumerWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(primaryModuleConfigProvider);
    final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BusinessHeader(),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: ListView(
                children: [
                  if (establishment != null)
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.storefront_outlined),
                      ),
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
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(l10n.settings),
                    onTap: () => context.push(Routes.settings),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(l10n.logout),
                    onTap: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
