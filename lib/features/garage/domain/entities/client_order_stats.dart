/// Agrégat "commandes" d'un client, calculé depuis ses prestations —
/// alimente la carte client de la liste (total dépensé, dernière commande).
class ClientOrderStats {
  const ClientOrderStats({
    required this.totalSpent,
    required this.lastOrderAt,
    required this.lastOrderContext,
  });

  final double totalSpent;
  final DateTime lastOrderAt;
  final String lastOrderContext;
}
