import 'package:drift/drift.dart';

import 'clients_table.dart';

class Vehicules extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get immatriculation => text()();
  TextColumn get marque => text()();
  TextColumn get modele => text()();
  IntColumn get annee => integer().nullable()();
  IntColumn get kilometrage => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
