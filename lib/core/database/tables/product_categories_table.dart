import 'package:drift/drift.dart';

class ProductCategories extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  IntColumn get ordre => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
