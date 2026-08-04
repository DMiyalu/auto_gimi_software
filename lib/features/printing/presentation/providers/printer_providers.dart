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
