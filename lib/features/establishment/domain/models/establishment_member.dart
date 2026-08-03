import 'establishment_role.dart';

/// Membership d'un utilisateur dans un établissement.
class EstablishmentMember {
  const EstablishmentMember({
    required this.uid,
    required this.establishmentId,
    required this.phone,
    required this.fullName,
    required this.role,
    required this.phoneVerified,
    required this.joinedAt,
  });

  final String uid;
  final String establishmentId;
  final String phone;
  final String fullName;
  final EstablishmentRole role;
  final bool phoneVerified;
  final DateTime joinedAt;
}
