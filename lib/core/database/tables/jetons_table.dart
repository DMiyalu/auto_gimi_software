import 'package:drift/drift.dart';

import '../converters/enum_converters.dart';
import 'clients_table.dart';
import 'prestations_table.dart';

class Jetons extends Table {
  TextColumn get id => text()();
  TextColumn get prestationId => text().references(Prestations, #id)();
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get statut => text().map(const JetonStatutConverter())();
  DateTimeColumn get dateEmission => dateTime()();
  DateTimeColumn get dateConsommation => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
