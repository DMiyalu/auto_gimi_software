import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';

class AppShellScreen extends ConsumerWidget {
  const AppShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;
    final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    establishment?.name ?? l10n.appTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (establishment != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      establishment.category.label(l10n),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            _NavTile(
              icon: Icons.dashboard_outlined,
              label: l10n.dashboard,
              selected: location == Routes.dashboard,
              onTap: () => _go(context, Routes.dashboard),
            ),
            _NavTile(
              icon: Icons.people_outline,
              label: l10n.clients,
              selected: location.startsWith('/clients'),
              onTap: () => _go(context, Routes.clients),
            ),
            _NavTile(
              icon: Icons.inventory_2_outlined,
              label: l10n.products,
              selected: location.startsWith('/produits'),
              onTap: () => _go(context, Routes.produits),
            ),
            _NavTile(
              icon: Icons.build_outlined,
              label: l10n.services,
              selected: location.startsWith('/services'),
              onTap: () => _go(context, Routes.services),
            ),
            _NavTile(
              icon: Icons.qr_code_scanner,
              label: l10n.scanClient,
              selected: location == Routes.prestationScan,
              onTap: () => _go(context, Routes.prestationScan),
            ),
            _NavTile(
              icon: Icons.local_drink_outlined,
              label: l10n.scanToken,
              selected: location == Routes.jetonScan,
              onTap: () => _go(context, Routes.jetonScan),
            ),
            _NavTile(
              icon: Icons.notifications_active_outlined,
              label: l10n.alerts,
              selected: location == Routes.alertes,
              onTap: () => _go(context, Routes.alertes),
            ),
            const Divider(),
            _NavTile(
              icon: Icons.settings_outlined,
              label: l10n.settings,
              selected: location == Routes.settings,
              onTap: () => _go(context, Routes.settings),
            ),
          ],
        ),
      ),
      body: child,
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.go(route);
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      onTap: onTap,
    );
  }
}
