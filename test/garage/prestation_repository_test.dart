import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/core/domain/enums.dart';
import 'package:auto_mobile_software/features/clients/data/repositories/client_repository_impl.dart';
import 'package:auto_mobile_software/features/garage/data/repositories/prestation_repository_impl.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';
import 'package:auto_mobile_software/features/services/data/repositories/service_repository_impl.dart';

void main() {
  late AppDatabase database;
  late PrestationRepositoryImpl repository;
  late ServiceRepositoryImpl serviceRepository;
  late ProduitRepositoryImpl produitRepository;
  late ClientRepositoryImpl clientRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = PrestationRepositoryImpl(database: database);
    serviceRepository = ServiceRepositoryImpl(database: database);
    produitRepository = ProduitRepositoryImpl(database: database);
    clientRepository = ClientRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('createPrestationForImmatriculation crée un véhicule minimal si '
      "l'immatriculation est inconnue", () async {
    final prestation = await repository.createPrestationForImmatriculation(
      establishmentId: 'est-1',
      immatriculation: 'cd 214 km',
    );

    expect(prestation.statut, PrestationStatut.ouverte);
    expect(prestation.montantTotal, 0);
    expect(prestation.clientId, isNull);

    final vehicule = await repository
        .watchVehicule(prestation.vehiculeId)
        .first;
    expect(vehicule, isNotNull);
    expect(vehicule!.immatriculation, 'CD 214 KM');
    expect(vehicule.clientId, isNull);
    expect(vehicule.marque, isNull);
  });

  test('createPrestationForImmatriculation réutilise le véhicule et son '
      'client pour une immatriculation déjà connue', () async {
    final first = await repository.createPrestationForImmatriculation(
      establishmentId: 'est-1',
      immatriculation: 'CD 214 KM',
    );
    final client = await clientRepository.createClient(
      establishmentId: 'est-1',
      name: 'Jean Kalonji',
      whatsappPhone: '243900000000',
    );
    await repository.attachClient(
      establishmentId: 'est-1',
      prestationId: first.id,
      clientId: client.id,
    );

    final second = await repository.createPrestationForImmatriculation(
      establishmentId: 'est-1',
      immatriculation: 'cd 214 km',
    );

    expect(second.vehiculeId, first.vehiculeId);
    expect(second.clientId, client.id);
    expect(second.id, isNot(first.id));
  });

  test('addServiceLine ajoute une ligne et recalcule le total', () async {
    final prestation = await repository.createPrestationForImmatriculation(
      establishmentId: 'est-1',
      immatriculation: 'CD 001 AA',
    );
    final service = await serviceRepository.createService(
      establishmentId: 'est-1',
      name: 'Vidange',
      price: 45000,
      currency: AppCurrency.usd,
      intervalDays: 0,
    );

    await repository.addServiceLine(
      establishmentId: 'est-1',
      prestationId: prestation.id,
      serviceId: service.id,
    );

    final lignes = await repository.watchLignes(prestation.id).first;
    expect(lignes, hasLength(1));
    expect(lignes.first.libelle, 'Vidange');
    expect(lignes.first.type, LigneType.service);
    expect(lignes.first.quantite, 1);
    expect(lignes.first.montantLigne, 45000);

    final updated = await repository.watchPrestation(prestation.id).first;
    expect(updated!.montantTotal, 45000);
  });

  test("ajouter deux fois le même service incrémente la quantité au lieu "
      'de dupliquer la ligne', () async {
    final prestation = await repository.createPrestationForImmatriculation(
      establishmentId: 'est-1',
      immatriculation: 'CD 002 AA',
    );
    final service = await serviceRepository.createService(
      establishmentId: 'est-1',
      name: 'Filtre à huile',
      price: 10000,
      currency: AppCurrency.usd,
      intervalDays: 0,
    );

    await repository.addServiceLine(
      establishmentId: 'est-1',
      prestationId: prestation.id,
      serviceId: service.id,
    );
    await repository.addServiceLine(
      establishmentId: 'est-1',
      prestationId: prestation.id,
      serviceId: service.id,
    );

    final lignes = await repository.watchLignes(prestation.id).first;
    expect(lignes, hasLength(1));
    expect(lignes.first.quantite, 2);
    expect(lignes.first.montantLigne, 20000);

    final updated = await repository.watchPrestation(prestation.id).first;
    expect(updated!.montantTotal, 20000);
  });

  test(
    'addProduitLine ajoute une ligne produit distincte des services',
    () async {
      final prestation = await repository.createPrestationForImmatriculation(
        establishmentId: 'est-1',
        immatriculation: 'CD 003 AA',
      );
      final produit = await produitRepository.createProduit(
        establishmentId: 'est-1',
        name: 'Huile moteur 5W30',
        price: 25000,
        currency: AppCurrency.usd,
      );

      await repository.addProduitLine(
        establishmentId: 'est-1',
        prestationId: prestation.id,
        produitId: produit.id,
      );

      final lignes = await repository.watchLignes(prestation.id).first;
      expect(lignes, hasLength(1));
      expect(lignes.first.type, LigneType.produit);
      expect(lignes.first.produitId, produit.id);
      expect(lignes.first.serviceId, isNull);
    },
  );

  test('removeLine retire la ligne et recalcule le total', () async {
    final prestation = await repository.createPrestationForImmatriculation(
      establishmentId: 'est-1',
      immatriculation: 'CD 004 AA',
    );
    final service = await serviceRepository.createService(
      establishmentId: 'est-1',
      name: 'Révision',
      price: 60000,
      currency: AppCurrency.usd,
      intervalDays: 0,
    );
    await repository.addServiceLine(
      establishmentId: 'est-1',
      prestationId: prestation.id,
      serviceId: service.id,
    );
    final lignes = await repository.watchLignes(prestation.id).first;

    await repository.removeLine(
      establishmentId: 'est-1',
      ligneId: lignes.first.id,
    );

    final remaining = await repository.watchLignes(prestation.id).first;
    expect(remaining, isEmpty);
    final updated = await repository.watchPrestation(prestation.id).first;
    expect(updated!.montantTotal, 0);
  });

  test(
    'attachClient rattache le client à la prestation et au véhicule',
    () async {
      final prestation = await repository.createPrestationForImmatriculation(
        establishmentId: 'est-1',
        immatriculation: 'CD 005 AA',
      );
      final client = await clientRepository.createClient(
        establishmentId: 'est-1',
        name: 'Grace Mbuyi',
        whatsappPhone: '243911111111',
      );

      await repository.attachClient(
        establishmentId: 'est-1',
        prestationId: prestation.id,
        clientId: client.id,
      );

      final updatedPrestation = await repository
          .watchPrestation(prestation.id)
          .first;
      final updatedVehicule = await repository
          .watchVehicule(prestation.vehiculeId)
          .first;
      expect(updatedPrestation!.clientId, client.id);
      expect(updatedVehicule!.clientId, client.id);
    },
  );

  test('detachClient retire le client de la prestation uniquement', () async {
    final prestation = await repository.createPrestationForImmatriculation(
      establishmentId: 'est-1',
      immatriculation: 'CD 006 AA',
    );
    final client = await clientRepository.createClient(
      establishmentId: 'est-1',
      name: 'Patrick Ilunga',
      whatsappPhone: '243922222222',
    );
    await repository.attachClient(
      establishmentId: 'est-1',
      prestationId: prestation.id,
      clientId: client.id,
    );

    await repository.detachClient(
      establishmentId: 'est-1',
      prestationId: prestation.id,
    );

    final updatedPrestation = await repository
        .watchPrestation(prestation.id)
        .first;
    final updatedVehicule = await repository
        .watchVehicule(prestation.vehiculeId)
        .first;
    expect(updatedPrestation!.clientId, isNull);
    expect(updatedVehicule!.clientId, client.id);
  });

  test('watchClientOrderStats cumule le total dépensé et retient la '
      'dernière commande par client', () async {
    final client = await clientRepository.createClient(
      establishmentId: 'est-1',
      name: 'Grace Mbuyi',
      whatsappPhone: '243944444444',
    );
    final service = await serviceRepository.createService(
      establishmentId: 'est-1',
      name: 'Vidange',
      price: 45000,
      currency: AppCurrency.usd,
      intervalDays: 0,
    );

    final first = await repository.createPrestationForImmatriculation(
      establishmentId: 'est-1',
      immatriculation: 'CD 010 AA',
    );
    await repository.attachClient(
      establishmentId: 'est-1',
      prestationId: first.id,
      clientId: client.id,
    );
    await repository.addServiceLine(
      establishmentId: 'est-1',
      prestationId: first.id,
      serviceId: service.id,
    );

    final second = await repository.createPrestationForImmatriculation(
      establishmentId: 'est-1',
      immatriculation: 'CD 011 BB',
    );
    await repository.attachClient(
      establishmentId: 'est-1',
      prestationId: second.id,
      clientId: client.id,
    );
    await repository.addServiceLine(
      establishmentId: 'est-1',
      prestationId: second.id,
      serviceId: service.id,
    );
    // Force un ordre chronologique déterministe : les deux prestations sont
    // créées dans le même test et peuvent partager le même timestamp.
    await (database.update(
      database.prestations,
    )..where((p) => p.id.equals(first.id))).write(
      PrestationsCompanion(dateOuverture: Value(DateTime(2020, 1, 1))),
    );
    await (database.update(
      database.prestations,
    )..where((p) => p.id.equals(second.id))).write(
      PrestationsCompanion(dateOuverture: Value(DateTime(2020, 6, 1))),
    );

    final stats = await repository.watchClientOrderStats().first;

    expect(stats[client.id]!.totalSpent, 90000);
    expect(stats[client.id]!.lastOrderContext, 'CD 011 BB');
  });

  test(
    'watchClientOrderStats ignore les prestations sans client rattaché',
    () async {
      await repository.createPrestationForImmatriculation(
        establishmentId: 'est-1',
        immatriculation: 'CD 012 CC',
      );

      final stats = await repository.watchClientOrderStats().first;

      expect(stats, isEmpty);
    },
  );

  test('ClientRepository.findByPhone retrouve un client existant', () async {
    await clientRepository.createClient(
      establishmentId: 'est-1',
      name: 'Société Kin Transport',
      whatsappPhone: '243933333333',
    );

    final found = await clientRepository.findByPhone('243933333333');
    final notFound = await clientRepository.findByPhone('243900009999');

    expect(found, isNotNull);
    expect(found!.name, 'Société Kin Transport');
    expect(notFound, isNull);
  });
}
