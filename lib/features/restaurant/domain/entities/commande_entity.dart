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
    this.paymentMethod,
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
  final CommandePaymentMethod? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// En cours : seul statut où les lignes et le client peuvent être modifiés.
  bool get isEditable => statusKey == CommandeStatus.enCours;

  /// En cours ou à payer : la commande peut encore être annulée.
  bool get canBeCanceled =>
      statusKey == CommandeStatus.enCours || statusKey == CommandeStatus.aPayer;

  /// En cours ou à payer : de l'argent peut encore être encaissé.
  bool get canCollectPayment =>
      statusKey == CommandeStatus.enCours || statusKey == CommandeStatus.aPayer;

  bool get isClosed => statusKey == CommandeStatus.cloturee;

  bool get isCanceled => statusKey == CommandeStatus.annulees;
}

enum CommandePaymentMethod {
  cash('cash', 'Cash'),
  mpesa('m_pesa', 'M-pesa'),
  orangeMoney('orange_money', 'Orange Money'),
  airtelMoney('airtel_money', 'Airtel Money'),
  afrimoney('afrimoney', 'Afrimoney'),
  equityBcdc('equity_bcdc', 'EquityBCDC');

  const CommandePaymentMethod(this.value, this.label);

  final String value;
  final String label;

  static CommandePaymentMethod fromValue(String? value) {
    return CommandePaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => CommandePaymentMethod.cash,
    );
  }
}

/// Clés de statut d'une commande — seule source de vérité pour éviter les
/// chaînes magiques dupliquées entre repository, controller et UI.
///
/// Cycle de vie : [enCours] → [aPayer] → [cloturee]. [annulees] est un
/// statut exceptionnel atteignable depuis [enCours] ou [aPayer] uniquement.
abstract final class CommandeStatus {
  static const enCours = 'en_cours';
  static const aPayer = 'a_payer';
  static const cloturee = 'cloturee';
  static const annulees = 'annulees';
}

String commandeStatusLabel(String key) {
  return switch (key) {
    CommandeStatus.enCours => 'En cours',
    CommandeStatus.aPayer => 'À payer',
    CommandeStatus.cloturee => 'Clôturée',
    CommandeStatus.annulees => 'Annulée',
    _ => key,
  };
}

Color commandeStatusColor(String key) {
  return switch (key) {
    CommandeStatus.enCours => const Color(0xFFFF8A00),
    CommandeStatus.aPayer => AppColors.zuriRed,
    CommandeStatus.cloturee => const Color(0xFF16A34A),
    CommandeStatus.annulees => Colors.grey.shade500,
    _ => Colors.blueGrey.shade500,
  };
}
