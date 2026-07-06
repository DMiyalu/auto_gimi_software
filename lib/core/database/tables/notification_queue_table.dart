import 'package:drift/drift.dart';

import '../converters/enum_converters.dart';
import 'clients_table.dart';

class NotificationQueue extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get telephone => text()();
  TextColumn get type => text().map(const NotificationTypeConverter())();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get statut =>
      text().map(const NotificationStatutConverter())();
  TextColumn get alerteEntretienId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
