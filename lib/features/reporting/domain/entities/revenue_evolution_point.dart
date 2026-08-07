/// Point journalier pour le graphique « Évolution du chiffre d'affaires ».
class RevenueEvolutionPoint {
  const RevenueEvolutionPoint({
    required this.day,
    required this.revenue,
  });

  /// Jour à minuit (local).
  final DateTime day;

  /// CA des commandes clôturées créées ce jour-là.
  final double revenue;
}
