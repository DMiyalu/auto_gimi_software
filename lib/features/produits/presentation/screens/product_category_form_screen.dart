import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/domain/business_category.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
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
  final _nameFocusNode = FocusNode();
  var _initialized = false;
  var _showInlineSuggestions = false;

  bool get _isEditing => widget.categoryId != null;

  static const _restaurantCategorySuggestions = [
    'Entrées',
    'Plats principaux',
    'Accompagnements',
    'Grillades',
    'Pizzas',
    'Burgers',
    'Desserts',
    'Boissons',
    'Jus naturels',
    'Cocktails',
    'Café et thé',
    'Menu enfant',
  ];

  static const _shopCategorySuggestions = [
    'Épicerie',
    'Boissons',
    'Produits frais',
    'Hygiène',
    'Beauté',
    'Maison',
    'Mode',
    'Accessoires',
    'Électronique',
    'Papeterie',
    'Promotions',
  ];

  List<String> _availableSuggestions(
    Set<String> existingNames,
    List<String> source,
  ) {
    return source
        .where((name) => !existingNames.contains(name.toLowerCase()))
        .toList();
  }

  void _applySuggestion(String suggestion) {
    _nameController.text = suggestion;
    _nameController.selection = TextSelection.collapsed(
      offset: suggestion.length,
    );
    _nameFocusNode.requestFocus();
    setState(() => _showInlineSuggestions = false);
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
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
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
    final category = establishment?.category;
    final suggestionSource = switch (category) {
      BusinessCategory.restaurant => _restaurantCategorySuggestions,
      BusinessCategory.shop => _shopCategorySuggestions,
      _ => const <String>[],
    };
    final showSuggestions = !_isEditing && suggestionSource.isNotEmpty;

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
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
          data: (categories) {
            final existingNames = categories
                .map((category) => category.name.toLowerCase())
                .toSet();
            final suggestions = showSuggestions
                ? _availableSuggestions(existingNames, suggestionSource)
                : const <String>[];
            final hasCategories = categories.isNotEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      decoration: InputDecoration(
                        labelText: l10n.categoryName,
                        suffixIcon: hasCategories && suggestions.isNotEmpty
                            ? const Icon(Icons.expand_more_rounded)
                            : null,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !formState.isLoading,
                      onTap: () {
                        if (hasCategories && suggestions.isNotEmpty) {
                          setState(() => _showInlineSuggestions = true);
                        }
                      },
                      onChanged: (_) {
                        if (hasCategories && suggestions.isNotEmpty) {
                          setState(() => _showInlineSuggestions = true);
                        }
                      },
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.categoryName
                          : null,
                    ),
                    if (hasCategories &&
                        suggestions.isNotEmpty &&
                        _showInlineSuggestions)
                      _InlineSuggestionList(
                        suggestions: suggestions,
                        onSelected: _applySuggestion,
                      ),
                    if (!hasCategories && suggestions.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _SuggestionCards(
                        suggestions: suggestions,
                        onSelected: _applySuggestion,
                      ),
                    ],
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

class _InlineSuggestionList extends StatelessWidget {
  const _InlineSuggestionList({
    required this.suggestions,
    required this.onSelected,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.zuriNavy.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < suggestions.length; index++) ...[
            ListTile(
              dense: true,
              leading: const Icon(
                Icons.sell_outlined,
                color: AppColors.zuriRed,
              ),
              title: Text(
                suggestions[index],
                style: const TextStyle(
                  color: AppColors.zuriNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () => onSelected(suggestions[index]),
            ),
            if (index < suggestions.length - 1)
              const Divider(height: 1, color: AppColors.borderSubtle),
          ],
        ],
      ),
    );
  }
}

class _SuggestionCards extends StatelessWidget {
  const _SuggestionCards({required this.suggestions, required this.onSelected});

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final suggestion in suggestions)
          ActionChip(
            avatar: const Icon(Icons.add_rounded, size: 18),
            label: Text(suggestion),
            labelStyle: const TextStyle(
              color: AppColors.zuriNavy,
              fontWeight: FontWeight.w700,
            ),
            backgroundColor: AppColors.zuriPink.withValues(alpha: 0.10),
            side: const BorderSide(color: AppColors.borderSubtle),
            onPressed: () => onSelected(suggestion),
          ),
      ],
    );
  }
}
