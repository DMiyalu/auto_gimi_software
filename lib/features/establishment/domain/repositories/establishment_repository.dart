import '../../../auth/domain/models/sign_up_request.dart';
import '../models/establishment.dart';
import '../models/user_profile.dart';

abstract class EstablishmentRepository {
  Future<Establishment> createEstablishmentForOwner({
    required String ownerId,
    required SignUpRequest request,
  });

  Stream<UserProfile?> watchUserProfile(String uid);

  Stream<Establishment?> watchEstablishment(String establishmentId);
}
