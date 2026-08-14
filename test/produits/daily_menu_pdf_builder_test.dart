import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/core/domain/app_currency.dart';
import 'package:auto_mobile_software/features/produits/data/services/daily_menu_pdf_builder.dart';
import 'package:auto_mobile_software/features/produits/domain/entities/produit_entity.dart';

void main() {
  test(
    'build genere un PDF de menu du jour avec les produits selectionnes',
    () async {
      final now = DateTime(2026, 8, 15, 12);
      final products = [
        ProduitEntity(
          id: 'p-1',
          categoryId: 'c-1',
          categoryName: 'Plats principaux',
          name: 'Poulet mayo',
          price: 12000,
          currency: AppCurrency.cdf,
          stock: 0,
          stockTrackingEnabled: false,
          createdAt: now,
          updatedAt: now,
        ),
        ProduitEntity(
          id: 'p-2',
          categoryId: 'c-2',
          categoryName: 'Boissons',
          name: 'Jus naturel',
          price: 3000,
          currency: AppCurrency.cdf,
          stock: 0,
          stockTrackingEnabled: false,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final bytes = await const DailyMenuPdfBuilder().build(
        establishmentName: 'Restaurant Zolana',
        products: products,
        date: now,
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    },
  );
}
