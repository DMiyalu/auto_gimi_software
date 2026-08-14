import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/database/app_database.dart';
import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/features/produits/data/repositories/produit_repository_impl.dart';
import 'package:auto_mobile_software/features/restaurant/data/repositories/commande_repository_impl.dart';
import 'package:auto_mobile_software/features/restaurant/domain/entities/commande_entity.dart';

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

  test(
    'ajoute un produit non suivi en stock sans bloquer la commande',
    () async {
      final produit = await produitRepository.createProduit(
        establishmentId: 'est-1',
        name: 'Menu du jour',
        price: 15,
        currency: AppCurrency.usd,
        stock: 0,
        stockTrackingEnabled: false,
      );
      final commande = await commandeRepository.createCommande(
        establishmentId: 'est-1',
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
      expect(lignes.single.quantity, 2);
      expect(lignes.single.lineAmount, 30);

      final updatedProduit = await produitRepository.getProduit(
        establishmentId: 'est-1',
        id: produit.id,
      );
      expect(updatedProduit!.stock, 0);
      expect(updatedProduit.stockTrackingEnabled, isFalse);
    },
  );

  test('une commande nait au statut en_cours', () async {
    final commande = await commandeRepository.createCommande(
      establishmentId: 'est-1',
    );

    expect(commande.statusKey, 'en_cours');
    expect(commande.statusLabel, 'En cours');
  });

  test(
    'imprimer la facture (markAwaitingPayment) fait passer en_cours -> a_payer',
    () async {
      final commande = await commandeRepository.createCommande(
        establishmentId: 'est-1',
        context: 'Livraison',
      );

      await commandeRepository.markAwaitingPayment(
        establishmentId: 'est-1',
        commandeId: commande.id,
      );

      final updated = await commandeRepository
          .watchCommande(establishmentId: 'est-1', id: commande.id)
          .first;

      expect(updated!.statusKey, 'a_payer');
      expect(updated.statusLabel, 'À payer');
    },
  );

  test('markAwaitingPayment est idempotent quand deja a_payer', () async {
    final commande = await commandeRepository.createCommande(
      establishmentId: 'est-1',
    );
    await commandeRepository.markAwaitingPayment(
      establishmentId: 'est-1',
      commandeId: commande.id,
    );

    await commandeRepository.markAwaitingPayment(
      establishmentId: 'est-1',
      commandeId: commande.id,
    );

    final updated = await commandeRepository
        .watchCommande(establishmentId: 'est-1', id: commande.id)
        .first;
    expect(updated!.statusKey, 'a_payer');
  });

  test(
    'encaisser le paiement (registerPayment) depuis a_payer cloture la commande',
    () async {
      final commande = await commandeRepository.createCommande(
        establishmentId: 'est-1',
      );
      await commandeRepository.markAwaitingPayment(
        establishmentId: 'est-1',
        commandeId: commande.id,
      );

      await commandeRepository.registerPayment(
        establishmentId: 'est-1',
        commandeId: commande.id,
        paymentMethod: CommandePaymentMethod.mpesa,
      );

      final updated = await commandeRepository
          .watchCommande(establishmentId: 'est-1', id: commande.id)
          .first;
      expect(updated!.statusKey, 'cloturee');
      expect(updated.statusLabel, 'Clôturée');
      expect(updated.paymentMethod, CommandePaymentMethod.mpesa);
    },
  );

  test(
    'encaisser le paiement sans facture imprimee cloture directement depuis en_cours',
    () async {
      final commande = await commandeRepository.createCommande(
        establishmentId: 'est-1',
      );

      await commandeRepository.registerPayment(
        establishmentId: 'est-1',
        commandeId: commande.id,
      );

      final updated = await commandeRepository
          .watchCommande(establishmentId: 'est-1', id: commande.id)
          .first;
      expect(updated!.statusKey, 'cloturee');
    },
  );

  test('registerPayment est idempotent quand deja cloturee', () async {
    final commande = await commandeRepository.createCommande(
      establishmentId: 'est-1',
    );
    await commandeRepository.registerPayment(
      establishmentId: 'est-1',
      commandeId: commande.id,
    );

    await commandeRepository.registerPayment(
      establishmentId: 'est-1',
      commandeId: commande.id,
    );

    final updated = await commandeRepository
        .watchCommande(establishmentId: 'est-1', id: commande.id)
        .first;
    expect(updated!.statusKey, 'cloturee');
  });

  test(
    'une commande cloturee ne peut plus etre modifiee ni annulee, mais reste imprimable',
    () async {
      final produit = await produitRepository.createProduit(
        establishmentId: 'est-1',
        name: 'Poulet braisé',
        price: 10,
        currency: AppCurrency.usd,
        stock: 5,
      );
      final commande = await commandeRepository.createCommande(
        establishmentId: 'est-1',
      );
      await commandeRepository.registerPayment(
        establishmentId: 'est-1',
        commandeId: commande.id,
      );

      await expectLater(
        commandeRepository.addProduitLine(
          establishmentId: 'est-1',
          commandeId: commande.id,
          produitId: produit.id,
        ),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        commandeRepository.cancelCommande(
          establishmentId: 'est-1',
          commandeId: commande.id,
        ),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        commandeRepository.markAwaitingPayment(
          establishmentId: 'est-1',
          commandeId: commande.id,
        ),
        throwsA(isA<StateError>()),
      );

      // L'impression (relecture de la facture) reste possible : aucune
      // exception à la simple lecture de la commande clôturée.
      final stillReadable = await commandeRepository
          .watchCommande(establishmentId: 'est-1', id: commande.id)
          .first;
      expect(stillReadable!.statusKey, 'cloturee');
    },
  );

  test(
    'une commande a_payer peut encore etre annulee mais plus modifiee',
    () async {
      final produit = await produitRepository.createProduit(
        establishmentId: 'est-1',
        name: 'Jus de gingembre',
        price: 4,
        currency: AppCurrency.usd,
        stock: 5,
      );
      final commande = await commandeRepository.createCommande(
        establishmentId: 'est-1',
      );
      await commandeRepository.markAwaitingPayment(
        establishmentId: 'est-1',
        commandeId: commande.id,
      );

      await expectLater(
        commandeRepository.addProduitLine(
          establishmentId: 'est-1',
          commandeId: commande.id,
          produitId: produit.id,
        ),
        throwsA(isA<StateError>()),
      );

      await commandeRepository.cancelCommande(
        establishmentId: 'est-1',
        commandeId: commande.id,
      );

      final updated = await commandeRepository
          .watchCommande(establishmentId: 'est-1', id: commande.id)
          .first;
      expect(updated!.statusKey, 'annulees');
    },
  );

  test('fusionne deux ajouts du meme produit sur une commande', () async {
    final produit = await produitRepository.createProduit(
      establishmentId: 'est-1',
      name: 'Burger',
      price: 8,
      currency: AppCurrency.usd,
      stock: 5,
    );
    final commande = await commandeRepository.createCommande(
      establishmentId: 'est-1',
    );

    await commandeRepository.addProduitLine(
      establishmentId: 'est-1',
      commandeId: commande.id,
      produitId: produit.id,
      quantity: 1,
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
    expect(lignes.single.quantity, 3);
    expect(lignes.single.lineAmount, 24);

    final updatedProduit = await produitRepository.getProduit(
      establishmentId: 'est-1',
      id: produit.id,
    );
    expect(updatedProduit!.stock, 2);
  });

  test('retire une ligne et restaure le stock produit', () async {
    final produit = await produitRepository.createProduit(
      establishmentId: 'est-1',
      name: 'Jus naturel',
      price: 3,
      currency: AppCurrency.usd,
      stock: 4,
    );
    final commande = await commandeRepository.createCommande(
      establishmentId: 'est-1',
    );
    await commandeRepository.addProduitLine(
      establishmentId: 'est-1',
      commandeId: commande.id,
      produitId: produit.id,
      quantity: 2,
    );

    final line =
        (await commandeRepository
                .watchLignes(establishmentId: 'est-1', commandeId: commande.id)
                .first)
            .single;

    await commandeRepository.removeLine(
      establishmentId: 'est-1',
      lineId: line.id,
    );

    final lignes = await commandeRepository
        .watchLignes(establishmentId: 'est-1', commandeId: commande.id)
        .first;
    expect(lignes, isEmpty);

    final commandes = await commandeRepository
        .watchCommandes(establishmentId: 'est-1')
        .first;
    expect(commandes.single.totalAmount, 0);

    final updatedProduit = await produitRepository.getProduit(
      establishmentId: 'est-1',
      id: produit.id,
    );
    expect(updatedProduit!.stock, 4);
  });

  test(
    'annule une commande et restaure le stock de toutes les lignes',
    () async {
      final pizza = await produitRepository.createProduit(
        establishmentId: 'est-1',
        name: 'Pizza',
        price: 12,
        currency: AppCurrency.usd,
        stock: 5,
      );
      final jus = await produitRepository.createProduit(
        establishmentId: 'est-1',
        name: 'Jus',
        price: 3,
        currency: AppCurrency.usd,
        stock: 4,
      );
      final commande = await commandeRepository.createCommande(
        establishmentId: 'est-1',
      );
      await commandeRepository.addProduitLine(
        establishmentId: 'est-1',
        commandeId: commande.id,
        produitId: pizza.id,
        quantity: 2,
      );
      await commandeRepository.addProduitLine(
        establishmentId: 'est-1',
        commandeId: commande.id,
        produitId: jus.id,
        quantity: 1,
      );

      await commandeRepository.cancelCommande(
        establishmentId: 'est-1',
        commandeId: commande.id,
      );

      final updated = await commandeRepository
          .watchCommande(establishmentId: 'est-1', id: commande.id)
          .first;
      expect(updated!.statusKey, 'annulees');
      expect(updated.totalAmount, 0);

      final lignes = await commandeRepository
          .watchLignes(establishmentId: 'est-1', commandeId: commande.id)
          .first;
      expect(lignes, isEmpty);

      final updatedPizza = await produitRepository.getProduit(
        establishmentId: 'est-1',
        id: pizza.id,
      );
      final updatedJus = await produitRepository.getProduit(
        establishmentId: 'est-1',
        id: jus.id,
      );
      expect(updatedPizza!.stock, 5);
      expect(updatedJus!.stock, 4);
    },
  );

  test('refuse les modifications apres annulation', () async {
    final produit = await produitRepository.createProduit(
      establishmentId: 'est-1',
      name: 'Eau',
      price: 1,
      currency: AppCurrency.usd,
      stock: 3,
    );
    final commande = await commandeRepository.createCommande(
      establishmentId: 'est-1',
    );
    await commandeRepository.cancelCommande(
      establishmentId: 'est-1',
      commandeId: commande.id,
    );

    await expectLater(
      commandeRepository.addProduitLine(
        establishmentId: 'est-1',
        commandeId: commande.id,
        produitId: produit.id,
      ),
      throwsA(isA<StateError>()),
    );

    await expectLater(
      commandeRepository.markAwaitingPayment(
        establishmentId: 'est-1',
        commandeId: commande.id,
      ),
      throwsA(isA<StateError>()),
    );

    await expectLater(
      commandeRepository.registerPayment(
        establishmentId: 'est-1',
        commandeId: commande.id,
      ),
      throwsA(isA<StateError>()),
    );
  });
}
