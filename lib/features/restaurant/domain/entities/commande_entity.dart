import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CommandeEntity {
  const CommandeEntity({
    required this.id,
    this.clientId,
    required this.reference,
    required this.statusKey,
    required this.statusLabel,
    this.context,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? clientId;
  final String reference;
  final String statusKey;
  final String statusLabel;
  final String? context;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

String commandeStatusLabel(String key) {
  return switch (key) {
    'en_attente' => 'En attente',
    'en_preparation' => 'En préparation',
    'pretes' => 'Prête',
    'livraison' => 'Livraison',
    'annulees' => 'Annulée',
    _ => key,
  };
}

Color commandeStatusColor(String key) {
  return switch (key) {
    'en_attente' => AppColors.violetClair,
    'en_preparation' => AppColors.violetPrincipal,
    'pretes' => AppColors.bleuRoyal,
    'livraison' => AppColors.cyan,
    'annulees' => Colors.grey.shade500,
    _ => Colors.blueGrey.shade500,
  };
}
