import 'establishment_role.dart';

enum EstablishmentInvitationStatus {
  pending,
  accepted,
  revoked;

  String get firestoreValue => switch (this) {
    pending => 'pending',
    accepted => 'accepted',
    revoked => 'revoked',
  };

  static EstablishmentInvitationStatus fromFirestore(String? value) {
    return EstablishmentInvitationStatus.values.firstWhere(
      (status) => status.firestoreValue == value,
      orElse: () => EstablishmentInvitationStatus.pending,
    );
  }
}

class EstablishmentInvitation {
  const EstablishmentInvitation({
    required this.id,
    required this.establishmentId,
    required this.establishmentName,
    required this.invitedPhone,
    required this.role,
    required this.status,
    required this.invitedBy,
    required this.invitedByName,
    required this.createdAt,
    this.acceptedBy,
    this.acceptedAt,
  });

  final String id;
  final String establishmentId;
  final String establishmentName;
  final String invitedPhone;
  final EstablishmentRole role;
  final EstablishmentInvitationStatus status;
  final String invitedBy;
  final String invitedByName;
  final DateTime createdAt;
  final String? acceptedBy;
  final DateTime? acceptedAt;
}
