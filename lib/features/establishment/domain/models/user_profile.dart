/// Profil utilisateur multi-tenant (collection `users`).
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.phone,
    required this.fullName,
    required this.establishmentId,
    required this.role,
    required this.phoneVerified,
    required this.createdAt,
    this.establishmentIds = const [],
    this.activeEstablishmentId,
    this.rolesByEstablishment = const {},
  });

  final String uid;
  final String phone;
  final String fullName;

  /// Champ historique : premier établissement créé/rejoint.
  final String establishmentId;

  /// Champ historique : rôle sur [establishmentId].
  final String role;
  final bool phoneVerified;
  final DateTime createdAt;

  /// IDs des établissements accessibles.
  ///
  /// Persisté Firestore sous `establishments` (et alias legacy
  /// `establishmentIds` pendant la migration).
  final List<String> establishmentIds;
  final String? activeEstablishmentId;
  final Map<String, String> rolesByEstablishment;

  /// Alias métier du plan (`users.establishments[]`).
  List<String> get establishments => establishmentIds;

  String get currentEstablishmentId => activeEstablishmentId ?? establishmentId;

  String roleFor(String establishmentId) =>
      rolesByEstablishment[establishmentId] ?? role;
}
