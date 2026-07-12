import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/service_providers.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _intervalController = TextEditingController(text: '0');
  String? _categoryId;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) return;

    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    final interval = int.tryParse(_intervalController.text.trim()) ?? 0;
    if (price == null) return;

    await ref.read(serviceControllerProvider.notifier).createService(
          categoryId: _categoryId!,
          name: _nameController.text,
          price: price,
          intervalDays: interval,
        );

    if (!mounted) return;

    final state = ref.read(serviceControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorMapper.message(state.error!))),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).serviceCreated)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formState = ref.watch(serviceControllerProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addService)),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
          data: (categories) {
            if (categories.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.createCategoryFirst,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            _categoryId ??= categories.first.id;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      decoration: InputDecoration(
                        labelText: l10n.serviceCategory,
                      ),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: formState.isLoading
                          ? null
                          : (value) => setState(() => _categoryId = value),
                      validator: (value) =>
                          value == null ? l10n.serviceCategory : null,
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
                      decoration: InputDecoration(
                        labelText: l10n.price,
                        suffixText: CurrencyFormatter.currencyCode,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]'),
                        ),
                      ],
                      enabled: !formState.isLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.price;
                        }
                        final parsed =
                            double.tryParse(value.replaceAll(',', '.'));
                        if (parsed == null || parsed < 0) {
                          return l10n.priceInvalid;
                        }
                        return null;
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      enabled: !formState.isLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
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
