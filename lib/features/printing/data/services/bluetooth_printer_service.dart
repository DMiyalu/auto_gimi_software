import 'package:flutter/services.dart';

import '../../domain/entities/bluetooth_printer_device.dart';

class BluetoothPrinterService {
  const BluetoothPrinterService();

  static const _channel = MethodChannel('zolana/printers');

  Future<List<BluetoothPrinterDevice>> searchDevices() async {
    try {
      final result = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'scanBluetoothDevices',
      );
      return (result ?? const []).map(BluetoothPrinterDevice.fromMap).toList();
    } on MissingPluginException {
      return const [];
    } on PlatformException catch (error) {
      throw BluetoothPrinterException(error.message ?? error.code);
    }
  }

  Future<void> openBluetoothSettings() async {
    try {
      await _channel.invokeMethod<void>('openBluetoothSettings');
    } on MissingPluginException {
      return;
    } on PlatformException catch (error) {
      throw BluetoothPrinterException(error.message ?? error.code);
    }
  }
}

class BluetoothPrinterException implements Exception {
  const BluetoothPrinterException(this.message);

  final String message;

  @override
  String toString() => message;
}
