import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/bluetooth_printer_service.dart';
import '../../data/services/invoice_printer_service.dart';
import '../../domain/entities/bluetooth_printer_device.dart';

final bluetoothPrinterServiceProvider = Provider<BluetoothPrinterService>((
  ref,
) {
  return const BluetoothPrinterService();
});

final invoicePrinterServiceProvider = Provider<InvoicePrinterService>((ref) {
  return InvoicePrinterService(
    bluetoothService: ref.watch(bluetoothPrinterServiceProvider),
  );
});

final pairedBluetoothPrintersProvider =
    FutureProvider.autoDispose<List<BluetoothPrinterDevice>>((ref) {
      return ref.watch(bluetoothPrinterServiceProvider).searchDevices();
    });

final currentPrinterStatusProvider = FutureProvider<PrinterConnectionStatus>((
  ref,
) async {
  final service = ref.watch(bluetoothPrinterServiceProvider);
  final address = await service.selectedPrinterAddress();
  final name = await service.selectedPrinterName();
  final connected = address != null && await service.isConnected();
  return PrinterConnectionStatus(
    selectedAddress: address,
    selectedName: name,
    connected: connected,
  );
});

class PrinterConnectionStatus {
  const PrinterConnectionStatus({
    required this.selectedAddress,
    required this.selectedName,
    required this.connected,
  });

  final String? selectedAddress;
  final String? selectedName;
  final bool connected;

  bool get hasSelectedPrinter =>
      selectedAddress != null && selectedAddress!.isNotEmpty;

  bool get canPrint => hasSelectedPrinter && connected;
}
