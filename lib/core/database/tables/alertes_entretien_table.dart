import 'package:drift/drift.dart';

import '../converters/enum_converters.dart';
import 'catalog_services_table.dart';
import 'vehicules_table.dart';

class AlertesEntretien extends Table {
  TextColumn get id => text()();
  TextColumn get establishmentId => text().withDefault(const Constant(''))();
  TextColumn get vehiculeId => text().references(Vehicules, #id)();
  TextColumn get serviceId => text().references(CatalogServices, #id)();
  DateTimeColumn get dateEcheance => dateTime()();
  TextColumn get statut => text().map(const AlerteStatutConverter())();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
