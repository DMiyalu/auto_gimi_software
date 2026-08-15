import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../establishment/domain/repositories/establishment_repository.dart';
import '../../domain/models/sign_up_request.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    required EstablishmentRepository establishmentRepository,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email']),
       _establishmentRepository = establishmentRepository;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final EstablishmentRepository _establishmentRepository;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<void> signIn({required String phone, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: PhoneAuthMapper.toAuthEmail(phone),
      password: password,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw StateError('Connexion Google annulée.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw StateError(
        'Connexion Google réussie mais utilisateur introuvable.',
      );
    }

    final existingProfile = await _establishmentRepository
        .watchUserProfile(user.uid)
        .first;
    if (existingProfile != null) return;

    final displayName = user.displayName?.trim();
    await _establishmentRepository.createUserProfile(
      uid: user.uid,
      fullName: displayName == null || displayName.isEmpty
          ? googleUser.displayName ?? googleUser.email
          : displayName,
      phone: user.phoneNumber ?? '',
      email: user.email ?? googleUser.email,
    );
  }

  @override
  Future<void> signUp(SignUpRequest request) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: PhoneAuthMapper.toAuthEmail(request.phone),
      password: request.password,
    );

    final user = credential.user;
    if (user == null) {
      throw StateError('Compte créé mais utilisateur introuvable.');
    }

    try {
      await _establishmentRepository.createUserProfile(
        uid: user.uid,
        fullName: request.fullName,
        phone: request.phone,
      );
    } catch (error) {
      await user.delete();
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
