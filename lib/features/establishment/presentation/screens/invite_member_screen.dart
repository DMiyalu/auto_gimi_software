import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/phone_number_field.dart';
import '../../domain/models/establishment_role.dart';
import '../providers/establishment_providers.dart';

class InviteMemberScreen extends ConsumerStatefulWidget {
  const InviteMemberScreen({super.key});

  @override
  ConsumerState<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends ConsumerState<InviteMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  EstablishmentRole _role = EstablishmentRole.agent;
  String _phone = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(establishmentControllerProvider.notifier)
        .createInvitation(role: _role, invitedPhone: _phone);

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
      appBar: AppBar(title: const Text('Inviter un membre')),
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
                    PhoneNumberField(
                      key: const Key('invite_phone_field'),
                      labelText: l10n.phoneNumber,
                      enabled: !state.isLoading,
                      localNumberKey: const Key('invite_phone_local_field'),
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<EstablishmentRole>(
                      initialValue: _role,
                      decoration: const InputDecoration(labelText: 'Rôle'),
                      items: const [
                        DropdownMenuItem(
                          value: EstablishmentRole.agent,
                          child: Text('Agent'),
                        ),
                        DropdownMenuItem(
                          value: EstablishmentRole.manager,
                          child: Text('Gérant'),
                        ),
                      ],
                      onChanged: state.isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _role = value);
                              }
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
                          : const Icon(Icons.send_outlined),
                      label: const Text('Envoyer l’invitation'),
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
