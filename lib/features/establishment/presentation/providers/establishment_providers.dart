import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/business_category.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../domain/models/establishment.dart';
import '../../domain/models/establishment_invitation.dart';
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

final canManageCatalogProvider = Provider<bool>((ref) {
  return ref.watch(activeEstablishmentRoleProvider)?.canManageCatalog ?? false;
});

final canCreateActivitiesProvider = Provider<bool>((ref) {
  return ref.watch(activeEstablishmentRoleProvider)?.canCreateActivities ??
      false;
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

/// Claim des pending par téléphone puis écoute de l'inbox utilisateur.
final pendingInvitationsProvider =
    StreamProvider<List<EstablishmentInvitation>>((ref) async* {
      final user = ref.watch(authStateProvider).valueOrNull;
      final profile = ref.watch(userProfileProvider).valueOrNull;
      if (user == null || profile == null || profile.phone.isEmpty) {
        yield const [];
        return;
      }

      final repo = ref.watch(establishmentRepositoryProvider);
      try {
        await repo.claimPendingInvitations(uid: user.uid, phone: profile.phone);
      } catch (_) {
        // L'inbox reste consultable même si le claim échoue (réseau / rules).
      }

      yield* repo.watchPendingInvitations(user.uid);
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

  Future<void> createInvitation({
    required EstablishmentRole role,
    required String invitedPhone,
  }) async {
    final user = ref.read(authStateProvider).valueOrNull;
    final profile = ref.read(userProfileProvider).valueOrNull;
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (user == null || profile == null || establishment == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (!ref.read(canInviteMembersProvider)) {
        throw StateError(
          'Seuls le propriétaire et les gérants peuvent inviter des membres.',
        );
      }
      await ref
          .read(establishmentRepositoryProvider)
          .createInvitation(
            establishmentId: establishment.id,
            establishmentName: establishment.name,
            invitedPhone: invitedPhone,
            role: role,
            invitedBy: user.uid,
            invitedByName: profile.fullName,
          );
    });
  }

  Future<void> acceptInvitation(EstablishmentInvitation invitation) async {
    final user = ref.read(authStateProvider).valueOrNull;
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (user == null || profile == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(establishmentRepositoryProvider)
          .acceptInvitation(
            uid: user.uid,
            fullName: profile.fullName,
            phone: profile.phone,
            invitation: invitation,
          );
    });
  }

  Future<void> refuseInvitation(EstablishmentInvitation invitation) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(establishmentRepositoryProvider)
          .refuseInvitation(uid: user.uid, invitation: invitation);
    });
  }
}
