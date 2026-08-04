import 'package:flutter/material.dart';

import '../../../core/domain/business_category.dart';
import '../models/activity_item.dart';

/// Jeux de données mockés pour l'activité principale, en attendant le
/// branchement sur l'API/le repository réel de chaque métier.
abstract final class MockActivityData {
  static List<ActivityItem> forCategory(BusinessCategory category) {
    return switch (category) {
      BusinessCategory.restaurant => _restaurant(),
      BusinessCategory.garageAuto => _garage(),
      BusinessCategory.sanitation => _sanitation(),
      _ => _garage(),
    };
  }

  static DateTime _todayAt(int hour, int minute) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Couleur sémantique associée à une clé de statut — partagée avec le
  /// notifier de la liste pour que les statuts changés à la main (épinglage
  /// mis à part) restent visuellement cohérents avec les données mockées.
  static Color statusColorFor(String key) {
    return switch (key) {
      'en_attente' => const Color(0xFFEF2E2E),
      'en_preparation' ||
      'en_cours' ||
      'diagnostic' ||
      'planifiees' => const Color(0xFF1E88E5),
      'pretes' || 'terminees' => const Color(0xFF1FA85B),
      'livraison' => Colors.deepOrange.shade400,
      'annulees' => Colors.grey.shade500,
      _ => Colors.blueGrey,
    };
  }

  static List<ActivityItem> _restaurant() {
    Color c(String key) => statusColorFor(key);
    return [
      ActivityItem(
        id: 'table-12',
        title: 'Table 12',
        subtitle: 'Poulet braisé x2, Alloco, Coca x2',
        time: _todayAt(10, 42),
        statusKey: 'en_preparation',
        statusLabel: 'En préparation',
        statusColor: c('en_preparation'),
        leadingIcon: Icons.table_restaurant_outlined,
        amount: 18000,
        metaLabel: '2 personnes',
        badgeCount: 2,
        accentColor: const Color(0xFF006B43),
      ),
      ActivityItem(
        id: 'livraison-1258',
        title: 'Livraison #1258',
        subtitle: 'Pizza Royale, Jus Bissap',
        time: _todayAt(10, 38),
        statusKey: 'en_attente',
        statusLabel: 'En attente',
        statusColor: c('en_attente'),
        leadingIcon: Icons.delivery_dining_outlined,
        amount: 32000,
        metaLabel: 'Kalamu, Avenue Kasavubu',
        badgeCount: 1,
        accentColor: const Color(0xFFFF5A66),
      ),
      ActivityItem(
        id: 'table-5',
        title: 'Table 5',
        subtitle: 'Mafé poulet, Riz blanc, Eau minérale',
        time: _todayAt(9, 55),
        statusKey: 'en_preparation',
        statusLabel: 'En préparation',
        statusColor: c('en_preparation'),
        leadingIcon: Icons.table_restaurant_outlined,
        amount: 22500,
        metaLabel: '3 personnes',
        accentColor: const Color(0xFFFF970F),
      ),
      ActivityItem(
        id: 'emporter-1256',
        title: 'À emporter #1256',
        subtitle: 'Burger Classique x2, Frites, Coca',
        time: _todayAt(9, 48),
        statusKey: 'pretes',
        statusLabel: 'Prête',
        statusColor: c('pretes'),
        leadingIcon: Icons.shopping_bag_outlined,
        amount: 15000,
        metaLabel: '1 personne',
        accentColor: const Color(0xFF40C979),
      ),
      ActivityItem(
        id: 'livraison-1255',
        title: 'Livraison #1255',
        subtitle: 'Thieboudienne, Salade, Eau minérale',
        time: _todayAt(9, 30),
        statusKey: 'en_attente',
        statusLabel: 'En attente',
        statusColor: c('en_attente'),
        leadingIcon: Icons.delivery_dining_outlined,
        amount: 27000,
        metaLabel: 'Gombe, Rue des Jardins',
        badgeCount: 3,
        accentColor: const Color(0xFFFF5A66),
      ),
      ActivityItem(
        id: 'table-8',
        title: 'Table 8',
        subtitle: 'Brochettes mixtes, Alloco, Sprite',
        time: _todayAt(9, 15),
        statusKey: 'en_preparation',
        statusLabel: 'En préparation',
        statusColor: c('en_preparation'),
        leadingIcon: Icons.table_restaurant_outlined,
        amount: 31000,
        metaLabel: '4 personnes',
        accentColor: const Color(0xFF4AAEFF),
      ),
    ];
  }

  static List<ActivityItem> _garage() {
    Color c(String key) => statusColorFor(key);
    return [
      ActivityItem(
        id: 'prestation-214',
        title: 'Toyota Corolla — CD 214 KM',
        subtitle: 'Vidange, Filtre à huile',
        time: _todayAt(11, 10),
        statusKey: 'en_cours',
        statusLabel: 'En cours',
        statusColor: c('en_cours'),
        leadingIcon: Icons.build_circle_outlined,
        amount: 45000,
        metaLabel: 'Jean Kalonji',
        badgeCount: 1,
      ),
      ActivityItem(
        id: 'prestation-198',
        title: 'Hyundai Tucson — CD 198 AB',
        subtitle: 'Diagnostic moteur',
        time: _todayAt(10, 25),
        statusKey: 'diagnostic',
        statusLabel: 'Diagnostic',
        statusColor: c('diagnostic'),
        leadingIcon: Icons.troubleshoot_outlined,
        amount: 15000,
        metaLabel: 'Grace Mbuyi',
      ),
      ActivityItem(
        id: 'prestation-176',
        title: 'Toyota Hilux — CD 176 GP',
        subtitle: 'Freins avant, Plaquettes',
        time: _todayAt(9, 40),
        statusKey: 'en_attente',
        statusLabel: 'En attente',
        statusColor: c('en_attente'),
        leadingIcon: Icons.build_circle_outlined,
        amount: 68000,
        metaLabel: 'Patrick Ilunga',
      ),
      ActivityItem(
        id: 'prestation-142',
        title: 'Mercedes Sprinter — CD 142 KL',
        subtitle: 'Révision complète',
        time: _todayAt(8, 55),
        statusKey: 'terminees',
        statusLabel: 'Terminée',
        statusColor: c('terminees'),
        leadingIcon: Icons.build_circle_outlined,
        amount: 120000,
        metaLabel: 'Société Kin Transport',
      ),
    ];
  }

  static List<ActivityItem> _sanitation() {
    Color c(String key) => statusColorFor(key);
    return [
      ActivityItem(
        id: 'collecte-88',
        title: 'Tournée Kalamu',
        subtitle: 'Collecte ordures ménagères',
        time: _todayAt(8, 30),
        statusKey: 'en_cours',
        statusLabel: 'En cours',
        statusColor: c('en_cours'),
        leadingIcon: Icons.local_shipping_outlined,
        metaLabel: '12 points de collecte',
        badgeCount: 2,
      ),
      ActivityItem(
        id: 'collecte-87',
        title: 'Collecte Gombe — Rue du Fleuve',
        subtitle: 'Client entreprise',
        time: _todayAt(9, 5),
        statusKey: 'planifiees',
        statusLabel: 'Planifiée',
        statusColor: c('planifiees'),
        leadingIcon: Icons.cleaning_services_outlined,
        amount: 25000,
        metaLabel: 'Société Bralima',
      ),
      ActivityItem(
        id: 'collecte-85',
        title: 'Tournée Ngaliema',
        subtitle: 'Collecte déchets industriels',
        time: _todayAt(7, 50),
        statusKey: 'terminees',
        statusLabel: 'Terminée',
        statusColor: c('terminees'),
        leadingIcon: Icons.local_shipping_outlined,
        amount: 40000,
        metaLabel: '8 points de collecte',
      ),
      ActivityItem(
        id: 'collecte-81',
        title: 'Collecte Lemba — Av. de la Paix',
        subtitle: 'Client particulier',
        time: _todayAt(7, 20),
        statusKey: 'annulees',
        statusLabel: 'Annulée',
        statusColor: c('annulees'),
        leadingIcon: Icons.cleaning_services_outlined,
        metaLabel: 'Reportée à demain',
      ),
    ];
  }
}
