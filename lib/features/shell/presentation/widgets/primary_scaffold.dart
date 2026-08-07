import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../primary_module/widgets/business_header.dart';
import 'primary_bottom_navigation.dart';

/// Coquille commune à tous les écrans racines de la bottom navigation
/// (Commandes/Prestations, Clients, Produits ou Services, Rapports, Plus) :
/// header (identité établissement + profil par défaut) + bottom nav.
/// [header] remplace le [BusinessHeader] quand un écran a besoin d'un titre
/// dédié (ex. Rapports).
class PrimaryScaffold extends StatelessWidget {
  const PrimaryScaffold({
    super.key,
    required this.body,
    this.header,
    this.floatingActionButton,
  });

  final Widget body;
  final Widget? header;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      extendBody: true,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: PrimaryBottomNavigation(location: location),
      body: SafeArea(
        child: Column(
          children: [
            header ?? const BusinessHeader(),
            const SizedBox(height: AppSpacing.xs),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
