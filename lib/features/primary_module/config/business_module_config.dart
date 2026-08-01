import 'package:flutter/material.dart';

import '../../../core/domain/business_category.dart';

/// Une option de filtre rapide au-dessus de la liste d'activité.
/// [key] == 'all' représente toujours "Toutes".
class StatusFilterOption {
  const StatusFilterOption({required this.key, required this.label});

  final String key;
  final String label;
}

/// Une action proposée dans le BottomSheet du bouton flottant.
/// [route] est nullable : quand aucun écran réel n'existe encore pour cette
/// action, l'UI affiche un message "bientôt disponible" au lieu de naviguer
/// vers du code mort.
class FabActionConfig {
  const FabActionConfig({
    required this.label,
    required this.icon,
    this.route,
  });

  final String label;
  final IconData icon;
  final String? route;
}

/// L'onglet catalogue de la bottom navigation (Produits ou Services selon
/// le métier).
class CatalogTabConfig {
  const CatalogTabConfig({required this.label, required this.route});

  final String label;
  final String route;
}

/// Un item de l'onglet "Plus" (menu débordement).
class MoreMenuItemConfig {
  const MoreMenuItemConfig({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

/// Configuration complète pilotant l'écran principal pour un métier donné.
/// Aucun widget ne doit connaître le métier actif autrement qu'à travers
/// cet objet.
class BusinessModuleConfig {
  const BusinessModuleConfig({
    required this.category,
    required this.primaryModuleLabel,
    required this.searchPlaceholder,
    required this.statusFilters,
    required this.primaryColor,
    required this.activityIcon,
    required this.fabActions,
    required this.catalogTab,
    required this.moreMenuItems,
    this.clientsLabel = 'Clients',
    this.reportsLabel = 'Rapports',
    this.moreLabel = 'Plus',
  });

  final BusinessCategory category;
  final String primaryModuleLabel;
  final String searchPlaceholder;
  final List<StatusFilterOption> statusFilters;
  final Color primaryColor;
  final IconData activityIcon;
  final List<FabActionConfig> fabActions;
  final CatalogTabConfig catalogTab;
  final List<MoreMenuItemConfig> moreMenuItems;
  final String clientsLabel;
  final String reportsLabel;
  final String moreLabel;
}
