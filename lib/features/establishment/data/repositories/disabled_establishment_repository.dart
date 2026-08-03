import '../../../../core/domain/business_category.dart';
import '../../domain/models/establishment.dart';
import '../../domain/models/establishment_invitation.dart';
import '../../domain/models/establishment_member.dart';
import '../../domain/models/establishment_role.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/establishment_repository.dart';

class DisabledEstablishmentRepository implements EstablishmentRepository {
  @override
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async {
    throw StateError('Firebase non configuré. Exécutez: flutterfire configure');
  }

  @override
  Future<Establishment> createOwnedEstablishment({
    required String ownerId,
    required BusinessCategory category,
    required String establishmentName,
    required String managerName,
    required String phone,
  }) async {
    throw StateError('Firebase non configuré. Exécutez: flutterfire configure');
  }

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
  Stream<List<EstablishmentInvitation>> watchPendingInvitationsForPhone(
    String phone,
  ) => Stream.value(const []);

  @override
  Future<void> createInvitation({
    required String establishmentId,
    required String establishmentName,
    required String invitedPhone,
    required EstablishmentRole role,
    required String invitedBy,
    required String invitedByName,
  }) async {
    throw StateError('Firebase non configuré. Exécutez: flutterfire configure');
  }

  @override
  Future<void> acceptInvitation({
    required String uid,
    required String fullName,
    required String phone,
    required EstablishmentInvitation invitation,
  }) async {
    throw StateError('Firebase non configuré. Exécutez: flutterfire configure');
  }

  @override
  Future<void> setActiveEstablishment({
    required String uid,
    required String establishmentId,
  }) async {
    throw StateError('Firebase non configuré. Exécutez: flutterfire configure');
  }
}
