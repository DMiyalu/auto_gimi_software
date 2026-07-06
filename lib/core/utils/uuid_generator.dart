import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Génère un identifiant UUID v4 pour les entités synchronisables.
String newUuid() => _uuid.v4();
