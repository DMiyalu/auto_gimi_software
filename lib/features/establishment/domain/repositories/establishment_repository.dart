import '../../../../core/domain/business_category.dart';
import '../models/establishment.dart';
import '../models/establishment_invitation.dart';
import '../models/establishment_member.dart';
import '../models/establishment_role.dart';
import '../models/user_profile.dart';

abstract class EstablishmentRepository {
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String phone,
  });

  Future<Establishment> createOwnedEstablishment({
    required String ownerId,
    required BusinessCategory category,
    required String establishmentName,
    required String managerName,
    required String phone,
  });

  Stream<UserProfile?> watchUserProfile(String uid);

  Stream<Establishment?> watchEstablishment(String establishmentId);

  Stream<List<Establishment>> watchUserEstablishments(String uid);

  Stream<List<EstablishmentMember>> watchUserMemberships(String uid);

  Stream<List<EstablishmentMember>> watchEstablishmentMembers(
    String establishmentId,
  );

  /// Invitations pending dans l'inbox `users/{uid}/invitations`.
  Stream<List<EstablishmentInvitation>> watchPendingInvitations(String uid);

  /// Copie `pendingInvitations` (par téléphone) vers l'inbox utilisateur.
  Future<void> claimPendingInvitations({
    required String uid,
    required String phone,
  });

  Future<void> createInvitation({
    required String establishmentId,
    required String establishmentName,
    required String invitedPhone,
    required EstablishmentRole role,
    required String invitedBy,
    required String invitedByName,
  });

  Future<void> acceptInvitation({
    required String uid,
    required String fullName,
    required String phone,
    required EstablishmentInvitation invitation,
  });

  Future<void> refuseInvitation({
    required String uid,
    required EstablishmentInvitation invitation,
  });

  Future<void> setActiveEstablishment({
    required String uid,
    required String establishmentId,
  });

  Future<void> updateUserFullName({
    required String uid,
    required String fullName,
  });

  Future<void> updateUserEmail({
    required String uid,
    required String email,
  });
}
