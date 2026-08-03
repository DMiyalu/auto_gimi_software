import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/establishment_providers.dart';

class CatalogPermissionGate extends ConsumerWidget {
  const CatalogPermissionGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManageCatalog = ref.watch(canManageCatalogProvider);
    if (canManageCatalog) return child;

    return Scaffold(
      appBar: AppBar(title: const Text('Accès limité')),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 56),
                SizedBox(height: 16),
                Text(
                  'Catalogue en lecture seule',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Seuls le propriétaire et les gérants peuvent modifier les produits, services et catégories.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
