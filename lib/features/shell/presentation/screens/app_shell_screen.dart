import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/auto_sync_coordinator.dart';

/// Point d'ancrage des routes authentifiées : ne dessine plus aucun chrome
/// (Scaffold/bottom nav) lui-même — chaque écran racine choisit son propre
/// habillage via [PrimaryScaffold], et les écrans secondaires gardent leur
/// simple [AppBar]. Son seul rôle restant est de garder le coordinateur de
/// synchro automatique vivant tant que l'utilisateur est sur une route
/// authentifiée, peu importe l'écran affiché.
class AppShellScreen extends ConsumerWidget {
  const AppShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(autoSyncCoordinatorProvider);
    return child;
  }
}
