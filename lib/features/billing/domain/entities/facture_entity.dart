import '../../../../core/domain/app_currency.dart';

class FactureEntity {
  const FactureEntity({
    required this.id,
    required this.reference,
    required this.activityType,
    required this.activityId,
    required this.status,
    required this.totalAmount,
    required this.paidAmount,
    required this.currency,
    required this.issuedAt,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String reference;
  final String activityType;
  final String activityId;
  final FactureStatus status;
  final double totalAmount;
  final double paidAmount;
  final AppCurrency currency;
  final DateTime issuedAt;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get balanceDue => (totalAmount - paidAmount).clamp(0, totalAmount);
}

enum FactureStatus {
  draft('brouillon', 'Brouillon'),
  issued('emise', 'Émise'),
  paid('payee', 'Payée'),
  canceled('annulee', 'Annulée');

  const FactureStatus(this.value, this.label);

  final String value;
  final String label;

  static FactureStatus fromValue(String? value) {
    return FactureStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => FactureStatus.issued,
    );
  }
}

enum BillingActivityType {
  commande('commande'),
  prestation('prestation');

  const BillingActivityType(this.value);

  final String value;
}
