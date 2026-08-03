import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../shell/presentation/widgets/primary_scaffold.dart';
import '../widgets/activity_list.dart';
import '../widgets/module_fab.dart';
import '../widgets/module_search_bar.dart';
import '../widgets/status_filters.dart';

/// Écran de l'activité principale — le même fondement UI sert tous les
/// métiers, seule la configuration change le contenu affiché.
class PrimaryModuleScreen extends StatelessWidget {
  const PrimaryModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrimaryScaffold(
      floatingActionButton: ModuleFab(),
      body: Column(
        children: [
          ModuleSearchBar(),
          SizedBox(height: AppSpacing.sm),
          StatusFilters(),
          SizedBox(height: AppSpacing.xs),
          Expanded(child: ActivityList()),
        ],
      ),
    );
  }
}
