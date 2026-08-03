import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/client_type.dart';
import 'package:auto_mobile_software/features/clients/data/repositories/client_repository_impl.dart';

void main() {
  late AppDatabase database;
  late ClientRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ClientRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('createClient enregistre nom et whatsapp en local', () async {
    final client = await repository.createClient(
      establishmentId: 'est-1',
      name: 'Amadou Diallo',
      whatsappPhone: '221771234567',
    );

    expect(client.name, 'Amadou Diallo');
    expect(client.whatsappPhone, '221771234567');

    final clients = await repository
        .watchClients(establishmentId: 'est-1')
        .first;
    expect(clients, hasLength(1));
    expect(clients.first.name, 'Amadou Diallo');
    expect(clients.first.displayPhone, '+221771234567');
  });

  test('createClient refuse un doublon whatsapp', () async {
    await repository.createClient(
      establishmentId: 'est-1',
      name: 'Client A',
      whatsappPhone: '221771234567',
    );

    expect(
      () => repository.createClient(
        establishmentId: 'est-1',
        name: 'Client B',
        whatsappPhone: '221771234567',
      ),
      throwsStateError,
    );
  });

  test(
    'createClient autorise le même téléphone dans deux établissements',
    () async {
      final est1Client = await repository.createClient(
        establishmentId: 'est-1',
        name: 'Client Est 1',
        whatsappPhone: '221771234567',
      );
      final est2Client = await repository.createClient(
        establishmentId: 'est-2',
        name: 'Client Est 2',
        whatsappPhone: '221771234567',
      );

      expect(est1Client.id, isNot(est2Client.id));

      final est1Clients = await repository
          .watchClients(establishmentId: 'est-1')
          .first;
      final est2Clients = await repository
          .watchClients(establishmentId: 'est-2')
          .first;

      expect(est1Clients.single.name, 'Client Est 1');
      expect(est2Clients.single.name, 'Client Est 2');
    },
  );

  test('createClient enregistre email, adresse, type et notes', () async {
    final client = await repository.createClient(
      establishmentId: 'est-1',
      name: 'Entreprise A',
      whatsappPhone: '221771234567',
      email: 'contact@entreprise-a.com',
      address: 'Avenue de la Paix, Gombe',
      clientType: ClientType.business,
      notes: 'Facture à 30 jours.',
    );

    expect(client.email, 'contact@entreprise-a.com');
    expect(client.address, 'Avenue de la Paix, Gombe');
    expect(client.clientType, ClientType.business);
    expect(client.notes, 'Facture à 30 jours.');
  });

  test('createClient traite les champs optionnels vides comme null', () async {
    final client = await repository.createClient(
      establishmentId: 'est-1',
      name: 'Client sans profil étendu',
      whatsappPhone: '221771234567',
      email: '   ',
      address: '',
    );

    expect(client.email, isNull);
    expect(client.address, isNull);
    expect(client.clientType, ClientType.individual);
  });

  test('updateClient met à jour le profil et lève isDirty', () async {
    final created = await repository.createClient(
      establishmentId: 'est-1',
      name: 'Amadou Diallo',
      whatsappPhone: '221771234567',
    );

    final updated = await repository.updateClient(
      id: created.id,
      name: 'Amadou D.',
      whatsappPhone: '221771234567',
      email: 'amadou@example.com',
      address: 'Dakar',
      clientType: ClientType.business,
      notes: 'Appelé le 1er janvier.',
    );

    expect(updated.name, 'Amadou D.');
    expect(updated.email, 'amadou@example.com');
    expect(updated.address, 'Dakar');
    expect(updated.clientType, ClientType.business);
    expect(updated.notes, 'Appelé le 1er janvier.');
  });

  test(
    'updateClient refuse un numéro déjà utilisé par un autre client',
    () async {
      await repository.createClient(
        establishmentId: 'est-1',
        name: 'Client A',
        whatsappPhone: '221771111111',
      );
      final clientB = await repository.createClient(
        establishmentId: 'est-1',
        name: 'Client B',
        whatsappPhone: '221772222222',
      );

      expect(
        () => repository.updateClient(
          id: clientB.id,
          name: 'Client B',
          whatsappPhone: '221771111111',
        ),
        throwsStateError,
      );
    },
  );
}
