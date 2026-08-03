import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/business_category.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../domain/models/establishment.dart';
import '../../domain/models/establishment_member.dart';
import '../../domain/models/establishment_role.dart';
import '../../domain/models/user_profile.dart';
import 'establishment_repository_provider.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref.watch(establishmentRepositoryProvider).watchUserProfile(user.uid);
});

final currentEstablishmentIdProvider = Provider<String?>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return profile?.currentEstablishmentId;
});

final currentEstablishmentProvider = StreamProvider<Establishment?>((ref) {
  final establishmentId = ref.watch(currentEstablishmentIdProvider);
  if (establishmentId == null || establishmentId.isEmpty) {
    return Stream.value(null);
  }
  return ref
      .watch(establishmentRepositoryProvider)
      .watchEstablishment(establishmentId);
});

final userEstablishmentsProvider = StreamProvider<List<Establishment>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(establishmentRepositoryProvider)
      .watchUserEstablishments(user.uid);
});

final userMembershipsProvider = StreamProvider<List<EstablishmentMember>>((
  ref,
) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(establishmentRepositoryProvider)
      .watchUserMemberships(user.uid);
});

final activeMembershipProvider = Provider<EstablishmentMember?>((ref) {
  final establishmentId = ref.watch(currentEstablishmentIdProvider);
  if (establishmentId == null) return null;
  final memberships = ref.watch(userMembershipsProvider).valueOrNull ?? [];
  for (final membership in memberships) {
    if (membership.establishmentId == establishmentId) return membership;
  }
  return null;
});

final activeEstablishmentRoleProvider = Provider<EstablishmentRole?>((ref) {
  final membership = ref.watch(activeMembershipProvider);
  if (membership != null) return membership.role;

  final profile = ref.watch(userProfileProvider).valueOrNull;
  final establishmentId = ref.watch(currentEstablishmentIdProvider);
  if (profile == null || establishmentId == null) return null;

  return EstablishmentRole.fromFirestore(profile.roleFor(establishmentId));
});

final canInviteMembersProvider = Provider<bool>((ref) {
  return ref.watch(activeEstablishmentRoleProvider)?.canInviteMembers ?? false;
});

final establishmentMembersProvider = StreamProvider<List<EstablishmentMember>>((
  ref,
) {
  final establishmentId = ref.watch(currentEstablishmentIdProvider);
  if (establishmentId == null || establishmentId.isEmpty) {
    return Stream.value(const []);
  }
  return ref
      .watch(establishmentRepositoryProvider)
      .watchEstablishmentMembers(establishmentId);
});

final establishmentControllerProvider =
    AsyncNotifierProvider<EstablishmentController, void>(
      EstablishmentController.new,
    );

class EstablishmentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> switchEstablishment(String establishmentId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref
          .read(establishmentRepositoryProvider)
          .setActiveEstablishment(
            uid: user.uid,
            establishmentId: establishmentId,
          );
    });
  }

  Future<void> createOwnedEstablishment({
    required BusinessCategory category,
    required String establishmentName,
    required String managerName,
    required String phone,
  }) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(establishmentRepositoryProvider)
          .createOwnedEstablishment(
            ownerId: user.uid,
            category: category,
            establishmentName: establishmentName,
            managerName: managerName,
            phone: phone,
          );
    });
  }
}
