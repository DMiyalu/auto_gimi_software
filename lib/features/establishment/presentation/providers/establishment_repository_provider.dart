import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../data/repositories/disabled_establishment_repository.dart';
import '../../data/repositories/firestore_establishment_repository.dart';
import '../../domain/repositories/establishment_repository.dart';

final establishmentRepositoryProvider = Provider<EstablishmentRepository>((ref) {
  if (isFirebaseConfigured) {
    return FirestoreEstablishmentRepository();
  }
  return DisabledEstablishmentRepository();
});
