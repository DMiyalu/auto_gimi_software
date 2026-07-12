import 'package:drift/drift.dart';

import 'product_categories_table.dart';

class Produits extends Table {
  TextColumn get id => text()();
  TextColumn get categorieId => text().references(ProductCategories, #id)();
  TextColumn get nom => text()();
  RealColumn get prix => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
