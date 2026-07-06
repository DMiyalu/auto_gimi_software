import 'package:drift/drift.dart';

/// Stocke l'horodatage de la dernière synchronisation pull par collection.
class SyncState extends Table {
  TextColumn get collection => text()();
  DateTimeColumn get lastSyncAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {collection};
}
