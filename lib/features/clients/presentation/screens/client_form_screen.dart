import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/domain/client_type.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/phone_number_field.dart';
import '../providers/client_providers.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key, this.clientId});

  final String? clientId;

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _whatsappPhone = '';
  ClientType _clientType = ClientType.individual;
  var _initialized = false;

  bool get _isEditing => widget.clientId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadIfNeeded() {
    if (_initialized || !_isEditing) return;
    final async = ref.read(clientByIdProvider(widget.clientId!));
    async.whenData((client) {
      if (client == null || _initialized) return;
      _nameController.text = client.name;
      _emailController.text = client.email ?? '';
      _addressController.text = client.address ?? '';
      _notesController.text = client.notes ?? '';
      _whatsappPhone = client.whatsappPhone;
      _clientType = client.clientType;
      _initialized = true;
      setState(() {});
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(clientControllerProvider.notifier);
    if (_isEditing) {
      await controller.updateClient(
        id: widget.clientId!,
        name: _nameController.text,
        whatsappPhone: _whatsappPhone,
        email: _emailController.text,
        address: _addressController.text,
        clientType: _clientType,
        notes: _notesController.text,
      );
    } else {
      await controller.createClient(
        name: _nameController.text,
        whatsappPhone: _whatsappPhone,
        email: _emailController.text,
        address: _addressController.text,
        clientType: _clientType,
        notes: _notesController.text,
      );
    }

    if (!mounted) return;

    final state = ref.read(clientControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorMapper.message(state.error!))),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? l10n.clientUpdated : l10n.clientCreated),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formState = ref.watch(clientControllerProvider);

    if (_isEditing) {
      ref.watch(clientByIdProvider(widget.clientId!));
      _loadIfNeeded();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editClient : l10n.addClient),
      ),
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
                  enabled: !formState.isLoading,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.clientName
                      : null,
                ),
                const SizedBox(height: 16),
                PhoneNumberField(
                  key: const Key('client_whatsapp_field'),
                  labelText: l10n.whatsappNumber,
                  enabled: !formState.isLoading,
                  localNumberKey: const Key('client_whatsapp_local_field'),
                  initialValue: _whatsappPhone.isEmpty ? null : _whatsappPhone,
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
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('client_email_field'),
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.clientEmail),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !formState.isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('client_address_field'),
                  controller: _addressController,
                  decoration: InputDecoration(labelText: l10n.clientAddress),
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !formState.isLoading,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ClientType>(
                  key: ValueKey('client_type_$_initialized$_clientType'),
                  initialValue: _clientType,
                  decoration: InputDecoration(labelText: l10n.clientTypeLabel),
                  items: [
                    DropdownMenuItem(
                      value: ClientType.individual,
                      child: Text(l10n.clientTypeIndividual),
                    ),
                    DropdownMenuItem(
                      value: ClientType.business,
                      child: Text(l10n.clientTypeBusiness),
                    ),
                  ],
                  onChanged: formState.isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _clientType = value);
                          }
                        },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('client_notes_field'),
                  controller: _notesController,
                  decoration: InputDecoration(labelText: l10n.clientNotes),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  enabled: !formState.isLoading,
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
