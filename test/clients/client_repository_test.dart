import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
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

    final clients = await repository.watchClients().first;
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
}
