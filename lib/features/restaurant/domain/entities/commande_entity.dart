import 'package:flutter/material.dart';

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
    'en_attente' => const Color(0xFFEF2E2E),
    'en_preparation' => const Color(0xFF006B43),
    'pretes' => const Color(0xFF1FA85B),
    'livraison' => const Color(0xFF1E88E5),
    'annulees' => Colors.grey.shade500,
    _ => Colors.blueGrey.shade500,
  };
}
