import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/domain/app_currency.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../establishment/presentation/widgets/catalog_permission_gate.dart';
import '../providers/produit_providers.dart';

class ProduitFormScreen extends ConsumerStatefulWidget {
  const ProduitFormScreen({super.key, this.produitId});

  final String? produitId;

  @override
  ConsumerState<ProduitFormScreen> createState() => _ProduitFormScreenState();
}

class _ProduitFormScreenState extends ConsumerState<ProduitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  String? _categoryId;
  AppCurrency _currency = AppCurrency.usd;
  bool _stockTrackingEnabled = false;
  var _initialized = false;

  bool get _isEditing => widget.produitId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _loadIfNeeded() {
    if (_initialized || !_isEditing) return;
    final async = ref.read(produitByIdProvider(widget.produitId!));
    async.whenData((produit) {
      if (produit == null || _initialized) return;
      _nameController.text = produit.name;
      _priceController.text = produit.price.toString();
      _stockController.text = produit.stock.toString();
      _categoryId = produit.categoryId;
      _currency = produit.currency;
      _stockTrackingEnabled = produit.stockTrackingEnabled;
      _initialized = true;
      setState(() {});
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    if (price == null) return;
    final stock = int.tryParse(_stockController.text) ?? 0;

    final controller = ref.read(produitControllerProvider.notifier);
    if (_isEditing) {
      await controller.updateProduit(
        id: widget.produitId!,
        categoryId: _categoryId,
        name: _nameController.text,
        price: price,
        currency: _currency,
        stock: stock,
        stockTrackingEnabled: _stockTrackingEnabled,
      );
    } else {
      await controller.createProduit(
        categoryId: _categoryId,
        name: _nameController.text,
        price: price,
        currency: _currency,
        stock: stock,
        stockTrackingEnabled: _stockTrackingEnabled,
      );
    }

    if (!mounted) return;

    final state = ref.read(produitControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorMapper.message(state.error!))),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? l10n.productUpdated : l10n.productCreated),
      ),
    );
    context.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProduct),
        content: Text(l10n.deleteProductConfirm),
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
        .read(produitControllerProvider.notifier)
        .deleteProduit(id: widget.produitId!);

    if (!mounted) return;
    final state = ref.read(produitControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorMapper.message(state.error!))),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.productDeleted)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CatalogPermissionGate(child: _buildForm(context));
  }

  Widget _buildForm(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formState = ref.watch(produitControllerProvider);
    final categoriesAsync = ref.watch(productCategoriesProvider);

    if (_isEditing) {
      ref.watch(produitByIdProvider(widget.produitId!));
      _loadIfNeeded();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editProduct : l10n.addProduct),
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
                      key: ValueKey('product_cat_$_initialized$_categoryId'),
                      initialValue: _categoryId,
                      decoration: InputDecoration(
                        labelText: l10n.productCategory,
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
                      decoration: InputDecoration(labelText: l10n.productName),
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !formState.isLoading,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.productName
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
                      key: ValueKey('product_cur_$_initialized$_currency'),
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
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Gestion du stock'),
                      subtitle: Text(
                        _stockTrackingEnabled
                            ? 'La quantité sera contrôlée à la commande.'
                            : 'Le produit pourra être commandé sans limite de stock.',
                      ),
                      value: _stockTrackingEnabled,
                      onChanged: formState.isLoading
                          ? null
                          : (value) =>
                                setState(() => _stockTrackingEnabled = value),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _stockTrackingEnabled
                          ? Padding(
                              key: const ValueKey('tracked_stock_field'),
                              padding: const EdgeInsets.only(top: 16),
                              child: TextFormField(
                                controller: _stockController,
                                decoration: const InputDecoration(
                                  labelText: 'Quantité en stock',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                enabled: !formState.isLoading,
                                validator: (value) {
                                  final parsed = int.tryParse(value ?? '');
                                  if (parsed == null || parsed < 0) {
                                    return 'Quantité invalide';
                                  }
                                  return null;
                                },
                              ),
                            )
                          : const Padding(
                              key: ValueKey('untracked_stock_hint'),
                              padding: EdgeInsets.only(top: 12),
                              child: Text(
                                'Stock non suivi pour ce produit.',
                                style: TextStyle(
                                  color: Color(0xFF707792),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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
