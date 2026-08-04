import 'package:drift/drift.dart';

import 'product_categories_table.dart';

class Produits extends Table {
  TextColumn get id => text()();
  TextColumn get establishmentId => text().withDefault(const Constant(''))();
  TextColumn get categorieId =>
      text().nullable().references(ProductCategories, #id)();
  TextColumn get nom => text()();
  RealColumn get prix => real()();
  TextColumn get devise => text().withDefault(const Constant('USD'))();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  BoolColumn get stockTrackingEnabled =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
