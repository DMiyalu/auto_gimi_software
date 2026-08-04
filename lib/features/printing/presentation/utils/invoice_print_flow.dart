import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../data/services/bluetooth_printer_service.dart';
import '../../domain/entities/invoice_ticket_data.dart';
import '../providers/printer_providers.dart';

/// Imprime un ticket de facture sur l'imprimante Bluetooth sélectionnée,
/// avec un dialogue de progression puis un snackbar de résultat. Si aucune
/// imprimante n'est configurée, propose de rejoindre les paramètres.
Future<void> printInvoiceTicket(
  BuildContext context,
  WidgetRef ref,
  InvoiceTicketData data,
) async {
  final messenger = ScaffoldMessenger.of(context);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _PrintingDialog(),
  );

  String? errorMessage;
  var offerPrinterSettings = false;

  try {
    await ref.read(invoicePrinterServiceProvider).printInvoice(data);
  } on BluetoothPrinterException catch (error) {
    errorMessage = error.message;
    offerPrinterSettings = error.message.contains('Aucune imprimante');
  } catch (error) {
    errorMessage = 'Impression impossible : $error';
  }

  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();

  if (errorMessage == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Facture envoyée à l’imprimante.')),
    );
    return;
  }

  messenger.showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      action: offerPrinterSettings
          ? SnackBarAction(
              label: 'Configurer',
              onPressed: () => context.push(Routes.printerSettings),
            )
          : null,
    ),
  );
}

class _PrintingDialog extends StatelessWidget {
  const _PrintingDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              SizedBox(width: 16),
              Text('Impression en cours...'),
            ],
          ),
        ),
      ),
    );
  }
}
