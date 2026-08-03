import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';
import 'package:auto_mobile_software/features/restaurant/data/repositories/commande_repository_impl.dart';

void main() {
  late AppDatabase database;
  late CommandeRepositoryImpl commandeRepository;
  late ProduitRepositoryImpl produitRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    commandeRepository = CommandeRepositoryImpl(database: database);
    produitRepository = ProduitRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'ajoute un produit a une commande et met a jour total et stock',
    () async {
      final produit = await produitRepository.createProduit(
        establishmentId: 'est-1',
        name: 'Pizza Zolana',
        price: 12,
        currency: AppCurrency.usd,
        stock: 5,
      );
      final commande = await commandeRepository.createCommande(
        establishmentId: 'est-1',
        context: 'Table 4',
      );

      await commandeRepository.addProduitLine(
        establishmentId: 'est-1',
        commandeId: commande.id,
        produitId: produit.id,
        quantity: 2,
      );

      final lignes = await commandeRepository
          .watchLignes(establishmentId: 'est-1', commandeId: commande.id)
          .first;
      expect(lignes, hasLength(1));
      expect(lignes.first.label, 'Pizza Zolana');
      expect(lignes.first.quantity, 2);
      expect(lignes.first.lineAmount, 24);

      final commandes = await commandeRepository
          .watchCommandes(establishmentId: 'est-1')
          .first;
      expect(commandes.single.totalAmount, 24);
      expect(commandes.single.context, 'Table 4');

      final updatedProduit = await produitRepository.getProduit(
        establishmentId: 'est-1',
        id: produit.id,
      );
      expect(updatedProduit!.stock, 3);
    },
  );

  test('observe une commande et persiste le changement de statut', () async {
    final commande = await commandeRepository.createCommande(
      establishmentId: 'est-1',
      context: 'Livraison',
    );

    await commandeRepository.setStatus(
      establishmentId: 'est-1',
      commandeId: commande.id,
      statusKey: 'en_preparation',
    );

    final updated = await commandeRepository
        .watchCommande(establishmentId: 'est-1', id: commande.id)
        .first;

    expect(updated!.statusKey, 'en_preparation');
    expect(updated.statusLabel, 'En préparation');
  });
}
