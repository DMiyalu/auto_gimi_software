// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prenomMeta = const VerificationMeta('prenom');
  @override
  late final GeneratedColumn<String> prenom = GeneratedColumn<String>(
    'prenom',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adresseMeta = const VerificationMeta(
    'adresse',
  );
  @override
  late final GeneratedColumn<String> adresse = GeneratedColumn<String>(
    'adresse',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeClientMeta = const VerificationMeta(
    'typeClient',
  );
  @override
  late final GeneratedColumn<String> typeClient = GeneratedColumn<String>(
    'type_client',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('particulier'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pointsFideliteMeta = const VerificationMeta(
    'pointsFidelite',
  );
  @override
  late final GeneratedColumn<int> pointsFidelite = GeneratedColumn<int>(
    'points_fidelite',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    phone,
    nom,
    prenom,
    email,
    adresse,
    typeClient,
    notes,
    pointsFidelite,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Client> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('prenom')) {
      context.handle(
        _prenomMeta,
        prenom.isAcceptableOrUnknown(data['prenom']!, _prenomMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('adresse')) {
      context.handle(
        _adresseMeta,
        adresse.isAcceptableOrUnknown(data['adresse']!, _adresseMeta),
      );
    }
    if (data.containsKey('type_client')) {
      context.handle(
        _typeClientMeta,
        typeClient.isAcceptableOrUnknown(data['type_client']!, _typeClientMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('points_fidelite')) {
      context.handle(
        _pointsFideliteMeta,
        pointsFidelite.isAcceptableOrUnknown(
          data['points_fidelite']!,
          _pointsFideliteMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      prenom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prenom'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      adresse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adresse'],
      ),
      typeClient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_client'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      pointsFidelite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_fidelite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final String id;
  final String establishmentId;
  final String phone;
  final String nom;
  final String? prenom;
  final String? email;
  final String? adresse;
  final String typeClient;
  final String? notes;
  final int pointsFidelite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const Client({
    required this.id,
    required this.establishmentId,
    required this.phone,
    required this.nom,
    this.prenom,
    this.email,
    this.adresse,
    required this.typeClient,
    this.notes,
    required this.pointsFidelite,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    map['phone'] = Variable<String>(phone);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || prenom != null) {
      map['prenom'] = Variable<String>(prenom);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || adresse != null) {
      map['adresse'] = Variable<String>(adresse);
    }
    map['type_client'] = Variable<String>(typeClient);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['points_fidelite'] = Variable<int>(pointsFidelite);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      phone: Value(phone),
      nom: Value(nom),
      prenom: prenom == null && nullToAbsent
          ? const Value.absent()
          : Value(prenom),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      adresse: adresse == null && nullToAbsent
          ? const Value.absent()
          : Value(adresse),
      typeClient: Value(typeClient),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      pointsFidelite: Value(pointsFidelite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      phone: serializer.fromJson<String>(json['phone']),
      nom: serializer.fromJson<String>(json['nom']),
      prenom: serializer.fromJson<String?>(json['prenom']),
      email: serializer.fromJson<String?>(json['email']),
      adresse: serializer.fromJson<String?>(json['adresse']),
      typeClient: serializer.fromJson<String>(json['typeClient']),
      notes: serializer.fromJson<String?>(json['notes']),
      pointsFidelite: serializer.fromJson<int>(json['pointsFidelite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'phone': serializer.toJson<String>(phone),
      'nom': serializer.toJson<String>(nom),
      'prenom': serializer.toJson<String?>(prenom),
      'email': serializer.toJson<String?>(email),
      'adresse': serializer.toJson<String?>(adresse),
      'typeClient': serializer.toJson<String>(typeClient),
      'notes': serializer.toJson<String?>(notes),
      'pointsFidelite': serializer.toJson<int>(pointsFidelite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Client copyWith({
    String? id,
    String? establishmentId,
    String? phone,
    String? nom,
    Value<String?> prenom = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> adresse = const Value.absent(),
    String? typeClient,
    Value<String?> notes = const Value.absent(),
    int? pointsFidelite,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => Client(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    phone: phone ?? this.phone,
    nom: nom ?? this.nom,
    prenom: prenom.present ? prenom.value : this.prenom,
    email: email.present ? email.value : this.email,
    adresse: adresse.present ? adresse.value : this.adresse,
    typeClient: typeClient ?? this.typeClient,
    notes: notes.present ? notes.value : this.notes,
    pointsFidelite: pointsFidelite ?? this.pointsFidelite,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      phone: data.phone.present ? data.phone.value : this.phone,
      nom: data.nom.present ? data.nom.value : this.nom,
      prenom: data.prenom.present ? data.prenom.value : this.prenom,
      email: data.email.present ? data.email.value : this.email,
      adresse: data.adresse.present ? data.adresse.value : this.adresse,
      typeClient: data.typeClient.present
          ? data.typeClient.value
          : this.typeClient,
      notes: data.notes.present ? data.notes.value : this.notes,
      pointsFidelite: data.pointsFidelite.present
          ? data.pointsFidelite.value
          : this.pointsFidelite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('phone: $phone, ')
          ..write('nom: $nom, ')
          ..write('prenom: $prenom, ')
          ..write('email: $email, ')
          ..write('adresse: $adresse, ')
          ..write('typeClient: $typeClient, ')
          ..write('notes: $notes, ')
          ..write('pointsFidelite: $pointsFidelite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    phone,
    nom,
    prenom,
    email,
    adresse,
    typeClient,
    notes,
    pointsFidelite,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.phone == this.phone &&
          other.nom == this.nom &&
          other.prenom == this.prenom &&
          other.email == this.email &&
          other.adresse == this.adresse &&
          other.typeClient == this.typeClient &&
          other.notes == this.notes &&
          other.pointsFidelite == this.pointsFidelite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String> phone;
  final Value<String> nom;
  final Value<String?> prenom;
  final Value<String?> email;
  final Value<String?> adresse;
  final Value<String> typeClient;
  final Value<String?> notes;
  final Value<int> pointsFidelite;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.phone = const Value.absent(),
    this.nom = const Value.absent(),
    this.prenom = const Value.absent(),
    this.email = const Value.absent(),
    this.adresse = const Value.absent(),
    this.typeClient = const Value.absent(),
    this.notes = const Value.absent(),
    this.pointsFidelite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    required String phone,
    required String nom,
    this.prenom = const Value.absent(),
    this.email = const Value.absent(),
    this.adresse = const Value.absent(),
    this.typeClient = const Value.absent(),
    this.notes = const Value.absent(),
    this.pointsFidelite = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       phone = Value(phone),
       nom = Value(nom),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Client> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? phone,
    Expression<String>? nom,
    Expression<String>? prenom,
    Expression<String>? email,
    Expression<String>? adresse,
    Expression<String>? typeClient,
    Expression<String>? notes,
    Expression<int>? pointsFidelite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (phone != null) 'phone': phone,
      if (nom != null) 'nom': nom,
      if (prenom != null) 'prenom': prenom,
      if (email != null) 'email': email,
      if (adresse != null) 'adresse': adresse,
      if (typeClient != null) 'type_client': typeClient,
      if (notes != null) 'notes': notes,
      if (pointsFidelite != null) 'points_fidelite': pointsFidelite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String>? phone,
    Value<String>? nom,
    Value<String?>? prenom,
    Value<String?>? email,
    Value<String?>? adresse,
    Value<String>? typeClient,
    Value<String?>? notes,
    Value<int>? pointsFidelite,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      phone: phone ?? this.phone,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      adresse: adresse ?? this.adresse,
      typeClient: typeClient ?? this.typeClient,
      notes: notes ?? this.notes,
      pointsFidelite: pointsFidelite ?? this.pointsFidelite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (prenom.present) {
      map['prenom'] = Variable<String>(prenom.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (adresse.present) {
      map['adresse'] = Variable<String>(adresse.value);
    }
    if (typeClient.present) {
      map['type_client'] = Variable<String>(typeClient.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (pointsFidelite.present) {
      map['points_fidelite'] = Variable<int>(pointsFidelite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('phone: $phone, ')
          ..write('nom: $nom, ')
          ..write('prenom: $prenom, ')
          ..write('email: $email, ')
          ..write('adresse: $adresse, ')
          ..write('typeClient: $typeClient, ')
          ..write('notes: $notes, ')
          ..write('pointsFidelite: $pointsFidelite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehiculesTable extends Vehicules
    with TableInfo<$VehiculesTable, Vehicule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiculesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _immatriculationMeta = const VerificationMeta(
    'immatriculation',
  );
  @override
  late final GeneratedColumn<String> immatriculation = GeneratedColumn<String>(
    'immatriculation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marqueMeta = const VerificationMeta('marque');
  @override
  late final GeneratedColumn<String> marque = GeneratedColumn<String>(
    'marque',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeleMeta = const VerificationMeta('modele');
  @override
  late final GeneratedColumn<String> modele = GeneratedColumn<String>(
    'modele',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anneeMeta = const VerificationMeta('annee');
  @override
  late final GeneratedColumn<int> annee = GeneratedColumn<int>(
    'annee',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kilometrageMeta = const VerificationMeta(
    'kilometrage',
  );
  @override
  late final GeneratedColumn<int> kilometrage = GeneratedColumn<int>(
    'kilometrage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    clientId,
    immatriculation,
    marque,
    modele,
    annee,
    kilometrage,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('immatriculation')) {
      context.handle(
        _immatriculationMeta,
        immatriculation.isAcceptableOrUnknown(
          data['immatriculation']!,
          _immatriculationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_immatriculationMeta);
    }
    if (data.containsKey('marque')) {
      context.handle(
        _marqueMeta,
        marque.isAcceptableOrUnknown(data['marque']!, _marqueMeta),
      );
    }
    if (data.containsKey('modele')) {
      context.handle(
        _modeleMeta,
        modele.isAcceptableOrUnknown(data['modele']!, _modeleMeta),
      );
    }
    if (data.containsKey('annee')) {
      context.handle(
        _anneeMeta,
        annee.isAcceptableOrUnknown(data['annee']!, _anneeMeta),
      );
    }
    if (data.containsKey('kilometrage')) {
      context.handle(
        _kilometrageMeta,
        kilometrage.isAcceptableOrUnknown(
          data['kilometrage']!,
          _kilometrageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      immatriculation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}immatriculation'],
      )!,
      marque: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marque'],
      ),
      modele: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modele'],
      ),
      annee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}annee'],
      ),
      kilometrage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kilometrage'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $VehiculesTable createAlias(String alias) {
    return $VehiculesTable(attachedDatabase, alias);
  }
}

class Vehicule extends DataClass implements Insertable<Vehicule> {
  final String id;
  final String establishmentId;
  final String? clientId;
  final String immatriculation;
  final String? marque;
  final String? modele;
  final int? annee;
  final int? kilometrage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const Vehicule({
    required this.id,
    required this.establishmentId,
    this.clientId,
    required this.immatriculation,
    this.marque,
    this.modele,
    this.annee,
    this.kilometrage,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['immatriculation'] = Variable<String>(immatriculation);
    if (!nullToAbsent || marque != null) {
      map['marque'] = Variable<String>(marque);
    }
    if (!nullToAbsent || modele != null) {
      map['modele'] = Variable<String>(modele);
    }
    if (!nullToAbsent || annee != null) {
      map['annee'] = Variable<int>(annee);
    }
    if (!nullToAbsent || kilometrage != null) {
      map['kilometrage'] = Variable<int>(kilometrage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  VehiculesCompanion toCompanion(bool nullToAbsent) {
    return VehiculesCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      immatriculation: Value(immatriculation),
      marque: marque == null && nullToAbsent
          ? const Value.absent()
          : Value(marque),
      modele: modele == null && nullToAbsent
          ? const Value.absent()
          : Value(modele),
      annee: annee == null && nullToAbsent
          ? const Value.absent()
          : Value(annee),
      kilometrage: kilometrage == null && nullToAbsent
          ? const Value.absent()
          : Value(kilometrage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory Vehicule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicule(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      immatriculation: serializer.fromJson<String>(json['immatriculation']),
      marque: serializer.fromJson<String?>(json['marque']),
      modele: serializer.fromJson<String?>(json['modele']),
      annee: serializer.fromJson<int?>(json['annee']),
      kilometrage: serializer.fromJson<int?>(json['kilometrage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'clientId': serializer.toJson<String?>(clientId),
      'immatriculation': serializer.toJson<String>(immatriculation),
      'marque': serializer.toJson<String?>(marque),
      'modele': serializer.toJson<String?>(modele),
      'annee': serializer.toJson<int?>(annee),
      'kilometrage': serializer.toJson<int?>(kilometrage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Vehicule copyWith({
    String? id,
    String? establishmentId,
    Value<String?> clientId = const Value.absent(),
    String? immatriculation,
    Value<String?> marque = const Value.absent(),
    Value<String?> modele = const Value.absent(),
    Value<int?> annee = const Value.absent(),
    Value<int?> kilometrage = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => Vehicule(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    clientId: clientId.present ? clientId.value : this.clientId,
    immatriculation: immatriculation ?? this.immatriculation,
    marque: marque.present ? marque.value : this.marque,
    modele: modele.present ? modele.value : this.modele,
    annee: annee.present ? annee.value : this.annee,
    kilometrage: kilometrage.present ? kilometrage.value : this.kilometrage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  Vehicule copyWithCompanion(VehiculesCompanion data) {
    return Vehicule(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      immatriculation: data.immatriculation.present
          ? data.immatriculation.value
          : this.immatriculation,
      marque: data.marque.present ? data.marque.value : this.marque,
      modele: data.modele.present ? data.modele.value : this.modele,
      annee: data.annee.present ? data.annee.value : this.annee,
      kilometrage: data.kilometrage.present
          ? data.kilometrage.value
          : this.kilometrage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicule(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('clientId: $clientId, ')
          ..write('immatriculation: $immatriculation, ')
          ..write('marque: $marque, ')
          ..write('modele: $modele, ')
          ..write('annee: $annee, ')
          ..write('kilometrage: $kilometrage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    clientId,
    immatriculation,
    marque,
    modele,
    annee,
    kilometrage,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicule &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.clientId == this.clientId &&
          other.immatriculation == this.immatriculation &&
          other.marque == this.marque &&
          other.modele == this.modele &&
          other.annee == this.annee &&
          other.kilometrage == this.kilometrage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class VehiculesCompanion extends UpdateCompanion<Vehicule> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String?> clientId;
  final Value<String> immatriculation;
  final Value<String?> marque;
  final Value<String?> modele;
  final Value<int?> annee;
  final Value<int?> kilometrage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const VehiculesCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.immatriculation = const Value.absent(),
    this.marque = const Value.absent(),
    this.modele = const Value.absent(),
    this.annee = const Value.absent(),
    this.kilometrage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiculesCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String immatriculation,
    this.marque = const Value.absent(),
    this.modele = const Value.absent(),
    this.annee = const Value.absent(),
    this.kilometrage = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       immatriculation = Value(immatriculation),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Vehicule> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? clientId,
    Expression<String>? immatriculation,
    Expression<String>? marque,
    Expression<String>? modele,
    Expression<int>? annee,
    Expression<int>? kilometrage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (clientId != null) 'client_id': clientId,
      if (immatriculation != null) 'immatriculation': immatriculation,
      if (marque != null) 'marque': marque,
      if (modele != null) 'modele': modele,
      if (annee != null) 'annee': annee,
      if (kilometrage != null) 'kilometrage': kilometrage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiculesCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String?>? clientId,
    Value<String>? immatriculation,
    Value<String?>? marque,
    Value<String?>? modele,
    Value<int?>? annee,
    Value<int?>? kilometrage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return VehiculesCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      clientId: clientId ?? this.clientId,
      immatriculation: immatriculation ?? this.immatriculation,
      marque: marque ?? this.marque,
      modele: modele ?? this.modele,
      annee: annee ?? this.annee,
      kilometrage: kilometrage ?? this.kilometrage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (immatriculation.present) {
      map['immatriculation'] = Variable<String>(immatriculation.value);
    }
    if (marque.present) {
      map['marque'] = Variable<String>(marque.value);
    }
    if (modele.present) {
      map['modele'] = Variable<String>(modele.value);
    }
    if (annee.present) {
      map['annee'] = Variable<int>(annee.value);
    }
    if (kilometrage.present) {
      map['kilometrage'] = Variable<int>(kilometrage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiculesCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('clientId: $clientId, ')
          ..write('immatriculation: $immatriculation, ')
          ..write('marque: $marque, ')
          ..write('modele: $modele, ')
          ..write('annee: $annee, ')
          ..write('kilometrage: $kilometrage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordreMeta = const VerificationMeta('ordre');
  @override
  late final GeneratedColumn<int> ordre = GeneratedColumn<int>(
    'ordre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    nom,
    ordre,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('ordre')) {
      context.handle(
        _ordreMeta,
        ordre.isAcceptableOrUnknown(data['ordre']!, _ordreMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      ordre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordre'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String establishmentId;
  final String nom;
  final int ordre;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const Category({
    required this.id,
    required this.establishmentId,
    required this.nom,
    required this.ordre,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    map['nom'] = Variable<String>(nom);
    map['ordre'] = Variable<int>(ordre);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      nom: Value(nom),
      ordre: Value(ordre),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      nom: serializer.fromJson<String>(json['nom']),
      ordre: serializer.fromJson<int>(json['ordre']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'nom': serializer.toJson<String>(nom),
      'ordre': serializer.toJson<int>(ordre),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Category copyWith({
    String? id,
    String? establishmentId,
    String? nom,
    int? ordre,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => Category(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    nom: nom ?? this.nom,
    ordre: ordre ?? this.ordre,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      nom: data.nom.present ? data.nom.value : this.nom,
      ordre: data.ordre.present ? data.ordre.value : this.ordre,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('nom: $nom, ')
          ..write('ordre: $ordre, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    nom,
    ordre,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.nom == this.nom &&
          other.ordre == this.ordre &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String> nom;
  final Value<int> ordre;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.nom = const Value.absent(),
    this.ordre = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    required String nom,
    this.ordre = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nom = Value(nom),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? nom,
    Expression<int>? ordre,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (nom != null) 'nom': nom,
      if (ordre != null) 'ordre': ordre,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String>? nom,
    Value<int>? ordre,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      nom: nom ?? this.nom,
      ordre: ordre ?? this.ordre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (ordre.present) {
      map['ordre'] = Variable<int>(ordre.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('nom: $nom, ')
          ..write('ordre: $ordre, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogServicesTable extends CatalogServices
    with TableInfo<$CatalogServicesTable, CatalogService> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categorieIdMeta = const VerificationMeta(
    'categorieId',
  );
  @override
  late final GeneratedColumn<String> categorieId = GeneratedColumn<String>(
    'categorie_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prixMeta = const VerificationMeta('prix');
  @override
  late final GeneratedColumn<double> prix = GeneratedColumn<double>(
    'prix',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
    'devise',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _intervalleJoursMeta = const VerificationMeta(
    'intervalleJours',
  );
  @override
  late final GeneratedColumn<int> intervalleJours = GeneratedColumn<int>(
    'intervalle_jours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    categorieId,
    nom,
    prix,
    devise,
    intervalleJours,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_services';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogService> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('categorie_id')) {
      context.handle(
        _categorieIdMeta,
        categorieId.isAcceptableOrUnknown(
          data['categorie_id']!,
          _categorieIdMeta,
        ),
      );
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('prix')) {
      context.handle(
        _prixMeta,
        prix.isAcceptableOrUnknown(data['prix']!, _prixMeta),
      );
    } else if (isInserting) {
      context.missing(_prixMeta);
    }
    if (data.containsKey('devise')) {
      context.handle(
        _deviseMeta,
        devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta),
      );
    }
    if (data.containsKey('intervalle_jours')) {
      context.handle(
        _intervalleJoursMeta,
        intervalleJours.isAcceptableOrUnknown(
          data['intervalle_jours']!,
          _intervalleJoursMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogService map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogService(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      categorieId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categorie_id'],
      ),
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      prix: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prix'],
      )!,
      devise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}devise'],
      )!,
      intervalleJours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intervalle_jours'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $CatalogServicesTable createAlias(String alias) {
    return $CatalogServicesTable(attachedDatabase, alias);
  }
}

class CatalogService extends DataClass implements Insertable<CatalogService> {
  final String id;
  final String establishmentId;
  final String? categorieId;
  final String nom;
  final double prix;
  final String devise;
  final int intervalleJours;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const CatalogService({
    required this.id,
    required this.establishmentId,
    this.categorieId,
    required this.nom,
    required this.prix,
    required this.devise,
    required this.intervalleJours,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    if (!nullToAbsent || categorieId != null) {
      map['categorie_id'] = Variable<String>(categorieId);
    }
    map['nom'] = Variable<String>(nom);
    map['prix'] = Variable<double>(prix);
    map['devise'] = Variable<String>(devise);
    map['intervalle_jours'] = Variable<int>(intervalleJours);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  CatalogServicesCompanion toCompanion(bool nullToAbsent) {
    return CatalogServicesCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      categorieId: categorieId == null && nullToAbsent
          ? const Value.absent()
          : Value(categorieId),
      nom: Value(nom),
      prix: Value(prix),
      devise: Value(devise),
      intervalleJours: Value(intervalleJours),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory CatalogService.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogService(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      categorieId: serializer.fromJson<String?>(json['categorieId']),
      nom: serializer.fromJson<String>(json['nom']),
      prix: serializer.fromJson<double>(json['prix']),
      devise: serializer.fromJson<String>(json['devise']),
      intervalleJours: serializer.fromJson<int>(json['intervalleJours']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'categorieId': serializer.toJson<String?>(categorieId),
      'nom': serializer.toJson<String>(nom),
      'prix': serializer.toJson<double>(prix),
      'devise': serializer.toJson<String>(devise),
      'intervalleJours': serializer.toJson<int>(intervalleJours),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  CatalogService copyWith({
    String? id,
    String? establishmentId,
    Value<String?> categorieId = const Value.absent(),
    String? nom,
    double? prix,
    String? devise,
    int? intervalleJours,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => CatalogService(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    categorieId: categorieId.present ? categorieId.value : this.categorieId,
    nom: nom ?? this.nom,
    prix: prix ?? this.prix,
    devise: devise ?? this.devise,
    intervalleJours: intervalleJours ?? this.intervalleJours,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  CatalogService copyWithCompanion(CatalogServicesCompanion data) {
    return CatalogService(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      categorieId: data.categorieId.present
          ? data.categorieId.value
          : this.categorieId,
      nom: data.nom.present ? data.nom.value : this.nom,
      prix: data.prix.present ? data.prix.value : this.prix,
      devise: data.devise.present ? data.devise.value : this.devise,
      intervalleJours: data.intervalleJours.present
          ? data.intervalleJours.value
          : this.intervalleJours,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogService(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('categorieId: $categorieId, ')
          ..write('nom: $nom, ')
          ..write('prix: $prix, ')
          ..write('devise: $devise, ')
          ..write('intervalleJours: $intervalleJours, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    categorieId,
    nom,
    prix,
    devise,
    intervalleJours,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogService &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.categorieId == this.categorieId &&
          other.nom == this.nom &&
          other.prix == this.prix &&
          other.devise == this.devise &&
          other.intervalleJours == this.intervalleJours &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class CatalogServicesCompanion extends UpdateCompanion<CatalogService> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String?> categorieId;
  final Value<String> nom;
  final Value<double> prix;
  final Value<String> devise;
  final Value<int> intervalleJours;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const CatalogServicesCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.categorieId = const Value.absent(),
    this.nom = const Value.absent(),
    this.prix = const Value.absent(),
    this.devise = const Value.absent(),
    this.intervalleJours = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogServicesCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    this.categorieId = const Value.absent(),
    required String nom,
    required double prix,
    this.devise = const Value.absent(),
    this.intervalleJours = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nom = Value(nom),
       prix = Value(prix),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CatalogService> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? categorieId,
    Expression<String>? nom,
    Expression<double>? prix,
    Expression<String>? devise,
    Expression<int>? intervalleJours,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (categorieId != null) 'categorie_id': categorieId,
      if (nom != null) 'nom': nom,
      if (prix != null) 'prix': prix,
      if (devise != null) 'devise': devise,
      if (intervalleJours != null) 'intervalle_jours': intervalleJours,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogServicesCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String?>? categorieId,
    Value<String>? nom,
    Value<double>? prix,
    Value<String>? devise,
    Value<int>? intervalleJours,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return CatalogServicesCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      categorieId: categorieId ?? this.categorieId,
      nom: nom ?? this.nom,
      prix: prix ?? this.prix,
      devise: devise ?? this.devise,
      intervalleJours: intervalleJours ?? this.intervalleJours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (categorieId.present) {
      map['categorie_id'] = Variable<String>(categorieId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (prix.present) {
      map['prix'] = Variable<double>(prix.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (intervalleJours.present) {
      map['intervalle_jours'] = Variable<int>(intervalleJours.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogServicesCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('categorieId: $categorieId, ')
          ..write('nom: $nom, ')
          ..write('prix: $prix, ')
          ..write('devise: $devise, ')
          ..write('intervalleJours: $intervalleJours, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductCategoriesTable extends ProductCategories
    with TableInfo<$ProductCategoriesTable, ProductCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordreMeta = const VerificationMeta('ordre');
  @override
  late final GeneratedColumn<int> ordre = GeneratedColumn<int>(
    'ordre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    nom,
    ordre,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('ordre')) {
      context.handle(
        _ordreMeta,
        ordre.isAcceptableOrUnknown(data['ordre']!, _ordreMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      ordre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordre'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $ProductCategoriesTable createAlias(String alias) {
    return $ProductCategoriesTable(attachedDatabase, alias);
  }
}

class ProductCategory extends DataClass implements Insertable<ProductCategory> {
  final String id;
  final String establishmentId;
  final String nom;
  final int ordre;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const ProductCategory({
    required this.id,
    required this.establishmentId,
    required this.nom,
    required this.ordre,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    map['nom'] = Variable<String>(nom);
    map['ordre'] = Variable<int>(ordre);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  ProductCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ProductCategoriesCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      nom: Value(nom),
      ordre: Value(ordre),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory ProductCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductCategory(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      nom: serializer.fromJson<String>(json['nom']),
      ordre: serializer.fromJson<int>(json['ordre']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'nom': serializer.toJson<String>(nom),
      'ordre': serializer.toJson<int>(ordre),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  ProductCategory copyWith({
    String? id,
    String? establishmentId,
    String? nom,
    int? ordre,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => ProductCategory(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    nom: nom ?? this.nom,
    ordre: ordre ?? this.ordre,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  ProductCategory copyWithCompanion(ProductCategoriesCompanion data) {
    return ProductCategory(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      nom: data.nom.present ? data.nom.value : this.nom,
      ordre: data.ordre.present ? data.ordre.value : this.ordre,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductCategory(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('nom: $nom, ')
          ..write('ordre: $ordre, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    nom,
    ordre,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductCategory &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.nom == this.nom &&
          other.ordre == this.ordre &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class ProductCategoriesCompanion extends UpdateCompanion<ProductCategory> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String> nom;
  final Value<int> ordre;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const ProductCategoriesCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.nom = const Value.absent(),
    this.ordre = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductCategoriesCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    required String nom,
    this.ordre = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nom = Value(nom),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProductCategory> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? nom,
    Expression<int>? ordre,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (nom != null) 'nom': nom,
      if (ordre != null) 'ordre': ordre,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String>? nom,
    Value<int>? ordre,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return ProductCategoriesCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      nom: nom ?? this.nom,
      ordre: ordre ?? this.ordre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (ordre.present) {
      map['ordre'] = Variable<int>(ordre.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('nom: $nom, ')
          ..write('ordre: $ordre, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProduitsTable extends Produits with TableInfo<$ProduitsTable, Produit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProduitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categorieIdMeta = const VerificationMeta(
    'categorieId',
  );
  @override
  late final GeneratedColumn<String> categorieId = GeneratedColumn<String>(
    'categorie_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES product_categories (id)',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prixMeta = const VerificationMeta('prix');
  @override
  late final GeneratedColumn<double> prix = GeneratedColumn<double>(
    'prix',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
    'devise',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    categorieId,
    nom,
    prix,
    devise,
    stock,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Produit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('categorie_id')) {
      context.handle(
        _categorieIdMeta,
        categorieId.isAcceptableOrUnknown(
          data['categorie_id']!,
          _categorieIdMeta,
        ),
      );
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('prix')) {
      context.handle(
        _prixMeta,
        prix.isAcceptableOrUnknown(data['prix']!, _prixMeta),
      );
    } else if (isInserting) {
      context.missing(_prixMeta);
    }
    if (data.containsKey('devise')) {
      context.handle(
        _deviseMeta,
        devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Produit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Produit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      categorieId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categorie_id'],
      ),
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      prix: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prix'],
      )!,
      devise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}devise'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $ProduitsTable createAlias(String alias) {
    return $ProduitsTable(attachedDatabase, alias);
  }
}

class Produit extends DataClass implements Insertable<Produit> {
  final String id;
  final String establishmentId;
  final String? categorieId;
  final String nom;
  final double prix;
  final String devise;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const Produit({
    required this.id,
    required this.establishmentId,
    this.categorieId,
    required this.nom,
    required this.prix,
    required this.devise,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    if (!nullToAbsent || categorieId != null) {
      map['categorie_id'] = Variable<String>(categorieId);
    }
    map['nom'] = Variable<String>(nom);
    map['prix'] = Variable<double>(prix);
    map['devise'] = Variable<String>(devise);
    map['stock'] = Variable<int>(stock);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  ProduitsCompanion toCompanion(bool nullToAbsent) {
    return ProduitsCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      categorieId: categorieId == null && nullToAbsent
          ? const Value.absent()
          : Value(categorieId),
      nom: Value(nom),
      prix: Value(prix),
      devise: Value(devise),
      stock: Value(stock),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory Produit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Produit(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      categorieId: serializer.fromJson<String?>(json['categorieId']),
      nom: serializer.fromJson<String>(json['nom']),
      prix: serializer.fromJson<double>(json['prix']),
      devise: serializer.fromJson<String>(json['devise']),
      stock: serializer.fromJson<int>(json['stock']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'categorieId': serializer.toJson<String?>(categorieId),
      'nom': serializer.toJson<String>(nom),
      'prix': serializer.toJson<double>(prix),
      'devise': serializer.toJson<String>(devise),
      'stock': serializer.toJson<int>(stock),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Produit copyWith({
    String? id,
    String? establishmentId,
    Value<String?> categorieId = const Value.absent(),
    String? nom,
    double? prix,
    String? devise,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => Produit(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    categorieId: categorieId.present ? categorieId.value : this.categorieId,
    nom: nom ?? this.nom,
    prix: prix ?? this.prix,
    devise: devise ?? this.devise,
    stock: stock ?? this.stock,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  Produit copyWithCompanion(ProduitsCompanion data) {
    return Produit(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      categorieId: data.categorieId.present
          ? data.categorieId.value
          : this.categorieId,
      nom: data.nom.present ? data.nom.value : this.nom,
      prix: data.prix.present ? data.prix.value : this.prix,
      devise: data.devise.present ? data.devise.value : this.devise,
      stock: data.stock.present ? data.stock.value : this.stock,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Produit(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('categorieId: $categorieId, ')
          ..write('nom: $nom, ')
          ..write('prix: $prix, ')
          ..write('devise: $devise, ')
          ..write('stock: $stock, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    categorieId,
    nom,
    prix,
    devise,
    stock,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Produit &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.categorieId == this.categorieId &&
          other.nom == this.nom &&
          other.prix == this.prix &&
          other.devise == this.devise &&
          other.stock == this.stock &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class ProduitsCompanion extends UpdateCompanion<Produit> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String?> categorieId;
  final Value<String> nom;
  final Value<double> prix;
  final Value<String> devise;
  final Value<int> stock;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const ProduitsCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.categorieId = const Value.absent(),
    this.nom = const Value.absent(),
    this.prix = const Value.absent(),
    this.devise = const Value.absent(),
    this.stock = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProduitsCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    this.categorieId = const Value.absent(),
    required String nom,
    required double prix,
    this.devise = const Value.absent(),
    this.stock = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nom = Value(nom),
       prix = Value(prix),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Produit> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? categorieId,
    Expression<String>? nom,
    Expression<double>? prix,
    Expression<String>? devise,
    Expression<int>? stock,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (categorieId != null) 'categorie_id': categorieId,
      if (nom != null) 'nom': nom,
      if (prix != null) 'prix': prix,
      if (devise != null) 'devise': devise,
      if (stock != null) 'stock': stock,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProduitsCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String?>? categorieId,
    Value<String>? nom,
    Value<double>? prix,
    Value<String>? devise,
    Value<int>? stock,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return ProduitsCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      categorieId: categorieId ?? this.categorieId,
      nom: nom ?? this.nom,
      prix: prix ?? this.prix,
      devise: devise ?? this.devise,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (categorieId.present) {
      map['categorie_id'] = Variable<String>(categorieId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (prix.present) {
      map['prix'] = Variable<double>(prix.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProduitsCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('categorieId: $categorieId, ')
          ..write('nom: $nom, ')
          ..write('prix: $prix, ')
          ..write('devise: $devise, ')
          ..write('stock: $stock, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrestationsTable extends Prestations
    with TableInfo<$PrestationsTable, Prestation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrestationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _vehiculeIdMeta = const VerificationMeta(
    'vehiculeId',
  );
  @override
  late final GeneratedColumn<String> vehiculeId = GeneratedColumn<String>(
    'vehicule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicules (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PrestationStatut, String> statut =
      GeneratedColumn<String>(
        'statut',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrestationStatut>($PrestationsTable.$converterstatut);
  static const VerificationMeta _dateOuvertureMeta = const VerificationMeta(
    'dateOuverture',
  );
  @override
  late final GeneratedColumn<DateTime> dateOuverture =
      GeneratedColumn<DateTime>(
        'date_ouverture',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dateClotureMeta = const VerificationMeta(
    'dateCloture',
  );
  @override
  late final GeneratedColumn<DateTime> dateCloture = GeneratedColumn<DateTime>(
    'date_cloture',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _montantTotalMeta = const VerificationMeta(
    'montantTotal',
  );
  @override
  late final GeneratedColumn<double> montantTotal = GeneratedColumn<double>(
    'montant_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _montantPointsDeduitMeta =
      const VerificationMeta('montantPointsDeduit');
  @override
  late final GeneratedColumn<double> montantPointsDeduit =
      GeneratedColumn<double>(
        'montant_points_deduit',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _pointsUtilisesMeta = const VerificationMeta(
    'pointsUtilises',
  );
  @override
  late final GeneratedColumn<int> pointsUtilises = GeneratedColumn<int>(
    'points_utilises',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pointsGagnesMeta = const VerificationMeta(
    'pointsGagnes',
  );
  @override
  late final GeneratedColumn<int> pointsGagnes = GeneratedColumn<int>(
    'points_gagnes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kilometrageMeta = const VerificationMeta(
    'kilometrage',
  );
  @override
  late final GeneratedColumn<int> kilometrage = GeneratedColumn<int>(
    'kilometrage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    clientId,
    vehiculeId,
    statut,
    dateOuverture,
    dateCloture,
    montantTotal,
    montantPointsDeduit,
    pointsUtilises,
    pointsGagnes,
    kilometrage,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prestations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prestation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('vehicule_id')) {
      context.handle(
        _vehiculeIdMeta,
        vehiculeId.isAcceptableOrUnknown(data['vehicule_id']!, _vehiculeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehiculeIdMeta);
    }
    if (data.containsKey('date_ouverture')) {
      context.handle(
        _dateOuvertureMeta,
        dateOuverture.isAcceptableOrUnknown(
          data['date_ouverture']!,
          _dateOuvertureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateOuvertureMeta);
    }
    if (data.containsKey('date_cloture')) {
      context.handle(
        _dateClotureMeta,
        dateCloture.isAcceptableOrUnknown(
          data['date_cloture']!,
          _dateClotureMeta,
        ),
      );
    }
    if (data.containsKey('montant_total')) {
      context.handle(
        _montantTotalMeta,
        montantTotal.isAcceptableOrUnknown(
          data['montant_total']!,
          _montantTotalMeta,
        ),
      );
    }
    if (data.containsKey('montant_points_deduit')) {
      context.handle(
        _montantPointsDeduitMeta,
        montantPointsDeduit.isAcceptableOrUnknown(
          data['montant_points_deduit']!,
          _montantPointsDeduitMeta,
        ),
      );
    }
    if (data.containsKey('points_utilises')) {
      context.handle(
        _pointsUtilisesMeta,
        pointsUtilises.isAcceptableOrUnknown(
          data['points_utilises']!,
          _pointsUtilisesMeta,
        ),
      );
    }
    if (data.containsKey('points_gagnes')) {
      context.handle(
        _pointsGagnesMeta,
        pointsGagnes.isAcceptableOrUnknown(
          data['points_gagnes']!,
          _pointsGagnesMeta,
        ),
      );
    }
    if (data.containsKey('kilometrage')) {
      context.handle(
        _kilometrageMeta,
        kilometrage.isAcceptableOrUnknown(
          data['kilometrage']!,
          _kilometrageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Prestation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prestation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      vehiculeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicule_id'],
      )!,
      statut: $PrestationsTable.$converterstatut.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}statut'],
        )!,
      ),
      dateOuverture: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_ouverture'],
      )!,
      dateCloture: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_cloture'],
      ),
      montantTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_total'],
      )!,
      montantPointsDeduit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_points_deduit'],
      )!,
      pointsUtilises: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_utilises'],
      )!,
      pointsGagnes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_gagnes'],
      )!,
      kilometrage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kilometrage'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $PrestationsTable createAlias(String alias) {
    return $PrestationsTable(attachedDatabase, alias);
  }

  static TypeConverter<PrestationStatut, String> $converterstatut =
      const PrestationStatutConverter();
}

class Prestation extends DataClass implements Insertable<Prestation> {
  final String id;
  final String establishmentId;
  final String? clientId;
  final String vehiculeId;
  final PrestationStatut statut;
  final DateTime dateOuverture;
  final DateTime? dateCloture;
  final double montantTotal;
  final double montantPointsDeduit;
  final int pointsUtilises;
  final int pointsGagnes;
  final int? kilometrage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const Prestation({
    required this.id,
    required this.establishmentId,
    this.clientId,
    required this.vehiculeId,
    required this.statut,
    required this.dateOuverture,
    this.dateCloture,
    required this.montantTotal,
    required this.montantPointsDeduit,
    required this.pointsUtilises,
    required this.pointsGagnes,
    this.kilometrage,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['vehicule_id'] = Variable<String>(vehiculeId);
    {
      map['statut'] = Variable<String>(
        $PrestationsTable.$converterstatut.toSql(statut),
      );
    }
    map['date_ouverture'] = Variable<DateTime>(dateOuverture);
    if (!nullToAbsent || dateCloture != null) {
      map['date_cloture'] = Variable<DateTime>(dateCloture);
    }
    map['montant_total'] = Variable<double>(montantTotal);
    map['montant_points_deduit'] = Variable<double>(montantPointsDeduit);
    map['points_utilises'] = Variable<int>(pointsUtilises);
    map['points_gagnes'] = Variable<int>(pointsGagnes);
    if (!nullToAbsent || kilometrage != null) {
      map['kilometrage'] = Variable<int>(kilometrage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  PrestationsCompanion toCompanion(bool nullToAbsent) {
    return PrestationsCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      vehiculeId: Value(vehiculeId),
      statut: Value(statut),
      dateOuverture: Value(dateOuverture),
      dateCloture: dateCloture == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCloture),
      montantTotal: Value(montantTotal),
      montantPointsDeduit: Value(montantPointsDeduit),
      pointsUtilises: Value(pointsUtilises),
      pointsGagnes: Value(pointsGagnes),
      kilometrage: kilometrage == null && nullToAbsent
          ? const Value.absent()
          : Value(kilometrage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory Prestation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prestation(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      vehiculeId: serializer.fromJson<String>(json['vehiculeId']),
      statut: serializer.fromJson<PrestationStatut>(json['statut']),
      dateOuverture: serializer.fromJson<DateTime>(json['dateOuverture']),
      dateCloture: serializer.fromJson<DateTime?>(json['dateCloture']),
      montantTotal: serializer.fromJson<double>(json['montantTotal']),
      montantPointsDeduit: serializer.fromJson<double>(
        json['montantPointsDeduit'],
      ),
      pointsUtilises: serializer.fromJson<int>(json['pointsUtilises']),
      pointsGagnes: serializer.fromJson<int>(json['pointsGagnes']),
      kilometrage: serializer.fromJson<int?>(json['kilometrage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'clientId': serializer.toJson<String?>(clientId),
      'vehiculeId': serializer.toJson<String>(vehiculeId),
      'statut': serializer.toJson<PrestationStatut>(statut),
      'dateOuverture': serializer.toJson<DateTime>(dateOuverture),
      'dateCloture': serializer.toJson<DateTime?>(dateCloture),
      'montantTotal': serializer.toJson<double>(montantTotal),
      'montantPointsDeduit': serializer.toJson<double>(montantPointsDeduit),
      'pointsUtilises': serializer.toJson<int>(pointsUtilises),
      'pointsGagnes': serializer.toJson<int>(pointsGagnes),
      'kilometrage': serializer.toJson<int?>(kilometrage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Prestation copyWith({
    String? id,
    String? establishmentId,
    Value<String?> clientId = const Value.absent(),
    String? vehiculeId,
    PrestationStatut? statut,
    DateTime? dateOuverture,
    Value<DateTime?> dateCloture = const Value.absent(),
    double? montantTotal,
    double? montantPointsDeduit,
    int? pointsUtilises,
    int? pointsGagnes,
    Value<int?> kilometrage = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => Prestation(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    clientId: clientId.present ? clientId.value : this.clientId,
    vehiculeId: vehiculeId ?? this.vehiculeId,
    statut: statut ?? this.statut,
    dateOuverture: dateOuverture ?? this.dateOuverture,
    dateCloture: dateCloture.present ? dateCloture.value : this.dateCloture,
    montantTotal: montantTotal ?? this.montantTotal,
    montantPointsDeduit: montantPointsDeduit ?? this.montantPointsDeduit,
    pointsUtilises: pointsUtilises ?? this.pointsUtilises,
    pointsGagnes: pointsGagnes ?? this.pointsGagnes,
    kilometrage: kilometrage.present ? kilometrage.value : this.kilometrage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  Prestation copyWithCompanion(PrestationsCompanion data) {
    return Prestation(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      vehiculeId: data.vehiculeId.present
          ? data.vehiculeId.value
          : this.vehiculeId,
      statut: data.statut.present ? data.statut.value : this.statut,
      dateOuverture: data.dateOuverture.present
          ? data.dateOuverture.value
          : this.dateOuverture,
      dateCloture: data.dateCloture.present
          ? data.dateCloture.value
          : this.dateCloture,
      montantTotal: data.montantTotal.present
          ? data.montantTotal.value
          : this.montantTotal,
      montantPointsDeduit: data.montantPointsDeduit.present
          ? data.montantPointsDeduit.value
          : this.montantPointsDeduit,
      pointsUtilises: data.pointsUtilises.present
          ? data.pointsUtilises.value
          : this.pointsUtilises,
      pointsGagnes: data.pointsGagnes.present
          ? data.pointsGagnes.value
          : this.pointsGagnes,
      kilometrage: data.kilometrage.present
          ? data.kilometrage.value
          : this.kilometrage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prestation(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('clientId: $clientId, ')
          ..write('vehiculeId: $vehiculeId, ')
          ..write('statut: $statut, ')
          ..write('dateOuverture: $dateOuverture, ')
          ..write('dateCloture: $dateCloture, ')
          ..write('montantTotal: $montantTotal, ')
          ..write('montantPointsDeduit: $montantPointsDeduit, ')
          ..write('pointsUtilises: $pointsUtilises, ')
          ..write('pointsGagnes: $pointsGagnes, ')
          ..write('kilometrage: $kilometrage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    clientId,
    vehiculeId,
    statut,
    dateOuverture,
    dateCloture,
    montantTotal,
    montantPointsDeduit,
    pointsUtilises,
    pointsGagnes,
    kilometrage,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prestation &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.clientId == this.clientId &&
          other.vehiculeId == this.vehiculeId &&
          other.statut == this.statut &&
          other.dateOuverture == this.dateOuverture &&
          other.dateCloture == this.dateCloture &&
          other.montantTotal == this.montantTotal &&
          other.montantPointsDeduit == this.montantPointsDeduit &&
          other.pointsUtilises == this.pointsUtilises &&
          other.pointsGagnes == this.pointsGagnes &&
          other.kilometrage == this.kilometrage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class PrestationsCompanion extends UpdateCompanion<Prestation> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String?> clientId;
  final Value<String> vehiculeId;
  final Value<PrestationStatut> statut;
  final Value<DateTime> dateOuverture;
  final Value<DateTime?> dateCloture;
  final Value<double> montantTotal;
  final Value<double> montantPointsDeduit;
  final Value<int> pointsUtilises;
  final Value<int> pointsGagnes;
  final Value<int?> kilometrage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const PrestationsCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.vehiculeId = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateOuverture = const Value.absent(),
    this.dateCloture = const Value.absent(),
    this.montantTotal = const Value.absent(),
    this.montantPointsDeduit = const Value.absent(),
    this.pointsUtilises = const Value.absent(),
    this.pointsGagnes = const Value.absent(),
    this.kilometrage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrestationsCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String vehiculeId,
    required PrestationStatut statut,
    required DateTime dateOuverture,
    this.dateCloture = const Value.absent(),
    this.montantTotal = const Value.absent(),
    this.montantPointsDeduit = const Value.absent(),
    this.pointsUtilises = const Value.absent(),
    this.pointsGagnes = const Value.absent(),
    this.kilometrage = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehiculeId = Value(vehiculeId),
       statut = Value(statut),
       dateOuverture = Value(dateOuverture),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Prestation> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? clientId,
    Expression<String>? vehiculeId,
    Expression<String>? statut,
    Expression<DateTime>? dateOuverture,
    Expression<DateTime>? dateCloture,
    Expression<double>? montantTotal,
    Expression<double>? montantPointsDeduit,
    Expression<int>? pointsUtilises,
    Expression<int>? pointsGagnes,
    Expression<int>? kilometrage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (clientId != null) 'client_id': clientId,
      if (vehiculeId != null) 'vehicule_id': vehiculeId,
      if (statut != null) 'statut': statut,
      if (dateOuverture != null) 'date_ouverture': dateOuverture,
      if (dateCloture != null) 'date_cloture': dateCloture,
      if (montantTotal != null) 'montant_total': montantTotal,
      if (montantPointsDeduit != null)
        'montant_points_deduit': montantPointsDeduit,
      if (pointsUtilises != null) 'points_utilises': pointsUtilises,
      if (pointsGagnes != null) 'points_gagnes': pointsGagnes,
      if (kilometrage != null) 'kilometrage': kilometrage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrestationsCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String?>? clientId,
    Value<String>? vehiculeId,
    Value<PrestationStatut>? statut,
    Value<DateTime>? dateOuverture,
    Value<DateTime?>? dateCloture,
    Value<double>? montantTotal,
    Value<double>? montantPointsDeduit,
    Value<int>? pointsUtilises,
    Value<int>? pointsGagnes,
    Value<int?>? kilometrage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return PrestationsCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      clientId: clientId ?? this.clientId,
      vehiculeId: vehiculeId ?? this.vehiculeId,
      statut: statut ?? this.statut,
      dateOuverture: dateOuverture ?? this.dateOuverture,
      dateCloture: dateCloture ?? this.dateCloture,
      montantTotal: montantTotal ?? this.montantTotal,
      montantPointsDeduit: montantPointsDeduit ?? this.montantPointsDeduit,
      pointsUtilises: pointsUtilises ?? this.pointsUtilises,
      pointsGagnes: pointsGagnes ?? this.pointsGagnes,
      kilometrage: kilometrage ?? this.kilometrage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (vehiculeId.present) {
      map['vehicule_id'] = Variable<String>(vehiculeId.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(
        $PrestationsTable.$converterstatut.toSql(statut.value),
      );
    }
    if (dateOuverture.present) {
      map['date_ouverture'] = Variable<DateTime>(dateOuverture.value);
    }
    if (dateCloture.present) {
      map['date_cloture'] = Variable<DateTime>(dateCloture.value);
    }
    if (montantTotal.present) {
      map['montant_total'] = Variable<double>(montantTotal.value);
    }
    if (montantPointsDeduit.present) {
      map['montant_points_deduit'] = Variable<double>(
        montantPointsDeduit.value,
      );
    }
    if (pointsUtilises.present) {
      map['points_utilises'] = Variable<int>(pointsUtilises.value);
    }
    if (pointsGagnes.present) {
      map['points_gagnes'] = Variable<int>(pointsGagnes.value);
    }
    if (kilometrage.present) {
      map['kilometrage'] = Variable<int>(kilometrage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrestationsCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('clientId: $clientId, ')
          ..write('vehiculeId: $vehiculeId, ')
          ..write('statut: $statut, ')
          ..write('dateOuverture: $dateOuverture, ')
          ..write('dateCloture: $dateCloture, ')
          ..write('montantTotal: $montantTotal, ')
          ..write('montantPointsDeduit: $montantPointsDeduit, ')
          ..write('pointsUtilises: $pointsUtilises, ')
          ..write('pointsGagnes: $pointsGagnes, ')
          ..write('kilometrage: $kilometrage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LignePrestationsTable extends LignePrestations
    with TableInfo<$LignePrestationsTable, LignePrestation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LignePrestationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _prestationIdMeta = const VerificationMeta(
    'prestationId',
  );
  @override
  late final GeneratedColumn<String> prestationId = GeneratedColumn<String>(
    'prestation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES prestations (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LigneType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LigneType>($LignePrestationsTable.$convertertype);
  static const VerificationMeta _serviceIdMeta = const VerificationMeta(
    'serviceId',
  );
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
    'service_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_services (id)',
    ),
  );
  static const VerificationMeta _produitIdMeta = const VerificationMeta(
    'produitId',
  );
  @override
  late final GeneratedColumn<String> produitId = GeneratedColumn<String>(
    'produit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produits (id)',
    ),
  );
  static const VerificationMeta _libelleMeta = const VerificationMeta(
    'libelle',
  );
  @override
  late final GeneratedColumn<String> libelle = GeneratedColumn<String>(
    'libelle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantiteMeta = const VerificationMeta(
    'quantite',
  );
  @override
  late final GeneratedColumn<int> quantite = GeneratedColumn<int>(
    'quantite',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _prixUnitaireMeta = const VerificationMeta(
    'prixUnitaire',
  );
  @override
  late final GeneratedColumn<double> prixUnitaire = GeneratedColumn<double>(
    'prix_unitaire',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montantLigneMeta = const VerificationMeta(
    'montantLigne',
  );
  @override
  late final GeneratedColumn<double> montantLigne = GeneratedColumn<double>(
    'montant_ligne',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    prestationId,
    type,
    serviceId,
    produitId,
    libelle,
    quantite,
    prixUnitaire,
    montantLigne,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ligne_prestations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LignePrestation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('prestation_id')) {
      context.handle(
        _prestationIdMeta,
        prestationId.isAcceptableOrUnknown(
          data['prestation_id']!,
          _prestationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prestationIdMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(
        _serviceIdMeta,
        serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta),
      );
    }
    if (data.containsKey('produit_id')) {
      context.handle(
        _produitIdMeta,
        produitId.isAcceptableOrUnknown(data['produit_id']!, _produitIdMeta),
      );
    }
    if (data.containsKey('libelle')) {
      context.handle(
        _libelleMeta,
        libelle.isAcceptableOrUnknown(data['libelle']!, _libelleMeta),
      );
    } else if (isInserting) {
      context.missing(_libelleMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(
        _quantiteMeta,
        quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta),
      );
    }
    if (data.containsKey('prix_unitaire')) {
      context.handle(
        _prixUnitaireMeta,
        prixUnitaire.isAcceptableOrUnknown(
          data['prix_unitaire']!,
          _prixUnitaireMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prixUnitaireMeta);
    }
    if (data.containsKey('montant_ligne')) {
      context.handle(
        _montantLigneMeta,
        montantLigne.isAcceptableOrUnknown(
          data['montant_ligne']!,
          _montantLigneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montantLigneMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LignePrestation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LignePrestation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      prestationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prestation_id'],
      )!,
      type: $LignePrestationsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      serviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_id'],
      ),
      produitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}produit_id'],
      ),
      libelle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}libelle'],
      )!,
      quantite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantite'],
      )!,
      prixUnitaire: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prix_unitaire'],
      )!,
      montantLigne: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_ligne'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $LignePrestationsTable createAlias(String alias) {
    return $LignePrestationsTable(attachedDatabase, alias);
  }

  static TypeConverter<LigneType, String> $convertertype =
      const LigneTypeConverter();
}

class LignePrestation extends DataClass implements Insertable<LignePrestation> {
  final String id;
  final String establishmentId;
  final String prestationId;
  final LigneType type;
  final String? serviceId;
  final String? produitId;
  final String libelle;
  final int quantite;
  final double prixUnitaire;
  final double montantLigne;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const LignePrestation({
    required this.id,
    required this.establishmentId,
    required this.prestationId,
    required this.type,
    this.serviceId,
    this.produitId,
    required this.libelle,
    required this.quantite,
    required this.prixUnitaire,
    required this.montantLigne,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    map['prestation_id'] = Variable<String>(prestationId);
    {
      map['type'] = Variable<String>(
        $LignePrestationsTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || serviceId != null) {
      map['service_id'] = Variable<String>(serviceId);
    }
    if (!nullToAbsent || produitId != null) {
      map['produit_id'] = Variable<String>(produitId);
    }
    map['libelle'] = Variable<String>(libelle);
    map['quantite'] = Variable<int>(quantite);
    map['prix_unitaire'] = Variable<double>(prixUnitaire);
    map['montant_ligne'] = Variable<double>(montantLigne);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  LignePrestationsCompanion toCompanion(bool nullToAbsent) {
    return LignePrestationsCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      prestationId: Value(prestationId),
      type: Value(type),
      serviceId: serviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceId),
      produitId: produitId == null && nullToAbsent
          ? const Value.absent()
          : Value(produitId),
      libelle: Value(libelle),
      quantite: Value(quantite),
      prixUnitaire: Value(prixUnitaire),
      montantLigne: Value(montantLigne),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory LignePrestation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LignePrestation(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      prestationId: serializer.fromJson<String>(json['prestationId']),
      type: serializer.fromJson<LigneType>(json['type']),
      serviceId: serializer.fromJson<String?>(json['serviceId']),
      produitId: serializer.fromJson<String?>(json['produitId']),
      libelle: serializer.fromJson<String>(json['libelle']),
      quantite: serializer.fromJson<int>(json['quantite']),
      prixUnitaire: serializer.fromJson<double>(json['prixUnitaire']),
      montantLigne: serializer.fromJson<double>(json['montantLigne']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'prestationId': serializer.toJson<String>(prestationId),
      'type': serializer.toJson<LigneType>(type),
      'serviceId': serializer.toJson<String?>(serviceId),
      'produitId': serializer.toJson<String?>(produitId),
      'libelle': serializer.toJson<String>(libelle),
      'quantite': serializer.toJson<int>(quantite),
      'prixUnitaire': serializer.toJson<double>(prixUnitaire),
      'montantLigne': serializer.toJson<double>(montantLigne),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  LignePrestation copyWith({
    String? id,
    String? establishmentId,
    String? prestationId,
    LigneType? type,
    Value<String?> serviceId = const Value.absent(),
    Value<String?> produitId = const Value.absent(),
    String? libelle,
    int? quantite,
    double? prixUnitaire,
    double? montantLigne,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => LignePrestation(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    prestationId: prestationId ?? this.prestationId,
    type: type ?? this.type,
    serviceId: serviceId.present ? serviceId.value : this.serviceId,
    produitId: produitId.present ? produitId.value : this.produitId,
    libelle: libelle ?? this.libelle,
    quantite: quantite ?? this.quantite,
    prixUnitaire: prixUnitaire ?? this.prixUnitaire,
    montantLigne: montantLigne ?? this.montantLigne,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  LignePrestation copyWithCompanion(LignePrestationsCompanion data) {
    return LignePrestation(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      prestationId: data.prestationId.present
          ? data.prestationId.value
          : this.prestationId,
      type: data.type.present ? data.type.value : this.type,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      produitId: data.produitId.present ? data.produitId.value : this.produitId,
      libelle: data.libelle.present ? data.libelle.value : this.libelle,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      prixUnitaire: data.prixUnitaire.present
          ? data.prixUnitaire.value
          : this.prixUnitaire,
      montantLigne: data.montantLigne.present
          ? data.montantLigne.value
          : this.montantLigne,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LignePrestation(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('prestationId: $prestationId, ')
          ..write('type: $type, ')
          ..write('serviceId: $serviceId, ')
          ..write('produitId: $produitId, ')
          ..write('libelle: $libelle, ')
          ..write('quantite: $quantite, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('montantLigne: $montantLigne, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    prestationId,
    type,
    serviceId,
    produitId,
    libelle,
    quantite,
    prixUnitaire,
    montantLigne,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LignePrestation &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.prestationId == this.prestationId &&
          other.type == this.type &&
          other.serviceId == this.serviceId &&
          other.produitId == this.produitId &&
          other.libelle == this.libelle &&
          other.quantite == this.quantite &&
          other.prixUnitaire == this.prixUnitaire &&
          other.montantLigne == this.montantLigne &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class LignePrestationsCompanion extends UpdateCompanion<LignePrestation> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String> prestationId;
  final Value<LigneType> type;
  final Value<String?> serviceId;
  final Value<String?> produitId;
  final Value<String> libelle;
  final Value<int> quantite;
  final Value<double> prixUnitaire;
  final Value<double> montantLigne;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const LignePrestationsCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.prestationId = const Value.absent(),
    this.type = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.produitId = const Value.absent(),
    this.libelle = const Value.absent(),
    this.quantite = const Value.absent(),
    this.prixUnitaire = const Value.absent(),
    this.montantLigne = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LignePrestationsCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    required String prestationId,
    required LigneType type,
    this.serviceId = const Value.absent(),
    this.produitId = const Value.absent(),
    required String libelle,
    this.quantite = const Value.absent(),
    required double prixUnitaire,
    required double montantLigne,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       prestationId = Value(prestationId),
       type = Value(type),
       libelle = Value(libelle),
       prixUnitaire = Value(prixUnitaire),
       montantLigne = Value(montantLigne),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LignePrestation> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? prestationId,
    Expression<String>? type,
    Expression<String>? serviceId,
    Expression<String>? produitId,
    Expression<String>? libelle,
    Expression<int>? quantite,
    Expression<double>? prixUnitaire,
    Expression<double>? montantLigne,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (prestationId != null) 'prestation_id': prestationId,
      if (type != null) 'type': type,
      if (serviceId != null) 'service_id': serviceId,
      if (produitId != null) 'produit_id': produitId,
      if (libelle != null) 'libelle': libelle,
      if (quantite != null) 'quantite': quantite,
      if (prixUnitaire != null) 'prix_unitaire': prixUnitaire,
      if (montantLigne != null) 'montant_ligne': montantLigne,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LignePrestationsCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String>? prestationId,
    Value<LigneType>? type,
    Value<String?>? serviceId,
    Value<String?>? produitId,
    Value<String>? libelle,
    Value<int>? quantite,
    Value<double>? prixUnitaire,
    Value<double>? montantLigne,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return LignePrestationsCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      prestationId: prestationId ?? this.prestationId,
      type: type ?? this.type,
      serviceId: serviceId ?? this.serviceId,
      produitId: produitId ?? this.produitId,
      libelle: libelle ?? this.libelle,
      quantite: quantite ?? this.quantite,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      montantLigne: montantLigne ?? this.montantLigne,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (prestationId.present) {
      map['prestation_id'] = Variable<String>(prestationId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $LignePrestationsTable.$convertertype.toSql(type.value),
      );
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (produitId.present) {
      map['produit_id'] = Variable<String>(produitId.value);
    }
    if (libelle.present) {
      map['libelle'] = Variable<String>(libelle.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<int>(quantite.value);
    }
    if (prixUnitaire.present) {
      map['prix_unitaire'] = Variable<double>(prixUnitaire.value);
    }
    if (montantLigne.present) {
      map['montant_ligne'] = Variable<double>(montantLigne.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LignePrestationsCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('prestationId: $prestationId, ')
          ..write('type: $type, ')
          ..write('serviceId: $serviceId, ')
          ..write('produitId: $produitId, ')
          ..write('libelle: $libelle, ')
          ..write('quantite: $quantite, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('montantLigne: $montantLigne, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JetonsTable extends Jetons with TableInfo<$JetonsTable, Jeton> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JetonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _prestationIdMeta = const VerificationMeta(
    'prestationId',
  );
  @override
  late final GeneratedColumn<String> prestationId = GeneratedColumn<String>(
    'prestation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES prestations (id)',
    ),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<JetonStatut, String> statut =
      GeneratedColumn<String>(
        'statut',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<JetonStatut>($JetonsTable.$converterstatut);
  static const VerificationMeta _dateEmissionMeta = const VerificationMeta(
    'dateEmission',
  );
  @override
  late final GeneratedColumn<DateTime> dateEmission = GeneratedColumn<DateTime>(
    'date_emission',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateConsommationMeta = const VerificationMeta(
    'dateConsommation',
  );
  @override
  late final GeneratedColumn<DateTime> dateConsommation =
      GeneratedColumn<DateTime>(
        'date_consommation',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    prestationId,
    clientId,
    statut,
    dateEmission,
    dateConsommation,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jetons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Jeton> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('prestation_id')) {
      context.handle(
        _prestationIdMeta,
        prestationId.isAcceptableOrUnknown(
          data['prestation_id']!,
          _prestationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prestationIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('date_emission')) {
      context.handle(
        _dateEmissionMeta,
        dateEmission.isAcceptableOrUnknown(
          data['date_emission']!,
          _dateEmissionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateEmissionMeta);
    }
    if (data.containsKey('date_consommation')) {
      context.handle(
        _dateConsommationMeta,
        dateConsommation.isAcceptableOrUnknown(
          data['date_consommation']!,
          _dateConsommationMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Jeton map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Jeton(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      prestationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prestation_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      statut: $JetonsTable.$converterstatut.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}statut'],
        )!,
      ),
      dateEmission: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_emission'],
      )!,
      dateConsommation: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_consommation'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $JetonsTable createAlias(String alias) {
    return $JetonsTable(attachedDatabase, alias);
  }

  static TypeConverter<JetonStatut, String> $converterstatut =
      const JetonStatutConverter();
}

class Jeton extends DataClass implements Insertable<Jeton> {
  final String id;
  final String establishmentId;
  final String prestationId;
  final String clientId;
  final JetonStatut statut;
  final DateTime dateEmission;
  final DateTime? dateConsommation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const Jeton({
    required this.id,
    required this.establishmentId,
    required this.prestationId,
    required this.clientId,
    required this.statut,
    required this.dateEmission,
    this.dateConsommation,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    map['prestation_id'] = Variable<String>(prestationId);
    map['client_id'] = Variable<String>(clientId);
    {
      map['statut'] = Variable<String>(
        $JetonsTable.$converterstatut.toSql(statut),
      );
    }
    map['date_emission'] = Variable<DateTime>(dateEmission);
    if (!nullToAbsent || dateConsommation != null) {
      map['date_consommation'] = Variable<DateTime>(dateConsommation);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  JetonsCompanion toCompanion(bool nullToAbsent) {
    return JetonsCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      prestationId: Value(prestationId),
      clientId: Value(clientId),
      statut: Value(statut),
      dateEmission: Value(dateEmission),
      dateConsommation: dateConsommation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateConsommation),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory Jeton.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Jeton(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      prestationId: serializer.fromJson<String>(json['prestationId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      statut: serializer.fromJson<JetonStatut>(json['statut']),
      dateEmission: serializer.fromJson<DateTime>(json['dateEmission']),
      dateConsommation: serializer.fromJson<DateTime?>(
        json['dateConsommation'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'prestationId': serializer.toJson<String>(prestationId),
      'clientId': serializer.toJson<String>(clientId),
      'statut': serializer.toJson<JetonStatut>(statut),
      'dateEmission': serializer.toJson<DateTime>(dateEmission),
      'dateConsommation': serializer.toJson<DateTime?>(dateConsommation),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Jeton copyWith({
    String? id,
    String? establishmentId,
    String? prestationId,
    String? clientId,
    JetonStatut? statut,
    DateTime? dateEmission,
    Value<DateTime?> dateConsommation = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => Jeton(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    prestationId: prestationId ?? this.prestationId,
    clientId: clientId ?? this.clientId,
    statut: statut ?? this.statut,
    dateEmission: dateEmission ?? this.dateEmission,
    dateConsommation: dateConsommation.present
        ? dateConsommation.value
        : this.dateConsommation,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  Jeton copyWithCompanion(JetonsCompanion data) {
    return Jeton(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      prestationId: data.prestationId.present
          ? data.prestationId.value
          : this.prestationId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      statut: data.statut.present ? data.statut.value : this.statut,
      dateEmission: data.dateEmission.present
          ? data.dateEmission.value
          : this.dateEmission,
      dateConsommation: data.dateConsommation.present
          ? data.dateConsommation.value
          : this.dateConsommation,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Jeton(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('prestationId: $prestationId, ')
          ..write('clientId: $clientId, ')
          ..write('statut: $statut, ')
          ..write('dateEmission: $dateEmission, ')
          ..write('dateConsommation: $dateConsommation, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    prestationId,
    clientId,
    statut,
    dateEmission,
    dateConsommation,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Jeton &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.prestationId == this.prestationId &&
          other.clientId == this.clientId &&
          other.statut == this.statut &&
          other.dateEmission == this.dateEmission &&
          other.dateConsommation == this.dateConsommation &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class JetonsCompanion extends UpdateCompanion<Jeton> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String> prestationId;
  final Value<String> clientId;
  final Value<JetonStatut> statut;
  final Value<DateTime> dateEmission;
  final Value<DateTime?> dateConsommation;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const JetonsCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.prestationId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateEmission = const Value.absent(),
    this.dateConsommation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JetonsCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    required String prestationId,
    required String clientId,
    required JetonStatut statut,
    required DateTime dateEmission,
    this.dateConsommation = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       prestationId = Value(prestationId),
       clientId = Value(clientId),
       statut = Value(statut),
       dateEmission = Value(dateEmission),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Jeton> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? prestationId,
    Expression<String>? clientId,
    Expression<String>? statut,
    Expression<DateTime>? dateEmission,
    Expression<DateTime>? dateConsommation,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (prestationId != null) 'prestation_id': prestationId,
      if (clientId != null) 'client_id': clientId,
      if (statut != null) 'statut': statut,
      if (dateEmission != null) 'date_emission': dateEmission,
      if (dateConsommation != null) 'date_consommation': dateConsommation,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JetonsCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String>? prestationId,
    Value<String>? clientId,
    Value<JetonStatut>? statut,
    Value<DateTime>? dateEmission,
    Value<DateTime?>? dateConsommation,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return JetonsCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      prestationId: prestationId ?? this.prestationId,
      clientId: clientId ?? this.clientId,
      statut: statut ?? this.statut,
      dateEmission: dateEmission ?? this.dateEmission,
      dateConsommation: dateConsommation ?? this.dateConsommation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (prestationId.present) {
      map['prestation_id'] = Variable<String>(prestationId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(
        $JetonsTable.$converterstatut.toSql(statut.value),
      );
    }
    if (dateEmission.present) {
      map['date_emission'] = Variable<DateTime>(dateEmission.value);
    }
    if (dateConsommation.present) {
      map['date_consommation'] = Variable<DateTime>(dateConsommation.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JetonsCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('prestationId: $prestationId, ')
          ..write('clientId: $clientId, ')
          ..write('statut: $statut, ')
          ..write('dateEmission: $dateEmission, ')
          ..write('dateConsommation: $dateConsommation, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertesEntretienTable extends AlertesEntretien
    with TableInfo<$AlertesEntretienTable, AlertesEntretienData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertesEntretienTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _vehiculeIdMeta = const VerificationMeta(
    'vehiculeId',
  );
  @override
  late final GeneratedColumn<String> vehiculeId = GeneratedColumn<String>(
    'vehicule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicules (id)',
    ),
  );
  static const VerificationMeta _serviceIdMeta = const VerificationMeta(
    'serviceId',
  );
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
    'service_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_services (id)',
    ),
  );
  static const VerificationMeta _dateEcheanceMeta = const VerificationMeta(
    'dateEcheance',
  );
  @override
  late final GeneratedColumn<DateTime> dateEcheance = GeneratedColumn<DateTime>(
    'date_echeance',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AlerteStatut, String> statut =
      GeneratedColumn<String>(
        'statut',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AlerteStatut>($AlertesEntretienTable.$converterstatut);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    vehiculeId,
    serviceId,
    dateEcheance,
    statut,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alertes_entretien';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertesEntretienData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('vehicule_id')) {
      context.handle(
        _vehiculeIdMeta,
        vehiculeId.isAcceptableOrUnknown(data['vehicule_id']!, _vehiculeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehiculeIdMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(
        _serviceIdMeta,
        serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('date_echeance')) {
      context.handle(
        _dateEcheanceMeta,
        dateEcheance.isAcceptableOrUnknown(
          data['date_echeance']!,
          _dateEcheanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateEcheanceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertesEntretienData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertesEntretienData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      vehiculeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicule_id'],
      )!,
      serviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_id'],
      )!,
      dateEcheance: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_echeance'],
      )!,
      statut: $AlertesEntretienTable.$converterstatut.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}statut'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $AlertesEntretienTable createAlias(String alias) {
    return $AlertesEntretienTable(attachedDatabase, alias);
  }

  static TypeConverter<AlerteStatut, String> $converterstatut =
      const AlerteStatutConverter();
}

class AlertesEntretienData extends DataClass
    implements Insertable<AlertesEntretienData> {
  final String id;
  final String establishmentId;
  final String vehiculeId;
  final String serviceId;
  final DateTime dateEcheance;
  final AlerteStatut statut;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const AlertesEntretienData({
    required this.id,
    required this.establishmentId,
    required this.vehiculeId,
    required this.serviceId,
    required this.dateEcheance,
    required this.statut,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    map['vehicule_id'] = Variable<String>(vehiculeId);
    map['service_id'] = Variable<String>(serviceId);
    map['date_echeance'] = Variable<DateTime>(dateEcheance);
    {
      map['statut'] = Variable<String>(
        $AlertesEntretienTable.$converterstatut.toSql(statut),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  AlertesEntretienCompanion toCompanion(bool nullToAbsent) {
    return AlertesEntretienCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      vehiculeId: Value(vehiculeId),
      serviceId: Value(serviceId),
      dateEcheance: Value(dateEcheance),
      statut: Value(statut),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory AlertesEntretienData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertesEntretienData(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      vehiculeId: serializer.fromJson<String>(json['vehiculeId']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      dateEcheance: serializer.fromJson<DateTime>(json['dateEcheance']),
      statut: serializer.fromJson<AlerteStatut>(json['statut']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'vehiculeId': serializer.toJson<String>(vehiculeId),
      'serviceId': serializer.toJson<String>(serviceId),
      'dateEcheance': serializer.toJson<DateTime>(dateEcheance),
      'statut': serializer.toJson<AlerteStatut>(statut),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  AlertesEntretienData copyWith({
    String? id,
    String? establishmentId,
    String? vehiculeId,
    String? serviceId,
    DateTime? dateEcheance,
    AlerteStatut? statut,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => AlertesEntretienData(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    vehiculeId: vehiculeId ?? this.vehiculeId,
    serviceId: serviceId ?? this.serviceId,
    dateEcheance: dateEcheance ?? this.dateEcheance,
    statut: statut ?? this.statut,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  AlertesEntretienData copyWithCompanion(AlertesEntretienCompanion data) {
    return AlertesEntretienData(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      vehiculeId: data.vehiculeId.present
          ? data.vehiculeId.value
          : this.vehiculeId,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      dateEcheance: data.dateEcheance.present
          ? data.dateEcheance.value
          : this.dateEcheance,
      statut: data.statut.present ? data.statut.value : this.statut,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertesEntretienData(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('vehiculeId: $vehiculeId, ')
          ..write('serviceId: $serviceId, ')
          ..write('dateEcheance: $dateEcheance, ')
          ..write('statut: $statut, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    vehiculeId,
    serviceId,
    dateEcheance,
    statut,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertesEntretienData &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.vehiculeId == this.vehiculeId &&
          other.serviceId == this.serviceId &&
          other.dateEcheance == this.dateEcheance &&
          other.statut == this.statut &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class AlertesEntretienCompanion extends UpdateCompanion<AlertesEntretienData> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String> vehiculeId;
  final Value<String> serviceId;
  final Value<DateTime> dateEcheance;
  final Value<AlerteStatut> statut;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const AlertesEntretienCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.vehiculeId = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.dateEcheance = const Value.absent(),
    this.statut = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertesEntretienCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    required String vehiculeId,
    required String serviceId,
    required DateTime dateEcheance,
    required AlerteStatut statut,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehiculeId = Value(vehiculeId),
       serviceId = Value(serviceId),
       dateEcheance = Value(dateEcheance),
       statut = Value(statut),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AlertesEntretienData> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? vehiculeId,
    Expression<String>? serviceId,
    Expression<DateTime>? dateEcheance,
    Expression<String>? statut,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (vehiculeId != null) 'vehicule_id': vehiculeId,
      if (serviceId != null) 'service_id': serviceId,
      if (dateEcheance != null) 'date_echeance': dateEcheance,
      if (statut != null) 'statut': statut,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertesEntretienCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String>? vehiculeId,
    Value<String>? serviceId,
    Value<DateTime>? dateEcheance,
    Value<AlerteStatut>? statut,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return AlertesEntretienCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      vehiculeId: vehiculeId ?? this.vehiculeId,
      serviceId: serviceId ?? this.serviceId,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      statut: statut ?? this.statut,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (vehiculeId.present) {
      map['vehicule_id'] = Variable<String>(vehiculeId.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (dateEcheance.present) {
      map['date_echeance'] = Variable<DateTime>(dateEcheance.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(
        $AlertesEntretienTable.$converterstatut.toSql(statut.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertesEntretienCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('vehiculeId: $vehiculeId, ')
          ..write('serviceId: $serviceId, ')
          ..write('dateEcheance: $dateEcheance, ')
          ..write('statut: $statut, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationQueueTable extends NotificationQueue
    with TableInfo<$NotificationQueueTable, NotificationQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establishmentIdMeta = const VerificationMeta(
    'establishmentId',
  );
  @override
  late final GeneratedColumn<String> establishmentId = GeneratedColumn<String>(
    'establishment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _telephoneMeta = const VerificationMeta(
    'telephone',
  );
  @override
  late final GeneratedColumn<String> telephone = GeneratedColumn<String>(
    'telephone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<NotificationType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<NotificationType>($NotificationQueueTable.$convertertype);
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<NotificationStatut, String>
  statut = GeneratedColumn<String>(
    'statut',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<NotificationStatut>($NotificationQueueTable.$converterstatut);
  static const VerificationMeta _alerteEntretienIdMeta = const VerificationMeta(
    'alerteEntretienId',
  );
  @override
  late final GeneratedColumn<String> alerteEntretienId =
      GeneratedColumn<String>(
        'alerte_entretien_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establishmentId,
    clientId,
    telephone,
    type,
    payload,
    statut,
    alerteEntretienId,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establishment_id')) {
      context.handle(
        _establishmentIdMeta,
        establishmentId.isAcceptableOrUnknown(
          data['establishment_id']!,
          _establishmentIdMeta,
        ),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('telephone')) {
      context.handle(
        _telephoneMeta,
        telephone.isAcceptableOrUnknown(data['telephone']!, _telephoneMeta),
      );
    } else if (isInserting) {
      context.missing(_telephoneMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('alerte_entretien_id')) {
      context.handle(
        _alerteEntretienIdMeta,
        alerteEntretienId.isAcceptableOrUnknown(
          data['alerte_entretien_id']!,
          _alerteEntretienIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establishmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      telephone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telephone'],
      )!,
      type: $NotificationQueueTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      statut: $NotificationQueueTable.$converterstatut.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}statut'],
        )!,
      ),
      alerteEntretienId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alerte_entretien_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $NotificationQueueTable createAlias(String alias) {
    return $NotificationQueueTable(attachedDatabase, alias);
  }

  static TypeConverter<NotificationType, String> $convertertype =
      const NotificationTypeConverter();
  static TypeConverter<NotificationStatut, String> $converterstatut =
      const NotificationStatutConverter();
}

class NotificationQueueData extends DataClass
    implements Insertable<NotificationQueueData> {
  final String id;
  final String establishmentId;
  final String clientId;
  final String telephone;
  final NotificationType type;
  final String payload;
  final NotificationStatut statut;
  final String? alerteEntretienId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isDirty;
  const NotificationQueueData({
    required this.id,
    required this.establishmentId,
    required this.clientId,
    required this.telephone,
    required this.type,
    required this.payload,
    required this.statut,
    this.alerteEntretienId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establishment_id'] = Variable<String>(establishmentId);
    map['client_id'] = Variable<String>(clientId);
    map['telephone'] = Variable<String>(telephone);
    {
      map['type'] = Variable<String>(
        $NotificationQueueTable.$convertertype.toSql(type),
      );
    }
    map['payload'] = Variable<String>(payload);
    {
      map['statut'] = Variable<String>(
        $NotificationQueueTable.$converterstatut.toSql(statut),
      );
    }
    if (!nullToAbsent || alerteEntretienId != null) {
      map['alerte_entretien_id'] = Variable<String>(alerteEntretienId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  NotificationQueueCompanion toCompanion(bool nullToAbsent) {
    return NotificationQueueCompanion(
      id: Value(id),
      establishmentId: Value(establishmentId),
      clientId: Value(clientId),
      telephone: Value(telephone),
      type: Value(type),
      payload: Value(payload),
      statut: Value(statut),
      alerteEntretienId: alerteEntretienId == null && nullToAbsent
          ? const Value.absent()
          : Value(alerteEntretienId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
    );
  }

  factory NotificationQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationQueueData(
      id: serializer.fromJson<String>(json['id']),
      establishmentId: serializer.fromJson<String>(json['establishmentId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      telephone: serializer.fromJson<String>(json['telephone']),
      type: serializer.fromJson<NotificationType>(json['type']),
      payload: serializer.fromJson<String>(json['payload']),
      statut: serializer.fromJson<NotificationStatut>(json['statut']),
      alerteEntretienId: serializer.fromJson<String?>(
        json['alerteEntretienId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establishmentId': serializer.toJson<String>(establishmentId),
      'clientId': serializer.toJson<String>(clientId),
      'telephone': serializer.toJson<String>(telephone),
      'type': serializer.toJson<NotificationType>(type),
      'payload': serializer.toJson<String>(payload),
      'statut': serializer.toJson<NotificationStatut>(statut),
      'alerteEntretienId': serializer.toJson<String?>(alerteEntretienId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  NotificationQueueData copyWith({
    String? id,
    String? establishmentId,
    String? clientId,
    String? telephone,
    NotificationType? type,
    String? payload,
    NotificationStatut? statut,
    Value<String?> alerteEntretienId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isDirty,
  }) => NotificationQueueData(
    id: id ?? this.id,
    establishmentId: establishmentId ?? this.establishmentId,
    clientId: clientId ?? this.clientId,
    telephone: telephone ?? this.telephone,
    type: type ?? this.type,
    payload: payload ?? this.payload,
    statut: statut ?? this.statut,
    alerteEntretienId: alerteEntretienId.present
        ? alerteEntretienId.value
        : this.alerteEntretienId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
  );
  NotificationQueueData copyWithCompanion(NotificationQueueCompanion data) {
    return NotificationQueueData(
      id: data.id.present ? data.id.value : this.id,
      establishmentId: data.establishmentId.present
          ? data.establishmentId.value
          : this.establishmentId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      telephone: data.telephone.present ? data.telephone.value : this.telephone,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      statut: data.statut.present ? data.statut.value : this.statut,
      alerteEntretienId: data.alerteEntretienId.present
          ? data.alerteEntretienId.value
          : this.alerteEntretienId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationQueueData(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('clientId: $clientId, ')
          ..write('telephone: $telephone, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('statut: $statut, ')
          ..write('alerteEntretienId: $alerteEntretienId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establishmentId,
    clientId,
    telephone,
    type,
    payload,
    statut,
    alerteEntretienId,
    createdAt,
    updatedAt,
    isDeleted,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationQueueData &&
          other.id == this.id &&
          other.establishmentId == this.establishmentId &&
          other.clientId == this.clientId &&
          other.telephone == this.telephone &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.statut == this.statut &&
          other.alerteEntretienId == this.alerteEntretienId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty);
}

class NotificationQueueCompanion
    extends UpdateCompanion<NotificationQueueData> {
  final Value<String> id;
  final Value<String> establishmentId;
  final Value<String> clientId;
  final Value<String> telephone;
  final Value<NotificationType> type;
  final Value<String> payload;
  final Value<NotificationStatut> statut;
  final Value<String?> alerteEntretienId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const NotificationQueueCompanion({
    this.id = const Value.absent(),
    this.establishmentId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.telephone = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.statut = const Value.absent(),
    this.alerteEntretienId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationQueueCompanion.insert({
    required String id,
    this.establishmentId = const Value.absent(),
    required String clientId,
    required String telephone,
    required NotificationType type,
    this.payload = const Value.absent(),
    required NotificationStatut statut,
    this.alerteEntretienId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       telephone = Value(telephone),
       type = Value(type),
       statut = Value(statut),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NotificationQueueData> custom({
    Expression<String>? id,
    Expression<String>? establishmentId,
    Expression<String>? clientId,
    Expression<String>? telephone,
    Expression<String>? type,
    Expression<String>? payload,
    Expression<String>? statut,
    Expression<String>? alerteEntretienId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establishmentId != null) 'establishment_id': establishmentId,
      if (clientId != null) 'client_id': clientId,
      if (telephone != null) 'telephone': telephone,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (statut != null) 'statut': statut,
      if (alerteEntretienId != null) 'alerte_entretien_id': alerteEntretienId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? establishmentId,
    Value<String>? clientId,
    Value<String>? telephone,
    Value<NotificationType>? type,
    Value<String>? payload,
    Value<NotificationStatut>? statut,
    Value<String?>? alerteEntretienId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return NotificationQueueCompanion(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      clientId: clientId ?? this.clientId,
      telephone: telephone ?? this.telephone,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      statut: statut ?? this.statut,
      alerteEntretienId: alerteEntretienId ?? this.alerteEntretienId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establishmentId.present) {
      map['establishment_id'] = Variable<String>(establishmentId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (telephone.present) {
      map['telephone'] = Variable<String>(telephone.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $NotificationQueueTable.$convertertype.toSql(type.value),
      );
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(
        $NotificationQueueTable.$converterstatut.toSql(statut.value),
      );
    }
    if (alerteEntretienId.present) {
      map['alerte_entretien_id'] = Variable<String>(alerteEntretienId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationQueueCompanion(')
          ..write('id: $id, ')
          ..write('establishmentId: $establishmentId, ')
          ..write('clientId: $clientId, ')
          ..write('telephone: $telephone, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('statut: $statut, ')
          ..write('alerteEntretienId: $alerteEntretienId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionMeta = const VerificationMeta(
    'collection',
  );
  @override
  late final GeneratedColumn<String> collection = GeneratedColumn<String>(
    'collection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [collection, lastSyncAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection')) {
      context.handle(
        _collectionMeta,
        collection.isAcceptableOrUnknown(data['collection']!, _collectionMeta),
      );
    } else if (isInserting) {
      context.missing(_collectionMeta);
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collection};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      collection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String collection;
  final DateTime lastSyncAt;
  const SyncStateData({required this.collection, required this.lastSyncAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection'] = Variable<String>(collection);
    map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      collection: Value(collection),
      lastSyncAt: Value(lastSyncAt),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      collection: serializer.fromJson<String>(json['collection']),
      lastSyncAt: serializer.fromJson<DateTime>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collection': serializer.toJson<String>(collection),
      'lastSyncAt': serializer.toJson<DateTime>(lastSyncAt),
    };
  }

  SyncStateData copyWith({String? collection, DateTime? lastSyncAt}) =>
      SyncStateData(
        collection: collection ?? this.collection,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('collection: $collection, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collection, lastSyncAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.collection == this.collection &&
          other.lastSyncAt == this.lastSyncAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> collection;
  final Value<DateTime> lastSyncAt;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.collection = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String collection,
    required DateTime lastSyncAt,
    this.rowid = const Value.absent(),
  }) : collection = Value(collection),
       lastSyncAt = Value(lastSyncAt);
  static Insertable<SyncStateData> custom({
    Expression<String>? collection,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collection != null) 'collection': collection,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? collection,
    Value<DateTime>? lastSyncAt,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      collection: collection ?? this.collection,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collection.present) {
      map['collection'] = Variable<String>(collection.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('collection: $collection, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $VehiculesTable vehicules = $VehiculesTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CatalogServicesTable catalogServices = $CatalogServicesTable(
    this,
  );
  late final $ProductCategoriesTable productCategories =
      $ProductCategoriesTable(this);
  late final $ProduitsTable produits = $ProduitsTable(this);
  late final $PrestationsTable prestations = $PrestationsTable(this);
  late final $LignePrestationsTable lignePrestations = $LignePrestationsTable(
    this,
  );
  late final $JetonsTable jetons = $JetonsTable(this);
  late final $AlertesEntretienTable alertesEntretien = $AlertesEntretienTable(
    this,
  );
  late final $NotificationQueueTable notificationQueue =
      $NotificationQueueTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clients,
    vehicules,
    categories,
    catalogServices,
    productCategories,
    produits,
    prestations,
    lignePrestations,
    jetons,
    alertesEntretien,
    notificationQueue,
    syncState,
  ];
}

typedef $$ClientsTableCreateCompanionBuilder =
    ClientsCompanion Function({
      required String id,
      Value<String> establishmentId,
      required String phone,
      required String nom,
      Value<String?> prenom,
      Value<String?> email,
      Value<String?> adresse,
      Value<String> typeClient,
      Value<String?> notes,
      Value<int> pointsFidelite,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$ClientsTableUpdateCompanionBuilder =
    ClientsCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String> phone,
      Value<String> nom,
      Value<String?> prenom,
      Value<String?> email,
      Value<String?> adresse,
      Value<String> typeClient,
      Value<String?> notes,
      Value<int> pointsFidelite,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$ClientsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientsTable, Client> {
  $$ClientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VehiculesTable, List<Vehicule>>
  _vehiculesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vehicules,
    aliasName: $_aliasNameGenerator(db.clients.id, db.vehicules.clientId),
  );

  $$VehiculesTableProcessedTableManager get vehiculesRefs {
    final manager = $$VehiculesTableTableManager(
      $_db,
      $_db.vehicules,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vehiculesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrestationsTable, List<Prestation>>
  _prestationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prestations,
    aliasName: $_aliasNameGenerator(db.clients.id, db.prestations.clientId),
  );

  $$PrestationsTableProcessedTableManager get prestationsRefs {
    final manager = $$PrestationsTableTableManager(
      $_db,
      $_db.prestations,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_prestationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JetonsTable, List<Jeton>> _jetonsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jetons,
    aliasName: $_aliasNameGenerator(db.clients.id, db.jetons.clientId),
  );

  $$JetonsTableProcessedTableManager get jetonsRefs {
    final manager = $$JetonsTableTableManager(
      $_db,
      $_db.jetons,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jetonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $NotificationQueueTable,
    List<NotificationQueueData>
  >
  _notificationQueueRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.notificationQueue,
        aliasName: $_aliasNameGenerator(
          db.clients.id,
          db.notificationQueue.clientId,
        ),
      );

  $$NotificationQueueTableProcessedTableManager get notificationQueueRefs {
    final manager = $$NotificationQueueTableTableManager(
      $_db,
      $_db.notificationQueue,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _notificationQueueRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prenom => $composableBuilder(
    column: $table.prenom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adresse => $composableBuilder(
    column: $table.adresse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeClient => $composableBuilder(
    column: $table.typeClient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsFidelite => $composableBuilder(
    column: $table.pointsFidelite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> vehiculesRefs(
    Expression<bool> Function($$VehiculesTableFilterComposer f) f,
  ) {
    final $$VehiculesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicules,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiculesTableFilterComposer(
            $db: $db,
            $table: $db.vehicules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prestationsRefs(
    Expression<bool> Function($$PrestationsTableFilterComposer f) f,
  ) {
    final $$PrestationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prestations,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrestationsTableFilterComposer(
            $db: $db,
            $table: $db.prestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jetonsRefs(
    Expression<bool> Function($$JetonsTableFilterComposer f) f,
  ) {
    final $$JetonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jetons,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JetonsTableFilterComposer(
            $db: $db,
            $table: $db.jetons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notificationQueueRefs(
    Expression<bool> Function($$NotificationQueueTableFilterComposer f) f,
  ) {
    final $$NotificationQueueTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notificationQueue,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotificationQueueTableFilterComposer(
            $db: $db,
            $table: $db.notificationQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prenom => $composableBuilder(
    column: $table.prenom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adresse => $composableBuilder(
    column: $table.adresse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeClient => $composableBuilder(
    column: $table.typeClient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsFidelite => $composableBuilder(
    column: $table.pointsFidelite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get prenom =>
      $composableBuilder(column: $table.prenom, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get adresse =>
      $composableBuilder(column: $table.adresse, builder: (column) => column);

  GeneratedColumn<String> get typeClient => $composableBuilder(
    column: $table.typeClient,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get pointsFidelite => $composableBuilder(
    column: $table.pointsFidelite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  Expression<T> vehiculesRefs<T extends Object>(
    Expression<T> Function($$VehiculesTableAnnotationComposer a) f,
  ) {
    final $$VehiculesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicules,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiculesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prestationsRefs<T extends Object>(
    Expression<T> Function($$PrestationsTableAnnotationComposer a) f,
  ) {
    final $$PrestationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prestations,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrestationsTableAnnotationComposer(
            $db: $db,
            $table: $db.prestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> jetonsRefs<T extends Object>(
    Expression<T> Function($$JetonsTableAnnotationComposer a) f,
  ) {
    final $$JetonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jetons,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JetonsTableAnnotationComposer(
            $db: $db,
            $table: $db.jetons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notificationQueueRefs<T extends Object>(
    Expression<T> Function($$NotificationQueueTableAnnotationComposer a) f,
  ) {
    final $$NotificationQueueTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.notificationQueue,
          getReferencedColumn: (t) => t.clientId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NotificationQueueTableAnnotationComposer(
                $db: $db,
                $table: $db.notificationQueue,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ClientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientsTable,
          Client,
          $$ClientsTableFilterComposer,
          $$ClientsTableOrderingComposer,
          $$ClientsTableAnnotationComposer,
          $$ClientsTableCreateCompanionBuilder,
          $$ClientsTableUpdateCompanionBuilder,
          (Client, $$ClientsTableReferences),
          Client,
          PrefetchHooks Function({
            bool vehiculesRefs,
            bool prestationsRefs,
            bool jetonsRefs,
            bool notificationQueueRefs,
          })
        > {
  $$ClientsTableTableManager(_$AppDatabase db, $ClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<String?> prenom = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> adresse = const Value.absent(),
                Value<String> typeClient = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> pointsFidelite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                establishmentId: establishmentId,
                phone: phone,
                nom: nom,
                prenom: prenom,
                email: email,
                adresse: adresse,
                typeClient: typeClient,
                notes: notes,
                pointsFidelite: pointsFidelite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                required String phone,
                required String nom,
                Value<String?> prenom = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> adresse = const Value.absent(),
                Value<String> typeClient = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> pointsFidelite = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                phone: phone,
                nom: nom,
                prenom: prenom,
                email: email,
                adresse: adresse,
                typeClient: typeClient,
                notes: notes,
                pointsFidelite: pointsFidelite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vehiculesRefs = false,
                prestationsRefs = false,
                jetonsRefs = false,
                notificationQueueRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (vehiculesRefs) db.vehicules,
                    if (prestationsRefs) db.prestations,
                    if (jetonsRefs) db.jetons,
                    if (notificationQueueRefs) db.notificationQueue,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (vehiculesRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          Vehicule
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._vehiculesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).vehiculesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (prestationsRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          Prestation
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._prestationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).prestationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (jetonsRefs)
                        await $_getPrefetchedData<Client, $ClientsTable, Jeton>(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._jetonsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).jetonsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notificationQueueRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          NotificationQueueData
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._notificationQueueRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).notificationQueueRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientsTable,
      Client,
      $$ClientsTableFilterComposer,
      $$ClientsTableOrderingComposer,
      $$ClientsTableAnnotationComposer,
      $$ClientsTableCreateCompanionBuilder,
      $$ClientsTableUpdateCompanionBuilder,
      (Client, $$ClientsTableReferences),
      Client,
      PrefetchHooks Function({
        bool vehiculesRefs,
        bool prestationsRefs,
        bool jetonsRefs,
        bool notificationQueueRefs,
      })
    >;
typedef $$VehiculesTableCreateCompanionBuilder =
    VehiculesCompanion Function({
      required String id,
      Value<String> establishmentId,
      Value<String?> clientId,
      required String immatriculation,
      Value<String?> marque,
      Value<String?> modele,
      Value<int?> annee,
      Value<int?> kilometrage,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$VehiculesTableUpdateCompanionBuilder =
    VehiculesCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String?> clientId,
      Value<String> immatriculation,
      Value<String?> marque,
      Value<String?> modele,
      Value<int?> annee,
      Value<int?> kilometrage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$VehiculesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiculesTable, Vehicule> {
  $$VehiculesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) => db.clients
      .createAlias($_aliasNameGenerator(db.vehicules.clientId, db.clients.id));

  $$ClientsTableProcessedTableManager? get clientId {
    final $_column = $_itemColumn<String>('client_id');
    if ($_column == null) return null;
    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PrestationsTable, List<Prestation>>
  _prestationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prestations,
    aliasName: $_aliasNameGenerator(db.vehicules.id, db.prestations.vehiculeId),
  );

  $$PrestationsTableProcessedTableManager get prestationsRefs {
    final manager = $$PrestationsTableTableManager(
      $_db,
      $_db.prestations,
    ).filter((f) => f.vehiculeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_prestationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AlertesEntretienTable, List<AlertesEntretienData>>
  _alertesEntretienRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.alertesEntretien,
    aliasName: $_aliasNameGenerator(
      db.vehicules.id,
      db.alertesEntretien.vehiculeId,
    ),
  );

  $$AlertesEntretienTableProcessedTableManager get alertesEntretienRefs {
    final manager = $$AlertesEntretienTableTableManager(
      $_db,
      $_db.alertesEntretien,
    ).filter((f) => f.vehiculeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _alertesEntretienRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiculesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiculesTable> {
  $$VehiculesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get immatriculation => $composableBuilder(
    column: $table.immatriculation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marque => $composableBuilder(
    column: $table.marque,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modele => $composableBuilder(
    column: $table.modele,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get annee => $composableBuilder(
    column: $table.annee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kilometrage => $composableBuilder(
    column: $table.kilometrage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> prestationsRefs(
    Expression<bool> Function($$PrestationsTableFilterComposer f) f,
  ) {
    final $$PrestationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prestations,
      getReferencedColumn: (t) => t.vehiculeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrestationsTableFilterComposer(
            $db: $db,
            $table: $db.prestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> alertesEntretienRefs(
    Expression<bool> Function($$AlertesEntretienTableFilterComposer f) f,
  ) {
    final $$AlertesEntretienTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alertesEntretien,
      getReferencedColumn: (t) => t.vehiculeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertesEntretienTableFilterComposer(
            $db: $db,
            $table: $db.alertesEntretien,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiculesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiculesTable> {
  $$VehiculesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get immatriculation => $composableBuilder(
    column: $table.immatriculation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marque => $composableBuilder(
    column: $table.marque,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modele => $composableBuilder(
    column: $table.modele,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get annee => $composableBuilder(
    column: $table.annee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kilometrage => $composableBuilder(
    column: $table.kilometrage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehiculesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiculesTable> {
  $$VehiculesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get immatriculation => $composableBuilder(
    column: $table.immatriculation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get marque =>
      $composableBuilder(column: $table.marque, builder: (column) => column);

  GeneratedColumn<String> get modele =>
      $composableBuilder(column: $table.modele, builder: (column) => column);

  GeneratedColumn<int> get annee =>
      $composableBuilder(column: $table.annee, builder: (column) => column);

  GeneratedColumn<int> get kilometrage => $composableBuilder(
    column: $table.kilometrage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> prestationsRefs<T extends Object>(
    Expression<T> Function($$PrestationsTableAnnotationComposer a) f,
  ) {
    final $$PrestationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prestations,
      getReferencedColumn: (t) => t.vehiculeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrestationsTableAnnotationComposer(
            $db: $db,
            $table: $db.prestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> alertesEntretienRefs<T extends Object>(
    Expression<T> Function($$AlertesEntretienTableAnnotationComposer a) f,
  ) {
    final $$AlertesEntretienTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alertesEntretien,
      getReferencedColumn: (t) => t.vehiculeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertesEntretienTableAnnotationComposer(
            $db: $db,
            $table: $db.alertesEntretien,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiculesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiculesTable,
          Vehicule,
          $$VehiculesTableFilterComposer,
          $$VehiculesTableOrderingComposer,
          $$VehiculesTableAnnotationComposer,
          $$VehiculesTableCreateCompanionBuilder,
          $$VehiculesTableUpdateCompanionBuilder,
          (Vehicule, $$VehiculesTableReferences),
          Vehicule,
          PrefetchHooks Function({
            bool clientId,
            bool prestationsRefs,
            bool alertesEntretienRefs,
          })
        > {
  $$VehiculesTableTableManager(_$AppDatabase db, $VehiculesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiculesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiculesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiculesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<String> immatriculation = const Value.absent(),
                Value<String?> marque = const Value.absent(),
                Value<String?> modele = const Value.absent(),
                Value<int?> annee = const Value.absent(),
                Value<int?> kilometrage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiculesCompanion(
                id: id,
                establishmentId: establishmentId,
                clientId: clientId,
                immatriculation: immatriculation,
                marque: marque,
                modele: modele,
                annee: annee,
                kilometrage: kilometrage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                required String immatriculation,
                Value<String?> marque = const Value.absent(),
                Value<String?> modele = const Value.absent(),
                Value<int?> annee = const Value.absent(),
                Value<int?> kilometrage = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiculesCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                clientId: clientId,
                immatriculation: immatriculation,
                marque: marque,
                modele: modele,
                annee: annee,
                kilometrage: kilometrage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiculesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clientId = false,
                prestationsRefs = false,
                alertesEntretienRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (prestationsRefs) db.prestations,
                    if (alertesEntretienRefs) db.alertesEntretien,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.clientId,
                                    referencedTable: $$VehiculesTableReferences
                                        ._clientIdTable(db),
                                    referencedColumn: $$VehiculesTableReferences
                                        ._clientIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (prestationsRefs)
                        await $_getPrefetchedData<
                          Vehicule,
                          $VehiculesTable,
                          Prestation
                        >(
                          currentTable: table,
                          referencedTable: $$VehiculesTableReferences
                              ._prestationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiculesTableReferences(
                                db,
                                table,
                                p0,
                              ).prestationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehiculeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (alertesEntretienRefs)
                        await $_getPrefetchedData<
                          Vehicule,
                          $VehiculesTable,
                          AlertesEntretienData
                        >(
                          currentTable: table,
                          referencedTable: $$VehiculesTableReferences
                              ._alertesEntretienRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiculesTableReferences(
                                db,
                                table,
                                p0,
                              ).alertesEntretienRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehiculeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehiculesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiculesTable,
      Vehicule,
      $$VehiculesTableFilterComposer,
      $$VehiculesTableOrderingComposer,
      $$VehiculesTableAnnotationComposer,
      $$VehiculesTableCreateCompanionBuilder,
      $$VehiculesTableUpdateCompanionBuilder,
      (Vehicule, $$VehiculesTableReferences),
      Vehicule,
      PrefetchHooks Function({
        bool clientId,
        bool prestationsRefs,
        bool alertesEntretienRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      Value<String> establishmentId,
      required String nom,
      Value<int> ordre,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String> nom,
      Value<int> ordre,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CatalogServicesTable, List<CatalogService>>
  _catalogServicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.catalogServices,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.catalogServices.categorieId,
    ),
  );

  $$CatalogServicesTableProcessedTableManager get catalogServicesRefs {
    final manager = $$CatalogServicesTableTableManager(
      $_db,
      $_db.catalogServices,
    ).filter((f) => f.categorieId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _catalogServicesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> catalogServicesRefs(
    Expression<bool> Function($$CatalogServicesTableFilterComposer f) f,
  ) {
    final $$CatalogServicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catalogServices,
      getReferencedColumn: (t) => t.categorieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogServicesTableFilterComposer(
            $db: $db,
            $table: $db.catalogServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<int> get ordre =>
      $composableBuilder(column: $table.ordre, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  Expression<T> catalogServicesRefs<T extends Object>(
    Expression<T> Function($$CatalogServicesTableAnnotationComposer a) f,
  ) {
    final $$CatalogServicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catalogServices,
      getReferencedColumn: (t) => t.categorieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogServicesTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool catalogServicesRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<int> ordre = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                establishmentId: establishmentId,
                nom: nom,
                ordre: ordre,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                required String nom,
                Value<int> ordre = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                nom: nom,
                ordre: ordre,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catalogServicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (catalogServicesRefs) db.catalogServices,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (catalogServicesRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      CatalogService
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._catalogServicesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).catalogServicesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.categorieId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool catalogServicesRefs})
    >;
typedef $$CatalogServicesTableCreateCompanionBuilder =
    CatalogServicesCompanion Function({
      required String id,
      Value<String> establishmentId,
      Value<String?> categorieId,
      required String nom,
      required double prix,
      Value<String> devise,
      Value<int> intervalleJours,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$CatalogServicesTableUpdateCompanionBuilder =
    CatalogServicesCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String?> categorieId,
      Value<String> nom,
      Value<double> prix,
      Value<String> devise,
      Value<int> intervalleJours,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$CatalogServicesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CatalogServicesTable, CatalogService> {
  $$CatalogServicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categorieIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.catalogServices.categorieId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get categorieId {
    final $_column = $_itemColumn<String>('categorie_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categorieIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LignePrestationsTable, List<LignePrestation>>
  _lignePrestationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lignePrestations,
    aliasName: $_aliasNameGenerator(
      db.catalogServices.id,
      db.lignePrestations.serviceId,
    ),
  );

  $$LignePrestationsTableProcessedTableManager get lignePrestationsRefs {
    final manager = $$LignePrestationsTableTableManager(
      $_db,
      $_db.lignePrestations,
    ).filter((f) => f.serviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lignePrestationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AlertesEntretienTable, List<AlertesEntretienData>>
  _alertesEntretienRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.alertesEntretien,
    aliasName: $_aliasNameGenerator(
      db.catalogServices.id,
      db.alertesEntretien.serviceId,
    ),
  );

  $$AlertesEntretienTableProcessedTableManager get alertesEntretienRefs {
    final manager = $$AlertesEntretienTableTableManager(
      $_db,
      $_db.alertesEntretien,
    ).filter((f) => f.serviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _alertesEntretienRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CatalogServicesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogServicesTable> {
  $$CatalogServicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prix => $composableBuilder(
    column: $table.prix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get devise => $composableBuilder(
    column: $table.devise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalleJours => $composableBuilder(
    column: $table.intervalleJours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categorieId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lignePrestationsRefs(
    Expression<bool> Function($$LignePrestationsTableFilterComposer f) f,
  ) {
    final $$LignePrestationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lignePrestations,
      getReferencedColumn: (t) => t.serviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LignePrestationsTableFilterComposer(
            $db: $db,
            $table: $db.lignePrestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> alertesEntretienRefs(
    Expression<bool> Function($$AlertesEntretienTableFilterComposer f) f,
  ) {
    final $$AlertesEntretienTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alertesEntretien,
      getReferencedColumn: (t) => t.serviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertesEntretienTableFilterComposer(
            $db: $db,
            $table: $db.alertesEntretien,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogServicesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogServicesTable> {
  $$CatalogServicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prix => $composableBuilder(
    column: $table.prix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get devise => $composableBuilder(
    column: $table.devise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalleJours => $composableBuilder(
    column: $table.intervalleJours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categorieId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogServicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogServicesTable> {
  $$CatalogServicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<double> get prix =>
      $composableBuilder(column: $table.prix, builder: (column) => column);

  GeneratedColumn<String> get devise =>
      $composableBuilder(column: $table.devise, builder: (column) => column);

  GeneratedColumn<int> get intervalleJours => $composableBuilder(
    column: $table.intervalleJours,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categorieId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lignePrestationsRefs<T extends Object>(
    Expression<T> Function($$LignePrestationsTableAnnotationComposer a) f,
  ) {
    final $$LignePrestationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lignePrestations,
      getReferencedColumn: (t) => t.serviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LignePrestationsTableAnnotationComposer(
            $db: $db,
            $table: $db.lignePrestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> alertesEntretienRefs<T extends Object>(
    Expression<T> Function($$AlertesEntretienTableAnnotationComposer a) f,
  ) {
    final $$AlertesEntretienTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alertesEntretien,
      getReferencedColumn: (t) => t.serviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertesEntretienTableAnnotationComposer(
            $db: $db,
            $table: $db.alertesEntretien,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogServicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogServicesTable,
          CatalogService,
          $$CatalogServicesTableFilterComposer,
          $$CatalogServicesTableOrderingComposer,
          $$CatalogServicesTableAnnotationComposer,
          $$CatalogServicesTableCreateCompanionBuilder,
          $$CatalogServicesTableUpdateCompanionBuilder,
          (CatalogService, $$CatalogServicesTableReferences),
          CatalogService,
          PrefetchHooks Function({
            bool categorieId,
            bool lignePrestationsRefs,
            bool alertesEntretienRefs,
          })
        > {
  $$CatalogServicesTableTableManager(
    _$AppDatabase db,
    $CatalogServicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogServicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogServicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String?> categorieId = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<double> prix = const Value.absent(),
                Value<String> devise = const Value.absent(),
                Value<int> intervalleJours = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogServicesCompanion(
                id: id,
                establishmentId: establishmentId,
                categorieId: categorieId,
                nom: nom,
                prix: prix,
                devise: devise,
                intervalleJours: intervalleJours,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                Value<String?> categorieId = const Value.absent(),
                required String nom,
                required double prix,
                Value<String> devise = const Value.absent(),
                Value<int> intervalleJours = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogServicesCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                categorieId: categorieId,
                nom: nom,
                prix: prix,
                devise: devise,
                intervalleJours: intervalleJours,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CatalogServicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categorieId = false,
                lignePrestationsRefs = false,
                alertesEntretienRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lignePrestationsRefs) db.lignePrestations,
                    if (alertesEntretienRefs) db.alertesEntretien,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categorieId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categorieId,
                                    referencedTable:
                                        $$CatalogServicesTableReferences
                                            ._categorieIdTable(db),
                                    referencedColumn:
                                        $$CatalogServicesTableReferences
                                            ._categorieIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lignePrestationsRefs)
                        await $_getPrefetchedData<
                          CatalogService,
                          $CatalogServicesTable,
                          LignePrestation
                        >(
                          currentTable: table,
                          referencedTable: $$CatalogServicesTableReferences
                              ._lignePrestationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CatalogServicesTableReferences(
                                db,
                                table,
                                p0,
                              ).lignePrestationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.serviceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (alertesEntretienRefs)
                        await $_getPrefetchedData<
                          CatalogService,
                          $CatalogServicesTable,
                          AlertesEntretienData
                        >(
                          currentTable: table,
                          referencedTable: $$CatalogServicesTableReferences
                              ._alertesEntretienRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CatalogServicesTableReferences(
                                db,
                                table,
                                p0,
                              ).alertesEntretienRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.serviceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CatalogServicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogServicesTable,
      CatalogService,
      $$CatalogServicesTableFilterComposer,
      $$CatalogServicesTableOrderingComposer,
      $$CatalogServicesTableAnnotationComposer,
      $$CatalogServicesTableCreateCompanionBuilder,
      $$CatalogServicesTableUpdateCompanionBuilder,
      (CatalogService, $$CatalogServicesTableReferences),
      CatalogService,
      PrefetchHooks Function({
        bool categorieId,
        bool lignePrestationsRefs,
        bool alertesEntretienRefs,
      })
    >;
typedef $$ProductCategoriesTableCreateCompanionBuilder =
    ProductCategoriesCompanion Function({
      required String id,
      Value<String> establishmentId,
      required String nom,
      Value<int> ordre,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$ProductCategoriesTableUpdateCompanionBuilder =
    ProductCategoriesCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String> nom,
      Value<int> ordre,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$ProductCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProductCategoriesTable,
          ProductCategory
        > {
  $$ProductCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ProduitsTable, List<Produit>> _produitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.produits,
    aliasName: $_aliasNameGenerator(
      db.productCategories.id,
      db.produits.categorieId,
    ),
  );

  $$ProduitsTableProcessedTableManager get produitsRefs {
    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.categorieId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_produitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> produitsRefs(
    Expression<bool> Function($$ProduitsTableFilterComposer f) f,
  ) {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.categorieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<int> get ordre =>
      $composableBuilder(column: $table.ordre, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  Expression<T> produitsRefs<T extends Object>(
    Expression<T> Function($$ProduitsTableAnnotationComposer a) f,
  ) {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.categorieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductCategoriesTable,
          ProductCategory,
          $$ProductCategoriesTableFilterComposer,
          $$ProductCategoriesTableOrderingComposer,
          $$ProductCategoriesTableAnnotationComposer,
          $$ProductCategoriesTableCreateCompanionBuilder,
          $$ProductCategoriesTableUpdateCompanionBuilder,
          (ProductCategory, $$ProductCategoriesTableReferences),
          ProductCategory,
          PrefetchHooks Function({bool produitsRefs})
        > {
  $$ProductCategoriesTableTableManager(
    _$AppDatabase db,
    $ProductCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<int> ordre = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductCategoriesCompanion(
                id: id,
                establishmentId: establishmentId,
                nom: nom,
                ordre: ordre,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                required String nom,
                Value<int> ordre = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductCategoriesCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                nom: nom,
                ordre: ordre,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produitsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (produitsRefs) db.produits],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (produitsRefs)
                    await $_getPrefetchedData<
                      ProductCategory,
                      $ProductCategoriesTable,
                      Produit
                    >(
                      currentTable: table,
                      referencedTable: $$ProductCategoriesTableReferences
                          ._produitsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProductCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).produitsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.categorieId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProductCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductCategoriesTable,
      ProductCategory,
      $$ProductCategoriesTableFilterComposer,
      $$ProductCategoriesTableOrderingComposer,
      $$ProductCategoriesTableAnnotationComposer,
      $$ProductCategoriesTableCreateCompanionBuilder,
      $$ProductCategoriesTableUpdateCompanionBuilder,
      (ProductCategory, $$ProductCategoriesTableReferences),
      ProductCategory,
      PrefetchHooks Function({bool produitsRefs})
    >;
typedef $$ProduitsTableCreateCompanionBuilder =
    ProduitsCompanion Function({
      required String id,
      Value<String> establishmentId,
      Value<String?> categorieId,
      required String nom,
      required double prix,
      Value<String> devise,
      Value<int> stock,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$ProduitsTableUpdateCompanionBuilder =
    ProduitsCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String?> categorieId,
      Value<String> nom,
      Value<double> prix,
      Value<String> devise,
      Value<int> stock,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$ProduitsTableReferences
    extends BaseReferences<_$AppDatabase, $ProduitsTable, Produit> {
  $$ProduitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductCategoriesTable _categorieIdTable(_$AppDatabase db) =>
      db.productCategories.createAlias(
        $_aliasNameGenerator(db.produits.categorieId, db.productCategories.id),
      );

  $$ProductCategoriesTableProcessedTableManager? get categorieId {
    final $_column = $_itemColumn<String>('categorie_id');
    if ($_column == null) return null;
    final manager = $$ProductCategoriesTableTableManager(
      $_db,
      $_db.productCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categorieIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LignePrestationsTable, List<LignePrestation>>
  _lignePrestationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lignePrestations,
    aliasName: $_aliasNameGenerator(
      db.produits.id,
      db.lignePrestations.produitId,
    ),
  );

  $$LignePrestationsTableProcessedTableManager get lignePrestationsRefs {
    final manager = $$LignePrestationsTableTableManager(
      $_db,
      $_db.lignePrestations,
    ).filter((f) => f.produitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lignePrestationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProduitsTableFilterComposer
    extends Composer<_$AppDatabase, $ProduitsTable> {
  $$ProduitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prix => $composableBuilder(
    column: $table.prix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get devise => $composableBuilder(
    column: $table.devise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductCategoriesTableFilterComposer get categorieId {
    final $$ProductCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.productCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.productCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lignePrestationsRefs(
    Expression<bool> Function($$LignePrestationsTableFilterComposer f) f,
  ) {
    final $$LignePrestationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lignePrestations,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LignePrestationsTableFilterComposer(
            $db: $db,
            $table: $db.lignePrestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProduitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProduitsTable> {
  $$ProduitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prix => $composableBuilder(
    column: $table.prix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get devise => $composableBuilder(
    column: $table.devise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductCategoriesTableOrderingComposer get categorieId {
    final $$ProductCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.productCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.productCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProduitsTable> {
  $$ProduitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<double> get prix =>
      $composableBuilder(column: $table.prix, builder: (column) => column);

  GeneratedColumn<String> get devise =>
      $composableBuilder(column: $table.devise, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$ProductCategoriesTableAnnotationComposer get categorieId {
    final $$ProductCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categorieId,
          referencedTable: $db.productCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.productCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> lignePrestationsRefs<T extends Object>(
    Expression<T> Function($$LignePrestationsTableAnnotationComposer a) f,
  ) {
    final $$LignePrestationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lignePrestations,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LignePrestationsTableAnnotationComposer(
            $db: $db,
            $table: $db.lignePrestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProduitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProduitsTable,
          Produit,
          $$ProduitsTableFilterComposer,
          $$ProduitsTableOrderingComposer,
          $$ProduitsTableAnnotationComposer,
          $$ProduitsTableCreateCompanionBuilder,
          $$ProduitsTableUpdateCompanionBuilder,
          (Produit, $$ProduitsTableReferences),
          Produit,
          PrefetchHooks Function({bool categorieId, bool lignePrestationsRefs})
        > {
  $$ProduitsTableTableManager(_$AppDatabase db, $ProduitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProduitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProduitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProduitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String?> categorieId = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<double> prix = const Value.absent(),
                Value<String> devise = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProduitsCompanion(
                id: id,
                establishmentId: establishmentId,
                categorieId: categorieId,
                nom: nom,
                prix: prix,
                devise: devise,
                stock: stock,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                Value<String?> categorieId = const Value.absent(),
                required String nom,
                required double prix,
                Value<String> devise = const Value.absent(),
                Value<int> stock = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProduitsCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                categorieId: categorieId,
                nom: nom,
                prix: prix,
                devise: devise,
                stock: stock,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProduitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categorieId = false, lignePrestationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lignePrestationsRefs) db.lignePrestations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categorieId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categorieId,
                                    referencedTable: $$ProduitsTableReferences
                                        ._categorieIdTable(db),
                                    referencedColumn: $$ProduitsTableReferences
                                        ._categorieIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lignePrestationsRefs)
                        await $_getPrefetchedData<
                          Produit,
                          $ProduitsTable,
                          LignePrestation
                        >(
                          currentTable: table,
                          referencedTable: $$ProduitsTableReferences
                              ._lignePrestationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduitsTableReferences(
                                db,
                                table,
                                p0,
                              ).lignePrestationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProduitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProduitsTable,
      Produit,
      $$ProduitsTableFilterComposer,
      $$ProduitsTableOrderingComposer,
      $$ProduitsTableAnnotationComposer,
      $$ProduitsTableCreateCompanionBuilder,
      $$ProduitsTableUpdateCompanionBuilder,
      (Produit, $$ProduitsTableReferences),
      Produit,
      PrefetchHooks Function({bool categorieId, bool lignePrestationsRefs})
    >;
typedef $$PrestationsTableCreateCompanionBuilder =
    PrestationsCompanion Function({
      required String id,
      Value<String> establishmentId,
      Value<String?> clientId,
      required String vehiculeId,
      required PrestationStatut statut,
      required DateTime dateOuverture,
      Value<DateTime?> dateCloture,
      Value<double> montantTotal,
      Value<double> montantPointsDeduit,
      Value<int> pointsUtilises,
      Value<int> pointsGagnes,
      Value<int?> kilometrage,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$PrestationsTableUpdateCompanionBuilder =
    PrestationsCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String?> clientId,
      Value<String> vehiculeId,
      Value<PrestationStatut> statut,
      Value<DateTime> dateOuverture,
      Value<DateTime?> dateCloture,
      Value<double> montantTotal,
      Value<double> montantPointsDeduit,
      Value<int> pointsUtilises,
      Value<int> pointsGagnes,
      Value<int?> kilometrage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$PrestationsTableReferences
    extends BaseReferences<_$AppDatabase, $PrestationsTable, Prestation> {
  $$PrestationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) =>
      db.clients.createAlias(
        $_aliasNameGenerator(db.prestations.clientId, db.clients.id),
      );

  $$ClientsTableProcessedTableManager? get clientId {
    final $_column = $_itemColumn<String>('client_id');
    if ($_column == null) return null;
    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VehiculesTable _vehiculeIdTable(_$AppDatabase db) =>
      db.vehicules.createAlias(
        $_aliasNameGenerator(db.prestations.vehiculeId, db.vehicules.id),
      );

  $$VehiculesTableProcessedTableManager get vehiculeId {
    final $_column = $_itemColumn<String>('vehicule_id')!;

    final manager = $$VehiculesTableTableManager(
      $_db,
      $_db.vehicules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehiculeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LignePrestationsTable, List<LignePrestation>>
  _lignePrestationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lignePrestations,
    aliasName: $_aliasNameGenerator(
      db.prestations.id,
      db.lignePrestations.prestationId,
    ),
  );

  $$LignePrestationsTableProcessedTableManager get lignePrestationsRefs {
    final manager = $$LignePrestationsTableTableManager(
      $_db,
      $_db.lignePrestations,
    ).filter((f) => f.prestationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lignePrestationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JetonsTable, List<Jeton>> _jetonsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jetons,
    aliasName: $_aliasNameGenerator(db.prestations.id, db.jetons.prestationId),
  );

  $$JetonsTableProcessedTableManager get jetonsRefs {
    final manager = $$JetonsTableTableManager(
      $_db,
      $_db.jetons,
    ).filter((f) => f.prestationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jetonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PrestationsTableFilterComposer
    extends Composer<_$AppDatabase, $PrestationsTable> {
  $$PrestationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PrestationStatut, PrestationStatut, String>
  get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get dateOuverture => $composableBuilder(
    column: $table.dateOuverture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCloture => $composableBuilder(
    column: $table.dateCloture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantTotal => $composableBuilder(
    column: $table.montantTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantPointsDeduit => $composableBuilder(
    column: $table.montantPointsDeduit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsUtilises => $composableBuilder(
    column: $table.pointsUtilises,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsGagnes => $composableBuilder(
    column: $table.pointsGagnes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kilometrage => $composableBuilder(
    column: $table.kilometrage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiculesTableFilterComposer get vehiculeId {
    final $$VehiculesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehiculeId,
      referencedTable: $db.vehicules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiculesTableFilterComposer(
            $db: $db,
            $table: $db.vehicules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lignePrestationsRefs(
    Expression<bool> Function($$LignePrestationsTableFilterComposer f) f,
  ) {
    final $$LignePrestationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lignePrestations,
      getReferencedColumn: (t) => t.prestationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LignePrestationsTableFilterComposer(
            $db: $db,
            $table: $db.lignePrestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jetonsRefs(
    Expression<bool> Function($$JetonsTableFilterComposer f) f,
  ) {
    final $$JetonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jetons,
      getReferencedColumn: (t) => t.prestationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JetonsTableFilterComposer(
            $db: $db,
            $table: $db.jetons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrestationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrestationsTable> {
  $$PrestationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOuverture => $composableBuilder(
    column: $table.dateOuverture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCloture => $composableBuilder(
    column: $table.dateCloture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantTotal => $composableBuilder(
    column: $table.montantTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantPointsDeduit => $composableBuilder(
    column: $table.montantPointsDeduit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsUtilises => $composableBuilder(
    column: $table.pointsUtilises,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsGagnes => $composableBuilder(
    column: $table.pointsGagnes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kilometrage => $composableBuilder(
    column: $table.kilometrage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiculesTableOrderingComposer get vehiculeId {
    final $$VehiculesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehiculeId,
      referencedTable: $db.vehicules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiculesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrestationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrestationsTable> {
  $$PrestationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PrestationStatut, String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOuverture => $composableBuilder(
    column: $table.dateOuverture,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCloture => $composableBuilder(
    column: $table.dateCloture,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montantTotal => $composableBuilder(
    column: $table.montantTotal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montantPointsDeduit => $composableBuilder(
    column: $table.montantPointsDeduit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointsUtilises => $composableBuilder(
    column: $table.pointsUtilises,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointsGagnes => $composableBuilder(
    column: $table.pointsGagnes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get kilometrage => $composableBuilder(
    column: $table.kilometrage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiculesTableAnnotationComposer get vehiculeId {
    final $$VehiculesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehiculeId,
      referencedTable: $db.vehicules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiculesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lignePrestationsRefs<T extends Object>(
    Expression<T> Function($$LignePrestationsTableAnnotationComposer a) f,
  ) {
    final $$LignePrestationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lignePrestations,
      getReferencedColumn: (t) => t.prestationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LignePrestationsTableAnnotationComposer(
            $db: $db,
            $table: $db.lignePrestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> jetonsRefs<T extends Object>(
    Expression<T> Function($$JetonsTableAnnotationComposer a) f,
  ) {
    final $$JetonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jetons,
      getReferencedColumn: (t) => t.prestationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JetonsTableAnnotationComposer(
            $db: $db,
            $table: $db.jetons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrestationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrestationsTable,
          Prestation,
          $$PrestationsTableFilterComposer,
          $$PrestationsTableOrderingComposer,
          $$PrestationsTableAnnotationComposer,
          $$PrestationsTableCreateCompanionBuilder,
          $$PrestationsTableUpdateCompanionBuilder,
          (Prestation, $$PrestationsTableReferences),
          Prestation,
          PrefetchHooks Function({
            bool clientId,
            bool vehiculeId,
            bool lignePrestationsRefs,
            bool jetonsRefs,
          })
        > {
  $$PrestationsTableTableManager(_$AppDatabase db, $PrestationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrestationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrestationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrestationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<String> vehiculeId = const Value.absent(),
                Value<PrestationStatut> statut = const Value.absent(),
                Value<DateTime> dateOuverture = const Value.absent(),
                Value<DateTime?> dateCloture = const Value.absent(),
                Value<double> montantTotal = const Value.absent(),
                Value<double> montantPointsDeduit = const Value.absent(),
                Value<int> pointsUtilises = const Value.absent(),
                Value<int> pointsGagnes = const Value.absent(),
                Value<int?> kilometrage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrestationsCompanion(
                id: id,
                establishmentId: establishmentId,
                clientId: clientId,
                vehiculeId: vehiculeId,
                statut: statut,
                dateOuverture: dateOuverture,
                dateCloture: dateCloture,
                montantTotal: montantTotal,
                montantPointsDeduit: montantPointsDeduit,
                pointsUtilises: pointsUtilises,
                pointsGagnes: pointsGagnes,
                kilometrage: kilometrage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                required String vehiculeId,
                required PrestationStatut statut,
                required DateTime dateOuverture,
                Value<DateTime?> dateCloture = const Value.absent(),
                Value<double> montantTotal = const Value.absent(),
                Value<double> montantPointsDeduit = const Value.absent(),
                Value<int> pointsUtilises = const Value.absent(),
                Value<int> pointsGagnes = const Value.absent(),
                Value<int?> kilometrage = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrestationsCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                clientId: clientId,
                vehiculeId: vehiculeId,
                statut: statut,
                dateOuverture: dateOuverture,
                dateCloture: dateCloture,
                montantTotal: montantTotal,
                montantPointsDeduit: montantPointsDeduit,
                pointsUtilises: pointsUtilises,
                pointsGagnes: pointsGagnes,
                kilometrage: kilometrage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrestationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clientId = false,
                vehiculeId = false,
                lignePrestationsRefs = false,
                jetonsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lignePrestationsRefs) db.lignePrestations,
                    if (jetonsRefs) db.jetons,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.clientId,
                                    referencedTable:
                                        $$PrestationsTableReferences
                                            ._clientIdTable(db),
                                    referencedColumn:
                                        $$PrestationsTableReferences
                                            ._clientIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (vehiculeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehiculeId,
                                    referencedTable:
                                        $$PrestationsTableReferences
                                            ._vehiculeIdTable(db),
                                    referencedColumn:
                                        $$PrestationsTableReferences
                                            ._vehiculeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lignePrestationsRefs)
                        await $_getPrefetchedData<
                          Prestation,
                          $PrestationsTable,
                          LignePrestation
                        >(
                          currentTable: table,
                          referencedTable: $$PrestationsTableReferences
                              ._lignePrestationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PrestationsTableReferences(
                                db,
                                table,
                                p0,
                              ).lignePrestationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.prestationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (jetonsRefs)
                        await $_getPrefetchedData<
                          Prestation,
                          $PrestationsTable,
                          Jeton
                        >(
                          currentTable: table,
                          referencedTable: $$PrestationsTableReferences
                              ._jetonsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PrestationsTableReferences(
                                db,
                                table,
                                p0,
                              ).jetonsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.prestationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PrestationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrestationsTable,
      Prestation,
      $$PrestationsTableFilterComposer,
      $$PrestationsTableOrderingComposer,
      $$PrestationsTableAnnotationComposer,
      $$PrestationsTableCreateCompanionBuilder,
      $$PrestationsTableUpdateCompanionBuilder,
      (Prestation, $$PrestationsTableReferences),
      Prestation,
      PrefetchHooks Function({
        bool clientId,
        bool vehiculeId,
        bool lignePrestationsRefs,
        bool jetonsRefs,
      })
    >;
typedef $$LignePrestationsTableCreateCompanionBuilder =
    LignePrestationsCompanion Function({
      required String id,
      Value<String> establishmentId,
      required String prestationId,
      required LigneType type,
      Value<String?> serviceId,
      Value<String?> produitId,
      required String libelle,
      Value<int> quantite,
      required double prixUnitaire,
      required double montantLigne,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$LignePrestationsTableUpdateCompanionBuilder =
    LignePrestationsCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String> prestationId,
      Value<LigneType> type,
      Value<String?> serviceId,
      Value<String?> produitId,
      Value<String> libelle,
      Value<int> quantite,
      Value<double> prixUnitaire,
      Value<double> montantLigne,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$LignePrestationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $LignePrestationsTable, LignePrestation> {
  $$LignePrestationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PrestationsTable _prestationIdTable(_$AppDatabase db) =>
      db.prestations.createAlias(
        $_aliasNameGenerator(
          db.lignePrestations.prestationId,
          db.prestations.id,
        ),
      );

  $$PrestationsTableProcessedTableManager get prestationId {
    final $_column = $_itemColumn<String>('prestation_id')!;

    final manager = $$PrestationsTableTableManager(
      $_db,
      $_db.prestations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prestationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CatalogServicesTable _serviceIdTable(_$AppDatabase db) =>
      db.catalogServices.createAlias(
        $_aliasNameGenerator(
          db.lignePrestations.serviceId,
          db.catalogServices.id,
        ),
      );

  $$CatalogServicesTableProcessedTableManager? get serviceId {
    final $_column = $_itemColumn<String>('service_id');
    if ($_column == null) return null;
    final manager = $$CatalogServicesTableTableManager(
      $_db,
      $_db.catalogServices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProduitsTable _produitIdTable(_$AppDatabase db) =>
      db.produits.createAlias(
        $_aliasNameGenerator(db.lignePrestations.produitId, db.produits.id),
      );

  $$ProduitsTableProcessedTableManager? get produitId {
    final $_column = $_itemColumn<String>('produit_id');
    if ($_column == null) return null;
    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LignePrestationsTableFilterComposer
    extends Composer<_$AppDatabase, $LignePrestationsTable> {
  $$LignePrestationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LigneType, LigneType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get libelle => $composableBuilder(
    column: $table.libelle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prixUnitaire => $composableBuilder(
    column: $table.prixUnitaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantLigne => $composableBuilder(
    column: $table.montantLigne,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$PrestationsTableFilterComposer get prestationId {
    final $$PrestationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prestationId,
      referencedTable: $db.prestations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrestationsTableFilterComposer(
            $db: $db,
            $table: $db.prestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CatalogServicesTableFilterComposer get serviceId {
    final $$CatalogServicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceId,
      referencedTable: $db.catalogServices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogServicesTableFilterComposer(
            $db: $db,
            $table: $db.catalogServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableFilterComposer get produitId {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LignePrestationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LignePrestationsTable> {
  $$LignePrestationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libelle => $composableBuilder(
    column: $table.libelle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prixUnitaire => $composableBuilder(
    column: $table.prixUnitaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantLigne => $composableBuilder(
    column: $table.montantLigne,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$PrestationsTableOrderingComposer get prestationId {
    final $$PrestationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prestationId,
      referencedTable: $db.prestations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrestationsTableOrderingComposer(
            $db: $db,
            $table: $db.prestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CatalogServicesTableOrderingComposer get serviceId {
    final $$CatalogServicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceId,
      referencedTable: $db.catalogServices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogServicesTableOrderingComposer(
            $db: $db,
            $table: $db.catalogServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableOrderingComposer get produitId {
    final $$ProduitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableOrderingComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LignePrestationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LignePrestationsTable> {
  $$LignePrestationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LigneType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get libelle =>
      $composableBuilder(column: $table.libelle, builder: (column) => column);

  GeneratedColumn<int> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<double> get prixUnitaire => $composableBuilder(
    column: $table.prixUnitaire,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montantLigne => $composableBuilder(
    column: $table.montantLigne,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$PrestationsTableAnnotationComposer get prestationId {
    final $$PrestationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prestationId,
      referencedTable: $db.prestations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrestationsTableAnnotationComposer(
            $db: $db,
            $table: $db.prestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CatalogServicesTableAnnotationComposer get serviceId {
    final $$CatalogServicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceId,
      referencedTable: $db.catalogServices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogServicesTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableAnnotationComposer get produitId {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LignePrestationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LignePrestationsTable,
          LignePrestation,
          $$LignePrestationsTableFilterComposer,
          $$LignePrestationsTableOrderingComposer,
          $$LignePrestationsTableAnnotationComposer,
          $$LignePrestationsTableCreateCompanionBuilder,
          $$LignePrestationsTableUpdateCompanionBuilder,
          (LignePrestation, $$LignePrestationsTableReferences),
          LignePrestation,
          PrefetchHooks Function({
            bool prestationId,
            bool serviceId,
            bool produitId,
          })
        > {
  $$LignePrestationsTableTableManager(
    _$AppDatabase db,
    $LignePrestationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LignePrestationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LignePrestationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LignePrestationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String> prestationId = const Value.absent(),
                Value<LigneType> type = const Value.absent(),
                Value<String?> serviceId = const Value.absent(),
                Value<String?> produitId = const Value.absent(),
                Value<String> libelle = const Value.absent(),
                Value<int> quantite = const Value.absent(),
                Value<double> prixUnitaire = const Value.absent(),
                Value<double> montantLigne = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LignePrestationsCompanion(
                id: id,
                establishmentId: establishmentId,
                prestationId: prestationId,
                type: type,
                serviceId: serviceId,
                produitId: produitId,
                libelle: libelle,
                quantite: quantite,
                prixUnitaire: prixUnitaire,
                montantLigne: montantLigne,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                required String prestationId,
                required LigneType type,
                Value<String?> serviceId = const Value.absent(),
                Value<String?> produitId = const Value.absent(),
                required String libelle,
                Value<int> quantite = const Value.absent(),
                required double prixUnitaire,
                required double montantLigne,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LignePrestationsCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                prestationId: prestationId,
                type: type,
                serviceId: serviceId,
                produitId: produitId,
                libelle: libelle,
                quantite: quantite,
                prixUnitaire: prixUnitaire,
                montantLigne: montantLigne,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LignePrestationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({prestationId = false, serviceId = false, produitId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (prestationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.prestationId,
                                    referencedTable:
                                        $$LignePrestationsTableReferences
                                            ._prestationIdTable(db),
                                    referencedColumn:
                                        $$LignePrestationsTableReferences
                                            ._prestationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (serviceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.serviceId,
                                    referencedTable:
                                        $$LignePrestationsTableReferences
                                            ._serviceIdTable(db),
                                    referencedColumn:
                                        $$LignePrestationsTableReferences
                                            ._serviceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (produitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.produitId,
                                    referencedTable:
                                        $$LignePrestationsTableReferences
                                            ._produitIdTable(db),
                                    referencedColumn:
                                        $$LignePrestationsTableReferences
                                            ._produitIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$LignePrestationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LignePrestationsTable,
      LignePrestation,
      $$LignePrestationsTableFilterComposer,
      $$LignePrestationsTableOrderingComposer,
      $$LignePrestationsTableAnnotationComposer,
      $$LignePrestationsTableCreateCompanionBuilder,
      $$LignePrestationsTableUpdateCompanionBuilder,
      (LignePrestation, $$LignePrestationsTableReferences),
      LignePrestation,
      PrefetchHooks Function({
        bool prestationId,
        bool serviceId,
        bool produitId,
      })
    >;
typedef $$JetonsTableCreateCompanionBuilder =
    JetonsCompanion Function({
      required String id,
      Value<String> establishmentId,
      required String prestationId,
      required String clientId,
      required JetonStatut statut,
      required DateTime dateEmission,
      Value<DateTime?> dateConsommation,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$JetonsTableUpdateCompanionBuilder =
    JetonsCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String> prestationId,
      Value<String> clientId,
      Value<JetonStatut> statut,
      Value<DateTime> dateEmission,
      Value<DateTime?> dateConsommation,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$JetonsTableReferences
    extends BaseReferences<_$AppDatabase, $JetonsTable, Jeton> {
  $$JetonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PrestationsTable _prestationIdTable(_$AppDatabase db) =>
      db.prestations.createAlias(
        $_aliasNameGenerator(db.jetons.prestationId, db.prestations.id),
      );

  $$PrestationsTableProcessedTableManager get prestationId {
    final $_column = $_itemColumn<String>('prestation_id')!;

    final manager = $$PrestationsTableTableManager(
      $_db,
      $_db.prestations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prestationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClientsTable _clientIdTable(_$AppDatabase db) => db.clients
      .createAlias($_aliasNameGenerator(db.jetons.clientId, db.clients.id));

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JetonsTableFilterComposer
    extends Composer<_$AppDatabase, $JetonsTable> {
  $$JetonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<JetonStatut, JetonStatut, String> get statut =>
      $composableBuilder(
        column: $table.statut,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get dateEmission => $composableBuilder(
    column: $table.dateEmission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateConsommation => $composableBuilder(
    column: $table.dateConsommation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$PrestationsTableFilterComposer get prestationId {
    final $$PrestationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prestationId,
      referencedTable: $db.prestations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrestationsTableFilterComposer(
            $db: $db,
            $table: $db.prestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JetonsTableOrderingComposer
    extends Composer<_$AppDatabase, $JetonsTable> {
  $$JetonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateEmission => $composableBuilder(
    column: $table.dateEmission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateConsommation => $composableBuilder(
    column: $table.dateConsommation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$PrestationsTableOrderingComposer get prestationId {
    final $$PrestationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prestationId,
      referencedTable: $db.prestations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrestationsTableOrderingComposer(
            $db: $db,
            $table: $db.prestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JetonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JetonsTable> {
  $$JetonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<JetonStatut, String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<DateTime> get dateEmission => $composableBuilder(
    column: $table.dateEmission,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateConsommation => $composableBuilder(
    column: $table.dateConsommation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$PrestationsTableAnnotationComposer get prestationId {
    final $$PrestationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prestationId,
      referencedTable: $db.prestations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrestationsTableAnnotationComposer(
            $db: $db,
            $table: $db.prestations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JetonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JetonsTable,
          Jeton,
          $$JetonsTableFilterComposer,
          $$JetonsTableOrderingComposer,
          $$JetonsTableAnnotationComposer,
          $$JetonsTableCreateCompanionBuilder,
          $$JetonsTableUpdateCompanionBuilder,
          (Jeton, $$JetonsTableReferences),
          Jeton,
          PrefetchHooks Function({bool prestationId, bool clientId})
        > {
  $$JetonsTableTableManager(_$AppDatabase db, $JetonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JetonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JetonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JetonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String> prestationId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<JetonStatut> statut = const Value.absent(),
                Value<DateTime> dateEmission = const Value.absent(),
                Value<DateTime?> dateConsommation = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JetonsCompanion(
                id: id,
                establishmentId: establishmentId,
                prestationId: prestationId,
                clientId: clientId,
                statut: statut,
                dateEmission: dateEmission,
                dateConsommation: dateConsommation,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                required String prestationId,
                required String clientId,
                required JetonStatut statut,
                required DateTime dateEmission,
                Value<DateTime?> dateConsommation = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JetonsCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                prestationId: prestationId,
                clientId: clientId,
                statut: statut,
                dateEmission: dateEmission,
                dateConsommation: dateConsommation,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$JetonsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({prestationId = false, clientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (prestationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.prestationId,
                                referencedTable: $$JetonsTableReferences
                                    ._prestationIdTable(db),
                                referencedColumn: $$JetonsTableReferences
                                    ._prestationIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (clientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.clientId,
                                referencedTable: $$JetonsTableReferences
                                    ._clientIdTable(db),
                                referencedColumn: $$JetonsTableReferences
                                    ._clientIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$JetonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JetonsTable,
      Jeton,
      $$JetonsTableFilterComposer,
      $$JetonsTableOrderingComposer,
      $$JetonsTableAnnotationComposer,
      $$JetonsTableCreateCompanionBuilder,
      $$JetonsTableUpdateCompanionBuilder,
      (Jeton, $$JetonsTableReferences),
      Jeton,
      PrefetchHooks Function({bool prestationId, bool clientId})
    >;
typedef $$AlertesEntretienTableCreateCompanionBuilder =
    AlertesEntretienCompanion Function({
      required String id,
      Value<String> establishmentId,
      required String vehiculeId,
      required String serviceId,
      required DateTime dateEcheance,
      required AlerteStatut statut,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$AlertesEntretienTableUpdateCompanionBuilder =
    AlertesEntretienCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String> vehiculeId,
      Value<String> serviceId,
      Value<DateTime> dateEcheance,
      Value<AlerteStatut> statut,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$AlertesEntretienTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AlertesEntretienTable,
          AlertesEntretienData
        > {
  $$AlertesEntretienTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiculesTable _vehiculeIdTable(_$AppDatabase db) =>
      db.vehicules.createAlias(
        $_aliasNameGenerator(db.alertesEntretien.vehiculeId, db.vehicules.id),
      );

  $$VehiculesTableProcessedTableManager get vehiculeId {
    final $_column = $_itemColumn<String>('vehicule_id')!;

    final manager = $$VehiculesTableTableManager(
      $_db,
      $_db.vehicules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehiculeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CatalogServicesTable _serviceIdTable(_$AppDatabase db) =>
      db.catalogServices.createAlias(
        $_aliasNameGenerator(
          db.alertesEntretien.serviceId,
          db.catalogServices.id,
        ),
      );

  $$CatalogServicesTableProcessedTableManager get serviceId {
    final $_column = $_itemColumn<String>('service_id')!;

    final manager = $$CatalogServicesTableTableManager(
      $_db,
      $_db.catalogServices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AlertesEntretienTableFilterComposer
    extends Composer<_$AppDatabase, $AlertesEntretienTable> {
  $$AlertesEntretienTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateEcheance => $composableBuilder(
    column: $table.dateEcheance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AlerteStatut, AlerteStatut, String>
  get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiculesTableFilterComposer get vehiculeId {
    final $$VehiculesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehiculeId,
      referencedTable: $db.vehicules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiculesTableFilterComposer(
            $db: $db,
            $table: $db.vehicules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CatalogServicesTableFilterComposer get serviceId {
    final $$CatalogServicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceId,
      referencedTable: $db.catalogServices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogServicesTableFilterComposer(
            $db: $db,
            $table: $db.catalogServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlertesEntretienTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertesEntretienTable> {
  $$AlertesEntretienTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateEcheance => $composableBuilder(
    column: $table.dateEcheance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiculesTableOrderingComposer get vehiculeId {
    final $$VehiculesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehiculeId,
      referencedTable: $db.vehicules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiculesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CatalogServicesTableOrderingComposer get serviceId {
    final $$CatalogServicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceId,
      referencedTable: $db.catalogServices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogServicesTableOrderingComposer(
            $db: $db,
            $table: $db.catalogServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlertesEntretienTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertesEntretienTable> {
  $$AlertesEntretienTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateEcheance => $composableBuilder(
    column: $table.dateEcheance,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AlerteStatut, String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$VehiculesTableAnnotationComposer get vehiculeId {
    final $$VehiculesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehiculeId,
      referencedTable: $db.vehicules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiculesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CatalogServicesTableAnnotationComposer get serviceId {
    final $$CatalogServicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceId,
      referencedTable: $db.catalogServices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogServicesTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlertesEntretienTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertesEntretienTable,
          AlertesEntretienData,
          $$AlertesEntretienTableFilterComposer,
          $$AlertesEntretienTableOrderingComposer,
          $$AlertesEntretienTableAnnotationComposer,
          $$AlertesEntretienTableCreateCompanionBuilder,
          $$AlertesEntretienTableUpdateCompanionBuilder,
          (AlertesEntretienData, $$AlertesEntretienTableReferences),
          AlertesEntretienData,
          PrefetchHooks Function({bool vehiculeId, bool serviceId})
        > {
  $$AlertesEntretienTableTableManager(
    _$AppDatabase db,
    $AlertesEntretienTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertesEntretienTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertesEntretienTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertesEntretienTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String> vehiculeId = const Value.absent(),
                Value<String> serviceId = const Value.absent(),
                Value<DateTime> dateEcheance = const Value.absent(),
                Value<AlerteStatut> statut = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertesEntretienCompanion(
                id: id,
                establishmentId: establishmentId,
                vehiculeId: vehiculeId,
                serviceId: serviceId,
                dateEcheance: dateEcheance,
                statut: statut,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                required String vehiculeId,
                required String serviceId,
                required DateTime dateEcheance,
                required AlerteStatut statut,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertesEntretienCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                vehiculeId: vehiculeId,
                serviceId: serviceId,
                dateEcheance: dateEcheance,
                statut: statut,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlertesEntretienTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehiculeId = false, serviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehiculeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehiculeId,
                                referencedTable:
                                    $$AlertesEntretienTableReferences
                                        ._vehiculeIdTable(db),
                                referencedColumn:
                                    $$AlertesEntretienTableReferences
                                        ._vehiculeIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (serviceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.serviceId,
                                referencedTable:
                                    $$AlertesEntretienTableReferences
                                        ._serviceIdTable(db),
                                referencedColumn:
                                    $$AlertesEntretienTableReferences
                                        ._serviceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AlertesEntretienTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertesEntretienTable,
      AlertesEntretienData,
      $$AlertesEntretienTableFilterComposer,
      $$AlertesEntretienTableOrderingComposer,
      $$AlertesEntretienTableAnnotationComposer,
      $$AlertesEntretienTableCreateCompanionBuilder,
      $$AlertesEntretienTableUpdateCompanionBuilder,
      (AlertesEntretienData, $$AlertesEntretienTableReferences),
      AlertesEntretienData,
      PrefetchHooks Function({bool vehiculeId, bool serviceId})
    >;
typedef $$NotificationQueueTableCreateCompanionBuilder =
    NotificationQueueCompanion Function({
      required String id,
      Value<String> establishmentId,
      required String clientId,
      required String telephone,
      required NotificationType type,
      Value<String> payload,
      required NotificationStatut statut,
      Value<String?> alerteEntretienId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$NotificationQueueTableUpdateCompanionBuilder =
    NotificationQueueCompanion Function({
      Value<String> id,
      Value<String> establishmentId,
      Value<String> clientId,
      Value<String> telephone,
      Value<NotificationType> type,
      Value<String> payload,
      Value<NotificationStatut> statut,
      Value<String?> alerteEntretienId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$NotificationQueueTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NotificationQueueTable,
          NotificationQueueData
        > {
  $$NotificationQueueTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClientsTable _clientIdTable(_$AppDatabase db) =>
      db.clients.createAlias(
        $_aliasNameGenerator(db.notificationQueue.clientId, db.clients.id),
      );

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotificationQueueTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationQueueTable> {
  $$NotificationQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NotificationType, NotificationType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NotificationStatut, NotificationStatut, String>
  get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get alerteEntretienId => $composableBuilder(
    column: $table.alerteEntretienId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationQueueTable> {
  $$NotificationQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alerteEntretienId => $composableBuilder(
    column: $table.alerteEntretienId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationQueueTable> {
  $$NotificationQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get establishmentId => $composableBuilder(
    column: $table.establishmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get telephone =>
      $composableBuilder(column: $table.telephone, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NotificationType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NotificationStatut, String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get alerteEntretienId => $composableBuilder(
    column: $table.alerteEntretienId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationQueueTable,
          NotificationQueueData,
          $$NotificationQueueTableFilterComposer,
          $$NotificationQueueTableOrderingComposer,
          $$NotificationQueueTableAnnotationComposer,
          $$NotificationQueueTableCreateCompanionBuilder,
          $$NotificationQueueTableUpdateCompanionBuilder,
          (NotificationQueueData, $$NotificationQueueTableReferences),
          NotificationQueueData,
          PrefetchHooks Function({bool clientId})
        > {
  $$NotificationQueueTableTableManager(
    _$AppDatabase db,
    $NotificationQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationQueueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> establishmentId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> telephone = const Value.absent(),
                Value<NotificationType> type = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<NotificationStatut> statut = const Value.absent(),
                Value<String?> alerteEntretienId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationQueueCompanion(
                id: id,
                establishmentId: establishmentId,
                clientId: clientId,
                telephone: telephone,
                type: type,
                payload: payload,
                statut: statut,
                alerteEntretienId: alerteEntretienId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> establishmentId = const Value.absent(),
                required String clientId,
                required String telephone,
                required NotificationType type,
                Value<String> payload = const Value.absent(),
                required NotificationStatut statut,
                Value<String?> alerteEntretienId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationQueueCompanion.insert(
                id: id,
                establishmentId: establishmentId,
                clientId: clientId,
                telephone: telephone,
                type: type,
                payload: payload,
                statut: statut,
                alerteEntretienId: alerteEntretienId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NotificationQueueTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.clientId,
                                referencedTable:
                                    $$NotificationQueueTableReferences
                                        ._clientIdTable(db),
                                referencedColumn:
                                    $$NotificationQueueTableReferences
                                        ._clientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotificationQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationQueueTable,
      NotificationQueueData,
      $$NotificationQueueTableFilterComposer,
      $$NotificationQueueTableOrderingComposer,
      $$NotificationQueueTableAnnotationComposer,
      $$NotificationQueueTableCreateCompanionBuilder,
      $$NotificationQueueTableUpdateCompanionBuilder,
      (NotificationQueueData, $$NotificationQueueTableReferences),
      NotificationQueueData,
      PrefetchHooks Function({bool clientId})
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String collection,
      required DateTime lastSyncAt,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> collection,
      Value<DateTime> lastSyncAt,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> collection = const Value.absent(),
                Value<DateTime> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                collection: collection,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String collection,
                required DateTime lastSyncAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                collection: collection,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$VehiculesTableTableManager get vehicules =>
      $$VehiculesTableTableManager(_db, _db.vehicules);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CatalogServicesTableTableManager get catalogServices =>
      $$CatalogServicesTableTableManager(_db, _db.catalogServices);
  $$ProductCategoriesTableTableManager get productCategories =>
      $$ProductCategoriesTableTableManager(_db, _db.productCategories);
  $$ProduitsTableTableManager get produits =>
      $$ProduitsTableTableManager(_db, _db.produits);
  $$PrestationsTableTableManager get prestations =>
      $$PrestationsTableTableManager(_db, _db.prestations);
  $$LignePrestationsTableTableManager get lignePrestations =>
      $$LignePrestationsTableTableManager(_db, _db.lignePrestations);
  $$JetonsTableTableManager get jetons =>
      $$JetonsTableTableManager(_db, _db.jetons);
  $$AlertesEntretienTableTableManager get alertesEntretien =>
      $$AlertesEntretienTableTableManager(_db, _db.alertesEntretien);
  $$NotificationQueueTableTableManager get notificationQueue =>
      $$NotificationQueueTableTableManager(_db, _db.notificationQueue);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
}
