/// Profil utilisateur lié à un établissement (multi-tenant).
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
  ///
  /// Conservé pendant la migration vers [establishmentIds].
  final String establishmentId;

  /// Champ historique : rôle sur [establishmentId].
  final String role;
  final bool phoneVerified;
  final DateTime createdAt;
  final List<String> establishmentIds;
  final String? activeEstablishmentId;
  final Map<String, String> rolesByEstablishment;

  String get currentEstablishmentId => activeEstablishmentId ?? establishmentId;

  String roleFor(String establishmentId) =>
      rolesByEstablishment[establishmentId] ?? role;
}
