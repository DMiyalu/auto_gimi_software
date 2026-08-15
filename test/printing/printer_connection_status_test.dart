import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/features/printing/presentation/providers/printer_providers.dart';

void main() {
  group('PrinterConnectionStatus', () {
    test(
      'autorise impression seulement si imprimante sélectionnée et connectée',
      () {
        expect(
          const PrinterConnectionStatus(
            selectedAddress: null,
            selectedName: null,
            connected: false,
          ).canPrint,
          isFalse,
        );
        expect(
          const PrinterConnectionStatus(
            selectedAddress: '00:11:22:AA:BB:CC',
            selectedName: 'MP210',
            connected: false,
          ).canPrint,
          isFalse,
        );
        expect(
          const PrinterConnectionStatus(
            selectedAddress: '00:11:22:AA:BB:CC',
            selectedName: 'MP210',
            connected: true,
          ).canPrint,
          isTrue,
        );
      },
    );
  });
}
