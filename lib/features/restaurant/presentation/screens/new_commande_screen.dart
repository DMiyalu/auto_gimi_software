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
  final _tableController = TextEditingController();

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(commandeControllerProvider.notifier);
    final commandeId = await controller.createCommande(
      context: _contextFromTable(_tableController.text),
    );

    if (!mounted) return;
    final state = ref.read(commandeControllerProvider);
    if (!state.hasError) context.go(Routes.commandeDetailPath(commandeId));
  }

  String? _contextFromTable(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final hasTablePrefix = trimmed.toLowerCase().startsWith('table');
    return hasTablePrefix ? trimmed : 'Table $trimmed';
  }

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
                  TextField(
                    controller: _tableController,
                    enabled: !state.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de table',
                      hintText: 'Ex. 12',
                      prefixIcon: Icon(Icons.table_restaurant_outlined),
                    ),
                    keyboardType: TextInputType.number,
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
