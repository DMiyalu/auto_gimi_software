import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../../establishment/presentation/providers/establishment_repository_provider.dart';
import '../../data/repositories/disabled_auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (isFirebaseConfigured) {
    return FirebaseAuthRepository(
      establishmentRepository: ref.watch(establishmentRepositoryProvider),
    );
  }
  return DisabledAuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
