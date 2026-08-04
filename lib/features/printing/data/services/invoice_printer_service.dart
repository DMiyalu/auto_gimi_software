import '../../domain/entities/invoice_ticket_data.dart';
import 'bluetooth_printer_service.dart';
import 'invoice_ticket_builder.dart';

/// Orchestre l'impression d'une facture : vérifie/établit la connexion à
/// l'imprimante Bluetooth sélectionnée, génère le ticket ESC/POS puis
/// l'envoie.
class InvoicePrinterService {
  const InvoicePrinterService({
    required BluetoothPrinterService bluetoothService,
    InvoiceTicketBuilder ticketBuilder = const InvoiceTicketBuilder(),
  }) : _bluetoothService = bluetoothService,
       _ticketBuilder = ticketBuilder;

  final BluetoothPrinterService _bluetoothService;
  final InvoiceTicketBuilder _ticketBuilder;

  Future<void> printInvoice(InvoiceTicketData data) async {
    await _bluetoothService.ensureConnectedToSelectedPrinter();
    final bytes = await _ticketBuilder.build(data);
    final sent = await _bluetoothService.sendBytes(bytes);
    if (!sent) {
      throw const BluetoothPrinterException(
        'L’imprimante n’a pas confirmé la réception du ticket.',
      );
    }
  }
}
