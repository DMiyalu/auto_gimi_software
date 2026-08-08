import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/establishment.dart';
import '../providers/establishment_providers.dart';
import '../utils/establishment_logo_codec.dart';

/// Paramètres d'identité et de facture de l'établissement courant.
class EstablishmentSettingsScreen extends ConsumerStatefulWidget {
  const EstablishmentSettingsScreen({super.key});

  @override
  ConsumerState<EstablishmentSettingsScreen> createState() =>
      _EstablishmentSettingsScreenState();
}

class _EstablishmentSettingsScreenState
    extends ConsumerState<EstablishmentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _headerControllers = <TextEditingController>[];
  final _footerControllers = <TextEditingController>[];

  String? _logoBase64;
  var _clearLogo = false;
  var _initialized = false;
  String? _boundEstablishmentId;

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _headerControllers) {
      controller.dispose();
    }
    for (final controller in _footerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncFromEstablishment(Establishment establishment) {
    if (_boundEstablishmentId == establishment.id && _initialized) return;

    _nameController.text = establishment.name;
    _logoBase64 = establishment.logoBase64;
    _clearLogo = false;

    _replaceControllers(
      _headerControllers,
      establishment.invoiceHeaderLines.isEmpty
          ? const ['']
          : establishment.invoiceHeaderLines,
    );
    _replaceControllers(
      _footerControllers,
      establishment.invoiceFooterLines.isEmpty
          ? const ['']
          : establishment.invoiceFooterLines,
    );

    _boundEstablishmentId = establishment.id;
    _initialized = true;
  }

  void _replaceControllers(
    List<TextEditingController> target,
    List<String> values,
  ) {
    for (final controller in target) {
      controller.dispose();
    }
    target
      ..clear()
      ..addAll(values.map((value) => TextEditingController(text: value)));
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    try {
      final bytes = await file.readAsBytes();
      final encoded = EstablishmentLogoCodec.encodeForStorage(bytes);
      if (!mounted) return;
      setState(() {
        _logoBase64 = encoded;
        _clearLogo = false;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorMapper.message(error))),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final headers = _headerControllers.map((c) => c.text).toList();
    final footers = _footerControllers.map((c) => c.text).toList();

    await ref
        .read(establishmentControllerProvider.notifier)
        .updateEstablishmentSettings(
          name: _nameController.text,
          logoBase64: _clearLogo ? null : _logoBase64,
          clearLogo: _clearLogo,
          invoiceHeaderLines: headers,
          invoiceFooterLines: footers,
        );

    if (!mounted) return;
    final state = ref.read(establishmentControllerProvider);
    if (state.hasError) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paramètres enregistrés.')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final canConfigure = ref.watch(canConfigureEstablishmentProvider);
    final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
    final saving = ref.watch(establishmentControllerProvider).isLoading;

    ref.listen(establishmentControllerProvider, (_, next) {
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    if (!canConfigure) {
      return Scaffold(
        backgroundColor: AppColors.zuriWhite,
        appBar: AppBar(
          title: const Text('Paramètres de l’établissement'),
          backgroundColor: AppColors.zuriWhite,
          foregroundColor: AppColors.zuriNavy,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48, color: AppColors.zuriRed),
                SizedBox(height: 16),
                Text(
                  'Accès réservé',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.zuriNavy,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Seuls le propriétaire et les gérants peuvent modifier les paramètres de l’établissement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8A90A5)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (establishment == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_initialized || _boundEstablishmentId != establishment.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _syncFromEstablishment(establishment));
      });
    }

    return Scaffold(
      backgroundColor: AppColors.zuriWhite,
      appBar: AppBar(
        title: const Text('Paramètres de l’établissement'),
        backgroundColor: AppColors.zuriWhite,
        foregroundColor: AppColors.zuriNavy,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              const Text(
                'Identité',
                style: TextStyle(
                  color: AppColors.zuriNavy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                enabled: !saving,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDecoration(
                  label: 'Nom de l’établissement',
                  hint: 'Ex. Le Goût Parfait',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _LogoPickerCard(
                logoBase64: _clearLogo ? null : _logoBase64,
                enabled: !saving,
                onPick: _pickLogo,
                onRemove: () => setState(() {
                  _logoBase64 = null;
                  _clearLogo = true;
                }),
              ),
              const SizedBox(height: 28),
              _InvoiceLinesSection(
                title: 'En-tête sur la facture',
                subtitle:
                    'Jusqu’à ${Establishment.invoiceLinesMaxCount} lignes, ${Establishment.invoiceLineMaxLength} caractères max.',
                controllers: _headerControllers,
                enabled: !saving,
                onAdd: () {
                  if (_headerControllers.length >=
                      Establishment.invoiceLinesMaxCount) {
                    return;
                  }
                  setState(
                    () => _headerControllers.add(TextEditingController()),
                  );
                },
                onRemove: (index) {
                  setState(() {
                    _headerControllers.removeAt(index).dispose();
                    if (_headerControllers.isEmpty) {
                      _headerControllers.add(TextEditingController());
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              _InvoiceLinesSection(
                title: 'Pied de page sur la facture',
                subtitle:
                    'Jusqu’à ${Establishment.invoiceLinesMaxCount} lignes, ${Establishment.invoiceLineMaxLength} caractères max.',
                controllers: _footerControllers,
                enabled: !saving,
                onAdd: () {
                  if (_footerControllers.length >=
                      Establishment.invoiceLinesMaxCount) {
                    return;
                  }
                  setState(
                    () => _footerControllers.add(TextEditingController()),
                  );
                },
                onRemove: (index) {
                  setState(() {
                    _footerControllers.removeAt(index).dispose();
                    if (_footerControllers.isEmpty) {
                      _footerControllers.add(TextEditingController());
                    }
                  });
                },
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.zuriRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.zuriWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.zuriRed, width: 1.4),
      ),
      labelStyle: const TextStyle(
        color: AppColors.zuriNavy,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _LogoPickerCard extends StatelessWidget {
  const _LogoPickerCard({
    required this.logoBase64,
    required this.enabled,
    required this.onPick,
    required this.onRemove,
  });

  final String? logoBase64;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bytes = () {
      final raw = logoBase64?.trim();
      if (raw == null || raw.isEmpty) return null;
      try {
        return base64Decode(raw);
      } catch (_) {
        return null;
      }
    }();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              color: Colors.white,
              alignment: Alignment.center,
              child: bytes == null
                  ? const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.zuriRed,
                      size: 32,
                    )
                  : Image.memory(bytes, fit: BoxFit.cover, width: 72, height: 72),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Logo',
                  style: TextStyle(
                    color: AppColors.zuriNavy,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Affiché en en-tête de facture. Sinon, le nom de l’établissement est utilisé.',
                  style: TextStyle(
                    color: Color(0xFF8A90A5),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: enabled ? onPick : null,
                      style: FilledButton.styleFrom(
                        foregroundColor: AppColors.zuriRed,
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        bytes == null ? 'Ajouter un logo' : 'Changer',
                      ),
                    ),
                    if (bytes != null)
                      TextButton(
                        onPressed: enabled ? onRemove : null,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.zuriNavy,
                        ),
                        child: const Text('Retirer'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceLinesSection extends StatelessWidget {
  const _InvoiceLinesSection({
    required this.title,
    required this.subtitle,
    required this.controllers,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final String subtitle;
  final List<TextEditingController> controllers;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.zuriNavy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF8A90A5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < controllers.length; i++) ...[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers[i],
                  enabled: enabled,
                  maxLength: Establishment.invoiceLineMaxLength,
                  decoration: InputDecoration(
                    labelText: 'Ligne ${i + 1}',
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.zuriWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.zuriRed,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: enabled ? () => onRemove(i) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF8A90A5),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed:
                enabled &&
                    controllers.length < Establishment.invoiceLinesMaxCount
                ? onAdd
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une ligne'),
            style: TextButton.styleFrom(foregroundColor: AppColors.zuriRed),
          ),
        ),
      ],
    );
  }
}
