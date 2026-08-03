import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../establishment/presentation/widgets/catalog_permission_gate.dart';
import '../providers/produit_providers.dart';

class ProductCategoryFormScreen extends ConsumerStatefulWidget {
  const ProductCategoryFormScreen({super.key, this.categoryId});

  final String? categoryId;

  @override
  ConsumerState<ProductCategoryFormScreen> createState() =>
      _ProductCategoryFormScreenState();
}

class _ProductCategoryFormScreenState
    extends ConsumerState<ProductCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  var _initialized = false;

  bool get _isEditing => widget.categoryId != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadIfNeeded() {
    if (_initialized || !_isEditing) return;
    final async = ref.read(productCategoryByIdProvider(widget.categoryId!));
    async.whenData((category) {
      if (category == null || _initialized) return;
      _nameController.text = category.name;
      _initialized = true;
      setState(() {});
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(produitControllerProvider.notifier);
    if (_isEditing) {
      await controller.updateCategory(
        id: widget.categoryId!,
        name: _nameController.text,
      );
    } else {
      await controller.createCategory(name: _nameController.text);
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
        content: Text(
          _isEditing ? l10n.categoryUpdated : l10n.productCategoryCreated,
        ),
      ),
    );
    context.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryConfirm),
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
        .deleteCategory(id: widget.categoryId!);

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
    ).showSnackBar(SnackBar(content: Text(l10n.categoryDeleted)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CatalogPermissionGate(child: _buildForm(context));
  }

  Widget _buildForm(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formState = ref.watch(produitControllerProvider);

    if (_isEditing) {
      ref.watch(productCategoryByIdProvider(widget.categoryId!));
      _loadIfNeeded();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCategory : l10n.addProductCategory),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.categoryName),
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !formState.isLoading,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.categoryName
                      : null,
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
        ),
      ),
    );
  }
}
