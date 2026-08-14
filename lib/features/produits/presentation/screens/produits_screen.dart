import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../../primary_module/config/business_module_config.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';
import '../../../primary_module/widgets/module_fab.dart';
import '../../../shell/presentation/widgets/primary_scaffold.dart';
import '../../data/services/daily_menu_pdf_builder.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/produit_entity.dart';
import '../providers/produit_list_view_providers.dart';
import '../providers/produit_providers.dart';
import '../widgets/produit_card.dart';
import '../widgets/produit_filters.dart';
import '../widgets/produit_search_bar.dart';

class ProduitsScreen extends ConsumerWidget {
  const ProduitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(primaryModuleConfigProvider);
    final isPrimary = config.catalogTab.route == Routes.produits;
    final canManageCatalog = ref.watch(canManageCatalogProvider);

    final fab = canManageCatalog
        ? ModuleFab(
            color: AppColors.zuriRed,
            actions: [
              FabActionConfig(
                label: l10n.addProduct,
                icon: Icons.inventory_2_outlined,
                route: Routes.produitNew,
              ),
              FabActionConfig(
                label: l10n.addProductCategory,
                icon: Icons.sell_outlined,
                route: Routes.productCategoryNew,
              ),
              FabActionConfig(
                label: 'Générer un menu du jour',
                icon: Icons.menu_book_outlined,
                onSelected: () => _showDailyMenuSheet(context),
              ),
            ],
          )
        : null;

    final produitsAsync = ref.watch(produitsProvider);
    final hasProducts = produitsAsync.valueOrNull?.isNotEmpty ?? false;

    final body = Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: ProduitSearchBar(),
        ),
        if (hasProducts) ...[
          const SizedBox(height: 14),
          const ProduitFilters(),
          const SizedBox(height: 14),
        ],
        const Expanded(child: _ProduitListView()),
      ],
    );

    if (isPrimary) {
      return PrimaryScaffold(floatingActionButton: fab, body: body);
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.products)),
      floatingActionButton: fab,
      body: body,
    );
  }

  void _showDailyMenuSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _DailyMenuSheet(),
    );
  }
}

class _ProduitListView extends ConsumerWidget {
  const _ProduitListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canManageCatalog = ref.watch(canManageCatalogProvider);
    final produitsAsync = ref.watch(produitsProvider);

    return produitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (produits) {
        if (produits.isEmpty) {
          return _EmptyState(
            icon: Icons.inventory_2_outlined,
            title: l10n.noProducts,
            hint: l10n.noProductsHint,
          );
        }

        final filtered = ref.watch(filteredProduitsProvider);
        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.noProductsMatchFilter,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8A90A5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
          itemCount: filtered.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.productsListTitle,
                        style: const TextStyle(
                          color: AppColors.zuriNavy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      l10n.productsCount(filtered.length),
                      style: const TextStyle(
                        color: Color(0xFF8A90A5),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            final produit = filtered[index - 1];
            return ProduitCard(produit: produit, canManage: canManageCatalog);
          },
        );
      },
    );
  }
}

class _DailyMenuSheet extends ConsumerStatefulWidget {
  const _DailyMenuSheet();

  @override
  ConsumerState<_DailyMenuSheet> createState() => _DailyMenuSheetState();
}

class _DailyMenuSheetState extends ConsumerState<_DailyMenuSheet> {
  final _searchController = TextEditingController();
  final _selectedProductIds = <String>{};
  String? _categoryId;
  var _isSharing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProduitEntity> _filteredProducts(List<ProduitEntity> products) {
    final query = _searchController.text.trim().toLowerCase();
    return products.where((product) {
      final matchesSearch =
          query.isEmpty || product.name.toLowerCase().contains(query);
      final matchesCategory =
          _categoryId == null || product.categoryId == _categoryId;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _shareMenu(List<ProduitEntity> products) async {
    final selected = products
        .where((product) => _selectedProductIds.contains(product.id))
        .toList();
    if (selected.isEmpty) return;

    setState(() => _isSharing = true);
    try {
      final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
      final bytes = await const DailyMenuPdfBuilder().build(
        establishmentName: establishment?.name ?? 'Restaurant',
        products: selected,
      );
      await Printing.sharePdf(bytes: bytes, filename: 'menu-du-jour-zuri.pdf');
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de générer le menu : $error')),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(produitsProvider);
    final categoriesAsync = ref.watch(productCategoriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (products) {
                final categories =
                    categoriesAsync.valueOrNull ??
                    const <ProductCategoryEntity>[];
                final filtered = _filteredProducts(products);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5D8E2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Creation Menu du Jour',
                      style: TextStyle(
                        color: AppColors.zuriNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: 'Rechercher un produit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('Toutes'),
                              selected: _categoryId == null,
                              onSelected: (_) =>
                                  setState(() => _categoryId = null),
                            ),
                          ),
                          for (final category in categories)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(category.name),
                                selected: _categoryId == category.id,
                                onSelected: (_) =>
                                    setState(() => _categoryId = category.id),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: products.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucun produit disponible pour créer un menu.',
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                color: AppColors.borderSubtle,
                              ),
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                final selected = _selectedProductIds.contains(
                                  product.id,
                                );
                                return CheckboxListTile(
                                  value: selected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedProductIds.add(product.id);
                                      } else {
                                        _selectedProductIds.remove(product.id);
                                      }
                                    });
                                  },
                                  title: Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: AppColors.zuriNavy,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  subtitle: Text(
                                    product.categoryName ?? 'Sans catégorie',
                                  ),
                                  secondary: const Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: AppColors.zuriRed,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _selectedProductIds.isEmpty || _isSharing
                          ? null
                          : () => _shareMenu(products),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.zuriRed,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: _isSharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(
                        _isSharing
                            ? 'Génération…'
                            : 'Générer et partager le PDF',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.hint,
  });

  final IconData icon;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.zuriPink.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 38, color: AppColors.zuriRed),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.zuriNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8A90A5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
