import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/auth/phone_auth_mapper.dart';
import '../../../establishment/domain/repositories/establishment_repository.dart';
import '../../domain/models/sign_up_request.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    required EstablishmentRepository establishmentRepository,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _establishmentRepository = establishmentRepository;

  final FirebaseAuth _auth;
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
  Future<void> signOut() => _auth.signOut();
}
