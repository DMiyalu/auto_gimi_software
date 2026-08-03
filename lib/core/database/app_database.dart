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
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            await _createProductTablesIfMissing(m);
          }
          if (from < 5) {
            await _ensureCatalogItemSchema(m);
          }
          if (from < 6) {
            await _migrateGarageSchema(m);
          }
          if (from < 7) {
            await _addClientProfileColumns(m);
          }
          if (from < 8) {
            await _addProductStockColumn(m);
          }
        },
        beforeOpen: (details) async {
          if (!details.wasCreated) {
            await _createProductTablesIfMissing(Migrator(this));
            await _ensureCatalogItemSchema(Migrator(this));
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

  /// Ajoute `devise` et rend `categorie_id` nullable (produits + services).
  Future<void> _ensureCatalogItemSchema(Migrator m) async {
    // Nettoie d'éventuelles tables temporaires d'une migration interrompue.
    await customStatement('DROP TABLE IF EXISTS tmp_for_copy_produits');
    await customStatement(
      'DROP TABLE IF EXISTS tmp_for_copy_catalog_services',
    );

    await _migrateCatalogTable(
      m: m,
      tableName: 'produits',
      table: produits,
      deviseColumn: produits.devise,
    );
    await _migrateCatalogTable(
      m: m,
      tableName: 'catalog_services',
      table: catalogServices,
      deviseColumn: catalogServices.devise,
    );
  }

  Future<void> _migrateCatalogTable({
    required Migrator m,
    required String tableName,
    required TableInfo table,
    required GeneratedColumn<String> deviseColumn,
  }) async {
    final info = await customSelect('PRAGMA table_info($tableName)').get();
    if (info.isEmpty) return;

    final columns = {
      for (final row in info) row.read<String>('name'): row,
    };
    final hasDevise = columns.containsKey('devise');
    final categorieNotNull =
        columns['categorie_id']?.read<int>('notnull') == 1;

    if (hasDevise && !categorieNotNull) return;

    // Simple ADD COLUMN si seule la devise manque.
    if (!hasDevise && !categorieNotNull) {
      await m.addColumn(table, deviseColumn);
      return;
    }

    // Recréation nécessaire pour rendre categorie_id nullable
    // et/ou injecter devise (absente de l'ancienne table).
    await m.alterTable(
      TableMigration(
        table,
        newColumns: [
          if (!hasDevise) deviseColumn,
        ],
        columnTransformer: {
          if (!hasDevise) deviseColumn: const Constant('USD'),
        },
      ),
    );
  }

  /// Rend nullable `Vehicules.clientId/marque/modele` et
  /// `Prestations.clientId`, et étend `LignePrestations` pour supporter des
  /// lignes "produit" en plus des lignes "service". Ces 3 tables sont
  /// garanties vides (aucun repository ne les utilisait avant l'ajout de la
  /// verticale Prestation) — pas de backfill nécessaire, donc pas de
  /// vérification défensive comme `_migrateCatalogTable` : on ne l'appelle
  /// qu'une fois depuis `onUpgrade` (jamais depuis `beforeOpen`, pour ne pas
  /// reconstruire ces tables à chaque lancement une fois de vraies données
  /// présentes).
  Future<void> _migrateGarageSchema(Migrator m) async {
    await m.alterTable(TableMigration(vehicules));
    await m.alterTable(TableMigration(prestations));
    await m.alterTable(
      TableMigration(
        lignePrestations,
        newColumns: [
          lignePrestations.type,
          lignePrestations.produitId,
          lignePrestations.libelle,
        ],
        columnTransformer: {
          lignePrestations.type: const Constant('service'),
          lignePrestations.libelle: const Constant(''),
        },
      ),
    );
  }

  /// Ajoute le profil étendu du client (email, adresse, type, notes) requis
  /// par l'écran de détail — simples colonnes nullables/à défaut, ajout
  /// additif sans backfill.
  Future<void> _addClientProfileColumns(Migrator m) async {
    await m.addColumn(clients, clients.email);
    await m.addColumn(clients, clients.adresse);
    await m.addColumn(clients, clients.typeClient);
    await m.addColumn(clients, clients.notes);
  }

  /// Ajoute la quantité en stock des produits — colonne additive à défaut
  /// `0`, aucun backfill nécessaire.
  Future<void> _addProductStockColumn(Migrator m) async {
    await m.addColumn(produits, produits.stock);
  }
}

Future<AppDatabase> openAppDatabase() async {
  final executor = await createDatabaseConnection();
  return AppDatabase(executor);
}
