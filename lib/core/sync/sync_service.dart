import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/establishment/presentation/providers/establishment_providers.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';
import 'connectivity_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  return SyncService(
    database: ref.watch(databaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    establishmentId: establishment?.id,
  );
});

/// Orchestration push/pull Firestore — implémentation complète à venir.
class SyncService {
  SyncService({
    required AppDatabase database,
    required ConnectivityService connectivity,
    required String? establishmentId,
  })  : _database = database,
        _connectivity = connectivity,
        _establishmentId = establishmentId;

  final AppDatabase _database; // ignore: unused_field — utilisé lors de l'implémentation sync
  final ConnectivityService _connectivity;
  final String? _establishmentId;

  String? get establishmentPath => _establishmentId == null
      ? null
      : 'establishments/$_establishmentId';

  Future<void> syncIfOnline() async {
    if (_establishmentId == null) return;
    if (!await _connectivity.isOnline()) return;
    await pushDirtyRecords();
    await pullRemoteChanges();
  }

  Future<void> pushDirtyRecords() async {
    // TODO: pousser les enregistrements isDirty vers Firestore
    // sous establishments/{establishmentId}/...
  }

  Future<void> pullRemoteChanges() async {
    // TODO: récupérer les changements distants (LWW sur updatedAt).
  }
}
