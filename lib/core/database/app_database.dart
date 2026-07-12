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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            await _createProductTablesIfMissing(m);
          }
          if (from < 4) {
            await _migrateToV4(m);
          }
        },
        beforeOpen: (details) async {
          if (!details.wasCreated) {
            await _createProductTablesIfMissing(Migrator(this));
            await _ensureDeviseColumns();
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

  Future<void> _migrateToV4(Migrator m) async {
    // Recrée les tables pour: categorieId nullable + colonne devise.
    await m.alterTable(TableMigration(produits));
    await m.alterTable(TableMigration(catalogServices));
  }

  Future<void> _ensureDeviseColumns() async {
    final produitCols = await customSelect('PRAGMA table_info(produits)').get();
    final produitNames =
        produitCols.map((row) => row.read<String>('name')).toSet();
    if (produitNames.isNotEmpty && !produitNames.contains('devise')) {
      await Migrator(this).addColumn(produits, produits.devise);
    }

    final serviceCols =
        await customSelect('PRAGMA table_info(catalog_services)').get();
    final serviceNames =
        serviceCols.map((row) => row.read<String>('name')).toSet();
    if (serviceNames.isNotEmpty && !serviceNames.contains('devise')) {
      await Migrator(this).addColumn(catalogServices, catalogServices.devise);
    }
  }
}

Future<AppDatabase> openAppDatabase() async {
  final executor = await createDatabaseConnection();
  return AppDatabase(executor);
}
