import 'package:drift/drift.dart';

import 'factures_table.dart';

class Paiements extends Table {
  TextColumn get id => text()();
  TextColumn get establishmentId => text().withDefault(const Constant(''))();
  TextColumn get factureId => text().references(Factures, #id)();
  TextColumn get methode => text()();
  RealColumn get montant => real()();
  TextColumn get devise => text().withDefault(const Constant('USD'))();
  DateTimeColumn get paidAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
