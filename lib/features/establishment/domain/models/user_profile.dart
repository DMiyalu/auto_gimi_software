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
  });

  final String uid;
  final String phone;
  final String fullName;
  final String establishmentId;
  final String role;
  final bool phoneVerified;
  final DateTime createdAt;
}
