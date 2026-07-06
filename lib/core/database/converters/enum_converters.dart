import 'package:drift/drift.dart';

import '../../domain/enums.dart';

class PrestationStatutConverter extends TypeConverter<PrestationStatut, String> {
  const PrestationStatutConverter();

  @override
  PrestationStatut fromSql(String fromDb) =>
      PrestationStatut.values.byName(fromDb);

  @override
  String toSql(PrestationStatut value) => value.name;
}

class JetonStatutConverter extends TypeConverter<JetonStatut, String> {
  const JetonStatutConverter();

  @override
  JetonStatut fromSql(String fromDb) => JetonStatut.values.byName(fromDb);

  @override
  String toSql(JetonStatut value) => value.name;
}

class AlerteStatutConverter extends TypeConverter<AlerteStatut, String> {
  const AlerteStatutConverter();

  @override
  AlerteStatut fromSql(String fromDb) => AlerteStatut.values.byName(fromDb);

  @override
  String toSql(AlerteStatut value) => value.name;
}

class NotificationTypeConverter extends TypeConverter<NotificationType, String> {
  const NotificationTypeConverter();

  @override
  NotificationType fromSql(String fromDb) =>
      NotificationType.values.byName(fromDb);

  @override
  String toSql(NotificationType value) => value.name;
}

class NotificationStatutConverter extends TypeConverter<NotificationStatut, String> {
  const NotificationStatutConverter();

  @override
  NotificationStatut fromSql(String fromDb) =>
      NotificationStatut.values.byName(fromDb);

  @override
  String toSql(NotificationStatut value) => value.name;
}
