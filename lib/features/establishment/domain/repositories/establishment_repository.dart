import '../../../auth/domain/models/sign_up_request.dart';
import '../../../../core/domain/business_category.dart';
import '../models/establishment.dart';
import '../models/establishment_member.dart';
import '../models/user_profile.dart';

abstract class EstablishmentRepository {
  Future<Establishment> createEstablishmentForOwner({
    required String ownerId,
    required SignUpRequest request,
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

  Future<void> setActiveEstablishment({
    required String uid,
    required String establishmentId,
  });
}
