import 'package:drift/drift.dart';

class Factures extends Table {
  TextColumn get id => text()();
  TextColumn get establishmentId => text().withDefault(const Constant(''))();
  TextColumn get reference => text()();
  TextColumn get activityType => text()();
  TextColumn get activityId => text()();
  TextColumn get statut => text().withDefault(const Constant('emise'))();
  RealColumn get montantTotal => real()();
  RealColumn get montantPaye => real().withDefault(const Constant(0))();
  TextColumn get devise => text().withDefault(const Constant('USD'))();
  DateTimeColumn get issuedAt => dateTime()();
  DateTimeColumn get paidAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
