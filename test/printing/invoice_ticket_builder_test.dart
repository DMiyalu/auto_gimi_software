import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/features/printing/data/services/invoice_ticket_builder.dart';
import 'package:auto_mobile_software/features/printing/domain/entities/invoice_ticket_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('facture : logo absent => nom, en-têtes, pieds et signature Zuri', () async {
    final bytes = await const InvoiceTicketBuilder().build(
      InvoiceTicketData(
        establishmentName: 'Le Goût Parfait',
        establishmentPhone: '+243900000000',
        headerLines: const ['Ouvert 7j/7', 'Livraison OK'],
        footerLines: const ['Merci !', 'A bientôt'],
        reference: 'FAC-001',
        date: DateTime(2026, 6, 6, 12, 30),
        clientName: 'Amina',
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

    final printable = String.fromCharCodes(
      bytes.where((b) => b >= 32 && b < 127),
    );
    expect(printable, contains('Parfait'));
    expect(printable, contains('Ouvert 7j/7'));
    expect(printable, contains('Livraison OK'));
    expect(printable, contains('Poulet'));
    expect(printable, contains('TOTAL'));
    expect(printable, contains('Merci !'));
    expect(printable, contains('Powered by Zuri Business Inc.'));
    expect(printable, isNot(contains('Merci de votre confiance !')));
  });
}
