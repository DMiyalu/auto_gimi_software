import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/enums.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/ligne_prestation_entity.dart';
import '../providers/prestation_providers.dart';
import 'add_line_sheet.dart';

/// Onglet "Travaux" — services et produits ajoutés à la prestation, avec le
/// total en pied de page.
class PrestationWorksTab extends ConsumerWidget {
  const PrestationWorksTab({super.key, required this.prestationId});

  final String prestationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lignesAsync = ref.watch(prestationLinesProvider(prestationId));
    final prestationAsync = ref.watch(prestationProvider(prestationId));

    return Scaffold(
      body: lignesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (lignes) {
          if (lignes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.build_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text('Aucun travail ajouté pour l’instant'),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              96,
            ),
            itemCount: lignes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _LigneTile(ligne: lignes[index]),
          );
        },
      ),
      bottomNavigationBar: _TotalFooter(
        total: prestationAsync.valueOrNull?.montantTotal ?? 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddLineSheet(context, prestationId),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LigneTile extends ConsumerWidget {
  const _LigneTile({required this.ligne});

  final LignePrestationEntity ligne;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        ligne.type == LigneType.service
            ? Icons.build_outlined
            : Icons.inventory_2_outlined,
      ),
      title: Text(ligne.libelle),
      subtitle: Text(
        'Qté ${ligne.quantite} × ${CurrencyFormatter.format(ligne.prixUnitaire)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CurrencyFormatter.format(ligne.montantLigne),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                ref.read(prestationControllerProvider.notifier).removeLine(
                      ligne.id,
                    ),
          ),
        ],
      ),
    );
  }
}

class _TotalFooter extends StatelessWidget {
  const _TotalFooter({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total'),
            Text(
              CurrencyFormatter.format(total),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
