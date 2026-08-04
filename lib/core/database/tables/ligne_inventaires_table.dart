import 'package:drift/drift.dart';

import 'inventaires_table.dart';
import 'produits_table.dart';

class LigneInventaires extends Table {
  TextColumn get id => text()();
  TextColumn get establishmentId => text().withDefault(const Constant(''))();
  TextColumn get inventaireId => text().references(Inventaires, #id)();
  TextColumn get produitId => text().references(Produits, #id)();
  TextColumn get libelle => text()();
  IntColumn get stockTheorique => integer()();
  IntColumn get stockCompte => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
