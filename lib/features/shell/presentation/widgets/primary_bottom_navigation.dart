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
    final safeSelectedIndex = selectedIndex < 0 ? 0 : selectedIndex;

    if (config.category.usesRestaurantWorkflow) {
      return SafeArea(
        minimum: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _RestaurantNavItem(
                    icon: i == safeSelectedIndex
                        ? destinations[i].selectedIcon
                        : destinations[i].icon,
                    label: destinations[i].label,
                    selected: i == safeSelectedIndex,
                    color: config.primaryColor,
                    onTap: () => context.go(destinations[i].route),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return NavigationBar(
      selectedIndex: safeSelectedIndex,
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

class _RestaurantNavItem extends StatelessWidget {
  const _RestaurantNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = selected ? color : const Color(0xFF8A90A5);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: itemColor),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: itemColor,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
