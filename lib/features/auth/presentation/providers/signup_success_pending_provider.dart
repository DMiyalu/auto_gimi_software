import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Après vérification OTP réussie, affiche l'écran « Inscription réussie »
/// avant la landing établissements.
final signupSuccessPendingProvider = StateProvider<bool>((ref) => false);
