import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/domain/business_category.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/phone_number_field.dart';
import '../providers/establishment_providers.dart';

class EstablishmentFormScreen extends ConsumerStatefulWidget {
  const EstablishmentFormScreen({super.key});

  @override
  ConsumerState<EstablishmentFormScreen> createState() =>
      _EstablishmentFormScreenState();
}

class _EstablishmentFormScreenState
    extends ConsumerState<EstablishmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _establishmentNameController = TextEditingController();
  final _managerNameController = TextEditingController();
  BusinessCategory _category = BusinessCategory.restaurant;
  String _phone = '';

  @override
  void dispose() {
    _establishmentNameController.dispose();
    _managerNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(establishmentControllerProvider.notifier)
        .createOwnedEstablishment(
          category: _category,
          establishmentName: _establishmentNameController.text,
          managerName: _managerNameController.text,
          phone: _phone,
        );

    if (!mounted) return;
    final state = ref.read(establishmentControllerProvider);
    if (!state.hasError) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(establishmentControllerProvider);

    ref.listen(establishmentControllerProvider, (_, next) {
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel établissement')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      child: Icon(_category.icon, size: 36),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<BusinessCategory>(
                      initialValue: _category,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.businessCategory,
                      ),
                      items: BusinessCategory.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.label(l10n)),
                            ),
                          )
                          .toList(),
                      onChanged: state.isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _category = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _establishmentNameController,
                      enabled: !state.isLoading,
                      decoration: InputDecoration(
                        labelText: l10n.establishmentName,
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.establishmentName
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _managerNameController,
                      enabled: !state.isLoading,
                      decoration: InputDecoration(labelText: l10n.managerName),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.managerName
                          : null,
                    ),
                    const SizedBox(height: 16),
                    PhoneNumberField(
                      key: const Key('establishment_phone_field'),
                      labelText: l10n.phoneNumber,
                      enabled: !state.isLoading,
                      localNumberKey: const Key(
                        'establishment_phone_local_field',
                      ),
                      onFullNumberChanged: (value) => _phone = value,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.phoneNumber;
                        }
                        if (!PhoneAuthMapper.isValidFullNumber(value)) {
                          return l10n.phoneNumberInvalid;
                        }
                        return null;
                      },
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
                          : const Icon(Icons.add_business_outlined),
                      label: const Text('Créer l’établissement'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
