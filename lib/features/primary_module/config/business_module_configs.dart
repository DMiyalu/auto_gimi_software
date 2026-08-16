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
      BusinessCategory.garageAuto => activityWorkflow(category),
      BusinessCategory.restaurant => restaurant,
      BusinessCategory.terraceBarLounge => activityWorkflow(category),
      _ => activityWorkflow(category),
    };
  }

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

  static BusinessModuleConfig activityWorkflow(BusinessCategory category) {
    final mainActivity = category.defaultMainActivity;
    final isGarage = category == BusinessCategory.garageAuto;
    final isCommande = mainActivity == 'Commandes';
    final singular = _singularMainActivity(mainActivity);

    return BusinessModuleConfig(
      category: category,
      primaryModuleLabel: mainActivity,
      searchPlaceholder: isGarage
          ? 'Rechercher une prestation, un véhicule ou un client…'
          : 'Rechercher $singular ou un client…',
      primaryColor: AppColors.zuriRed,
      activityIcon: category.icon,
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
      fabActions: [
        FabActionConfig(
          label: isCommande
              ? 'Nouvelle commande'
              : '${singular.startsWith('un ') ? 'Nouveau' : 'Nouvelle'} '
                    '${singular.replaceFirst(RegExp(r'^(un|une) '), '')}',
          icon: isCommande
              ? Icons.add_shopping_cart_outlined
              : Icons.add_circle_outline,
          route: isGarage
              ? Routes.prestationNew
              : isCommande
              ? Routes.commandeNew
              : null,
        ),
        if (isCommande) ...const [
          FabActionConfig(
            label: 'Réservation',
            icon: Icons.event_seat_outlined,
          ),
          FabActionConfig(
            label: 'À emporter',
            icon: Icons.shopping_bag_outlined,
          ),
          FabActionConfig(
            label: 'Livraison',
            icon: Icons.delivery_dining_outlined,
          ),
        ],
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
  }

  static String _singularMainActivity(String mainActivity) {
    return switch (mainActivity) {
      'Commandes' => 'une commande',
      'Prestations' => 'une prestation',
      'Séjours' => 'un séjour',
      _ => 'une activité',
    };
  }
}
