import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';
import '../../../shell/presentation/widgets/primary_scaffold.dart';
import '../providers/produit_providers.dart';

class ProduitsScreen extends ConsumerStatefulWidget {
  const ProduitsScreen({super.key});

  @override
  ConsumerState<ProduitsScreen> createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends ConsumerState<ProduitsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCategories = _tabController.index == 1;
    final config = ref.watch(primaryModuleConfigProvider);
    final isPrimary = config.catalogTab.route == Routes.produits;

    final body = Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.products),
            Tab(text: l10n.productCategories),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _ProduitsListTab(),
              _ProductCategoriesTab(),
            ],
          ),
        ),
      ],
    );
    final fab = FloatingActionButton.extended(
      onPressed: () => context.push(
        isCategories ? Routes.productCategoryNew : Routes.produitNew,
      ),
      icon: Icon(
        isCategories ? Icons.create_new_folder_outlined : Icons.add,
      ),
      label: Text(
        isCategories ? l10n.addProductCategory : l10n.addProduct,
      ),
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
}

class _ProduitsListTab extends ConsumerWidget {
  const _ProduitsListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: produits.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final produit = produits[index];
            return ListTile(
              leading: CircleAvatar(
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(produit.name),
              subtitle: Text(produit.categoryName ?? l10n.noCategory),
              trailing: Text(
                CurrencyFormatter.formatWithCode(
                  produit.price,
                  currency: produit.currency,
                ),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              onTap: () => context.push(Routes.produitEditPath(produit.id)),
            );
          },
        );
      },
    );
  }
}

class _ProductCategoriesTab extends ConsumerWidget {
  const _ProductCategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final produitsAsync = ref.watch(produitsProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (categories) {
        if (categories.isEmpty) {
          return _EmptyState(
            icon: Icons.folder_outlined,
            title: l10n.noProductCategories,
            hint: l10n.noProductCategoriesHint,
          );
        }

        final produits = produitsAsync.valueOrNull ?? [];
        final counts = <String, int>{};
        for (final produit in produits) {
          final categoryId = produit.categoryId;
          if (categoryId == null) continue;
          counts[categoryId] = (counts[categoryId] ?? 0) + 1;
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final category = categories[index];
            final count = counts[category.id] ?? 0;
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.folder_outlined),
              ),
              title: Text(category.name),
              subtitle: Text(l10n.productsCount(count)),
              onTap: () =>
                  context.push(Routes.productCategoryEditPath(category.id)),
            );
          },
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
