/// KPIs de la période sélectionnée + variation vs période précédente.
class RestaurantReportKpis {
  const RestaurantReportKpis({
    required this.revenue,
    required this.revenueChangePercent,
    required this.ordersCount,
    required this.ordersChangePercent,
    required this.averageBasket,
    required this.averageBasketChangePercent,
    required this.clientsServed,
    required this.clientsServedChangePercent,
  });

  static const empty = RestaurantReportKpis(
    revenue: 0,
    revenueChangePercent: null,
    ordersCount: 0,
    ordersChangePercent: null,
    averageBasket: 0,
    averageBasketChangePercent: null,
    clientsServed: 0,
    clientsServedChangePercent: null,
  );

  /// Chiffre d'affaires (commandes clôturées).
  final double revenue;

  /// Variation relative du CA vs période précédente (`null` si indéfinie).
  final double? revenueChangePercent;

  /// Nombre de commandes non annulées.
  final int ordersCount;

  final double? ordersChangePercent;

  /// Panier moyen = CA / commandes clôturées (0 si aucune).
  final double averageBasket;

  final double? averageBasketChangePercent;

  /// Clients distincts rattachés aux commandes de la période.
  final int clientsServed;

  final double? clientsServedChangePercent;
}
