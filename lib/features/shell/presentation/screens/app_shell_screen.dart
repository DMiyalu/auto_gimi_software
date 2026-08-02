import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/sync/auto_sync_coordinator.dart';
import '../../../primary_module/config/business_module_config.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';
import '../widgets/primary_bottom_navigation.dart';

/// Coquille commune à tous les métiers : porte la BottomNavigation
/// persistante et, pour les écrans qui n'ont pas leur propre AppBar (listes
/// racines des onglets), un titre minimal. L'onglet principal (activité)
/// gère entièrement son propre header custom, donc aucune AppBar ici.
class AppShellScreen extends ConsumerWidget {
  const AppShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Garde le coordinateur de synchro automatique vivant tant que
    // l'utilisateur est sur une route authentifiée ; il se nettoie tout seul
    // (timers/écouteurs annulés) quand l'utilisateur se déconnecte.
    ref.watch(autoSyncCoordinatorProvider);

    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;
    final config = ref.watch(primaryModuleConfigProvider);
    final title = _fallbackTitle(location, config, l10n);

    return Scaffold(
      appBar: title == null ? null : AppBar(title: Text(title)),
      body: child,
      bottomNavigationBar: PrimaryBottomNavigation(location: location),
    );
  }

  /// Titre affiché pour les écrans qui n'ont pas leur propre AppBar (les
  /// listes racines de chaque onglet). Les autres écrans (formulaires,
  /// détails, "Plus"...) gèrent déjà la leur — on ne les recouvre pas.
  String? _fallbackTitle(
    String location,
    BusinessModuleConfig config,
    AppLocalizations l10n,
  ) {
    if (location == Routes.produits) return l10n.products;
    if (location == Routes.services) return l10n.services;
    if (location == Routes.reports) return config.reportsLabel;
    if (location == Routes.prestationScan) return l10n.scanClient;
    if (location == Routes.jetonScan) return l10n.scanToken;
    if (location == Routes.alertes) return l10n.alerts;
    return null;
  }
}
