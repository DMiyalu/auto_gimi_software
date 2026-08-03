import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/domain/app_currency.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../establishment/presentation/widgets/catalog_permission_gate.dart';
import '../providers/service_providers.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  const ServiceFormScreen({super.key, this.serviceId});

  final String? serviceId;

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _intervalController = TextEditingController(text: '0');
  String? _categoryId;
  AppCurrency _currency = AppCurrency.usd;
  var _initialized = false;

  bool get _isEditing => widget.serviceId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _loadIfNeeded() {
    if (_initialized || !_isEditing) return;
    final async = ref.read(serviceByIdProvider(widget.serviceId!));
    async.whenData((service) {
      if (service == null || _initialized) return;
      _nameController.text = service.name;
      _priceController.text = service.price.toString();
      _intervalController.text = service.intervalDays.toString();
      _categoryId = service.categoryId;
      _currency = service.currency;
      _initialized = true;
      setState(() {});
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    final interval = int.tryParse(_intervalController.text.trim()) ?? 0;
    if (price == null) return;

    final controller = ref.read(serviceControllerProvider.notifier);
    if (_isEditing) {
      await controller.updateService(
        id: widget.serviceId!,
        categoryId: _categoryId,
        name: _nameController.text,
        price: price,
        currency: _currency,
        intervalDays: interval,
      );
    } else {
      await controller.createService(
        categoryId: _categoryId,
        name: _nameController.text,
        price: price,
        currency: _currency,
        intervalDays: interval,
      );
    }

    if (!mounted) return;

    final state = ref.read(serviceControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorMapper.message(state.error!))),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? l10n.serviceUpdated : l10n.serviceCreated),
      ),
    );
    context.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteService),
        content: Text(l10n.deleteServiceConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref
        .read(serviceControllerProvider.notifier)
        .deleteService(id: widget.serviceId!);

    if (!mounted) return;
    final state = ref.read(serviceControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorMapper.message(state.error!))),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.serviceDeleted)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CatalogPermissionGate(child: _buildForm(context));
  }

  Widget _buildForm(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formState = ref.watch(serviceControllerProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);

    if (_isEditing) {
      ref.watch(serviceByIdProvider(widget.serviceId!));
      _loadIfNeeded();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editService : l10n.addService),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: l10n.delete,
              onPressed: formState.isLoading ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
          data: (categories) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String?>(
                      key: ValueKey('service_cat_$_initialized$_categoryId'),
                      initialValue: _categoryId,
                      decoration: InputDecoration(
                        labelText: l10n.serviceCategory,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.noCategory),
                        ),
                        ...categories.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: formState.isLoading
                          ? null
                          : (value) => setState(() => _categoryId = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: l10n.serviceName),
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !formState.isLoading,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.serviceName
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: l10n.price),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      enabled: !formState.isLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.price;
                        }
                        final parsed = double.tryParse(
                          value.replaceAll(',', '.'),
                        );
                        if (parsed == null || parsed < 0) {
                          return l10n.priceInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AppCurrency>(
                      key: ValueKey('service_cur_$_initialized$_currency'),
                      initialValue: _currency,
                      decoration: InputDecoration(labelText: l10n.currency),
                      items: AppCurrency.values
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.label),
                            ),
                          )
                          .toList(),
                      onChanged: formState.isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _currency = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _intervalController,
                      decoration: InputDecoration(
                        labelText: l10n.maintenanceInterval,
                        helperText: l10n.maintenanceIntervalHint,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: !formState.isLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed < 0) {
                          return l10n.maintenanceInterval;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: formState.isLoading ? null : _submit,
                      child: formState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.save),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
