import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/screens/splash_screen.dart';
import '../../../core/theme/app_spacing.dart';
import '../../establishment/presentation/providers/establishment_providers.dart';
import '../../shell/presentation/widgets/primary_scaffold.dart';
import '../widgets/activity_list.dart';
import '../widgets/module_fab.dart';
import '../widgets/module_search_bar.dart';
import '../widgets/status_filters.dart';

/// Écran de l'activité principale — le même fondement UI sert tous les
/// métiers, seule la configuration change le contenu affiché.
class PrimaryModuleScreen extends ConsumerWidget {
  const PrimaryModuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final establishment = ref.watch(currentEstablishmentProvider);
    if (!establishment.hasValue || establishment.valueOrNull == null) {
      return const SplashScreen();
    }

    return const PrimaryScaffold(
      floatingActionButton: ModuleFab(),
      body: Column(
        children: [
          ModuleSearchBar(),
          SizedBox(height: AppSpacing.md),
          StatusFilters(),
          SizedBox(height: AppSpacing.sm),
          Expanded(child: ActivityList()),
        ],
      ),
    );
  }
}
