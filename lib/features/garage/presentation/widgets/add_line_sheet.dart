import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/app_currency.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../produits/domain/entities/produit_entity.dart';
import '../../../produits/presentation/providers/produit_providers.dart';
import '../../../services/domain/entities/catalog_service_entity.dart';
import '../../../services/presentation/providers/service_providers.dart';
import '../providers/prestation_providers.dart';

/// BottomSheet à 2 onglets (Services / Produits) pour ajouter une ligne de
/// travaux — réutilise directement les catalogues déjà chargés ailleurs
/// dans l'app, aucune nouvelle source de données.
void showAddLineSheet(BuildContext context, String prestationId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  const TabBar(
                    tabs: [Tab(text: 'Services'), Tab(text: 'Produits')],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _ServiceList(
                          prestationId: prestationId,
                          scrollController: scrollController,
                        ),
                        _ProduitList(
                          prestationId: prestationId,
                          scrollController: scrollController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _ServiceList extends ConsumerWidget {
  const _ServiceList({required this.prestationId, required this.scrollController});

  final String prestationId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(catalogServicesProvider);

    return servicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (services) {
        if (services.isEmpty) {
          return const Center(child: Text('Aucun service au catalogue.'));
        }
        return ListView.builder(
          controller: scrollController,
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _CatalogTile(
              name: service.name,
              price: service.price,
              currency: service.currency,
              onTap: () => _addService(context, ref, service),
            );
          },
        );
      },
    );
  }

  Future<void> _addService(
    BuildContext context,
    WidgetRef ref,
    CatalogServiceEntity service,
  ) async {
    await ref.read(prestationControllerProvider.notifier).addServiceLine(
          prestationId: prestationId,
          serviceId: service.id,
        );
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _ProduitList extends ConsumerWidget {
  const _ProduitList({required this.prestationId, required this.scrollController});

  final String prestationId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitsAsync = ref.watch(produitsProvider);

    return produitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (produits) {
        if (produits.isEmpty) {
          return const Center(child: Text('Aucun produit en magasin.'));
        }
        return ListView.builder(
          controller: scrollController,
          itemCount: produits.length,
          itemBuilder: (context, index) {
            final produit = produits[index];
            return _CatalogTile(
              name: produit.name,
              price: produit.price,
              currency: produit.currency,
              onTap: () => _addProduit(context, ref, produit),
            );
          },
        );
      },
    );
  }

  Future<void> _addProduit(
    BuildContext context,
    WidgetRef ref,
    ProduitEntity produit,
  ) async {
    await ref.read(prestationControllerProvider.notifier).addProduitLine(
          prestationId: prestationId,
          produitId: produit.id,
        );
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.name,
    required this.price,
    required this.currency,
    required this.onTap,
  });

  final String name;
  final double price;
  final AppCurrency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      trailing: Text(
        CurrencyFormatter.formatWithCode(price, currency: currency),
      ),
      onTap: onTap,
    );
  }
}
