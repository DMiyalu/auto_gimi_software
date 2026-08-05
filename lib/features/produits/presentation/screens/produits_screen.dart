import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/domain_card.dart';
import '../../../../core/presentation/widgets/module_list_header.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/domain_accent_colors.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';
import '../../../shell/presentation/widgets/primary_scaffold.dart';
import '../providers/produit_list_view_providers.dart';
import '../providers/produit_providers.dart';
import '../widgets/produit_card.dart';
import '../widgets/produit_filters.dart';
import '../widgets/produit_search_bar.dart';

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
    final canManageCatalog = ref.watch(canManageCatalogProvider);

    final body = Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.products),
            Tab(text: l10n.productCategories),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [_ProduitsListTab(), _ProductCategoriesTab()],
          ),
        ),
      ],
    );
    final fab = canManageCatalog
        ? FloatingActionButton.extended(
            onPressed: () => context.push(
              isCategories ? Routes.productCategoryNew : Routes.produitNew,
            ),
            icon: Icon(
              isCategories ? Icons.create_new_folder_outlined : Icons.add,
            ),
            label: Text(
              isCategories ? l10n.addProductCategory : l10n.addProduct,
            ),
          )
        : null;

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
    final canManageCatalog = ref.watch(canManageCatalogProvider);

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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(child: ProduitSearchBar()),
                  const SizedBox(width: AppSpacing.xs),
                  const _FiltersButton(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const ProduitFilters(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _ProduitListView(canManageCatalog: canManageCatalog),
            ),
          ],
        );
      },
    );
  }
}

class _FiltersButton extends StatelessWidget {
  const _FiltersButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 16,
        ),
      ),
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
      },
      icon: const Icon(Icons.tune, size: 18),
      label: Text(l10n.filters),
    );
  }
}

class _ProduitListView extends ConsumerWidget {
  const _ProduitListView({required this.canManageCatalog});

  final bool canManageCatalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final produits = ref.watch(filteredProduitsProvider);

    if (produits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            l10n.noProductsMatchFilter,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      itemCount: produits.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        if (index == 0) {
          return ModuleListHeader(
            title: l10n.productsListTitle,
            countLabel: l10n.productsCount(produits.length),
          );
        }

        final produit = produits[index - 1];
        return ProduitCard(produit: produit, canManage: canManageCatalog);
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
    final canManageCatalog = ref.watch(canManageCatalogProvider);

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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            final category = categories[index];
            final count = counts[category.id] ?? 0;
            final accent = DomainAccentColors.forId(category.id);

            return DomainCard(
              accentColor: accent,
              onTap: canManageCatalog
                  ? () => context.push(
                      Routes.productCategoryEditPath(category.id),
                    )
                  : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: accent.withValues(alpha: 0.12),
                    child: Icon(Icons.folder_outlined, color: accent),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.productsCount(count),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
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
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
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
