import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/domain/enums.dart';
import 'package:auto_mobile_software/core/sync/auto_sync_coordinator.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/garage/domain/entities/client_order_stats.dart';
import 'package:auto_mobile_software/features/garage/domain/entities/ligne_prestation_entity.dart';
import 'package:auto_mobile_software/features/garage/domain/entities/prestation_entity.dart';
import 'package:auto_mobile_software/features/garage/domain/entities/prestation_summary.dart';
import 'package:auto_mobile_software/features/garage/domain/entities/vehicule_entity.dart';
import 'package:auto_mobile_software/features/garage/domain/repositories/prestation_repository.dart';
import 'package:auto_mobile_software/features/garage/presentation/providers/prestation_providers.dart';

void main() {
  final establishment = Establishment(
    id: 'est-1',
    name: 'Garage Zolana',
    category: BusinessCategory.garageAuto,
    ownerId: 'owner-1',
    managerName: 'Amina Kabasele',
    phone: '+243900000000',
    phoneVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );

  ProviderContainer testContainer({
    required bool canCreateActivities,
    required _FakePrestationRepository repository,
  }) {
    return ProviderContainer(
      overrides: [
        currentEstablishmentProvider.overrideWith(
          (ref) => Stream.value(establishment),
        ),
        canCreateActivitiesProvider.overrideWithValue(canCreateActivities),
        prestationRepositoryProvider.overrideWithValue(repository),
        autoSyncCoordinatorProvider.overrideWithValue(
          _NoopAutoSyncCoordinator(),
        ),
      ],
    );
  }

  test('un agent peut creer une prestation operationnelle', () async {
    final repository = _FakePrestationRepository();
    final container = testContainer(
      canCreateActivities: EstablishmentRole.agent.canCreateActivities,
      repository: repository,
    );
    addTearDown(container.dispose);

    await container.read(currentEstablishmentProvider.future);

    final id = await container
        .read(prestationControllerProvider.notifier)
        .createPrestationForImmatriculation('CD 214 KM');

    expect(id, 'prest-1');
    expect(repository.createdImmatriculations, ['CD 214 KM']);
    expect(container.read(prestationControllerProvider).hasError, isFalse);
  });

  test('le controleur refuse une activite sans role actif', () async {
    final repository = _FakePrestationRepository();
    final container = testContainer(
      canCreateActivities: false,
      repository: repository,
    );
    addTearDown(container.dispose);

    await container.read(currentEstablishmentProvider.future);

    await expectLater(
      container
          .read(prestationControllerProvider.notifier)
          .createPrestationForImmatriculation('CD 214 KM'),
      throwsA(isA<StateError>()),
    );

    expect(repository.createdImmatriculations, isEmpty);
    expect(container.read(prestationControllerProvider).hasError, isTrue);
  });
}

class _NoopAutoSyncCoordinator implements AutoSyncCoordinator {
  @override
  void dispose() {}

  @override
  void schedulePush() {}
}

class _FakePrestationRepository implements PrestationRepository {
  final createdImmatriculations = <String>[];

  @override
  Future<PrestationEntity> createPrestationForImmatriculation({
    required String establishmentId,
    required String immatriculation,
  }) async {
    createdImmatriculations.add(immatriculation);
    final now = DateTime(2026, 1, 1);
    return PrestationEntity(
      id: 'prest-${createdImmatriculations.length}',
      vehiculeId: 'veh-1',
      statut: PrestationStatut.ouverte,
      dateOuverture: now,
      montantTotal: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> addProduitLine({
    required String establishmentId,
    required String prestationId,
    required String produitId,
  }) async {}

  @override
  Future<void> addServiceLine({
    required String establishmentId,
    required String prestationId,
    required String serviceId,
  }) async {}

  @override
  Future<void> attachClient({
    required String establishmentId,
    required String prestationId,
    required String clientId,
  }) async {}

  @override
  Future<void> detachClient({
    required String establishmentId,
    required String prestationId,
  }) async {}

  @override
  Future<void> removeLine({
    required String establishmentId,
    required String ligneId,
  }) async {}

  @override
  Stream<Map<String, ClientOrderStats>> watchClientOrderStats({
    required String establishmentId,
  }) {
    return Stream.value(const {});
  }

  @override
  Stream<List<LignePrestationEntity>> watchLignes({
    required String establishmentId,
    required String prestationId,
  }) {
    return Stream.value(const []);
  }

  @override
  Stream<PrestationEntity?> watchPrestation({
    required String establishmentId,
    required String id,
  }) {
    return Stream.value(null);
  }

  @override
  Stream<List<PrestationSummary>> watchPrestationsForClient({
    required String establishmentId,
    required String clientId,
  }) {
    return Stream.value(const []);
  }

  @override
  Stream<List<PrestationSummary>> watchPrestationsSummary({
    required String establishmentId,
  }) {
    return Stream.value(const []);
  }

  @override
  Stream<VehiculeEntity?> watchVehicule({
    required String establishmentId,
    required String id,
  }) {
    return Stream.value(null);
  }
}
