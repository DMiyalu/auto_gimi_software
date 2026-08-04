import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/invoice_ticket_data.dart';

/// Génère les octets ESC/POS d'un ticket de facture pour une imprimante
/// thermique 58mm, à partir de données génériques [InvoiceTicketData].
class InvoiceTicketBuilder {
  const InvoiceTicketBuilder();

  static final _amountFormat = NumberFormat('#,##0.##');
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  Future<List<int>> build(InvoiceTicketData data) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    bytes.addAll(
      generator.text(
        data.establishmentName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    if (data.establishmentPhone != null &&
        data.establishmentPhone!.isNotEmpty) {
      bytes.addAll(
        generator.text(
          data.establishmentPhone!,
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
    }

    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.text('Facture ${data.reference}', styles: const PosStyles(bold: true)),
    );
    bytes.addAll(generator.text(_dateFormat.format(data.date)));
    if (data.clientName != null && data.clientName!.isNotEmpty) {
      bytes.addAll(generator.text('Client : ${data.clientName}'));
    }
    if (data.clientPhone != null && data.clientPhone!.isNotEmpty) {
      bytes.addAll(generator.text('Tél : ${data.clientPhone}'));
    }
    if (data.vehicleLabel != null && data.vehicleLabel!.isNotEmpty) {
      bytes.addAll(generator.text('Véhicule : ${data.vehicleLabel}'));
    }
    bytes.addAll(generator.hr());

    for (final line in data.lines) {
      bytes.addAll(generator.text(line.label, styles: const PosStyles(bold: true)));
      final qtyPrice = line.quantity > 1
          ? '${line.quantity} x ${_amountFormat.format(line.unitPrice)}'
          : _amountFormat.format(line.unitPrice);
      bytes.addAll(
        generator.row([
          PosColumn(text: qtyPrice, width: 6),
          PosColumn(
            text: '${_amountFormat.format(line.lineAmount)} ${data.currency.symbol}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }

    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.row([
        PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: const PosStyles(bold: true, height: PosTextSize.size2),
        ),
        PosColumn(
          text: '${_amountFormat.format(data.totalAmount)} ${data.currency.symbol}',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      ]),
    );

    if (data.paidAmount != null) {
      bytes.addAll(
        generator.row([
          PosColumn(text: 'Payé', width: 6),
          PosColumn(
            text: '${_amountFormat.format(data.paidAmount)} ${data.currency.symbol}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }
    if (data.balanceDue != null) {
      bytes.addAll(
        generator.row([
          PosColumn(text: 'Solde', width: 6, styles: const PosStyles(bold: true)),
          PosColumn(
            text: '${_amountFormat.format(data.balanceDue)} ${data.currency.symbol}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]),
      );
    }
    if (data.statusLabel != null && data.statusLabel!.isNotEmpty) {
      bytes.addAll(
        generator.text(
          data.statusLabel!,
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
    }

    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.text(
        'Merci de votre confiance !',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    return bytes;
  }
}
