import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../providers/produit_providers.dart';

class ProductCategoryFormScreen extends ConsumerStatefulWidget {
  const ProductCategoryFormScreen({super.key});

  @override
  ConsumerState<ProductCategoryFormScreen> createState() =>
      _ProductCategoryFormScreenState();
}

class _ProductCategoryFormScreenState
    extends ConsumerState<ProductCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(produitControllerProvider.notifier).createCategory(
          name: _nameController.text,
        );

    if (!mounted) return;

    final state = ref.read(produitControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorMapper.message(state.error!))),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).productCategoryCreated),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formState = ref.watch(produitControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addProductCategory)),
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
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !formState.isLoading,
                  validator: (value) =>
                      value == null || value.trim().isEmpty
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
