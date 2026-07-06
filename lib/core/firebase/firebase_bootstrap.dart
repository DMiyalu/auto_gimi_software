import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// Initialise Firebase. Exécuter `flutterfire configure` avant le premier lancement.
Future<void> initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) return;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

/// Indique si Firebase est configuré pour cette plateforme.
bool get isFirebaseConfigured {
  try {
    DefaultFirebaseOptions.currentPlatform;
    return true;
  } on UnimplementedError {
    return false;
  } catch (_) {
    return false;
  }
}

void logFirebaseSetupHint() {
  if (kDebugMode && !isFirebaseConfigured) {
    debugPrint(
      '[Firebase] Exécutez `flutterfire configure` pour générer '
      'lib/core/firebase/firebase_options.dart',
    );
  }
}
