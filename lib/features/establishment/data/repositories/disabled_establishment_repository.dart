import '../../../auth/domain/models/sign_up_request.dart';
import '../../domain/models/establishment.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/establishment_repository.dart';

class DisabledEstablishmentRepository implements EstablishmentRepository {
  @override
  Future<Establishment> createEstablishmentForOwner({
    required String ownerId,
    required SignUpRequest request,
  }) async {
    throw StateError(
      'Firebase non configuré. Exécutez: flutterfire configure',
    );
  }

  @override
  Stream<UserProfile?> watchUserProfile(String uid) => Stream.value(null);

  @override
  Stream<Establishment?> watchEstablishment(String establishmentId) =>
      Stream.value(null);
}
