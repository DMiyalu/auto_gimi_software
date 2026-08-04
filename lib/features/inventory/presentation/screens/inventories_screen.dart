import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/inventory_providers.dart';

class InventoriesScreen extends ConsumerWidget {
  const InventoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventories = ref.watch(inventoriesProvider);
    final state = ref.watch(inventoryControllerProvider);

    ref.listen(inventoryControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Inventaires')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isLoading
            ? null
            : () async {
                final inventory = await ref
                    .read(inventoryControllerProvider.notifier)
                    .createInventory();
                if (inventory == null || !context.mounted) return;
                context.push(Routes.inventoryDetailPath(inventory.id));
              },
        icon: state.isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: const Text('Nouvel inventaire'),
      ),
      body: inventories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyInventories();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              96,
            ),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final item = items[index];
              return DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: AppRadius.cardRadius,
                ),
                child: ListTile(
                  leading: Icon(
                    item.isDraft
                        ? Icons.pending_actions_outlined
                        : Icons.assignment_turned_in_outlined,
                  ),
                  title: Text(item.reference),
                  subtitle: Text(item.status.label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push(Routes.inventoryDetailPath(item.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyInventories extends StatelessWidget {
  const _EmptyInventories();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fact_check_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Aucun inventaire',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Démarrez un inventaire pour compter les produits et ajuster le stock.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
