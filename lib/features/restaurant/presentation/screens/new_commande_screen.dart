import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../providers/commande_providers.dart';

class NewCommandeScreen extends ConsumerStatefulWidget {
  const NewCommandeScreen({super.key});

  @override
  ConsumerState<NewCommandeScreen> createState() => _NewCommandeScreenState();
}

class _NewCommandeScreenState extends ConsumerState<NewCommandeScreen> {
  static final _tableNumbers = List<int>.unmodifiable(
    List.generate(20, (index) => index + 1),
  );

  int? _selectedTable;

  Future<void> _submit() async {
    final controller = ref.read(commandeControllerProvider.notifier);
    final commandeId = await controller.createCommande(
      context: _contextFromTable(_selectedTable),
    );

    if (!mounted) return;
    final state = ref.read(commandeControllerProvider);
    if (!state.hasError) context.go(Routes.commandeDetailPath(commandeId));
  }

  String? _contextFromTable(int? tableNumber) =>
      tableNumber == null ? null : 'Table $tableNumber';

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouvelle commande'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.table_restaurant_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Créer une commande',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Le numéro de table est optionnel. Vous pourrez ajouter les produits et le client ensuite.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF707792),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<int?>(
                    initialValue: _selectedTable,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Table',
                      prefixIcon: Icon(Icons.table_restaurant_outlined),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Sans table'),
                      ),
                      for (final number in _tableNumbers)
                        DropdownMenuItem<int?>(
                          value: number,
                          child: Text('Table $number'),
                        ),
                    ],
                    onChanged: state.isLoading
                        ? null
                        : (value) => setState(() => _selectedTable = value),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: state.isLoading ? null : _submit,
                    icon: state.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Continuer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
