import 'package:flutter/services.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
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

  Future<String?> selectedPrinterName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedPrinterNameKey);
  }

  Future<void> saveSelectedPrinter(BluetoothPrinterDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedPrinterNameKey, device.name);
    await prefs.setString(_selectedPrinterAddressKey, device.address);
  }

  /// Bluetooth activé sur le device (requis avant toute connexion).
  Future<bool> isBluetoothEnabled() => PrintBluetoothThermal.bluetoothEnabled;

  /// État réel de la connexion socket avec l'imprimante (pas seulement
  /// l'appairage système) — c'est ce qui garantit qu'une impression aboutira.
  Future<bool> isConnected() => PrintBluetoothThermal.connectionStatus;

  Future<bool> connect(String macAddress) {
    return PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  Future<bool> disconnectPrinter() => PrintBluetoothThermal.disconnect;

  Future<bool> sendBytes(List<int> bytes) {
    return PrintBluetoothThermal.writeBytes(bytes);
  }

  /// Vérifie qu'une connexion effective existe avec l'imprimante
  /// sélectionnée, en se (re)connectant si nécessaire. Lève une
  /// [BluetoothPrinterException] explicite à chaque étape qui peut échouer
  /// (aucune imprimante choisie, Bluetooth désactivé, imprimante injoignable)
  /// afin que l'UI puisse afficher un message actionnable.
  Future<void> ensureConnectedToSelectedPrinter() async {
    final address = await selectedPrinterAddress();
    if (address == null || address.isEmpty) {
      throw const BluetoothPrinterException(
        'Aucune imprimante sélectionnée. Configurez-la dans les paramètres.',
      );
    }

    if (await isConnected()) return;

    if (!await isBluetoothEnabled()) {
      throw const BluetoothPrinterException(
        'Le Bluetooth est désactivé. Activez-le puis réessayez.',
      );
    }

    final connected = await connect(address);
    if (!connected) {
      final name = await selectedPrinterName();
      throw BluetoothPrinterException(
        'Connexion à ${name ?? "l’imprimante"} impossible. '
        'Vérifiez qu’elle est allumée et à proximité.',
      );
    }
  }
}

class BluetoothPrinterException implements Exception {
  const BluetoothPrinterException(this.message);

  final String message;

  @override
  String toString() => message;
}
