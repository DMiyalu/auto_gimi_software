import 'package:drift/drift.dart';

import 'database_connection/connection.dart';

import '../domain/enums.dart';
import 'converters/enum_converters.dart';
import 'tables/alertes_entretien_table.dart';
import 'tables/catalog_services_table.dart';
import 'tables/categories_table.dart';
import 'tables/clients_table.dart';
import 'tables/jetons_table.dart';
import 'tables/ligne_prestations_table.dart';
import 'tables/notification_queue_table.dart';
import 'tables/prestations_table.dart';
import 'tables/sync_state_table.dart';
import 'tables/vehicules_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Clients,
    Vehicules,
    Categories,
    CatalogServices,
    Prestations,
    LignePrestations,
    Jetons,
    AlertesEntretien,
    NotificationQueue,
    SyncState,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

Future<AppDatabase> openAppDatabase() async {
  final executor = await createDatabaseConnection();
  return AppDatabase(executor);
}
