import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Catégories d'établissement supportées par la plateforme SaaS.
enum BusinessCategory {
  restaurant,
  garageAuto,
  pressing,
  sanitation,
  gym,
  pharmacy;

  String get firestoreValue => switch (this) {
        restaurant => 'restaurant',
        garageAuto => 'garage_auto',
        pressing => 'pressing',
        sanitation => 'sanitation',
        gym => 'gym',
        pharmacy => 'pharmacy',
      };

  static BusinessCategory fromFirestore(String value) {
    return BusinessCategory.values.firstWhere(
      (c) => c.firestoreValue == value,
      orElse: () => BusinessCategory.restaurant,
    );
  }

  String label(AppLocalizations l10n) => switch (this) {
        restaurant => l10n.categoryRestaurant,
        garageAuto => l10n.categoryGarageAuto,
        pressing => l10n.categoryPressing,
        sanitation => l10n.categorySanitation,
        gym => l10n.categoryGym,
        pharmacy => l10n.categoryPharmacy,
      };

  IconData get icon => switch (this) {
        restaurant => Icons.restaurant_outlined,
        garageAuto => Icons.car_repair_outlined,
        pressing => Icons.local_laundry_service_outlined,
        sanitation => Icons.cleaning_services_outlined,
        gym => Icons.fitness_center_outlined,
        pharmacy => Icons.local_pharmacy_outlined,
      };
}
