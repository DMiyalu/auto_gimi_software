import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../shell/presentation/widgets/app_drawer.dart';
import '../widgets/activity_list.dart';
import '../widgets/business_header.dart';
import '../widgets/module_fab.dart';
import '../widgets/module_search_bar.dart';
import '../widgets/status_filters.dart';

/// Écran de l'activité principale — le même fondement UI sert tous les
/// métiers, seule la configuration change le contenu affiché.
class PrimaryModuleScreen extends StatelessWidget {
  const PrimaryModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      floatingActionButton: const ModuleFab(),
      body: SafeArea(
        child: Column(
          children: [
            const BusinessHeader(),
            const SizedBox(height: AppSpacing.xs),
            const ModuleSearchBar(),
            const SizedBox(height: AppSpacing.sm),
            const StatusFilters(),
            const SizedBox(height: AppSpacing.xs),
            const Expanded(child: ActivityList()),
          ],
        ),
      ),
    );
  }
}
