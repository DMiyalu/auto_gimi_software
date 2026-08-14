import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Messages d'erreur Firebase Auth / Functions lisibles pour l'utilisateur.
abstract final class AuthErrorMapper {
  static String message(Object error) {
    if (error is FirebaseAuthException) {
      return _firebaseMessage(error);
    }
    if (error is FirebaseFunctionsException) {
      final details = error.message?.trim();
      if (details != null && details.isNotEmpty) {
        return details;
      }
      return 'Erreur serveur (${error.code}).';
    }
    if (error is StateError) {
      return error.message;
    }
    if (error is ArgumentError) {
      return error.message?.toString() ?? error.toString();
    }
    return error.toString();
  }

  static String _firebaseMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'admin-restricted-operation':
        return "L'inscription publique est désactivée dans Firebase. "
            'Activez « Enable create (sign-up) » dans Authentication → Settings → User actions.';
      case 'email-already-in-use':
        return 'Ce numéro de téléphone est déjà utilisé.';
      case 'invalid-email':
        return 'Numéro de téléphone invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Numéro ou mot de passe incorrect.';
      case 'user-not-found':
        return 'Aucun compte trouvé pour ce numéro.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion.';
      default:
        return error.message ?? 'Erreur d\'authentification (${error.code}).';
    }
  }
}
