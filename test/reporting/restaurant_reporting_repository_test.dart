import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';
import 'package:auto_mobile_software/features/reporting/data/repositories/restaurant_reporting_repository_impl.dart';
import 'package:auto_mobile_software/features/reporting/domain/entities/report_date_range.dart';
import 'package:auto_mobile_software/features/restaurant/data/repositories/commande_repository_impl.dart';
import 'package:auto_mobile_software/features/restaurant/domain/entities/commande_entity.dart';

void main() {
  late AppDatabase database;
  late CommandeRepositoryImpl commandeRepository;
  late ProduitRepositoryImpl produitRepository;
  late RestaurantReportingRepositoryImpl reportingRepository;

  const establishmentId = 'etab-1';

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    commandeRepository = CommandeRepositoryImpl(database: database);
    produitRepository = ProduitRepositoryImpl(database: database);
    reportingRepository = RestaurantReportingRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> _backdateCommande(String id, DateTime createdAt) async {
    await (database.update(database.commandes)..where((c) => c.id.equals(id)))
        .write(
          CommandesCompanion(
            createdAt: Value(createdAt),
            updatedAt: Value(createdAt),
          ),
        );
  }

  test(
    'watchProductSales agrège quantités des commandes clôturées et ignore le reste',
    () async {
      final plats = await produitRepository.createCategory(
        establishmentId: establishmentId,
        name: 'Plats',
      );
      final poulet = await produitRepository.createProduit(
        establishmentId: establishmentId,
        categoryId: plats.id,
        name: 'Poulet braisé',
        price: 10000,
        currency: AppCurrency.cdf,
        stock: 50,
      );
      final riz = await produitRepository.createProduit(
        establishmentId: establishmentId,
        categoryId: plats.id,
        name: 'Riz gras',
        price: 5000,
        currency: AppCurrency.cdf,
        stock: 50,
      );

      final closed = await commandeRepository.createCommande(
        establishmentId: establishmentId,
      );
      await commandeRepository.addProduitLine(
        establishmentId: establishmentId,
        commandeId: closed.id,
        produitId: poulet.id,
        quantity: 3,
      );
      await commandeRepository.addProduitLine(
        establishmentId: establishmentId,
        commandeId: closed.id,
        produitId: riz.id,
        quantity: 1,
      );
      await commandeRepository.registerPayment(
        establishmentId: establishmentId,
        commandeId: closed.id,
      );

      final open = await commandeRepository.createCommande(
        establishmentId: establishmentId,
      );
      await commandeRepository.addProduitLine(
        establishmentId: establishmentId,
        commandeId: open.id,
        produitId: poulet.id,
        quantity: 10,
      );

      final canceled = await commandeRepository.createCommande(
        establishmentId: establishmentId,
      );
      await commandeRepository.addProduitLine(
        establishmentId: establishmentId,
        commandeId: canceled.id,
        produitId: riz.id,
        quantity: 5,
      );
      await commandeRepository.cancelCommande(
        establishmentId: establishmentId,
        commandeId: canceled.id,
      );

      final now = DateTime.now();
      await _backdateCommande(closed.id, now);
      await _backdateCommande(open.id, now);
      await _backdateCommande(canceled.id, now);

      final sales = await reportingRepository
          .watchProductSales(
            establishmentId: establishmentId,
            range: ReportDateRange.today(now),
            categoryId: plats.id,
          )
          .first;

      expect(sales, hasLength(2));
      expect(sales.first.label, 'Poulet braisé');
      expect(sales.first.quantity, 3);
      expect(sales.first.rank, 1);
      expect(sales.last.label, 'Riz gras');
      expect(sales.last.quantity, 1);
      expect(sales.first.percentage + sales.last.percentage, closeTo(100, 0.01));
    },
  );

  test('watchProductSales respecte le filtre de catégorie et la limite', () async {
    final plats = await produitRepository.createCategory(
      establishmentId: establishmentId,
      name: 'Plats',
    );
    final boissons = await produitRepository.createCategory(
      establishmentId: establishmentId,
      name: 'Boissons',
    );
    final poulet = await produitRepository.createProduit(
      establishmentId: establishmentId,
      categoryId: plats.id,
      name: 'Poulet braisé',
      price: 10000,
      currency: AppCurrency.cdf,
      stock: 20,
    );
    final jus = await produitRepository.createProduit(
      establishmentId: establishmentId,
      categoryId: boissons.id,
      name: 'Jus de bissap',
      price: 2000,
      currency: AppCurrency.cdf,
      stock: 20,
    );

    final commande = await commandeRepository.createCommande(
      establishmentId: establishmentId,
    );
    await commandeRepository.addProduitLine(
      establishmentId: establishmentId,
      commandeId: commande.id,
      produitId: poulet.id,
      quantity: 2,
    );
    await commandeRepository.addProduitLine(
      establishmentId: establishmentId,
      commandeId: commande.id,
      produitId: jus.id,
      quantity: 4,
    );
    await commandeRepository.registerPayment(
      establishmentId: establishmentId,
      commandeId: commande.id,
    );
    await _backdateCommande(commande.id, DateTime.now());

    final platsOnly = await reportingRepository
        .watchProductSales(
          establishmentId: establishmentId,
          range: ReportDateRange.today(),
          categoryId: plats.id,
        )
        .first;

    expect(platsOnly, hasLength(1));
    expect(platsOnly.single.label, 'Poulet braisé');
    expect(platsOnly.single.quantity, 2);

    final top1 = await reportingRepository
        .watchProductSales(
          establishmentId: establishmentId,
          range: ReportDateRange.today(),
          limit: 1,
        )
        .first;

    expect(top1, hasLength(1));
    expect(top1.single.label, 'Jus de bissap');
    expect(top1.single.quantity, 4);
  });

  test('watchProductSales ignore les commandes hors période', () async {
    final plats = await produitRepository.createCategory(
      establishmentId: establishmentId,
      name: 'Plats',
    );
    final poulet = await produitRepository.createProduit(
      establishmentId: establishmentId,
      categoryId: plats.id,
      name: 'Poulet braisé',
      price: 10000,
      currency: AppCurrency.cdf,
      stock: 10,
    );

    final old = await commandeRepository.createCommande(
      establishmentId: establishmentId,
    );
    await commandeRepository.addProduitLine(
      establishmentId: establishmentId,
      commandeId: old.id,
      produitId: poulet.id,
      quantity: 2,
    );
    await commandeRepository.registerPayment(
      establishmentId: establishmentId,
      commandeId: old.id,
    );
    await _backdateCommande(old.id, DateTime.now().subtract(const Duration(days: 3)));

    final sales = await reportingRepository
        .watchProductSales(
          establishmentId: establishmentId,
          range: ReportDateRange.today(),
          categoryId: plats.id,
        )
        .first;

    expect(sales, isEmpty);
    // Garde un assert métier utile : statut clôturée bien persisté.
    final commandes = await commandeRepository
        .watchCommandes(establishmentId: establishmentId)
        .first;
    expect(commandes.single.statusKey, CommandeStatus.cloturee);
  });
}
