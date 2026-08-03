import '../../../../core/domain/app_currency.dart';

class PaiementEntity {
  const PaiementEntity({
    required this.id,
    required this.factureId,
    required this.method,
    required this.amount,
    required this.currency,
    required this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String factureId;
  final PaymentMethod method;
  final double amount;
  final AppCurrency currency;
  final DateTime paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum PaymentMethod {
  cash('cash', 'Cash'),
  mobileMoney('mobile_money', 'Mobile money'),
  card('carte', 'Carte'),
  transfer('virement', 'Virement');

  const PaymentMethod(this.value, this.label);

  final String value;
  final String label;

  static PaymentMethod fromValue(String? value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}
