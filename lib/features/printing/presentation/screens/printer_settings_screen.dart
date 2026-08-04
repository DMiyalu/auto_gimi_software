import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/bluetooth_printer_device.dart';
import '../providers/printer_providers.dart';

class PrinterSettingsScreen extends ConsumerWidget {
  const PrinterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printers = ref.watch(pairedBluetoothPrintersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuration imprimante')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(pairedBluetoothPrintersProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              const _BluetoothGuideCard(),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Imprimantes Bluetooth',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF101529),
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Actualiser',
                    onPressed: () =>
                        ref.invalidate(pairedBluetoothPrintersProvider),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              printers.when(
                loading: () => const _LoadingPrinters(),
                error: (error, _) => _PrinterError(message: error.toString()),
                data: (devices) {
                  if (devices.isEmpty) return const _NoPrinterFound();
                  final sorted = [...devices]
                    ..sort((a, b) {
                      if (a.isLikelyPrinter != b.isLikelyPrinter) {
                        return a.isLikelyPrinter ? -1 : 1;
                      }
                      return a.name.toLowerCase().compareTo(
                        b.name.toLowerCase(),
                      );
                    });
                  return Column(
                    children: [
                      for (final device in sorted) ...[
                        _PrinterTile(device: device),
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BluetoothGuideCard extends StatelessWidget {
  const _BluetoothGuideCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.violetPrincipal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.violetPrincipal.withValues(alpha: 0.16),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.violetPrincipal,
                foregroundColor: Colors.white,
                child: Icon(Icons.print_outlined),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Connectez votre imprimante thermique',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF101529),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _GuideStep(
            icon: Icons.bluetooth_connected_outlined,
            text: 'Activez le Bluetooth du téléphone.',
          ),
          SizedBox(height: 10),
          _GuideStep(
            icon: Icons.settings_bluetooth_outlined,
            text:
                'Associez l’imprimante dans les paramètres Bluetooth du device.',
          ),
          SizedBox(height: 10),
          _GuideStep(
            icon: Icons.refresh_rounded,
            text: 'Revenez ici puis actualisez la liste.',
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.violetPrincipal),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5C637D),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrinterTile extends StatelessWidget {
  const _PrinterTile({required this.device});

  final BluetoothPrinterDevice device;

  @override
  Widget build(BuildContext context) {
    final printerColor = device.isLikelyPrinter
        ? AppColors.violetPrincipal
        : const Color(0xFF707792);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: printerColor.withValues(alpha: 0.12),
            foregroundColor: printerColor,
            child: Icon(
              device.isLikelyPrinter
                  ? Icons.local_printshop_outlined
                  : Icons.bluetooth_outlined,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF101529),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  device.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF707792),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusBadge(
            label: device.isConnected ? 'Connectée' : 'Appairée',
            active: device.isConnected,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active
            ? AppColors.violetPrincipal.withValues(alpha: 0.12)
            : const Color(0xFFF4F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.violetPrincipal : const Color(0xFF707792),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _LoadingPrinters extends StatelessWidget {
  const _LoadingPrinters();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 34),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _NoPrinterFound extends StatelessWidget {
  const _NoPrinterFound();

  @override
  Widget build(BuildContext context) {
    return const _MessagePanel(
      icon: Icons.print_disabled_outlined,
      title: 'Aucune imprimante détectée',
      message:
          'Associez une imprimante thermique dans les paramètres Bluetooth, puis actualisez cette page.',
    );
  }
}

class _PrinterError extends StatelessWidget {
  const _PrinterError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _MessagePanel(
      icon: Icons.bluetooth_disabled_outlined,
      title: 'Bluetooth indisponible',
      message: message,
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8EF)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFF707792)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF101529),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF707792),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
