import 'package:drift/drift.dart';

import 'catalog_services_table.dart';
import 'prestations_table.dart';

class LignePrestations extends Table {
  TextColumn get id => text()();
  TextColumn get prestationId => text().references(Prestations, #id)();
  TextColumn get serviceId => text().references(CatalogServices, #id)();
  IntColumn get quantite => integer().withDefault(const Constant(1))();
  RealColumn get prixUnitaire => real()();
  RealColumn get montantLigne => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
