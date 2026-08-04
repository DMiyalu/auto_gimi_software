import '../../../../core/domain/app_currency.dart';

/// Une ligne imprimée sur le ticket (service, produit...).
class InvoiceTicketLine {
  const InvoiceTicketLine({
    required this.label,
    required this.quantity,
    required this.unitPrice,
    required this.lineAmount,
  });

  final String label;
  final int quantity;
  final double unitPrice;
  final double lineAmount;
}

/// Données génériques d'une facture à imprimer — indépendantes du module
/// métier d'origine (prestation garage ou commande restaurant).
class InvoiceTicketData {
  const InvoiceTicketData({
    required this.establishmentName,
    this.establishmentPhone,
    required this.reference,
    required this.date,
    this.clientName,
    this.clientPhone,
    this.vehicleLabel,
    required this.lines,
    required this.totalAmount,
    this.paidAmount,
    this.balanceDue,
    required this.currency,
    this.statusLabel,
  });

  final String establishmentName;
  final String? establishmentPhone;
  final String reference;
  final DateTime date;
  final String? clientName;
  final String? clientPhone;
  final String? vehicleLabel;
  final List<InvoiceTicketLine> lines;
  final double totalAmount;
  final double? paidAmount;
  final double? balanceDue;
  final AppCurrency currency;
  final String? statusLabel;
}
