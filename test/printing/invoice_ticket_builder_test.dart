import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/features/printing/data/services/invoice_ticket_builder.dart';
import 'package:auto_mobile_software/features/printing/domain/entities/invoice_ticket_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('facture : entête/pied configurés, accents et signature Zuri', () async {
    final bytes = await const InvoiceTicketBuilder().build(
      InvoiceTicketData(
        establishmentName: 'Le Goût Parfait',
        establishmentPhone: '+243900000000',
        headerLines: const [
          'Ouvert 7j/7',
          'Livraison à Kinshasa',
          'Spécialité: chèvre braisée',
        ],
        footerLines: const ['Merci !', 'À bientôt'],
        reference: 'FAC-001',
        date: DateTime(2026, 6, 6, 12, 30),
        clientName: 'Grâce',
        lines: const [
          InvoiceTicketLine(
            label: 'Poulet braisé',
            quantity: 2,
            unitPrice: 10000,
            lineAmount: 20000,
          ),
        ],
        totalAmount: 20000,
        currency: AppCurrency.cdf,
      ),
    );

    final printable = _printableText(bytes);
    expect(printable, contains('Le Goût Parfait'));
    expect(printable, isNot(contains('+243900000000')));
    expect(printable, contains('Ouvert 7j/7'));
    expect(printable, contains('Livraison à Kinshasa'));
    expect(printable, contains('Spécialité: chèvre braisée'));
    expect(printable, contains('Client : Grâce'));
    expect(printable, contains('Poulet braisé'));
    expect(printable, contains('TOTAL'));
    expect(printable, contains('Merci !'));
    expect(printable, contains('À bientôt'));
    expect(printable, contains('Powered by Zuri Business Inc.'));
    expect(printable, isNot(contains('Merci de votre confiance !')));
  });
}

String _printableText(List<int> bytes) {
  final textBytes = bytes.where((b) => b >= 32 && b != 127).toList();
  return latin1.decode(textBytes, allowInvalid: true);
}
