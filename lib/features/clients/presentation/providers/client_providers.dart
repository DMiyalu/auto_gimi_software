import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/client_type.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/sync/auto_sync_coordinator.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryImpl(database: ref.watch(databaseProvider));
});

final clientsProvider = StreamProvider<List<ClientEntity>>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value([]);
  return ref
      .watch(clientRepositoryProvider)
      .watchClients(establishmentId: establishment.id);
});

final clientByIdProvider = StreamProvider.family<ClientEntity?, String>((
  ref,
  id,
) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value(null);
  return ref
      .watch(clientRepositoryProvider)
      .watchClient(establishmentId: establishment.id, id: id);
});

/// Filtres rapides de l'écran Clients — indépendants du métier actif
/// (contrairement aux filtres de statut de l'écran principal). Le filtrage
/// effectif (recherche + application) vit dans
/// `client_list_view_providers.dart`, qui a besoin des stats de commandes
/// (garage) pour Actifs ce mois / Inactifs.
enum ClientListFilter { all, fideles, nouveaux, actifsCeMois, inactifs }

final clientSearchQueryProvider = StateProvider<String>((ref) => '');

final clientListFilterProvider = StateProvider<ClientListFilter>(
  (ref) => ClientListFilter.all,
);

final clientControllerProvider = AsyncNotifierProvider<ClientController, void>(
  ClientController.new,
);

class ClientController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createClient({
    required String name,
    required String whatsappPhone,
    String? email,
    String? address,
    ClientType clientType = ClientType.individual,
    String? notes,
  }) async {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(clientRepositoryProvider)
          .createClient(
            establishmentId: establishment.id,
            name: name,
            whatsappPhone: whatsappPhone,
            email: email,
            address: address,
            clientType: clientType,
            notes: notes,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  Future<void> updateClient({
    required String id,
    required String name,
    required String whatsappPhone,
    String? email,
    String? address,
    ClientType clientType = ClientType.individual,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(clientRepositoryProvider)
          .updateClient(
            id: id,
            name: name,
            whatsappPhone: whatsappPhone,
            email: email,
            address: address,
            clientType: clientType,
            notes: notes,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }
}
