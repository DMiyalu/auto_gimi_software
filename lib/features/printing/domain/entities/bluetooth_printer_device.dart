class BluetoothPrinterDevice {
  const BluetoothPrinterDevice({
    required this.name,
    required this.address,
    required this.isLikelyPrinter,
    required this.isConnected,
  });

  final String name;
  final String address;
  final bool isLikelyPrinter;
  final bool isConnected;

  factory BluetoothPrinterDevice.fromMap(Map<dynamic, dynamic> map) {
    return BluetoothPrinterDevice(
      name: map['name'] as String? ?? 'Imprimante sans nom',
      address: map['address'] as String? ?? '',
      isLikelyPrinter: map['isLikelyPrinter'] as bool? ?? false,
      isConnected: map['isConnected'] as bool? ?? false,
    );
  }
}
