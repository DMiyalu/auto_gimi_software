/// Palier de fidélité dérivé des points cumulés — alimente le badge affiché
/// sur la carte client (aucun champ dédié en base, calculé à la volée).
enum ClientTier {
  none,
  loyal,
  gold;

  static ClientTier forPoints(int loyaltyPoints) {
    if (loyaltyPoints >= 100) return ClientTier.gold;
    if (loyaltyPoints >= 20) return ClientTier.loyal;
    return ClientTier.none;
  }
}
