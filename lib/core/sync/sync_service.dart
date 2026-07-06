import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';
import 'connectivity_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    database: ref.watch(databaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

/// Orchestration push/pull Firestore — implémentation complète à venir.
class SyncService {
  SyncService({
    required AppDatabase database,
    required ConnectivityService connectivity,
  })  : _database = database,
        _connectivity = connectivity;

  final AppDatabase _database; // ignore: unused_field — utilisé lors de l'implémentation sync
  final ConnectivityService _connectivity;

  String get garagePath => 'garages/${AppConfig.garageId}';

  Future<void> syncIfOnline() async {
    if (!await _connectivity.isOnline()) return;
    await pushDirtyRecords();
    await pullRemoteChanges();
  }

  Future<void> pushDirtyRecords() async {
    // TODO: pousser les enregistrements isDirty vers Firestore.
  }

  Future<void> pullRemoteChanges() async {
    // TODO: récupérer les changements distants (LWW sur updatedAt).
  }
}
