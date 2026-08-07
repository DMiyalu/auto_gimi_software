import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/bluetooth_printer_device.dart';
import '../providers/printer_providers.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() =>
      _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  var _devices = const <BluetoothPrinterDevice>[];
  var _isSearching = false;
  var _hasSearched = false;
  String? _selectedAddress;
  String? _selectedName;
  String? _errorMessage;
  String? _verifiedAddress;
  var _testingConnection = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedPrinter();
  }

  Future<void> _loadSelectedPrinter() async {
    final service = ref.read(bluetoothPrinterServiceProvider);
    final address = await service.selectedPrinterAddress();
    final name = await service.selectedPrinterName();
    if (!mounted) return;
    setState(() {
      _selectedAddress = address;
      _selectedName = name;
    });

    if (address == null) return;
    // Vérifie l'état réel de la connexion (sans tenter de reconnecter) pour
    // savoir si l'imprimante est effectivement connectée à l'application.
    final connected = await service.isConnected();
    if (!mounted) return;
    if (connected) setState(() => _verifiedAddress = address);
  }

  Future<void> _searchPrinters() async {
    if (_isSearching) return;
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      final devices = await ref
          .read(bluetoothPrinterServiceProvider)
          .searchDevices()
          .timeout(
            const Duration(seconds: 18),
            onTimeout: () {
              throw TimeoutException(
                'La recherche Bluetooth prend trop de temps. Vérifiez que le Bluetooth est activé, puis réessayez.',
              );
            },
          );
      if (!mounted) return;
      setState(() {
        _devices = _sortDevices(devices);
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isSearching = false;
      });
    }
  }

  Future<void> _openBluetoothSettings() {
    return ref.read(bluetoothPrinterServiceProvider).openBluetoothSettings();
  }

  Future<void> _loadPairedPrinters() async {
    if (_isSearching) return;
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final devices = await ref
          .read(bluetoothPrinterServiceProvider)
          .pairedDevices()
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              throw TimeoutException(
                'La lecture des appareils appairés prend trop de temps. Ouvrez Bluetooth, associez le MP210, puis revenez ici.',
              );
            },
          );
      if (!mounted) return;
      setState(() {
        _devices = _sortDevices(devices);
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isSearching = false;
      });
    }
  }

  Future<void> _selectPrinter(BluetoothPrinterDevice device) async {
    await ref.read(bluetoothPrinterServiceProvider).saveSelectedPrinter(device);
    if (!mounted) return;
    setState(() {
      _selectedAddress = device.address;
      _selectedName = device.name;
      _verifiedAddress = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${device.name} sélectionnée pour les factures.')),
    );
    await _testConnection();
  }

  /// Établit (ou vérifie) une vraie connexion socket avec l'imprimante
  /// sélectionnée via print_bluetooth_thermal — l'appairage Bluetooth seul
  /// ne garantit pas qu'une impression aboutira.
  Future<void> _testConnection() async {
    final address = _selectedAddress;
    if (address == null || _testingConnection) return;

    setState(() => _testingConnection = true);
    final service = ref.read(bluetoothPrinterServiceProvider);
    try {
      await service.ensureConnectedToSelectedPrinter();
      if (!mounted) return;
      final name = await service.selectedPrinterName();
      if (!mounted) return;
      setState(() => _verifiedAddress = address);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${name ?? "Imprimante"} connectée avec succès.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        if (_verifiedAddress == address) _verifiedAddress = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _testingConnection = false);
    }
  }

  Future<void> _disconnectPrinter() async {
    final address = _selectedAddress;
    if (address == null) return;
    await ref.read(bluetoothPrinterServiceProvider).disconnectPrinter();
    if (!mounted) return;
    setState(() {
      if (_verifiedAddress == address) _verifiedAddress = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Imprimante déconnectée.')));
  }

  Future<void> _showManualPrinterDialog() async {
    final nameController = TextEditingController(text: 'MP210');
    final addressController = TextEditingController();
    final device = await showDialog<BluetoothPrinterDevice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une imprimante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse MAC',
                hintText: '00:11:22:AA:BB:CC',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final address = addressController.text.trim().toUpperCase();
              if (address.isEmpty) return;
              Navigator.pop(
                context,
                BluetoothPrinterDevice(
                  name: nameController.text.trim().isEmpty
                      ? 'MP210'
                      : nameController.text.trim(),
                  address: address,
                  source: 'Manuelle',
                  isLikelyPrinter: true,
                  isConnected: false,
                ),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    nameController.dispose();
    addressController.dispose();
    if (device == null) return;

    final merged = {
      for (final item in _devices) item.address: item,
      device.address: device,
    }.values.toList();
    setState(() => _devices = _sortDevices(merged));
    await _selectPrinter(device);
  }

  List<BluetoothPrinterDevice> _sortDevices(
    List<BluetoothPrinterDevice> devices,
  ) {
    return [...devices]..sort((a, b) {
      if (a.isLikelyPrinter != b.isLikelyPrinter) {
        return a.isLikelyPrinter ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration imprimante')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _searchPrinters,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              _ConnectedPrinterCard(
                name: _selectedName,
                address: _selectedAddress,
                connected:
                    _selectedAddress != null &&
                    _verifiedAddress == _selectedAddress,
                testing: _testingConnection,
                onTest: _testConnection,
                onDisconnect: _disconnectPrinter,
              ),
              const SizedBox(height: 18),
              const _BluetoothGuideCard(),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recherche imprimante',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF101529),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _isSearching ? null : _searchPrinters,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search_rounded),
                    label: Text(_isSearching ? 'Recherche...' : 'Rechercher'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isSearching ? null : _loadPairedPrinters,
                    icon: const Icon(Icons.bluetooth_connected_outlined),
                    label: const Text('Appareils appairés'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isSearching ? null : _openBluetoothSettings,
                    icon: const Icon(Icons.settings_bluetooth_outlined),
                    label: const Text('Ouvrir Bluetooth'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isSearching ? null : _showManualPrinterDialog,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Ajouter manuellement'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _PrinterSearchResult(
                  key: ValueKey(
                    '${_isSearching}_${_hasSearched}_${_errorMessage}_${_devices.length}',
                  ),
                  hasSearched: _hasSearched,
                  isSearching: _isSearching,
                  errorMessage: _errorMessage,
                  devices: _devices,
                  selectedAddress: _selectedAddress,
                  verifiedAddress: _verifiedAddress,
                  testingConnection: _testingConnection,
                  onRetry: _searchPrinters,
                  onLoadPaired: _loadPairedPrinters,
                  onOpenBluetoothSettings: _openBluetoothSettings,
                  onManualAdd: _showManualPrinterDialog,
                  onSelect: _selectPrinter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrinterSearchResult extends StatelessWidget {
  const _PrinterSearchResult({
    super.key,
    required this.hasSearched,
    required this.isSearching,
    required this.errorMessage,
    required this.devices,
    required this.selectedAddress,
    required this.verifiedAddress,
    required this.testingConnection,
    required this.onRetry,
    required this.onLoadPaired,
    required this.onOpenBluetoothSettings,
    required this.onManualAdd,
    required this.onSelect,
  });

  final bool hasSearched;
  final bool isSearching;
  final String? errorMessage;
  final List<BluetoothPrinterDevice> devices;
  final String? selectedAddress;
  final String? verifiedAddress;
  final bool testingConnection;
  final VoidCallback onRetry;
  final VoidCallback onLoadPaired;
  final VoidCallback onOpenBluetoothSettings;
  final VoidCallback onManualAdd;
  final ValueChanged<BluetoothPrinterDevice> onSelect;

  @override
  Widget build(BuildContext context) {
    if (isSearching) return const _SearchingPrinters();
    if (errorMessage != null) {
      return _PrinterError(
        message: errorMessage!,
        onRetry: onRetry,
        onOpenBluetoothSettings: onOpenBluetoothSettings,
      );
    }
    if (!hasSearched) {
      return _MessagePanel(
        icon: Icons.bluetooth_searching_rounded,
        title: 'Prêt à rechercher',
        message:
            'Touchez Rechercher pour demander les autorisations Bluetooth et détecter les imprimantes proches.',
        primaryActionLabel: 'Rechercher',
        onPrimaryAction: onRetry,
        secondaryActions: [
          _MessageAction(
            label: 'Appairer MP210',
            icon: Icons.settings_bluetooth_outlined,
            onTap: onOpenBluetoothSettings,
          ),
          _MessageAction(
            label: 'Ajouter manuellement',
            icon: Icons.edit_outlined,
            onTap: onManualAdd,
          ),
        ],
      );
    }
    if (devices.isEmpty) {
      return _NoPrinterFound(
        onRetry: onRetry,
        onLoadPaired: onLoadPaired,
        onOpenBluetoothSettings: onOpenBluetoothSettings,
        onManualAdd: onManualAdd,
      );
    }

    return Column(
      children: [
        for (final device in devices) ...[
          _PrinterTile(
            device: device,
            selected: device.address == selectedAddress,
            verified: device.address == verifiedAddress,
            testing: testingConnection && device.address == selectedAddress,
            onSelect: () => onSelect(device),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ConnectedPrinterCard extends StatelessWidget {
  const _ConnectedPrinterCard({
    required this.name,
    required this.address,
    required this.connected,
    required this.testing,
    required this.onTest,
    required this.onDisconnect,
  });

  final String? name;
  final String? address;
  final bool connected;
  final bool testing;
  final VoidCallback onTest;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E8EF)),
        ),
        child: const Row(
          children: [
            Icon(Icons.print_disabled_outlined, color: Color(0xFF707792)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucune imprimante connectée à l’application pour le moment.',
                style: TextStyle(
                  color: Color(0xFF5C637D),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final statusColor = connected
        ? AppColors.violetPrincipal
        : const Color(0xFFEF2E2E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: statusColor.withValues(alpha: 0.14),
            foregroundColor: statusColor,
            child: Icon(
              connected ? Icons.print_rounded : Icons.print_disabled_outlined,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'Imprimante',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF101529),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  testing
                      ? 'Vérification de la connexion...'
                      : connected
                      ? 'Connectée à l’application'
                      : 'Non connectée actuellement',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (testing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (connected)
            IconButton(
              tooltip: 'Déconnecter',
              onPressed: onDisconnect,
              icon: const Icon(Icons.link_off_rounded),
              color: statusColor,
            )
          else
            IconButton(
              tooltip: 'Tester la connexion',
              onPressed: onTest,
              icon: const Icon(Icons.refresh_rounded),
              color: statusColor,
            ),
        ],
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
  const _PrinterTile({
    required this.device,
    required this.selected,
    required this.verified,
    required this.testing,
    required this.onSelect,
  });

  final BluetoothPrinterDevice device;
  final bool selected;
  final bool verified;
  final bool testing;
  final VoidCallback onSelect;

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
                  '${device.source} • ${device.address}',
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
            label: testing
                ? 'Vérification...'
                : selected && verified
                ? 'Connectée ✅'
                : selected
                ? 'Sélectionnée'
                : device.isConnected
                ? 'Connectée'
                : 'Choisir',
            active: selected || device.isConnected,
            onTap: selected ? null : onSelect,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.active, this.onTap});

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: DecoratedBox(
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
              color: active
                  ? AppColors.violetPrincipal
                  : const Color(0xFF707792),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchingPrinters extends StatelessWidget {
  const _SearchingPrinters();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.violetPrincipal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.violetPrincipal.withValues(alpha: 0.14),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Recherche des imprimantes Bluetooth autour de vous...',
              style: TextStyle(
                color: Color(0xFF101529),
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoPrinterFound extends StatelessWidget {
  const _NoPrinterFound({
    required this.onRetry,
    required this.onLoadPaired,
    required this.onOpenBluetoothSettings,
    required this.onManualAdd,
  });

  final VoidCallback onRetry;
  final VoidCallback onLoadPaired;
  final VoidCallback onOpenBluetoothSettings;
  final VoidCallback onManualAdd;

  @override
  Widget build(BuildContext context) {
    return _MessagePanel(
      icon: Icons.print_disabled_outlined,
      title: 'Aucune imprimante détectée',
      message:
          'Le MP210 peut être visible uniquement après appairage. Ouvrez Bluetooth, associez-le, puis revenez lire les appareils appairés.',
      primaryActionLabel: 'Rechercher encore',
      onPrimaryAction: onRetry,
      secondaryActions: [
        _MessageAction(
          label: 'Appareils appairés',
          icon: Icons.bluetooth_connected_outlined,
          onTap: onLoadPaired,
        ),
        _MessageAction(
          label: 'Ouvrir Bluetooth',
          icon: Icons.settings_bluetooth_outlined,
          onTap: onOpenBluetoothSettings,
        ),
        _MessageAction(
          label: 'Ajouter MP210',
          icon: Icons.edit_outlined,
          onTap: onManualAdd,
        ),
      ],
    );
  }
}

class _PrinterError extends StatelessWidget {
  const _PrinterError({
    required this.message,
    required this.onRetry,
    required this.onOpenBluetoothSettings,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenBluetoothSettings;

  @override
  Widget build(BuildContext context) {
    return _MessagePanel(
      icon: Icons.bluetooth_disabled_outlined,
      title: 'Recherche impossible',
      message: message,
      primaryActionLabel: 'Réessayer',
      onPrimaryAction: onRetry,
      secondaryActionLabel: 'Ouvrir Bluetooth',
      onSecondaryAction: onOpenBluetoothSettings,
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActions = const [],
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final List<_MessageAction> secondaryActions;

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
          if (primaryActionLabel != null ||
              secondaryActionLabel != null ||
              secondaryActions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                if (secondaryActionLabel != null)
                  OutlinedButton.icon(
                    onPressed: onSecondaryAction,
                    icon: const Icon(Icons.settings_bluetooth_outlined),
                    label: Text(secondaryActionLabel!),
                  ),
                for (final action in secondaryActions)
                  OutlinedButton.icon(
                    onPressed: action.onTap,
                    icon: Icon(action.icon),
                    label: Text(action.label),
                  ),
                if (primaryActionLabel != null)
                  FilledButton.icon(
                    onPressed: onPrimaryAction,
                    icon: const Icon(Icons.search_rounded),
                    label: Text(primaryActionLabel!),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageAction {
  const _MessageAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}
