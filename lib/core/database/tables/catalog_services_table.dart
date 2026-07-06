import 'package:drift/drift.dart';

import 'categories_table.dart';

class CatalogServices extends Table {
  TextColumn get id => text()();
  TextColumn get categorieId => text().references(Categories, #id)();
  TextColumn get nom => text()();
  RealColumn get prix => real()();
  IntColumn get intervalleJours => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
