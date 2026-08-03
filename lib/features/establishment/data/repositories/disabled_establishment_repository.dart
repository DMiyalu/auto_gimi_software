import '../../../auth/domain/models/sign_up_request.dart';
import '../../domain/models/establishment.dart';
import '../../domain/models/establishment_member.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/establishment_repository.dart';

class DisabledEstablishmentRepository implements EstablishmentRepository {
  @override
  Future<Establishment> createEstablishmentForOwner({
    required String ownerId,
    required SignUpRequest request,
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
  Future<void> setActiveEstablishment({
    required String uid,
    required String establishmentId,
  }) async {
    throw StateError('Firebase non configuré. Exécutez: flutterfire configure');
  }
}
