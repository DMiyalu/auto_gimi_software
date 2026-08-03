import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../../produits/presentation/providers/produit_providers.dart';
import '../providers/commande_providers.dart';

class NewCommandeScreen extends ConsumerStatefulWidget {
  const NewCommandeScreen({super.key});

  @override
  ConsumerState<NewCommandeScreen> createState() => _NewCommandeScreenState();
}

class _NewCommandeScreenState extends ConsumerState<NewCommandeScreen> {
  final _contextController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String? _selectedProduitId;

  @override
  void dispose() {
    _contextController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final produits = ref.read(produitsProvider).valueOrNull ?? [];
    final produit = produits
        .where((item) => item.id == _selectedProduitId)
        .firstOrNull;
    if (produit == null) return;
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;

    final controller = ref.read(commandeControllerProvider.notifier);
    final commandeId = await controller.createCommande(
      context: _contextController.text,
    );
    await controller.addProduitLine(
      commandeId: commandeId,
      produitId: produit.id,
      quantity: quantity,
    );

    if (!mounted) return;
    final state = ref.read(commandeControllerProvider);
    if (!state.hasError) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final produits = ref.watch(produitsProvider).valueOrNull ?? [];
    final state = ref.watch(commandeControllerProvider);
    final canCreateActivities = ref.watch(canCreateActivitiesProvider);

    ref.listen(commandeControllerProvider, (_, next) {
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    if (!canCreateActivities) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accès limité')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Vous n’avez pas le droit de créer des commandes pour cet établissement.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle commande')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _contextController,
                    enabled: !state.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Table, livraison ou contexte',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedProduitId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Produit'),
                    items: [
                      for (final produit in produits)
                        DropdownMenuItem(
                          value: produit.id,
                          child: Text(
                            '${produit.name} • ${produit.price.toStringAsFixed(2)} ${produit.currency.code} • Stock ${produit.stock}',
                          ),
                        ),
                    ],
                    onChanged: state.isLoading
                        ? null
                        : (value) => setState(() => _selectedProduitId = value),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _quantityController,
                    enabled: !state.isLoading,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantité'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: state.isLoading || produits.isEmpty
                        ? null
                        : _submit,
                    icon: state.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_shopping_cart_outlined),
                    label: const Text('Créer la commande'),
                  ),
                  if (produits.isEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Ajoutez d’abord des produits au catalogue pour créer une commande.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
