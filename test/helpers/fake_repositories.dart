import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:auto_mobile_software/core/domain/business_category.dart';
import 'package:auto_mobile_software/features/auth/domain/models/sign_up_request.dart';
import 'package:auto_mobile_software/features/auth/domain/repositories/auth_repository.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_invitation.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_member.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/establishment_role.dart';
import 'package:auto_mobile_software/features/establishment/domain/models/user_profile.dart';
import 'package:auto_mobile_software/features/establishment/domain/repositories/establishment_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository() : _controller = StreamController<User?>.broadcast();

  final StreamController<User?> _controller;
  User? _currentUser;

  void setUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({required String phone, required String password}) async {
    if (_currentUser == null) {
      throw StateError('Aucun utilisateur de test configuré.');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    if (_currentUser == null) {
      throw StateError('Aucun utilisateur de test configuré.');
    }
  }

  @override
  Future<void> signUp(SignUpRequest request) async {
    if (_currentUser == null) {
      throw StateError('Aucun utilisateur de test configuré.');
    }
  }

  @override
  Future<void> signOut() async {
    setUser(null);
  }
}

class FakeEstablishmentRepository implements EstablishmentRepository {
  UserProfile? profile;
  Establishment? establishment;
  List<Establishment> establishments = const [];
  List<EstablishmentMember> memberships = const [];
  List<EstablishmentInvitation> invitations = const [];

  final _profileController = StreamController<UserProfile?>.broadcast();
  final _establishmentController = StreamController<Establishment?>.broadcast();
  final _establishmentsController =
      StreamController<List<Establishment>>.broadcast();
  final _membershipsController =
      StreamController<List<EstablishmentMember>>.broadcast();
  final _invitationsController =
      StreamController<List<EstablishmentInvitation>>.broadcast();

  void setProfile(UserProfile value) {
    profile = value;
    _profileController.add(value);
  }

  void setEstablishments(List<Establishment> value) {
    establishments = value;
    _establishmentsController.add(value);
  }

  void setMemberships(List<EstablishmentMember> value) {
    memberships = value;
    _membershipsController.add(value);
  }

  void setInvitations(List<EstablishmentInvitation> value) {
    invitations = value;
    _invitationsController.add(value);
  }

  @override
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String phone,
    String? email,
  }) async {
    setProfile(
      UserProfile(
        uid: uid,
        phone: phone,
        fullName: fullName,
        email: email,
        establishmentId: '',
        role: 'agent',
        phoneVerified: true,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  }

  @override
  Future<Establishment> createOwnedEstablishment({
    required String ownerId,
    required BusinessCategory category,
    required String establishmentName,
    required String managerName,
    required String phone,
    String? logoBase64,
  }) async {
    final value = Establishment(
      id: 'est-${establishments.length + 1}',
      name: establishmentName,
      category: category,
      ownerId: ownerId,
      managerName: managerName,
      phone: phone,
      phoneVerified: false,
      logoBase64: logoBase64,
      createdAt: DateTime(2026, 1, 1),
    );
    setEstablishments([...establishments, value]);
    establishment = value;
    _establishmentController.add(value);
    await setActiveEstablishment(uid: ownerId, establishmentId: value.id);
    return value;
  }

  @override
  Stream<UserProfile?> watchUserProfile(String uid) async* {
    yield profile;
    yield* _profileController.stream;
  }

  @override
  Stream<Establishment?> watchEstablishment(String establishmentId) async* {
    yield establishment;
    yield* _establishmentController.stream;
  }

  @override
  Stream<List<Establishment>> watchUserEstablishments(String uid) async* {
    yield establishments.isEmpty && establishment != null
        ? [establishment!]
        : establishments;
    yield* _establishmentsController.stream;
  }

  @override
  Stream<List<EstablishmentMember>> watchUserMemberships(String uid) async* {
    yield memberships;
    yield* _membershipsController.stream;
  }

  @override
  Stream<List<EstablishmentMember>> watchEstablishmentMembers(
    String establishmentId,
  ) async* {
    yield memberships
        .where((member) => member.establishmentId == establishmentId)
        .toList();
    yield* _membershipsController.stream.map(
      (items) => items
          .where((member) => member.establishmentId == establishmentId)
          .toList(),
    );
  }

  @override
  Stream<List<EstablishmentInvitation>> watchPendingInvitations(
    String uid,
  ) async* {
    List<EstablishmentInvitation> pending(List<EstablishmentInvitation> items) {
      return items
          .where(
            (invitation) =>
                invitation.status == EstablishmentInvitationStatus.pending,
          )
          .toList();
    }

    yield pending(invitations);
    yield* _invitationsController.stream.map(pending);
  }

  @override
  Future<void> claimPendingInvitations({
    required String uid,
    required String phone,
  }) async {
    // No-op : les fakes alimentent déjà l'inbox via setInvitations.
  }

  @override
  Future<void> createInvitation({
    required String establishmentId,
    required String establishmentName,
    required String invitedPhone,
    required EstablishmentRole role,
    required String invitedBy,
    required String invitedByName,
  }) async {
    setInvitations([
      ...invitations,
      EstablishmentInvitation(
        id: 'inv-${invitations.length + 1}',
        establishmentId: establishmentId,
        establishmentName: establishmentName,
        invitedPhone: invitedPhone,
        role: role,
        status: EstablishmentInvitationStatus.pending,
        invitedBy: invitedBy,
        invitedByName: invitedByName,
        createdAt: DateTime(2026, 1, 1),
      ),
    ]);
  }

  @override
  Future<void> acceptInvitation({
    required String uid,
    required String fullName,
    required String phone,
    required EstablishmentInvitation invitation,
  }) async {
    final joinedEstablishment = Establishment(
      id: invitation.establishmentId,
      name: invitation.establishmentName,
      category: BusinessCategory.restaurant,
      ownerId: invitation.invitedBy,
      managerName: invitation.invitedByName,
      phone: phone,
      phoneVerified: true,
      createdAt: invitation.createdAt,
    );
    setEstablishments([
      ...establishments.where((item) => item.id != invitation.establishmentId),
      joinedEstablishment,
    ]);
    establishment = joinedEstablishment;
    _establishmentController.add(joinedEstablishment);

    final member = EstablishmentMember(
      uid: uid,
      establishmentId: invitation.establishmentId,
      phone: phone,
      fullName: fullName,
      role: invitation.role,
      phoneVerified: true,
      joinedAt: DateTime(2026, 1, 1),
    );
    setMemberships([
      ...memberships.where(
        (item) =>
            item.uid != uid ||
            item.establishmentId != invitation.establishmentId,
      ),
      member,
    ]);
    setInvitations([
      for (final item in invitations)
        if (item.id == invitation.id)
          EstablishmentInvitation(
            id: item.id,
            establishmentId: item.establishmentId,
            establishmentName: item.establishmentName,
            invitedPhone: item.invitedPhone,
            role: item.role,
            status: EstablishmentInvitationStatus.accepted,
            invitedBy: item.invitedBy,
            invitedByName: item.invitedByName,
            createdAt: item.createdAt,
            acceptedBy: uid,
            acceptedAt: DateTime(2026, 1, 1),
          )
        else
          item,
    ]);
    final current = profile;
    if (current != null) {
      setProfile(
        UserProfile(
          uid: current.uid,
          phone: phone,
          fullName: fullName,
          email: current.email,
          establishmentId: current.establishmentId.isEmpty
              ? invitation.establishmentId
              : current.establishmentId,
          role: invitation.role.firestoreValue,
          phoneVerified: true,
          createdAt: current.createdAt,
          establishmentIds: [
            ...{...current.establishmentIds, invitation.establishmentId},
          ],
          activeEstablishmentId: current.activeEstablishmentId,
          rolesByEstablishment: {
            ...current.rolesByEstablishment,
            invitation.establishmentId: invitation.role.firestoreValue,
          },
        ),
      );
    }
  }

  @override
  Future<void> refuseInvitation({
    required String uid,
    required EstablishmentInvitation invitation,
  }) async {
    setInvitations([
      for (final item in invitations)
        if (item.id == invitation.id)
          EstablishmentInvitation(
            id: item.id,
            establishmentId: item.establishmentId,
            establishmentName: item.establishmentName,
            invitedPhone: item.invitedPhone,
            role: item.role,
            status: EstablishmentInvitationStatus.revoked,
            invitedBy: item.invitedBy,
            invitedByName: item.invitedByName,
            createdAt: item.createdAt,
            acceptedBy: item.acceptedBy,
            acceptedAt: item.acceptedAt,
          )
        else
          item,
    ]);
  }

  @override
  Future<void> setActiveEstablishment({
    required String uid,
    required String establishmentId,
  }) async {
    final current = profile;
    if (current == null) return;
    profile = UserProfile(
      uid: current.uid,
      phone: current.phone,
      fullName: current.fullName,
      email: current.email,
      establishmentId: current.establishmentId,
      role: current.role,
      phoneVerified: current.phoneVerified,
      createdAt: current.createdAt,
      establishmentIds: current.establishmentIds,
      activeEstablishmentId: establishmentId,
      rolesByEstablishment: current.rolesByEstablishment,
    );
    _profileController.add(profile);
  }

  @override
  Future<void> updateUserFullName({
    required String uid,
    required String fullName,
  }) async {
    final current = profile;
    if (current == null) return;
    setProfile(
      UserProfile(
        uid: current.uid,
        phone: current.phone,
        fullName: fullName.trim(),
        email: current.email,
        establishmentId: current.establishmentId,
        role: current.role,
        phoneVerified: current.phoneVerified,
        createdAt: current.createdAt,
        establishmentIds: current.establishmentIds,
        activeEstablishmentId: current.activeEstablishmentId,
        rolesByEstablishment: current.rolesByEstablishment,
      ),
    );
  }

  @override
  Future<void> updateUserEmail({
    required String uid,
    required String email,
  }) async {
    final current = profile;
    if (current == null) return;
    final trimmed = email.trim();
    if (!UserProfile.isValidReportEmail(trimmed)) {
      throw ArgumentError('Adresse e-mail invalide.');
    }
    setProfile(
      UserProfile(
        uid: current.uid,
        phone: current.phone,
        fullName: current.fullName,
        email: trimmed,
        establishmentId: current.establishmentId,
        role: current.role,
        phoneVerified: current.phoneVerified,
        createdAt: current.createdAt,
        establishmentIds: current.establishmentIds,
        activeEstablishmentId: current.activeEstablishmentId,
        rolesByEstablishment: current.rolesByEstablishment,
      ),
    );
  }

  @override
  Future<void> updateEstablishmentSettings({
    required String establishmentId,
    required String name,
    String? logoBase64,
    bool clearLogo = false,
    required List<String> invoiceHeaderLines,
    required List<String> invoiceFooterLines,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Le nom de l’établissement est obligatoire.');
    }

    Establishment update(Establishment current) {
      return current.copyWith(
        name: trimmedName,
        logoBase64: logoBase64,
        clearLogo: clearLogo,
        invoiceHeaderLines: Establishment.sanitizeInvoiceLines(
          invoiceHeaderLines,
        ),
        invoiceFooterLines: Establishment.sanitizeInvoiceLines(
          invoiceFooterLines,
        ),
      );
    }

    if (establishment?.id == establishmentId) {
      establishment = update(establishment!);
      _establishmentController.add(establishment);
    }

    setEstablishments([
      for (final item in establishments)
        if (item.id == establishmentId) update(item) else item,
    ]);
  }
}
