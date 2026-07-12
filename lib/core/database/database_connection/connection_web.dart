import 'package:drift/drift.dart';
import 'package:drift/web.dart';

Future<QueryExecutor> createDatabaseConnection() async {
  // WebDatabase persists data in browser storage (IndexedDB/localStorage).
  return WebDatabase('garage_db');
}
