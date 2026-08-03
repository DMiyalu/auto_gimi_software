import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/sync/auto_sync_coordinator.dart';
import '../widgets/primary_bottom_navigation.dart';

/// Coquille commune à tous les métiers : porte la BottomNavigation
/// persistante. Les listes racines dessinent elles-mêmes leur header métier
/// pour garder la même hiérarchie visuelle partout.
class AppShellScreen extends ConsumerWidget {
  const AppShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Garde le coordinateur de synchro automatique vivant tant que
    // l'utilisateur est sur une route authentifiée ; il se nettoie tout seul
    // (timers/écouteurs annulés) quand l'utilisateur se déconnecte.
    ref.watch(autoSyncCoordinatorProvider);

    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: PrimaryBottomNavigation(location: location),
    );
  }
}
