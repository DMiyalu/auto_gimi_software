import 'package:drift/drift.dart';

import '../converters/enum_converters.dart';
import 'clients_table.dart';
import 'vehicules_table.dart';

class Prestations extends Table {
  TextColumn get id => text()();
  TextColumn get establishmentId => text().withDefault(const Constant(''))();
  TextColumn get clientId => text().nullable().references(Clients, #id)();
  TextColumn get vehiculeId => text().references(Vehicules, #id)();
  TextColumn get statut => text().map(const PrestationStatutConverter())();
  DateTimeColumn get dateOuverture => dateTime()();
  DateTimeColumn get dateCloture => dateTime().nullable()();
  RealColumn get montantTotal => real().withDefault(const Constant(0))();
  RealColumn get montantPointsDeduit => real().withDefault(const Constant(0))();
  IntColumn get pointsUtilises => integer().withDefault(const Constant(0))();
  IntColumn get pointsGagnes => integer().withDefault(const Constant(0))();
  IntColumn get kilometrage => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
