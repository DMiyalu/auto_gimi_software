import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/phone_number_field.dart';
import '../providers/client_providers.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _whatsappPhone = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(clientControllerProvider.notifier).createClient(
          name: _nameController.text,
          whatsappPhone: _whatsappPhone,
        );

    if (!mounted) return;

    final state = ref.read(clientControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorMapper.message(state.error!))),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).clientCreated)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formState = ref.watch(clientControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addClient)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('client_name_field'),
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.clientName),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? l10n.clientName
                          : null,
                ),
                const SizedBox(height: 16),
                PhoneNumberField(
                  key: const Key('client_whatsapp_field'),
                  labelText: l10n.whatsappNumber,
                  enabled: !formState.isLoading,
                  localNumberKey: const Key('client_whatsapp_local_field'),
                  onFullNumberChanged: (value) => _whatsappPhone = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.whatsappNumber;
                    }
                    if (!PhoneAuthMapper.isValidFullNumber(value)) {
                      return l10n.phoneNumberInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                FilledButton(
                  key: const Key('client_submit_button'),
                  onPressed: formState.isLoading ? null : _submit,
                  child: formState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveClient),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
