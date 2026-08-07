import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/features/reporting/domain/entities/report_date_range.dart';
import 'package:auto_mobile_software/features/reporting/domain/services/restaurant_report_aggregator.dart';
import 'package:auto_mobile_software/features/restaurant/domain/entities/commande_entity.dart';

CommandeEntity _commande({
  required String id,
  required String statusKey,
  required DateTime createdAt,
  double totalAmount = 0,
  String? clientId,
}) {
  return CommandeEntity(
    id: id,
    clientId: clientId,
    reference: 'CMD-$id',
    statusKey: statusKey,
    statusLabel: commandeStatusLabel(statusKey),
    totalAmount: totalAmount,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

void main() {
  final today = DateTime(2026, 6, 6, 12);
  final range = ReportDateRange.today(today);

  group('RestaurantReportAggregator.computeKpis', () {
    test('agrège CA, commandes, panier et clients sur la période', () {
      final commandes = [
        _commande(
          id: '1',
          statusKey: CommandeStatus.cloturee,
          createdAt: DateTime(2026, 6, 6, 10),
          totalAmount: 1000,
          clientId: 'c1',
        ),
        _commande(
          id: '2',
          statusKey: CommandeStatus.cloturee,
          createdAt: DateTime(2026, 6, 6, 11),
          totalAmount: 500,
          clientId: 'c2',
        ),
        _commande(
          id: '3',
          statusKey: CommandeStatus.enCours,
          createdAt: DateTime(2026, 6, 6, 12),
          totalAmount: 200,
          clientId: 'c1',
        ),
      ];

      final kpis = RestaurantReportAggregator.computeKpis(
        commandes: commandes,
        range: range,
      );

      expect(kpis.revenue, 1500);
      expect(kpis.ordersCount, 3);
      expect(kpis.averageBasket, 750);
      expect(kpis.clientsServed, 2);
    });

    test('ignore les commandes annulées et hors période', () {
      final commandes = [
        _commande(
          id: 'ok',
          statusKey: CommandeStatus.cloturee,
          createdAt: DateTime(2026, 6, 6, 9),
          totalAmount: 800,
          clientId: 'c1',
        ),
        _commande(
          id: 'annulee',
          statusKey: CommandeStatus.annulees,
          createdAt: DateTime(2026, 6, 6, 10),
          totalAmount: 999,
          clientId: 'c2',
        ),
        _commande(
          id: 'hier',
          statusKey: CommandeStatus.cloturee,
          createdAt: DateTime(2026, 6, 5, 10),
          totalAmount: 400,
          clientId: 'c3',
        ),
      ];

      final kpis = RestaurantReportAggregator.computeKpis(
        commandes: commandes,
        range: range,
      );

      expect(kpis.revenue, 800);
      expect(kpis.ordersCount, 1);
      expect(kpis.clientsServed, 1);
      // Hier = 400 → variation (800-400)/400 = +100 %
      expect(kpis.revenueChangePercent, closeTo(100, 0.001));
    });

    test('variation null si période précédente à zéro et actuel > 0', () {
      final commandes = [
        _commande(
          id: '1',
          statusKey: CommandeStatus.cloturee,
          createdAt: DateTime(2026, 6, 6, 10),
          totalAmount: 100,
        ),
      ];

      final kpis = RestaurantReportAggregator.computeKpis(
        commandes: commandes,
        range: range,
      );

      expect(kpis.revenueChangePercent, isNull);
      expect(kpis.ordersChangePercent, isNull);
    });

    test('panier moyen à 0 sans commande clôturée', () {
      final commandes = [
        _commande(
          id: '1',
          statusKey: CommandeStatus.enCours,
          createdAt: DateTime(2026, 6, 6, 10),
          totalAmount: 50,
        ),
      ];

      final kpis = RestaurantReportAggregator.computeKpis(
        commandes: commandes,
        range: range,
      );

      expect(kpis.revenue, 0);
      expect(kpis.ordersCount, 1);
      expect(kpis.averageBasket, 0);
    });
  });

  group('RestaurantReportAggregator.computeRevenueEvolution', () {
    test('produit un point par jour, y compris CA à 0', () {
      final week = ReportDateRange.custom(
        start: DateTime(2026, 6, 2),
        end: DateTime(2026, 6, 6),
      );
      final commandes = [
        _commande(
          id: '1',
          statusKey: CommandeStatus.cloturee,
          createdAt: DateTime(2026, 6, 2, 12),
          totalAmount: 520000,
        ),
        _commande(
          id: '2',
          statusKey: CommandeStatus.cloturee,
          createdAt: DateTime(2026, 6, 5, 12),
          totalAmount: 1050000,
        ),
        _commande(
          id: '3',
          statusKey: CommandeStatus.enCours,
          createdAt: DateTime(2026, 6, 6, 12),
          totalAmount: 100,
        ),
      ];

      final points = RestaurantReportAggregator.computeRevenueEvolution(
        commandes: commandes,
        range: week,
      );

      expect(points, hasLength(5));
      expect(points[0].day, DateTime(2026, 6, 2));
      expect(points[0].revenue, 520000);
      expect(points[1].revenue, 0);
      expect(points[2].revenue, 0);
      expect(points[3].revenue, 1050000);
      expect(points[4].revenue, 0); // en_cours ignorée
    });
  });
}
