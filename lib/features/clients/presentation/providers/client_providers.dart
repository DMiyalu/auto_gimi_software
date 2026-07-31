import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  return ref.watch(clientRepositoryProvider).watchClients();
});

final clientControllerProvider =
    AsyncNotifierProvider<ClientController, void>(ClientController.new);

class ClientController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createClient({
    required String name,
    required String whatsappPhone,
  }) async {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(clientRepositoryProvider).createClient(
            establishmentId: establishment.id,
            name: name,
            whatsappPhone: whatsappPhone,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }
}
