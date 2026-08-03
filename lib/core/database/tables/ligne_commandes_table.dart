import 'package:drift/drift.dart';

import 'commandes_table.dart';
import 'produits_table.dart';

class LigneCommandes extends Table {
  TextColumn get id => text()();
  TextColumn get establishmentId => text().withDefault(const Constant(''))();
  TextColumn get commandeId => text().references(Commandes, #id)();
  TextColumn get produitId => text().references(Produits, #id)();
  TextColumn get libelle => text()();
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
