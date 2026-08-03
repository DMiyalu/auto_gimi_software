import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../primary_module/widgets/business_header.dart';
import 'app_drawer.dart';
import 'primary_bottom_navigation.dart';

/// Coquille commune à tous les écrans racines de la bottom navigation
/// (Commandes/Prestations, Clients, Produits ou Services, Rapports, Plus) :
/// même header (menu hamburger + identité établissement), même Drawer, même
/// bottom nav. Seuls [body] et [floatingActionButton] varient d'un écran à
/// l'autre — c'est le seul endroit de l'app qui compose ces trois éléments,
/// pour garantir qu'ils restent identiques partout.
class PrimaryScaffold extends StatelessWidget {
  const PrimaryScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
  });

  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      drawer: const AppDrawer(),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: PrimaryBottomNavigation(location: location),
      body: SafeArea(
        child: Column(
          children: [
            const BusinessHeader(),
            const SizedBox(height: AppSpacing.xs),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
