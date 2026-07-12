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
import 'tables/product_categories_table.dart';
import 'tables/produits_table.dart';
import 'tables/sync_state_table.dart';
import 'tables/vehicules_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Clients,
    Vehicules,
    Categories,
    CatalogServices,
    ProductCategories,
    Produits,
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            await _createProductTablesIfMissing(m);
          }
        },
        beforeOpen: (details) async {
          // Web / hot-reload: le user_version peut déjà être à jour
          // alors que les tables produits n'ont jamais été créées.
          if (!details.wasCreated) {
            await _createProductTablesIfMissing(Migrator(this));
          }
        },
      );

  Future<void> _createProductTablesIfMissing(Migrator m) async {
    final existing = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name IN ('product_categories', 'produits')",
    ).get();
    final names = existing.map((row) => row.read<String>('name')).toSet();

    if (!names.contains('product_categories')) {
      await m.createTable(productCategories);
    }
    if (!names.contains('produits')) {
      await m.createTable(produits);
    }
  }
}

Future<AppDatabase> openAppDatabase() async {
  final executor = await createDatabaseConnection();
  return AppDatabase(executor);
}
