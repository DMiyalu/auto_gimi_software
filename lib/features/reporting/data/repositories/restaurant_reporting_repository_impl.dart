import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../restaurant/domain/entities/commande_entity.dart';
import '../../domain/entities/product_sales_item.dart';
import '../../domain/entities/report_date_range.dart';
import '../../domain/repositories/restaurant_reporting_repository.dart';

class RestaurantReportingRepositoryImpl
    implements RestaurantReportingRepository {
  RestaurantReportingRepositoryImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  Stream<List<ProductSalesItem>> watchProductSales({
    required String establishmentId,
    required ReportDateRange range,
    String? categoryId,
    int? limit,
  }) {
    final query =
        _database.select(_database.ligneCommandes).join([
            innerJoin(
              _database.commandes,
              _database.commandes.id.equalsExp(
                    _database.ligneCommandes.commandeId,
                  ) &
                  _database.commandes.establishmentId.equals(establishmentId) &
                  _database.commandes.isDeleted.equals(false),
            ),
            leftOuterJoin(
              _database.produits,
              _database.produits.id.equalsExp(
                    _database.ligneCommandes.produitId,
                  ) &
                  _database.produits.establishmentId.equals(establishmentId) &
                  _database.produits.isDeleted.equals(false),
            ),
          ])
          ..where(
            _database.ligneCommandes.establishmentId.equals(establishmentId) &
                _database.ligneCommandes.isDeleted.equals(false) &
                _database.commandes.statut.equals(CommandeStatus.cloturee) &
                _database.commandes.createdAt.isBiggerOrEqualValue(range.start) &
                _database.commandes.createdAt.isSmallerThanValue(range.end),
          );

    if (categoryId != null) {
      query.where(_database.produits.categorieId.equals(categoryId));
    }

    return query.watch().map((rows) {
      final aggregates = <String, _ProductAgg>{};

      for (final row in rows) {
        final ligne = row.readTable(_database.ligneCommandes);
        final produit = row.readTableOrNull(_database.produits);
        final key = ligne.produitId;
        final existing = aggregates[key];
        if (existing == null) {
          aggregates[key] = _ProductAgg(
            produitId: key,
            label: produit?.nom ?? ligne.libelle,
            quantity: ligne.quantite,
            amount: ligne.montantLigne,
          );
        } else {
          existing.quantity += ligne.quantite;
          existing.amount += ligne.montantLigne;
        }
      }

      final sorted = aggregates.values.toList()
        ..sort((a, b) {
          final byQty = b.quantity.compareTo(a.quantity);
          if (byQty != 0) return byQty;
          return a.label.toLowerCase().compareTo(b.label.toLowerCase());
        });

      final totalQty = sorted.fold<int>(0, (sum, item) => sum + item.quantity);
      final bounded = limit == null ? sorted : sorted.take(limit);

      var rank = 0;
      return bounded.map((item) {
        rank++;
        final percentage = totalQty == 0
            ? 0.0
            : (item.quantity / totalQty) * 100;
        return ProductSalesItem(
          produitId: item.produitId,
          label: item.label,
          quantity: item.quantity,
          amount: item.amount,
          percentage: percentage,
          rank: rank,
        );
      }).toList();
    });
  }
}

class _ProductAgg {
  _ProductAgg({
    required this.produitId,
    required this.label,
    required this.quantity,
    required this.amount,
  });

  final String produitId;
  final String label;
  int quantity;
  double amount;
}
