import '../../../../core/domain/business_category.dart';
import '../../domain/models/establishment.dart';
import '../../domain/models/establishment_invitation.dart';
import '../../domain/models/establishment_member.dart';
import '../../domain/models/establishment_role.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/establishment_repository.dart';

class DisabledEstablishmentRepository implements EstablishmentRepository {
  Never _disabled() => throw StateError(
    'Firebase non configuré. Exécutez: flutterfire configure',
  );

  @override
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async => _disabled();

  @override
  Future<Establishment> createOwnedEstablishment({
    required String ownerId,
    required BusinessCategory category,
    required String establishmentName,
    required String managerName,
    required String phone,
    String? logoBase64,
  }) async => _disabled();

  @override
  Stream<UserProfile?> watchUserProfile(String uid) => Stream.value(null);

  @override
  Stream<Establishment?> watchEstablishment(String establishmentId) =>
      Stream.value(null);

  @override
  Stream<List<Establishment>> watchUserEstablishments(String uid) =>
      Stream.value(const []);

  @override
  Stream<List<EstablishmentMember>> watchUserMemberships(String uid) =>
      Stream.value(const []);

  @override
  Stream<List<EstablishmentMember>> watchEstablishmentMembers(
    String establishmentId,
  ) => Stream.value(const []);

  @override
  Stream<List<EstablishmentInvitation>> watchPendingInvitations(String uid) =>
      Stream.value(const []);

  @override
  Future<void> claimPendingInvitations({
    required String uid,
    required String phone,
  }) async => _disabled();

  @override
  Future<void> createInvitation({
    required String establishmentId,
    required String establishmentName,
    required String invitedPhone,
    required EstablishmentRole role,
    required String invitedBy,
    required String invitedByName,
  }) async => _disabled();

  @override
  Future<void> acceptInvitation({
    required String uid,
    required String fullName,
    required String phone,
    required EstablishmentInvitation invitation,
  }) async => _disabled();

  @override
  Future<void> refuseInvitation({
    required String uid,
    required EstablishmentInvitation invitation,
  }) async => _disabled();

  @override
  Future<void> setActiveEstablishment({
    required String uid,
    required String establishmentId,
  }) async => _disabled();

  @override
  Future<void> updateUserFullName({
    required String uid,
    required String fullName,
  }) async => _disabled();

  @override
  Future<void> updateUserEmail({
    required String uid,
    required String email,
  }) async => _disabled();

  @override
  Future<void> updateEstablishmentSettings({
    required String establishmentId,
    required String name,
    String? logoBase64,
    bool clearLogo = false,
    required List<String> invoiceHeaderLines,
    required List<String> invoiceFooterLines,
  }) async => _disabled();
}
