import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/bluetooth_printer_service.dart';
import '../../domain/entities/invoice_ticket_data.dart';
import '../providers/printer_providers.dart';

/// Affiche un popup montrant l'imprimante actuellement connectée et demande
/// confirmation avant d'imprimer. Retourne `true` si l'utilisateur a
/// confirmé l'impression, `false` s'il a annulé.
Future<bool> confirmPrintInvoice(BuildContext context, WidgetRef ref) async {
  final service = ref.read(bluetoothPrinterServiceProvider);
  final name = await service.selectedPrinterName();
  final address = await service.selectedPrinterAddress();
  final connected = address != null && await service.isConnected();

  if (!context.mounted) return false;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => _PrintConfirmationDialog(
      printerName: name,
      hasPrinter: address != null,
      connected: connected,
    ),
  );
  return confirmed ?? false;
}

/// Imprime un ticket de facture sur l'imprimante Bluetooth sélectionnée,
/// avec un dialogue de progression puis un snackbar de résultat. Si aucune
/// imprimante n'est configurée, propose de rejoindre les paramètres.
/// Retourne `true` si l'impression a abouti.
Future<bool> printInvoiceTicket(
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

  if (!context.mounted) return errorMessage == null;
  Navigator.of(context, rootNavigator: true).pop();

  if (errorMessage == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Facture envoyée à l’imprimante.')),
    );
    return true;
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
  return false;
}

class _PrintConfirmationDialog extends StatelessWidget {
  const _PrintConfirmationDialog({
    required this.printerName,
    required this.hasPrinter,
    required this.connected,
  });

  final String? printerName;
  final bool hasPrinter;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final statusColor = !hasPrinter
        ? const Color(0xFF707792)
        : connected
        ? AppColors.violetPrincipal
        : const Color(0xFFEF2E2E);
    final statusText = !hasPrinter
        ? 'Aucune imprimante configurée.'
        : connected
        ? '${printerName ?? "Imprimante"} — connectée'
        : '${printerName ?? "Imprimante"} — non connectée actuellement';
    final helperText = !hasPrinter
        ? 'Configurez une imprimante dans les paramètres pour pouvoir imprimer.'
        : connected
        ? null
        : 'Elle sera contactée automatiquement au moment de l’impression. Vérifiez qu’elle est allumée et à proximité.';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Imprimer la facture'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: statusColor.withValues(alpha: 0.14),
                foregroundColor: statusColor,
                child: Icon(
                  hasPrinter && connected
                      ? Icons.print_rounded
                      : Icons.print_disabled_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (helperText != null) ...[
            const SizedBox(height: 10),
            Text(
              helperText,
              style: const TextStyle(color: Color(0xFF707792), fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        if (!hasPrinter)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              context.push(Routes.printerSettings);
            },
            child: const Text('Configurer'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        if (hasPrinter)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Imprimer'),
          ),
      ],
    );
  }
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
