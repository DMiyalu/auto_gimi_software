import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/prestation_providers.dart';

/// Ouverture d'une prestation : la seule information demandée est le
/// numéro d'immatriculation du véhicule. Le client se rattache ensuite
/// depuis l'onglet "Client" de l'écran de détail.
class NewPrestationScreen extends ConsumerStatefulWidget {
  const NewPrestationScreen({super.key});

  @override
  ConsumerState<NewPrestationScreen> createState() =>
      _NewPrestationScreenState();
}

class _NewPrestationScreenState extends ConsumerState<NewPrestationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _immatriculationController = TextEditingController();

  @override
  void dispose() {
    _immatriculationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final prestationId = await ref
        .read(prestationControllerProvider.notifier)
        .createPrestationForImmatriculation(_immatriculationController.text);

    if (!mounted) return;

    final state = ref.read(prestationControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${state.error}')),
      );
      return;
    }

    context.pushReplacement(Routes.prestationDetailPath(prestationId));
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(prestationControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle prestation')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('immatriculation_field'),
                  controller: _immatriculationController,
                  textCapitalization: TextCapitalization.characters,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Numéro d'immatriculation",
                    hintText: 'CD 214 KM',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? "Le numéro d'immatriculation est requis"
                          : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  key: const Key('new_prestation_submit_button'),
                  onPressed: formState.isLoading ? null : _submit,
                  child: formState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Créer la prestation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
