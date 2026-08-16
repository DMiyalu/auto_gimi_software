import 'package:drift/drift.dart';

class Commandes extends Table {
  TextColumn get id => text()();
  TextColumn get establishmentId => text().withDefault(const Constant(''))();
  TextColumn get clientId => text().nullable()();
  TextColumn get servedByMemberId => text().nullable()();
  TextColumn get reference => text()();
  TextColumn get statut => text().withDefault(const Constant('en_cours'))();
  TextColumn get contexte => text().nullable()();
  RealColumn get montantTotal => real().withDefault(const Constant(0))();
  TextColumn get paymentMethod => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
