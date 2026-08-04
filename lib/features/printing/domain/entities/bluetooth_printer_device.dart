class BluetoothPrinterDevice {
  const BluetoothPrinterDevice({
    required this.name,
    required this.address,
    required this.source,
    required this.isLikelyPrinter,
    required this.isConnected,
  });

  final String name;
  final String address;
  final String source;
  final bool isLikelyPrinter;
  final bool isConnected;

  factory BluetoothPrinterDevice.fromMap(Map<dynamic, dynamic> map) {
    return BluetoothPrinterDevice(
      name: map['name'] as String? ?? 'Imprimante sans nom',
      address: map['address'] as String? ?? '',
      source: map['source'] as String? ?? 'Bluetooth',
      isLikelyPrinter: map['isLikelyPrinter'] as bool? ?? false,
      isConnected: map['isConnected'] as bool? ?? false,
    );
  }
}
