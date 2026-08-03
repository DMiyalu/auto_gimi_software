import 'package:drift/drift.dart';

import 'categories_table.dart';

class CatalogServices extends Table {
  TextColumn get id => text()();
  TextColumn get establishmentId => text().withDefault(const Constant(''))();
  TextColumn get categorieId => text().nullable().references(Categories, #id)();
  TextColumn get nom => text()();
  RealColumn get prix => real()();
  TextColumn get devise => text().withDefault(const Constant('USD'))();
  IntColumn get intervalleJours => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
