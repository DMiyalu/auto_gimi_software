import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';

import '../../../establishment/presentation/utils/establishment_logo_codec.dart';
import '../../domain/entities/invoice_ticket_data.dart';

/// Génère les octets ESC/POS d'un ticket de facture pour une imprimante
/// thermique 58mm, à partir de données génériques [InvoiceTicketData].
class InvoiceTicketBuilder {
  const InvoiceTicketBuilder();

  static const poweredBy = 'Powered by Zuri Business Inc.';

  static final _amountFormat = NumberFormat('#,##0.##');
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  Future<List<int>> build(InvoiceTicketData data) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    bytes.addAll(generator.setGlobalCodeTable('CP1252'));

    final logo = EstablishmentLogoCodec.decodeForPrint(data.logoBase64);
    if (logo != null) {
      bytes.addAll(generator.image(logo));
      bytes.addAll(generator.feed(1));
    } else {
      bytes.addAll(
        generator.text(
          _escPosText(data.establishmentName),
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
      );
    }

    for (final line in data.headerLines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      bytes.addAll(
        generator.text(
          _escPosText(trimmed),
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
    }

    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.text(
        _escPosText('Facture ${data.reference}'),
        styles: const PosStyles(bold: true),
      ),
    );
    bytes.addAll(generator.text(_dateFormat.format(data.date)));
    if (data.clientName != null && data.clientName!.isNotEmpty) {
      bytes.addAll(generator.text(_escPosText('Client : ${data.clientName}')));
    }
    if (data.clientPhone != null && data.clientPhone!.isNotEmpty) {
      bytes.addAll(generator.text(_escPosText('Tél : ${data.clientPhone}')));
    }
    if (data.vehicleLabel != null && data.vehicleLabel!.isNotEmpty) {
      bytes.addAll(
        generator.text(_escPosText('Véhicule : ${data.vehicleLabel}')),
      );
    }
    bytes.addAll(generator.hr());

    for (final line in data.lines) {
      bytes.addAll(
        generator.text(
          _escPosText(line.label),
          styles: const PosStyles(bold: true),
        ),
      );
      final qtyPrice = line.quantity > 1
          ? '${line.quantity} x ${_amountFormat.format(line.unitPrice)}'
          : _amountFormat.format(line.unitPrice);
      bytes.addAll(
        generator.row([
          PosColumn(text: _escPosText(qtyPrice), width: 6),
          PosColumn(
            text: _escPosText(
              '${_amountFormat.format(line.lineAmount)} ${data.currency.symbol}',
            ),
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
          text: _escPosText('TOTAL'),
          width: 6,
          styles: const PosStyles(bold: true, height: PosTextSize.size2),
        ),
        PosColumn(
          text: _escPosText(
            '${_amountFormat.format(data.totalAmount)} ${data.currency.symbol}',
          ),
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
          PosColumn(text: _escPosText('Payé'), width: 6),
          PosColumn(
            text: _escPosText(
              '${_amountFormat.format(data.paidAmount)} ${data.currency.symbol}',
            ),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }
    if (data.balanceDue != null) {
      bytes.addAll(
        generator.row([
          PosColumn(
            text: _escPosText('Solde'),
            width: 6,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: _escPosText(
              '${_amountFormat.format(data.balanceDue)} ${data.currency.symbol}',
            ),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]),
      );
    }
    if (data.statusLabel != null && data.statusLabel!.isNotEmpty) {
      bytes.addAll(
        generator.text(
          _escPosText(data.statusLabel!),
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
    }

    final footerLines = data.footerLines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (footerLines.isNotEmpty) {
      bytes.addAll(generator.hr());
      for (final line in footerLines) {
        bytes.addAll(
          generator.text(
            _escPosText(line),
            styles: const PosStyles(align: PosAlign.center),
          ),
        );
      }
    }

    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.text(
        _escPosText(poweredBy),
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    return bytes;
  }

  static String _escPosText(String value) {
    return value
        .replaceAll('\u00A0', ' ')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('…', '...')
        .replaceAll('œ', 'oe')
        .replaceAll('Œ', 'OE');
  }
}
