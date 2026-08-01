import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';

/// Navigation basse commune à tous les métiers. Les icônes ne changent
/// jamais — seuls les libellés et les routes de chaque onglet viennent de la
/// configuration métier active.
class PrimaryBottomNavigation extends ConsumerWidget {
  const PrimaryBottomNavigation({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(primaryModuleConfigProvider);

    final destinations = [
      (
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        label: config.primaryModuleLabel,
        route: Routes.dashboard,
      ),
      (
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        label: config.clientsLabel,
        route: Routes.clients,
      ),
      (
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        label: config.catalogTab.label,
        route: config.catalogTab.route,
      ),
      (
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        label: config.reportsLabel,
        route: Routes.reports,
      ),
      (
        icon: Icons.more_horiz,
        selectedIcon: Icons.more_horiz,
        label: config.moreLabel,
        route: Routes.more,
      ),
    ];

    final selectedIndex = _selectedIndex(destinations.map((d) => d.route));

    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (index) => context.go(destinations[index].route),
      destinations: [
        for (final d in destinations)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
          ),
      ],
    );
  }

  int _selectedIndex(Iterable<String> routes) {
    final routeList = routes.toList();
    if (location == Routes.dashboard) return 0;
    for (var i = 1; i < routeList.length; i++) {
      if (location.startsWith(routeList[i])) return i;
    }
    return -1;
  }
}
