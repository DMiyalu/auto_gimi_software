import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/bluetooth_printer_device.dart';

class BluetoothPrinterService {
  const BluetoothPrinterService();

  static const _channel = MethodChannel('zolana/printers');
  static const _selectedPrinterNameKey = 'selected_printer_name';
  static const _selectedPrinterAddressKey = 'selected_printer_address';

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

  Future<List<BluetoothPrinterDevice>> pairedDevices() async {
    try {
      final result = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'pairedBluetoothDevices',
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

  Future<String?> selectedPrinterAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedPrinterAddressKey);
  }

  Future<void> saveSelectedPrinter(BluetoothPrinterDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedPrinterNameKey, device.name);
    await prefs.setString(_selectedPrinterAddressKey, device.address);
  }
}

class BluetoothPrinterException implements Exception {
  const BluetoothPrinterException(this.message);

  final String message;

  @override
  String toString() => message;
}
