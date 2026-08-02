import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/sync/auto_sync_coordinator.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../data/repositories/prestation_repository_impl.dart';
import '../../domain/entities/ligne_prestation_entity.dart';
import '../../domain/entities/prestation_entity.dart';
import '../../domain/entities/prestation_summary.dart';
import '../../domain/entities/vehicule_entity.dart';
import '../../domain/repositories/prestation_repository.dart';

final prestationRepositoryProvider = Provider<PrestationRepository>((ref) {
  return PrestationRepositoryImpl(database: ref.watch(databaseProvider));
});

final prestationProvider =
    StreamProvider.family<PrestationEntity?, String>((ref, id) {
  return ref.watch(prestationRepositoryProvider).watchPrestation(id);
});

final vehiculeProvider =
    StreamProvider.family<VehiculeEntity?, String>((ref, id) {
  return ref.watch(prestationRepositoryProvider).watchVehicule(id);
});

final prestationsSummaryProvider = StreamProvider<List<PrestationSummary>>((ref) {
  return ref.watch(prestationRepositoryProvider).watchPrestationsSummary();
});

final prestationsForClientProvider =
    StreamProvider.family<List<PrestationSummary>, String>((ref, clientId) {
  return ref
      .watch(prestationRepositoryProvider)
      .watchPrestationsForClient(clientId);
});

final prestationLinesProvider =
    StreamProvider.family<List<LignePrestationEntity>, String>(
  (ref, prestationId) {
    return ref.watch(prestationRepositoryProvider).watchLignes(prestationId);
  },
);

final prestationControllerProvider =
    AsyncNotifierProvider<PrestationController, void>(
  PrestationController.new,
);

class PrestationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  String _requireEstablishmentId() {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }
    return establishment.id;
  }

  Future<String> createPrestationForImmatriculation(
    String immatriculation,
  ) async {
    final establishmentId = _requireEstablishmentId();
    String? prestationId;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final prestation = await ref
          .read(prestationRepositoryProvider)
          .createPrestationForImmatriculation(
            establishmentId: establishmentId,
            immatriculation: immatriculation,
          );
      prestationId = prestation.id;
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });

    if (state.hasError) {
      throw state.error!;
    }
    return prestationId!;
  }

  Future<void> addServiceLine({
    required String prestationId,
    required String serviceId,
  }) async {
    final establishmentId = _requireEstablishmentId();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prestationRepositoryProvider).addServiceLine(
            establishmentId: establishmentId,
            prestationId: prestationId,
            serviceId: serviceId,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  Future<void> addProduitLine({
    required String prestationId,
    required String produitId,
  }) async {
    final establishmentId = _requireEstablishmentId();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prestationRepositoryProvider).addProduitLine(
            establishmentId: establishmentId,
            prestationId: prestationId,
            produitId: produitId,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  Future<void> removeLine(String ligneId) async {
    final establishmentId = _requireEstablishmentId();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prestationRepositoryProvider).removeLine(
            establishmentId: establishmentId,
            ligneId: ligneId,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  Future<void> attachClient({
    required String prestationId,
    required String clientId,
  }) async {
    final establishmentId = _requireEstablishmentId();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prestationRepositoryProvider).attachClient(
            establishmentId: establishmentId,
            prestationId: prestationId,
            clientId: clientId,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  Future<void> detachClient(String prestationId) async {
    final establishmentId = _requireEstablishmentId();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prestationRepositoryProvider).detachClient(
            establishmentId: establishmentId,
            prestationId: prestationId,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }
}
