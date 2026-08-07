import '../../../restaurant/domain/entities/commande_entity.dart';
import '../entities/report_date_range.dart';
import '../entities/restaurant_report_kpis.dart';
import '../entities/revenue_evolution_point.dart';

/// Agrégations pures à partir des commandes déjà chargées.
///
/// Règles :
/// - Commandes / clients : statut ≠ annulée, filtrées sur [CommandeEntity.createdAt]
/// - CA / panier moyen : uniquement les commandes clôturées
/// - Panier moyen = CA / nombre de commandes clôturées
abstract final class RestaurantReportAggregator {
  static RestaurantReportKpis computeKpis({
    required List<CommandeEntity> commandes,
    required ReportDateRange range,
  }) {
    final previous = range.previous;
    final current = _metricsFor(commandes, range);
    final prior = _metricsFor(commandes, previous);

    return RestaurantReportKpis(
      revenue: current.revenue,
      revenueChangePercent: _percentChange(current.revenue, prior.revenue),
      ordersCount: current.ordersCount,
      ordersChangePercent: _percentChange(
        current.ordersCount.toDouble(),
        prior.ordersCount.toDouble(),
      ),
      averageBasket: current.averageBasket,
      averageBasketChangePercent: _percentChange(
        current.averageBasket,
        prior.averageBasket,
      ),
      clientsServed: current.clientsServed,
      clientsServedChangePercent: _percentChange(
        current.clientsServed.toDouble(),
        prior.clientsServed.toDouble(),
      ),
    );
  }

  /// Un point par jour calendaire couvert par [range] (y compris CA = 0).
  static List<RevenueEvolutionPoint> computeRevenueEvolution({
    required List<CommandeEntity> commandes,
    required ReportDateRange range,
  }) {
    final byDay = <DateTime, double>{};
    for (final commande in commandes) {
      if (!commande.isClosed) continue;
      if (!range.contains(commande.createdAt)) continue;
      final day = DateTime(
        commande.createdAt.year,
        commande.createdAt.month,
        commande.createdAt.day,
      );
      byDay[day] = (byDay[day] ?? 0) + commande.totalAmount;
    }

    final points = <RevenueEvolutionPoint>[];
    var cursor = DateTime(range.start.year, range.start.month, range.start.day);
    final last = range.end.subtract(const Duration(microseconds: 1));
    final lastDay = DateTime(last.year, last.month, last.day);

    while (!cursor.isAfter(lastDay)) {
      points.add(
        RevenueEvolutionPoint(day: cursor, revenue: byDay[cursor] ?? 0),
      );
      cursor = cursor.add(const Duration(days: 1));
    }
    return points;
  }

  static _PeriodMetrics _metricsFor(
    List<CommandeEntity> commandes,
    ReportDateRange range,
  ) {
    var revenue = 0.0;
    var ordersCount = 0;
    var closedCount = 0;
    final clientIds = <String>{};

    for (final commande in commandes) {
      if (commande.isCanceled) continue;
      if (!range.contains(commande.createdAt)) continue;

      ordersCount++;
      final clientId = commande.clientId;
      if (clientId != null && clientId.isNotEmpty) {
        clientIds.add(clientId);
      }

      if (commande.isClosed) {
        closedCount++;
        revenue += commande.totalAmount;
      }
    }

    return _PeriodMetrics(
      revenue: revenue,
      ordersCount: ordersCount,
      closedCount: closedCount,
      clientsServed: clientIds.length,
    );
  }

  /// `null` lorsque la base est 0 (variation indéfinie).
  static double? _percentChange(double current, double previous) {
    if (previous == 0) {
      if (current == 0) return 0;
      return null;
    }
    return ((current - previous) / previous) * 100;
  }
}

class _PeriodMetrics {
  const _PeriodMetrics({
    required this.revenue,
    required this.ordersCount,
    required this.closedCount,
    required this.clientsServed,
  });

  final double revenue;
  final int ordersCount;
  final int closedCount;
  final int clientsServed;

  double get averageBasket => closedCount == 0 ? 0 : revenue / closedCount;
}
