// Preuve directe du besoin "plusieurs serveurs, tous à jour" : deux
// appareils indépendants (deux ProviderContainer, chacun avec sa propre
// base Drift locale) partageant le même Firestore. Le device A modifie une
// commande ; le device B, resté totalement inactif (aucune écriture locale,
// aucun changement de connectivité), doit détecter le changement via son
// écouteur Firestore temps réel — sans attendre le filet de sécurité (5min).
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/core/providers/database_provider.dart';
import 'package:auto_mobile_software/core/sync/auto_sync_coordinator.dart';
import 'package:auto_mobile_software/core/sync/sync_engine.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_member.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';
import 'package:auto_mobile_software/features/establishment/presentation/providers/establishment_providers.dart';
import 'package:auto_mobile_software/features/restaurant/presentation/providers/commande_providers.dart';

const _establishmentId = 'etab-multi-device';

final _establishment = Establishment(
  id: _establishmentId,
  name: 'Le Goût Parfait',
  category: BusinessCategory.restaurant,
  ownerId: 'owner-1',
  managerName: 'Jean Kalonji',
  phone: '+243900000000',
  phoneVerified: true,
  createdAt: DateTime(2026, 1, 1),
);

class _Device {
  _Device(this.container, this.database);

  final ProviderContainer container;
  final AppDatabase database;

  Future<void> disposeDevice() async {
    // Le container en premier : ça déclenche AutoSyncCoordinator.dispose()
    // (annule timers et écouteurs Firestore) avant de fermer la base sur
    // laquelle un cycle de synchro pourrait encore écrire.
    container.dispose();
    await database.close();
  }
}

Future<_Device> _createDevice(FakeFirebaseFirestore sharedFirestore) async {
  final database = AppDatabase(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [
      currentEstablishmentProvider.overrideWith(
        (ref) => Stream.value(_establishment),
      ),
      userMembershipsProvider.overrideWith(
        (ref) => Stream.value([
          EstablishmentMember(
            uid: 'owner-1',
            establishmentId: _establishmentId,
            phone: '+243900000000',
            fullName: 'Jean Kalonji',
            role: EstablishmentRole.owner,
            phoneVerified: true,
            joinedAt: DateTime(2026, 1, 1),
          ),
        ]),
      ),
      databaseProvider.overrideWithValue(database),
      firestoreProvider.overrideWithValue(sharedFirestore),
      canCreateActivitiesProvider.overrideWithValue(true),
    ],
  );
  // Maintient AutoSyncCoordinator vivant pour toute la durée du test, comme
  // le fait AppShellScreen via ref.watch dans la vraie app.
  container.listen(autoSyncCoordinatorProvider, (_, _) {});
  // Laisse le temps au StreamProvider de résoudre sa première valeur avant
  // toute utilisation (sinon currentEstablishmentProvider est encore en
  // AsyncLoading juste après la création du container).
  await container.read(currentEstablishmentProvider.future);
  return _Device(container, database);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'un changement fait sur un appareil est détecté par un autre appareil '
    'du même établissement, sans action locale de sa part (temps réel)',
    () async {
      final sharedFirestore = FakeFirebaseFirestore();
      final deviceA = await _createDevice(sharedFirestore);
      final deviceB = await _createDevice(sharedFirestore);
      addTearDown(() async {
        await deviceA.disposeDevice();
        await deviceB.disposeDevice();
      });

      // Device A crée une commande et l'encaisse directement.
      final commandeId = await deviceA.container
          .read(commandeControllerProvider.notifier)
          .createCommande(context: 'Table 3');
      await Future<void>.delayed(const Duration(milliseconds: 1700));

      var remoteDoc = await sharedFirestore
          .collection('establishments/$_establishmentId/commandes')
          .doc(commandeId)
          .get();
      expect(remoteDoc.data()?['statut'], 'en_cours');

      await deviceA.container
          .read(commandeControllerProvider.notifier)
          .registerPayment(commandeId: commandeId);
      await Future<void>.delayed(const Duration(milliseconds: 1700));

      remoteDoc = await sharedFirestore
          .collection('establishments/$_establishmentId/commandes')
          .doc(commandeId)
          .get();
      expect(remoteDoc.data()?['statut'], 'cloturee');

      // Laisse le temps au second cycle temps réel de device B (débounce
      // ~1s + pull) de réagir à ce second changement distant : son premier
      // cycle a déjà pu consommer le précédent ("en_cours") entre-temps.
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Device B n'a rien fait localement (aucune écriture, aucun
      // changement de connectivité) : seul son écouteur Firestore temps
      // réel peut lui avoir appris le changement fait par device A — et il
      // doit déjà refléter l'état final clôturé.
      final localOnB = await deviceB.container
          .read(commandeRepositoryProvider)
          .watchCommande(establishmentId: _establishmentId, id: commandeId)
          .first;
      expect(localOnB, isNotNull);
      expect(localOnB!.statusKey, 'cloturee');
    },
  );
}
