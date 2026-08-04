import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/inventory_line_entity.dart';
import '../../domain/entities/inventory_session_entity.dart';
import '../providers/inventory_providers.dart';

class InventoryDetailScreen extends ConsumerWidget {
  const InventoryDetailScreen({super.key, required this.inventoryId});

  final String inventoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider(inventoryId));
    final lines = ref.watch(inventoryLinesProvider(inventoryId));
    final state = ref.watch(inventoryControllerProvider);

    ref.listen(inventoryControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    return inventory.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Inventaire')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Inventaire')),
        body: Center(child: Text(error.toString())),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Inventaire')),
            body: const Center(child: Text('Inventaire introuvable')),
          );
        }

        final lineItems = lines.valueOrNull ?? [];
        final canClose =
            item.status == InventoryStatus.draft &&
            lineItems.isNotEmpty &&
            lineItems.every((line) => line.isCounted);

        return Scaffold(
          appBar: AppBar(
            title: Text(item.reference),
            actions: [
              if (item.status == InventoryStatus.draft)
                IconButton(
                  tooltip: 'Annuler',
                  onPressed: state.isLoading
                      ? null
                      : () => _confirmCancel(context, ref),
                  icon: const Icon(Icons.cancel_outlined),
                ),
            ],
          ),
          bottomNavigationBar: item.status == InventoryStatus.draft
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: FilledButton.icon(
                      onPressed: state.isLoading || !canClose
                          ? null
                          : () async {
                              await ref
                                  .read(inventoryControllerProvider.notifier)
                                  .closeInventory(inventoryId: inventoryId);
                              if (!context.mounted) return;
                              final next = ref.read(
                                inventoryControllerProvider,
                              );
                              if (!next.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Inventaire clôturé'),
                                  ),
                                );
                              }
                            },
                      icon: state.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: const Text('Clôturer l’inventaire'),
                    ),
                  ),
                )
              : null,
          body: lines.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (items) {
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  96,
                ),
                itemCount: items.length + 1,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  if (index == 0) return _InventoryHeader(item: item);
                  final line = items[index - 1];
                  return _InventoryLineTile(
                    line: line,
                    enabled:
                        item.status == InventoryStatus.draft &&
                        !state.isLoading,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler l’inventaire ?'),
        content: const Text('Le stock produit ne sera pas modifié.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Retour'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(inventoryControllerProvider.notifier)
        .cancelInventory(inventoryId: inventoryId);
    if (!context.mounted) return;
    final state = ref.read(inventoryControllerProvider);
    if (!state.hasError) context.pop();
  }
}

class _InventoryHeader extends StatelessWidget {
  const _InventoryHeader({required this.item});

  final InventorySessionEntity item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Chip(label: Text(item.status.label)),
            const Spacer(),
            Text(
              item.closedAt == null ? 'En cours' : 'Clôturé',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryLineTile extends ConsumerStatefulWidget {
  const _InventoryLineTile({required this.line, required this.enabled});

  final InventoryLineEntity line;
  final bool enabled;

  @override
  ConsumerState<_InventoryLineTile> createState() => _InventoryLineTileState();
}

class _InventoryLineTileState extends ConsumerState<_InventoryLineTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.line.countedStock?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _InventoryLineTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.line.countedStock?.toString() ?? '';
    if (oldWidget.line.countedStock != widget.line.countedStock &&
        _controller.text != next) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = int.tryParse(_controller.text.trim());
    if (value == null) return;
    await ref
        .read(inventoryControllerProvider.notifier)
        .setCountedStock(lineId: widget.line.id, countedStock: value);
  }

  @override
  Widget build(BuildContext context) {
    final variance = widget.line.variance;
    final varianceLabel = variance == null
        ? 'À compter'
        : variance == 0
        ? 'Écart 0'
        : 'Écart ${variance > 0 ? '+' : ''}$variance';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.line.label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text('Théorique : ${widget.line.expectedStock}'),
                  Text(varianceLabel),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 96,
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Compté'),
                onSubmitted: (_) => _save(),
                onEditingComplete: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
