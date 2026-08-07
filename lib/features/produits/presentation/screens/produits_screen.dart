import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/module_list_header.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../../primary_module/config/business_module_config.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';
import '../../../primary_module/widgets/module_fab.dart';
import '../../../shell/presentation/widgets/primary_scaffold.dart';
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
            actions: [
              FabActionConfig(
                label: l10n.addProduct,
                icon: Icons.add,
                route: Routes.produitNew,
              ),
              FabActionConfig(
                label: l10n.addProductCategory,
                icon: Icons.create_new_folder_outlined,
                route: Routes.productCategoryNew,
              ),
            ],
          )
        : null;

    final body = Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: ProduitSearchBar(),
        ),
        const SizedBox(height: AppSpacing.sm),
        const ProduitFilters(),
        const SizedBox(height: AppSpacing.sm),
        Expanded(child: _ProduitListView(canManageCatalog: canManageCatalog)),
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
}

class _ProduitListView extends ConsumerWidget {
  const _ProduitListView({required this.canManageCatalog});

  final bool canManageCatalog;

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

        final filtered = ref.watch(filteredProduitsProvider);
        if (filtered.isEmpty) {
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
          itemCount: filtered.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ModuleListHeader(
                title: l10n.productsListTitle,
                countLabel: l10n.productsCount(filtered.length),
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
