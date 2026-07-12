import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/service_providers.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCategories = _tabController.index == 1;

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.services),
              Tab(text: l10n.serviceCategories),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ServicesListTab(),
                _ServiceCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          isCategories ? Routes.serviceCategoryNew : Routes.serviceNew,
        ),
        icon: Icon(
          isCategories ? Icons.create_new_folder_outlined : Icons.add,
        ),
        label: Text(
          isCategories ? l10n.addServiceCategory : l10n.addService,
        ),
      ),
    );
  }
}

class _ServicesListTab extends ConsumerWidget {
  const _ServicesListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final servicesAsync = ref.watch(catalogServicesProvider);

    return servicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (services) {
        if (services.isEmpty) {
          return _EmptyState(
            icon: Icons.build_outlined,
            title: l10n.noServices,
            hint: l10n.noServicesHint,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: services.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final service = services[index];
            return ListTile(
              leading: CircleAvatar(
                child: Icon(
                  Icons.build_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(service.name),
              subtitle: Text(service.categoryName),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(service.price),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (service.intervalDays > 0)
                    Text(
                      l10n.intervalDays(service.intervalDays),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ServiceCategoriesTab extends ConsumerWidget {
  const _ServiceCategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final servicesAsync = ref.watch(catalogServicesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (categories) {
        if (categories.isEmpty) {
          return _EmptyState(
            icon: Icons.folder_outlined,
            title: l10n.noServiceCategories,
            hint: l10n.noServiceCategoriesHint,
          );
        }

        final services = servicesAsync.valueOrNull ?? [];
        final counts = <String, int>{};
        for (final service in services) {
          counts[service.categoryId] = (counts[service.categoryId] ?? 0) + 1;
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final category = categories[index];
            final count = counts[category.id] ?? 0;
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.folder_outlined),
              ),
              title: Text(category.name),
              subtitle: Text(l10n.servicesCount(count)),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.hint,
  });

  final IconData icon;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
