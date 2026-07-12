import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../domain/models/establishment.dart';
import '../../domain/models/user_profile.dart';
import 'establishment_repository_provider.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref
      .watch(establishmentRepositoryProvider)
      .watchUserProfile(user.uid);
});

final currentEstablishmentProvider = StreamProvider<Establishment?>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile == null) return Stream.value(null);
  return ref
      .watch(establishmentRepositoryProvider)
      .watchEstablishment(profile.establishmentId);
});
