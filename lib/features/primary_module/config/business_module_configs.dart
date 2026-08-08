import 'package:flutter/material.dart';

import '../../../core/domain/business_category.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import 'business_module_config.dart';

/// Registre unique métier -> configuration de l'écran principal.
/// C'est le SEUL endroit du code qui connaît des libellés spécifiques à un
/// métier (restaurant, garage, assainissement...) — les widgets restent
/// entièrement génériques.
abstract final class BusinessModuleConfigs {
  static BusinessModuleConfig forCategory(BusinessCategory category) {
    return switch (category) {
      BusinessCategory.garageAuto => garage,
      BusinessCategory.restaurant => restaurant,
      BusinessCategory.sanitation => sanitation,
      _ => _genericFallback(category),
    };
  }

  static final garage = BusinessModuleConfig(
    category: BusinessCategory.garageAuto,
    primaryModuleLabel: 'Prestations',
    searchPlaceholder: 'Rechercher une prestation, un véhicule ou un client…',
    primaryColor: AppColors.bleuRoyal,
    activityIcon: Icons.build_circle_outlined,
    statusFilters: const [
      StatusFilterOption(key: 'all', label: 'Toutes'),
      StatusFilterOption(key: 'diagnostic', label: 'Diagnostic'),
      StatusFilterOption(key: 'en_cours', label: 'En cours'),
      StatusFilterOption(key: 'terminees', label: 'Terminées'),
      StatusFilterOption(key: 'en_attente', label: 'En attente'),
      StatusFilterOption(key: 'annulees', label: 'Annulées'),
    ],
    catalogTab: const CatalogTabConfig(
      label: 'Services',
      route: Routes.services,
    ),
    fabActions: const [
      FabActionConfig(
        label: 'Nouvelle prestation',
        icon: Icons.build_outlined,
        route: Routes.prestationNew,
      ),
      FabActionConfig(
        label: 'Nouveau rendez-vous',
        icon: Icons.event_available_outlined,
      ),
      FabActionConfig(
        label: 'Nouveau véhicule',
        icon: Icons.directions_car_outlined,
      ),
    ],
    moreMenuItems: const [
      MoreMenuItemConfig(
        label: 'Produits',
        icon: Icons.inventory_2_outlined,
        route: Routes.produits,
      ),
      MoreMenuItemConfig(
        label: 'Scanner client',
        icon: Icons.qr_code_scanner,
        route: Routes.prestationScan,
      ),
      MoreMenuItemConfig(
        label: 'Scanner jeton',
        icon: Icons.local_drink_outlined,
        route: Routes.jetonScan,
      ),
      MoreMenuItemConfig(
        label: 'Alertes',
        icon: Icons.notifications_active_outlined,
        route: Routes.alertes,
      ),
    ],
  );

  static final restaurant = BusinessModuleConfig(
    category: BusinessCategory.restaurant,
    primaryModuleLabel: 'Commandes',
    searchPlaceholder: 'Rechercher une commande, table, client…',
    primaryColor: AppColors.zuriRed,
    activityIcon: Icons.restaurant_outlined,
    statusFilters: const [
      StatusFilterOption(key: 'all', label: 'Toutes'),
      StatusFilterOption(key: 'en_cours', label: 'En cours'),
      StatusFilterOption(key: 'a_payer', label: 'À payer'),
      StatusFilterOption(key: 'cloturee', label: 'Clôturées'),
      StatusFilterOption(key: 'annulees', label: 'Annulées'),
    ],
    catalogTab: const CatalogTabConfig(
      label: 'Produits',
      route: Routes.produits,
    ),
    fabActions: const [
      FabActionConfig(
        label: 'Nouvelle commande',
        icon: Icons.add_shopping_cart_outlined,
        route: Routes.commandeNew,
      ),
      FabActionConfig(label: 'Réservation', icon: Icons.event_seat_outlined),
      FabActionConfig(label: 'À emporter', icon: Icons.shopping_bag_outlined),
      FabActionConfig(label: 'Livraison', icon: Icons.delivery_dining_outlined),
    ],
    moreMenuItems: const [
      MoreMenuItemConfig(
        label: 'Inventaires',
        icon: Icons.inventory_2_outlined,
        route: Routes.inventories,
      ),
      MoreMenuItemConfig(
        label: 'Services',
        icon: Icons.room_service_outlined,
        route: Routes.services,
      ),
    ],
  );

  static final sanitation = BusinessModuleConfig(
    category: BusinessCategory.sanitation,
    primaryModuleLabel: 'Collectes',
    searchPlaceholder: 'Rechercher une collecte, une tournée ou un client…',
    primaryColor: AppColors.cyan,
    activityIcon: Icons.cleaning_services_outlined,
    statusFilters: const [
      StatusFilterOption(key: 'all', label: 'Toutes'),
      StatusFilterOption(key: 'planifiees', label: 'Planifiées'),
      StatusFilterOption(key: 'en_cours', label: 'En cours'),
      StatusFilterOption(key: 'terminees', label: 'Terminées'),
      StatusFilterOption(key: 'annulees', label: 'Annulées'),
    ],
    catalogTab: const CatalogTabConfig(
      label: 'Services',
      route: Routes.services,
    ),
    fabActions: const [
      FabActionConfig(
        label: 'Nouvelle collecte',
        icon: Icons.local_shipping_outlined,
      ),
      FabActionConfig(
        label: 'Nouvelle tournée',
        icon: Icons.alt_route_outlined,
      ),
      FabActionConfig(
        label: 'Nouveau client',
        icon: Icons.person_add_alt_outlined,
        route: Routes.clientNew,
      ),
    ],
    moreMenuItems: const [
      MoreMenuItemConfig(
        label: 'Produits',
        icon: Icons.inventory_2_outlined,
        route: Routes.produits,
      ),
    ],
  );

  /// Filet de sécurité pour les métiers pas encore détaillés (pressing,
  /// gym, pharmacy...) — reste générique, sans libellé métier hasardeux.
  static BusinessModuleConfig _genericFallback(BusinessCategory category) {
    return BusinessModuleConfig(
      category: category,
      primaryModuleLabel: 'Activités',
      searchPlaceholder: 'Rechercher une activité ou un client…',
      primaryColor: AppColors.bleuSaas,
      activityIcon: category.icon,
      statusFilters: const [
        StatusFilterOption(key: 'all', label: 'Toutes'),
        StatusFilterOption(key: 'en_attente', label: 'En attente'),
        StatusFilterOption(key: 'en_cours', label: 'En cours'),
        StatusFilterOption(key: 'terminees', label: 'Terminées'),
        StatusFilterOption(key: 'annulees', label: 'Annulées'),
      ],
      catalogTab: const CatalogTabConfig(
        label: 'Produits',
        route: Routes.produits,
      ),
      fabActions: const [
        FabActionConfig(
          label: 'Nouvelle activité',
          icon: Icons.add_circle_outline,
        ),
      ],
      moreMenuItems: const [
        MoreMenuItemConfig(
          label: 'Services',
          icon: Icons.room_service_outlined,
          route: Routes.services,
        ),
      ],
    );
  }
}
