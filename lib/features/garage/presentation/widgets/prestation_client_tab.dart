import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../../core/presentation/widgets/phone_number_field.dart';
import '../../../../core/sync/auto_sync_coordinator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../clients/domain/entities/client_entity.dart';
import '../../../clients/presentation/providers/client_providers.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../providers/prestation_providers.dart';

/// Onglet "Client" — infos du client rattaché, ou recherche par téléphone
/// (et création à la volée) s'il n'y en a pas encore.
class PrestationClientTab extends ConsumerWidget {
  const PrestationClientTab({super.key, required this.prestationId});

  final String prestationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestationAsync = ref.watch(prestationProvider(prestationId));

    return prestationAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (prestation) {
        final clientId = prestation?.clientId;
        if (clientId == null) {
          return _ClientSearchSection(prestationId: prestationId);
        }
        return _AttachedClientCard(
          clientId: clientId,
          prestationId: prestationId,
        );
      },
    );
  }
}

class _AttachedClientCard extends ConsumerWidget {
  const _AttachedClientCard({
    required this.clientId,
    required this.prestationId,
  });

  final String clientId;
  final String prestationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientByIdProvider(clientId));

    return clientAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (client) {
        if (client == null) {
          return const Center(child: Text('Client introuvable.'));
        }
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          client.name.isNotEmpty
                              ? client.name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(client.displayPhone),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.card_giftcard_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('${client.loyaltyPoints} points bonus'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Changer de client'),
                          content: const Text(
                            'Retirer ce client de la prestation pour en '
                            'rechercher un autre ?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: const Text('Annuler'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                ref
                                    .read(prestationControllerProvider.notifier)
                                    .detachClient(prestationId);
                              },
                              child: const Text('Changer'),
                            ),
                          ],
                        ),
                      ),
                      child: const Text('Changer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClientSearchSection extends ConsumerStatefulWidget {
  const _ClientSearchSection({required this.prestationId});

  final String prestationId;

  @override
  ConsumerState<_ClientSearchSection> createState() =>
      _ClientSearchSectionState();
}

class _ClientSearchSectionState extends ConsumerState<_ClientSearchSection> {
  final _nameController = TextEditingController();
  String _phone = '';
  bool _searched = false;
  bool _loading = false;
  ClientEntity? _found;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (!PhoneAuthMapper.isValidFullNumber(_phone)) return;

    setState(() {
      _loading = true;
      _searched = false;
      _found = null;
    });

    final client =
        await ref.read(clientRepositoryProvider).findByPhone(_phone);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _searched = true;
      _found = client;
    });
  }

  Future<void> _attach(String clientId) async {
    await ref.read(prestationControllerProvider.notifier).attachClient(
          prestationId: widget.prestationId,
          clientId: clientId,
        );
  }

  Future<void> _createAndAttach() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) return;

    setState(() => _loading = true);
    try {
      final client = await ref.read(clientRepositoryProvider).createClient(
            establishmentId: establishment.id,
            name: name,
            whatsappPhone: _phone,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
      if (!mounted) return;
      await _attach(client.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PhoneNumberField(
            labelText: 'Trouver le client (numéro de téléphone)',
            enabled: !_loading,
            onFullNumberChanged: (value) => setState(() => _phone = value),
          ),
          const SizedBox(height: AppSpacing.xs),
          FilledButton(
            onPressed:
                _loading || !PhoneAuthMapper.isValidFullNumber(_phone)
                    ? null
                    : _search,
            child: const Text('Rechercher'),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_searched && !_loading) ...[
            if (_found != null)
              Card(
                child: ListTile(
                  title: Text(_found!.name),
                  subtitle: Text(_found!.displayPhone),
                  trailing: FilledButton(
                    onPressed: () => _attach(_found!.id),
                    child: const Text('Rattacher'),
                  ),
                ),
              )
            else ...[
              const Text('Aucun client trouvé avec ce numéro.'),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nom du client'),
              ),
              const SizedBox(height: AppSpacing.xs),
              FilledButton(
                onPressed: _createAndAttach,
                child: const Text('Créer et rattacher'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
