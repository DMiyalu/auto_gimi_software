import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
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
            return ProduitCard(
              produit: produit,
              canManage: canManageCatalog,
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
