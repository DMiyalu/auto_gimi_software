import 'package:drift/drift.dart';

class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get phone => text()();
  TextColumn get nom => text()();
  TextColumn get prenom => text().nullable()();
  IntColumn get pointsFidelite => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
