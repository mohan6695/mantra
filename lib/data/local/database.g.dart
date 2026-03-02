// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MantraConfigTableTable extends MantraConfigTable
    with TableInfo<$MantraConfigTableTable, MantraConfigTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MantraConfigTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _devanagariMeta = const VerificationMeta(
    'devanagari',
  );
  @override
  late final GeneratedColumn<String> devanagari = GeneratedColumn<String>(
    'devanagari',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _romanizedMeta = const VerificationMeta(
    'romanized',
  );
  @override
  late final GeneratedColumn<String> romanized = GeneratedColumn<String>(
    'romanized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(108),
  );
  static const VerificationMeta _sensitivityMeta = const VerificationMeta(
    'sensitivity',
  );
  @override
  late final GeneratedColumn<double> sensitivity = GeneratedColumn<double>(
    'sensitivity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.82),
  );
  static const VerificationMeta _refractoryMsMeta = const VerificationMeta(
    'refractoryMs',
  );
  @override
  late final GeneratedColumn<int> refractoryMs = GeneratedColumn<int>(
    'refractory_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(800),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    devanagari,
    romanized,
    targetCount,
    sensitivity,
    refractoryMs,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mantra_config_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MantraConfigTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('devanagari')) {
      context.handle(
        _devanagariMeta,
        devanagari.isAcceptableOrUnknown(data['devanagari']!, _devanagariMeta),
      );
    } else if (isInserting) {
      context.missing(_devanagariMeta);
    }
    if (data.containsKey('romanized')) {
      context.handle(
        _romanizedMeta,
        romanized.isAcceptableOrUnknown(data['romanized']!, _romanizedMeta),
      );
    } else if (isInserting) {
      context.missing(_romanizedMeta);
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    }
    if (data.containsKey('sensitivity')) {
      context.handle(
        _sensitivityMeta,
        sensitivity.isAcceptableOrUnknown(
          data['sensitivity']!,
          _sensitivityMeta,
        ),
      );
    }
    if (data.containsKey('refractory_ms')) {
      context.handle(
        _refractoryMsMeta,
        refractoryMs.isAcceptableOrUnknown(
          data['refractory_ms']!,
          _refractoryMsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MantraConfigTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MantraConfigTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      devanagari: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}devanagari'],
      )!,
      romanized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}romanized'],
      )!,
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      sensitivity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sensitivity'],
      )!,
      refractoryMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refractory_ms'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $MantraConfigTableTable createAlias(String alias) {
    return $MantraConfigTableTable(attachedDatabase, alias);
  }
}

class MantraConfigTableData extends DataClass
    implements Insertable<MantraConfigTableData> {
  final int id;
  final String name;
  final String devanagari;
  final String romanized;
  final int targetCount;
  final double sensitivity;
  final int refractoryMs;
  final bool isActive;
  final int sortOrder;
  const MantraConfigTableData({
    required this.id,
    required this.name,
    required this.devanagari,
    required this.romanized,
    required this.targetCount,
    required this.sensitivity,
    required this.refractoryMs,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['devanagari'] = Variable<String>(devanagari);
    map['romanized'] = Variable<String>(romanized);
    map['target_count'] = Variable<int>(targetCount);
    map['sensitivity'] = Variable<double>(sensitivity);
    map['refractory_ms'] = Variable<int>(refractoryMs);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MantraConfigTableCompanion toCompanion(bool nullToAbsent) {
    return MantraConfigTableCompanion(
      id: Value(id),
      name: Value(name),
      devanagari: Value(devanagari),
      romanized: Value(romanized),
      targetCount: Value(targetCount),
      sensitivity: Value(sensitivity),
      refractoryMs: Value(refractoryMs),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory MantraConfigTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MantraConfigTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      devanagari: serializer.fromJson<String>(json['devanagari']),
      romanized: serializer.fromJson<String>(json['romanized']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      sensitivity: serializer.fromJson<double>(json['sensitivity']),
      refractoryMs: serializer.fromJson<int>(json['refractoryMs']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'devanagari': serializer.toJson<String>(devanagari),
      'romanized': serializer.toJson<String>(romanized),
      'targetCount': serializer.toJson<int>(targetCount),
      'sensitivity': serializer.toJson<double>(sensitivity),
      'refractoryMs': serializer.toJson<int>(refractoryMs),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MantraConfigTableData copyWith({
    int? id,
    String? name,
    String? devanagari,
    String? romanized,
    int? targetCount,
    double? sensitivity,
    int? refractoryMs,
    bool? isActive,
    int? sortOrder,
  }) => MantraConfigTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    devanagari: devanagari ?? this.devanagari,
    romanized: romanized ?? this.romanized,
    targetCount: targetCount ?? this.targetCount,
    sensitivity: sensitivity ?? this.sensitivity,
    refractoryMs: refractoryMs ?? this.refractoryMs,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  MantraConfigTableData copyWithCompanion(MantraConfigTableCompanion data) {
    return MantraConfigTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      devanagari: data.devanagari.present
          ? data.devanagari.value
          : this.devanagari,
      romanized: data.romanized.present ? data.romanized.value : this.romanized,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      sensitivity: data.sensitivity.present
          ? data.sensitivity.value
          : this.sensitivity,
      refractoryMs: data.refractoryMs.present
          ? data.refractoryMs.value
          : this.refractoryMs,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MantraConfigTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('devanagari: $devanagari, ')
          ..write('romanized: $romanized, ')
          ..write('targetCount: $targetCount, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('refractoryMs: $refractoryMs, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    devanagari,
    romanized,
    targetCount,
    sensitivity,
    refractoryMs,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MantraConfigTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.devanagari == this.devanagari &&
          other.romanized == this.romanized &&
          other.targetCount == this.targetCount &&
          other.sensitivity == this.sensitivity &&
          other.refractoryMs == this.refractoryMs &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class MantraConfigTableCompanion
    extends UpdateCompanion<MantraConfigTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> devanagari;
  final Value<String> romanized;
  final Value<int> targetCount;
  final Value<double> sensitivity;
  final Value<int> refractoryMs;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  const MantraConfigTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.devanagari = const Value.absent(),
    this.romanized = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.sensitivity = const Value.absent(),
    this.refractoryMs = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  MantraConfigTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String devanagari,
    required String romanized,
    this.targetCount = const Value.absent(),
    this.sensitivity = const Value.absent(),
    this.refractoryMs = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       devanagari = Value(devanagari),
       romanized = Value(romanized);
  static Insertable<MantraConfigTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? devanagari,
    Expression<String>? romanized,
    Expression<int>? targetCount,
    Expression<double>? sensitivity,
    Expression<int>? refractoryMs,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (devanagari != null) 'devanagari': devanagari,
      if (romanized != null) 'romanized': romanized,
      if (targetCount != null) 'target_count': targetCount,
      if (sensitivity != null) 'sensitivity': sensitivity,
      if (refractoryMs != null) 'refractory_ms': refractoryMs,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  MantraConfigTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? devanagari,
    Value<String>? romanized,
    Value<int>? targetCount,
    Value<double>? sensitivity,
    Value<int>? refractoryMs,
    Value<bool>? isActive,
    Value<int>? sortOrder,
  }) {
    return MantraConfigTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      devanagari: devanagari ?? this.devanagari,
      romanized: romanized ?? this.romanized,
      targetCount: targetCount ?? this.targetCount,
      sensitivity: sensitivity ?? this.sensitivity,
      refractoryMs: refractoryMs ?? this.refractoryMs,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (devanagari.present) {
      map['devanagari'] = Variable<String>(devanagari.value);
    }
    if (romanized.present) {
      map['romanized'] = Variable<String>(romanized.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (sensitivity.present) {
      map['sensitivity'] = Variable<double>(sensitivity.value);
    }
    if (refractoryMs.present) {
      map['refractory_ms'] = Variable<int>(refractoryMs.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MantraConfigTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('devanagari: $devanagari, ')
          ..write('romanized: $romanized, ')
          ..write('targetCount: $targetCount, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('refractoryMs: $refractoryMs, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $SessionsTableTable extends SessionsTable
    with TableInfo<$SessionsTableTable, SessionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mantraIdMeta = const VerificationMeta(
    'mantraId',
  );
  @override
  late final GeneratedColumn<int> mantraId = GeneratedColumn<int>(
    'mantra_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mantra_config_table (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievedCountMeta = const VerificationMeta(
    'achievedCount',
  );
  @override
  late final GeneratedColumn<int> achievedCount = GeneratedColumn<int>(
    'achieved_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mantraId,
    startedAt,
    endedAt,
    targetCount,
    achievedCount,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mantra_id')) {
      context.handle(
        _mantraIdMeta,
        mantraId.isAcceptableOrUnknown(data['mantra_id']!, _mantraIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mantraIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCountMeta);
    }
    if (data.containsKey('achieved_count')) {
      context.handle(
        _achievedCountMeta,
        achievedCount.isAcceptableOrUnknown(
          data['achieved_count']!,
          _achievedCountMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mantraId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mantra_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      achievedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achieved_count'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $SessionsTableTable createAlias(String alias) {
    return $SessionsTableTable(attachedDatabase, alias);
  }
}

class SessionsTableData extends DataClass
    implements Insertable<SessionsTableData> {
  final String id;
  final int mantraId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int targetCount;
  final int achievedCount;
  final bool isSynced;
  const SessionsTableData({
    required this.id,
    required this.mantraId,
    required this.startedAt,
    this.endedAt,
    required this.targetCount,
    required this.achievedCount,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mantra_id'] = Variable<int>(mantraId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['target_count'] = Variable<int>(targetCount);
    map['achieved_count'] = Variable<int>(achievedCount);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  SessionsTableCompanion toCompanion(bool nullToAbsent) {
    return SessionsTableCompanion(
      id: Value(id),
      mantraId: Value(mantraId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      targetCount: Value(targetCount),
      achievedCount: Value(achievedCount),
      isSynced: Value(isSynced),
    );
  }

  factory SessionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionsTableData(
      id: serializer.fromJson<String>(json['id']),
      mantraId: serializer.fromJson<int>(json['mantraId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      achievedCount: serializer.fromJson<int>(json['achievedCount']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mantraId': serializer.toJson<int>(mantraId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'targetCount': serializer.toJson<int>(targetCount),
      'achievedCount': serializer.toJson<int>(achievedCount),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  SessionsTableData copyWith({
    String? id,
    int? mantraId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? targetCount,
    int? achievedCount,
    bool? isSynced,
  }) => SessionsTableData(
    id: id ?? this.id,
    mantraId: mantraId ?? this.mantraId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    targetCount: targetCount ?? this.targetCount,
    achievedCount: achievedCount ?? this.achievedCount,
    isSynced: isSynced ?? this.isSynced,
  );
  SessionsTableData copyWithCompanion(SessionsTableCompanion data) {
    return SessionsTableData(
      id: data.id.present ? data.id.value : this.id,
      mantraId: data.mantraId.present ? data.mantraId.value : this.mantraId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      achievedCount: data.achievedCount.present
          ? data.achievedCount.value
          : this.achievedCount,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionsTableData(')
          ..write('id: $id, ')
          ..write('mantraId: $mantraId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('targetCount: $targetCount, ')
          ..write('achievedCount: $achievedCount, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mantraId,
    startedAt,
    endedAt,
    targetCount,
    achievedCount,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionsTableData &&
          other.id == this.id &&
          other.mantraId == this.mantraId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.targetCount == this.targetCount &&
          other.achievedCount == this.achievedCount &&
          other.isSynced == this.isSynced);
}

class SessionsTableCompanion extends UpdateCompanion<SessionsTableData> {
  final Value<String> id;
  final Value<int> mantraId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> targetCount;
  final Value<int> achievedCount;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const SessionsTableCompanion({
    this.id = const Value.absent(),
    this.mantraId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.achievedCount = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsTableCompanion.insert({
    required String id,
    required int mantraId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required int targetCount,
    this.achievedCount = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mantraId = Value(mantraId),
       startedAt = Value(startedAt),
       targetCount = Value(targetCount);
  static Insertable<SessionsTableData> custom({
    Expression<String>? id,
    Expression<int>? mantraId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? targetCount,
    Expression<int>? achievedCount,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mantraId != null) 'mantra_id': mantraId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (targetCount != null) 'target_count': targetCount,
      if (achievedCount != null) 'achieved_count': achievedCount,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsTableCompanion copyWith({
    Value<String>? id,
    Value<int>? mantraId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? targetCount,
    Value<int>? achievedCount,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return SessionsTableCompanion(
      id: id ?? this.id,
      mantraId: mantraId ?? this.mantraId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      targetCount: targetCount ?? this.targetCount,
      achievedCount: achievedCount ?? this.achievedCount,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mantraId.present) {
      map['mantra_id'] = Variable<int>(mantraId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (achievedCount.present) {
      map['achieved_count'] = Variable<int>(achievedCount.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('mantraId: $mantraId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('targetCount: $targetCount, ')
          ..write('achievedCount: $achievedCount, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DetectionsTableTable extends DetectionsTable
    with TableInfo<$DetectionsTableTable, DetectionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetectionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions_table (id)',
    ),
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineMeta = const VerificationMeta('engine');
  @override
  late final GeneratedColumn<String> engine = GeneratedColumn<String>(
    'engine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tflite'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    detectedAt,
    confidence,
    engine,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detections_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DetectionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('engine')) {
      context.handle(
        _engineMeta,
        engine.isAcceptableOrUnknown(data['engine']!, _engineMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetectionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetectionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      engine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine'],
      )!,
    );
  }

  @override
  $DetectionsTableTable createAlias(String alias) {
    return $DetectionsTableTable(attachedDatabase, alias);
  }
}

class DetectionsTableData extends DataClass
    implements Insertable<DetectionsTableData> {
  final int id;
  final String sessionId;
  final DateTime detectedAt;
  final double confidence;
  final String engine;
  const DetectionsTableData({
    required this.id,
    required this.sessionId,
    required this.detectedAt,
    required this.confidence,
    required this.engine,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['detected_at'] = Variable<DateTime>(detectedAt);
    map['confidence'] = Variable<double>(confidence);
    map['engine'] = Variable<String>(engine);
    return map;
  }

  DetectionsTableCompanion toCompanion(bool nullToAbsent) {
    return DetectionsTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      detectedAt: Value(detectedAt),
      confidence: Value(confidence),
      engine: Value(engine),
    );
  }

  factory DetectionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetectionsTableData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      confidence: serializer.fromJson<double>(json['confidence']),
      engine: serializer.fromJson<String>(json['engine']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'confidence': serializer.toJson<double>(confidence),
      'engine': serializer.toJson<String>(engine),
    };
  }

  DetectionsTableData copyWith({
    int? id,
    String? sessionId,
    DateTime? detectedAt,
    double? confidence,
    String? engine,
  }) => DetectionsTableData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    detectedAt: detectedAt ?? this.detectedAt,
    confidence: confidence ?? this.confidence,
    engine: engine ?? this.engine,
  );
  DetectionsTableData copyWithCompanion(DetectionsTableCompanion data) {
    return DetectionsTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      engine: data.engine.present ? data.engine.value : this.engine,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetectionsTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('confidence: $confidence, ')
          ..write('engine: $engine')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, detectedAt, confidence, engine);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetectionsTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.detectedAt == this.detectedAt &&
          other.confidence == this.confidence &&
          other.engine == this.engine);
}

class DetectionsTableCompanion extends UpdateCompanion<DetectionsTableData> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<DateTime> detectedAt;
  final Value<double> confidence;
  final Value<String> engine;
  const DetectionsTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.confidence = const Value.absent(),
    this.engine = const Value.absent(),
  });
  DetectionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required DateTime detectedAt,
    required double confidence,
    this.engine = const Value.absent(),
  }) : sessionId = Value(sessionId),
       detectedAt = Value(detectedAt),
       confidence = Value(confidence);
  static Insertable<DetectionsTableData> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<DateTime>? detectedAt,
    Expression<double>? confidence,
    Expression<String>? engine,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (confidence != null) 'confidence': confidence,
      if (engine != null) 'engine': engine,
    });
  }

  DetectionsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<DateTime>? detectedAt,
    Value<double>? confidence,
    Value<String>? engine,
  }) {
    return DetectionsTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      detectedAt: detectedAt ?? this.detectedAt,
      confidence: confidence ?? this.confidence,
      engine: engine ?? this.engine,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (engine.present) {
      map['engine'] = Variable<String>(engine.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetectionsTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('confidence: $confidence, ')
          ..write('engine: $engine')
          ..write(')'))
        .toString();
  }
}

class $DailyStatsTableTable extends DailyStatsTable
    with TableInfo<$DailyStatsTableTable, DailyStatsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStatsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mantraIdMeta = const VerificationMeta(
    'mantraId',
  );
  @override
  late final GeneratedColumn<int> mantraId = GeneratedColumn<int>(
    'mantra_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mantra_config_table (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sessionsCountMeta = const VerificationMeta(
    'sessionsCount',
  );
  @override
  late final GeneratedColumn<int> sessionsCount = GeneratedColumn<int>(
    'sessions_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakDaysMeta = const VerificationMeta(
    'streakDays',
  );
  @override
  late final GeneratedColumn<int> streakDays = GeneratedColumn<int>(
    'streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    mantraId,
    date,
    totalCount,
    sessionsCount,
    streakDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_stats_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyStatsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mantra_id')) {
      context.handle(
        _mantraIdMeta,
        mantraId.isAcceptableOrUnknown(data['mantra_id']!, _mantraIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mantraIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    }
    if (data.containsKey('sessions_count')) {
      context.handle(
        _sessionsCountMeta,
        sessionsCount.isAcceptableOrUnknown(
          data['sessions_count']!,
          _sessionsCountMeta,
        ),
      );
    }
    if (data.containsKey('streak_days')) {
      context.handle(
        _streakDaysMeta,
        streakDays.isAcceptableOrUnknown(data['streak_days']!, _streakDaysMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mantraId, date};
  @override
  DailyStatsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStatsTableData(
      mantraId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mantra_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
      sessionsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessions_count'],
      )!,
      streakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_days'],
      )!,
    );
  }

  @override
  $DailyStatsTableTable createAlias(String alias) {
    return $DailyStatsTableTable(attachedDatabase, alias);
  }
}

class DailyStatsTableData extends DataClass
    implements Insertable<DailyStatsTableData> {
  final int mantraId;
  final String date;
  final int totalCount;
  final int sessionsCount;
  final int streakDays;
  const DailyStatsTableData({
    required this.mantraId,
    required this.date,
    required this.totalCount,
    required this.sessionsCount,
    required this.streakDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mantra_id'] = Variable<int>(mantraId);
    map['date'] = Variable<String>(date);
    map['total_count'] = Variable<int>(totalCount);
    map['sessions_count'] = Variable<int>(sessionsCount);
    map['streak_days'] = Variable<int>(streakDays);
    return map;
  }

  DailyStatsTableCompanion toCompanion(bool nullToAbsent) {
    return DailyStatsTableCompanion(
      mantraId: Value(mantraId),
      date: Value(date),
      totalCount: Value(totalCount),
      sessionsCount: Value(sessionsCount),
      streakDays: Value(streakDays),
    );
  }

  factory DailyStatsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStatsTableData(
      mantraId: serializer.fromJson<int>(json['mantraId']),
      date: serializer.fromJson<String>(json['date']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
      sessionsCount: serializer.fromJson<int>(json['sessionsCount']),
      streakDays: serializer.fromJson<int>(json['streakDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mantraId': serializer.toJson<int>(mantraId),
      'date': serializer.toJson<String>(date),
      'totalCount': serializer.toJson<int>(totalCount),
      'sessionsCount': serializer.toJson<int>(sessionsCount),
      'streakDays': serializer.toJson<int>(streakDays),
    };
  }

  DailyStatsTableData copyWith({
    int? mantraId,
    String? date,
    int? totalCount,
    int? sessionsCount,
    int? streakDays,
  }) => DailyStatsTableData(
    mantraId: mantraId ?? this.mantraId,
    date: date ?? this.date,
    totalCount: totalCount ?? this.totalCount,
    sessionsCount: sessionsCount ?? this.sessionsCount,
    streakDays: streakDays ?? this.streakDays,
  );
  DailyStatsTableData copyWithCompanion(DailyStatsTableCompanion data) {
    return DailyStatsTableData(
      mantraId: data.mantraId.present ? data.mantraId.value : this.mantraId,
      date: data.date.present ? data.date.value : this.date,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      sessionsCount: data.sessionsCount.present
          ? data.sessionsCount.value
          : this.sessionsCount,
      streakDays: data.streakDays.present
          ? data.streakDays.value
          : this.streakDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatsTableData(')
          ..write('mantraId: $mantraId, ')
          ..write('date: $date, ')
          ..write('totalCount: $totalCount, ')
          ..write('sessionsCount: $sessionsCount, ')
          ..write('streakDays: $streakDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(mantraId, date, totalCount, sessionsCount, streakDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStatsTableData &&
          other.mantraId == this.mantraId &&
          other.date == this.date &&
          other.totalCount == this.totalCount &&
          other.sessionsCount == this.sessionsCount &&
          other.streakDays == this.streakDays);
}

class DailyStatsTableCompanion extends UpdateCompanion<DailyStatsTableData> {
  final Value<int> mantraId;
  final Value<String> date;
  final Value<int> totalCount;
  final Value<int> sessionsCount;
  final Value<int> streakDays;
  final Value<int> rowid;
  const DailyStatsTableCompanion({
    this.mantraId = const Value.absent(),
    this.date = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.sessionsCount = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyStatsTableCompanion.insert({
    required int mantraId,
    required String date,
    this.totalCount = const Value.absent(),
    this.sessionsCount = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : mantraId = Value(mantraId),
       date = Value(date);
  static Insertable<DailyStatsTableData> custom({
    Expression<int>? mantraId,
    Expression<String>? date,
    Expression<int>? totalCount,
    Expression<int>? sessionsCount,
    Expression<int>? streakDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mantraId != null) 'mantra_id': mantraId,
      if (date != null) 'date': date,
      if (totalCount != null) 'total_count': totalCount,
      if (sessionsCount != null) 'sessions_count': sessionsCount,
      if (streakDays != null) 'streak_days': streakDays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyStatsTableCompanion copyWith({
    Value<int>? mantraId,
    Value<String>? date,
    Value<int>? totalCount,
    Value<int>? sessionsCount,
    Value<int>? streakDays,
    Value<int>? rowid,
  }) {
    return DailyStatsTableCompanion(
      mantraId: mantraId ?? this.mantraId,
      date: date ?? this.date,
      totalCount: totalCount ?? this.totalCount,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      streakDays: streakDays ?? this.streakDays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mantraId.present) {
      map['mantra_id'] = Variable<int>(mantraId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (sessionsCount.present) {
      map['sessions_count'] = Variable<int>(sessionsCount.value);
    }
    if (streakDays.present) {
      map['streak_days'] = Variable<int>(streakDays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatsTableCompanion(')
          ..write('mantraId: $mantraId, ')
          ..write('date: $date, ')
          ..write('totalCount: $totalCount, ')
          ..write('sessionsCount: $sessionsCount, ')
          ..write('streakDays: $streakDays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingSyncsTableTable extends PendingSyncsTable
    with TableInfo<$PendingSyncsTableTable, PendingSyncsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSyncsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    payload,
    createdAt,
    retryCount,
    lastAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_syncs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingSyncsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSyncsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSyncsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
    );
  }

  @override
  $PendingSyncsTableTable createAlias(String alias) {
    return $PendingSyncsTableTable(attachedDatabase, alias);
  }
}

class PendingSyncsTableData extends DataClass
    implements Insertable<PendingSyncsTableData> {
  final int id;
  final String sessionId;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttemptAt;
  const PendingSyncsTableData({
    required this.id,
    required this.sessionId,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
    this.lastAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    return map;
  }

  PendingSyncsTableCompanion toCompanion(bool nullToAbsent) {
    return PendingSyncsTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
    );
  }

  factory PendingSyncsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSyncsTableData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
    };
  }

  PendingSyncsTableData copyWith({
    int? id,
    String? sessionId,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
  }) => PendingSyncsTableData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
  );
  PendingSyncsTableData copyWithCompanion(PendingSyncsTableCompanion data) {
    return PendingSyncsTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncsTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, payload, createdAt, retryCount, lastAttemptAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSyncsTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastAttemptAt == this.lastAttemptAt);
}

class PendingSyncsTableCompanion
    extends UpdateCompanion<PendingSyncsTableData> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<DateTime?> lastAttemptAt;
  const PendingSyncsTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
  });
  PendingSyncsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required String payload,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
  }) : sessionId = Value(sessionId),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<PendingSyncsTableData> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<DateTime>? lastAttemptAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
    });
  }

  PendingSyncsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
    Value<DateTime?>? lastAttemptAt,
  }) {
    return PendingSyncsTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncsTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MantraConfigTableTable mantraConfigTable =
      $MantraConfigTableTable(this);
  late final $SessionsTableTable sessionsTable = $SessionsTableTable(this);
  late final $DetectionsTableTable detectionsTable = $DetectionsTableTable(
    this,
  );
  late final $DailyStatsTableTable dailyStatsTable = $DailyStatsTableTable(
    this,
  );
  late final $PendingSyncsTableTable pendingSyncsTable =
      $PendingSyncsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mantraConfigTable,
    sessionsTable,
    detectionsTable,
    dailyStatsTable,
    pendingSyncsTable,
  ];
}

typedef $$MantraConfigTableTableCreateCompanionBuilder =
    MantraConfigTableCompanion Function({
      Value<int> id,
      required String name,
      required String devanagari,
      required String romanized,
      Value<int> targetCount,
      Value<double> sensitivity,
      Value<int> refractoryMs,
      Value<bool> isActive,
      Value<int> sortOrder,
    });
typedef $$MantraConfigTableTableUpdateCompanionBuilder =
    MantraConfigTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> devanagari,
      Value<String> romanized,
      Value<int> targetCount,
      Value<double> sensitivity,
      Value<int> refractoryMs,
      Value<bool> isActive,
      Value<int> sortOrder,
    });

final class $$MantraConfigTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MantraConfigTableTable,
          MantraConfigTableData
        > {
  $$MantraConfigTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SessionsTableTable, List<SessionsTableData>>
  _sessionsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionsTable,
    aliasName: $_aliasNameGenerator(
      db.mantraConfigTable.id,
      db.sessionsTable.mantraId,
    ),
  );

  $$SessionsTableTableProcessedTableManager get sessionsTableRefs {
    final manager = $$SessionsTableTableTableManager(
      $_db,
      $_db.sessionsTable,
    ).filter((f) => f.mantraId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DailyStatsTableTable, List<DailyStatsTableData>>
  _dailyStatsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyStatsTable,
    aliasName: $_aliasNameGenerator(
      db.mantraConfigTable.id,
      db.dailyStatsTable.mantraId,
    ),
  );

  $$DailyStatsTableTableProcessedTableManager get dailyStatsTableRefs {
    final manager = $$DailyStatsTableTableTableManager(
      $_db,
      $_db.dailyStatsTable,
    ).filter((f) => f.mantraId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dailyStatsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MantraConfigTableTableFilterComposer
    extends Composer<_$AppDatabase, $MantraConfigTableTable> {
  $$MantraConfigTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get devanagari => $composableBuilder(
    column: $table.devanagari,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get romanized => $composableBuilder(
    column: $table.romanized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sensitivity => $composableBuilder(
    column: $table.sensitivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refractoryMs => $composableBuilder(
    column: $table.refractoryMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsTableRefs(
    Expression<bool> Function($$SessionsTableTableFilterComposer f) f,
  ) {
    final $$SessionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.mantraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableFilterComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyStatsTableRefs(
    Expression<bool> Function($$DailyStatsTableTableFilterComposer f) f,
  ) {
    final $$DailyStatsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyStatsTable,
      getReferencedColumn: (t) => t.mantraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyStatsTableTableFilterComposer(
            $db: $db,
            $table: $db.dailyStatsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MantraConfigTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MantraConfigTableTable> {
  $$MantraConfigTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get devanagari => $composableBuilder(
    column: $table.devanagari,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get romanized => $composableBuilder(
    column: $table.romanized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sensitivity => $composableBuilder(
    column: $table.sensitivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refractoryMs => $composableBuilder(
    column: $table.refractoryMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MantraConfigTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MantraConfigTableTable> {
  $$MantraConfigTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get devanagari => $composableBuilder(
    column: $table.devanagari,
    builder: (column) => column,
  );

  GeneratedColumn<String> get romanized =>
      $composableBuilder(column: $table.romanized, builder: (column) => column);

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sensitivity => $composableBuilder(
    column: $table.sensitivity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refractoryMs => $composableBuilder(
    column: $table.refractoryMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> sessionsTableRefs<T extends Object>(
    Expression<T> Function($$SessionsTableTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.mantraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailyStatsTableRefs<T extends Object>(
    Expression<T> Function($$DailyStatsTableTableAnnotationComposer a) f,
  ) {
    final $$DailyStatsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyStatsTable,
      getReferencedColumn: (t) => t.mantraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyStatsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyStatsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MantraConfigTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MantraConfigTableTable,
          MantraConfigTableData,
          $$MantraConfigTableTableFilterComposer,
          $$MantraConfigTableTableOrderingComposer,
          $$MantraConfigTableTableAnnotationComposer,
          $$MantraConfigTableTableCreateCompanionBuilder,
          $$MantraConfigTableTableUpdateCompanionBuilder,
          (MantraConfigTableData, $$MantraConfigTableTableReferences),
          MantraConfigTableData,
          PrefetchHooks Function({
            bool sessionsTableRefs,
            bool dailyStatsTableRefs,
          })
        > {
  $$MantraConfigTableTableTableManager(
    _$AppDatabase db,
    $MantraConfigTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MantraConfigTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MantraConfigTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MantraConfigTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> devanagari = const Value.absent(),
                Value<String> romanized = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<double> sensitivity = const Value.absent(),
                Value<int> refractoryMs = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => MantraConfigTableCompanion(
                id: id,
                name: name,
                devanagari: devanagari,
                romanized: romanized,
                targetCount: targetCount,
                sensitivity: sensitivity,
                refractoryMs: refractoryMs,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String devanagari,
                required String romanized,
                Value<int> targetCount = const Value.absent(),
                Value<double> sensitivity = const Value.absent(),
                Value<int> refractoryMs = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => MantraConfigTableCompanion.insert(
                id: id,
                name: name,
                devanagari: devanagari,
                romanized: romanized,
                targetCount: targetCount,
                sensitivity: sensitivity,
                refractoryMs: refractoryMs,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MantraConfigTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionsTableRefs = false, dailyStatsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionsTableRefs) db.sessionsTable,
                    if (dailyStatsTableRefs) db.dailyStatsTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionsTableRefs)
                        await $_getPrefetchedData<
                          MantraConfigTableData,
                          $MantraConfigTableTable,
                          SessionsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$MantraConfigTableTableReferences
                              ._sessionsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MantraConfigTableTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mantraId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailyStatsTableRefs)
                        await $_getPrefetchedData<
                          MantraConfigTableData,
                          $MantraConfigTableTable,
                          DailyStatsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$MantraConfigTableTableReferences
                              ._dailyStatsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MantraConfigTableTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyStatsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mantraId == item.id,
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

typedef $$MantraConfigTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MantraConfigTableTable,
      MantraConfigTableData,
      $$MantraConfigTableTableFilterComposer,
      $$MantraConfigTableTableOrderingComposer,
      $$MantraConfigTableTableAnnotationComposer,
      $$MantraConfigTableTableCreateCompanionBuilder,
      $$MantraConfigTableTableUpdateCompanionBuilder,
      (MantraConfigTableData, $$MantraConfigTableTableReferences),
      MantraConfigTableData,
      PrefetchHooks Function({bool sessionsTableRefs, bool dailyStatsTableRefs})
    >;
typedef $$SessionsTableTableCreateCompanionBuilder =
    SessionsTableCompanion Function({
      required String id,
      required int mantraId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required int targetCount,
      Value<int> achievedCount,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$SessionsTableTableUpdateCompanionBuilder =
    SessionsTableCompanion Function({
      Value<String> id,
      Value<int> mantraId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> targetCount,
      Value<int> achievedCount,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$SessionsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $SessionsTableTable, SessionsTableData> {
  $$SessionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MantraConfigTableTable _mantraIdTable(_$AppDatabase db) =>
      db.mantraConfigTable.createAlias(
        $_aliasNameGenerator(
          db.sessionsTable.mantraId,
          db.mantraConfigTable.id,
        ),
      );

  $$MantraConfigTableTableProcessedTableManager get mantraId {
    final $_column = $_itemColumn<int>('mantra_id')!;

    final manager = $$MantraConfigTableTableTableManager(
      $_db,
      $_db.mantraConfigTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mantraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DetectionsTableTable, List<DetectionsTableData>>
  _detectionsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detectionsTable,
    aliasName: $_aliasNameGenerator(
      db.sessionsTable.id,
      db.detectionsTable.sessionId,
    ),
  );

  $$DetectionsTableTableProcessedTableManager get detectionsTableRefs {
    final manager = $$DetectionsTableTableTableManager(
      $_db,
      $_db.detectionsTable,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _detectionsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTableTable> {
  $$SessionsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get achievedCount => $composableBuilder(
    column: $table.achievedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$MantraConfigTableTableFilterComposer get mantraId {
    final $$MantraConfigTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mantraId,
      referencedTable: $db.mantraConfigTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MantraConfigTableTableFilterComposer(
            $db: $db,
            $table: $db.mantraConfigTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> detectionsTableRefs(
    Expression<bool> Function($$DetectionsTableTableFilterComposer f) f,
  ) {
    final $$DetectionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detectionsTable,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetectionsTableTableFilterComposer(
            $db: $db,
            $table: $db.detectionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTableTable> {
  $$SessionsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get achievedCount => $composableBuilder(
    column: $table.achievedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$MantraConfigTableTableOrderingComposer get mantraId {
    final $$MantraConfigTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mantraId,
      referencedTable: $db.mantraConfigTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MantraConfigTableTableOrderingComposer(
            $db: $db,
            $table: $db.mantraConfigTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTableTable> {
  $$SessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get achievedCount => $composableBuilder(
    column: $table.achievedCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$MantraConfigTableTableAnnotationComposer get mantraId {
    final $$MantraConfigTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mantraId,
          referencedTable: $db.mantraConfigTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MantraConfigTableTableAnnotationComposer(
                $db: $db,
                $table: $db.mantraConfigTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> detectionsTableRefs<T extends Object>(
    Expression<T> Function($$DetectionsTableTableAnnotationComposer a) f,
  ) {
    final $$DetectionsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detectionsTable,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetectionsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.detectionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTableTable,
          SessionsTableData,
          $$SessionsTableTableFilterComposer,
          $$SessionsTableTableOrderingComposer,
          $$SessionsTableTableAnnotationComposer,
          $$SessionsTableTableCreateCompanionBuilder,
          $$SessionsTableTableUpdateCompanionBuilder,
          (SessionsTableData, $$SessionsTableTableReferences),
          SessionsTableData,
          PrefetchHooks Function({bool mantraId, bool detectionsTableRefs})
        > {
  $$SessionsTableTableTableManager(_$AppDatabase db, $SessionsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> mantraId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<int> achievedCount = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsTableCompanion(
                id: id,
                mantraId: mantraId,
                startedAt: startedAt,
                endedAt: endedAt,
                targetCount: targetCount,
                achievedCount: achievedCount,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int mantraId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required int targetCount,
                Value<int> achievedCount = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsTableCompanion.insert(
                id: id,
                mantraId: mantraId,
                startedAt: startedAt,
                endedAt: endedAt,
                targetCount: targetCount,
                achievedCount: achievedCount,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({mantraId = false, detectionsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (detectionsTableRefs) db.detectionsTable,
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
                        if (mantraId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mantraId,
                                    referencedTable:
                                        $$SessionsTableTableReferences
                                            ._mantraIdTable(db),
                                    referencedColumn:
                                        $$SessionsTableTableReferences
                                            ._mantraIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (detectionsTableRefs)
                        await $_getPrefetchedData<
                          SessionsTableData,
                          $SessionsTableTable,
                          DetectionsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableTableReferences
                              ._detectionsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).detectionsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
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

typedef $$SessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTableTable,
      SessionsTableData,
      $$SessionsTableTableFilterComposer,
      $$SessionsTableTableOrderingComposer,
      $$SessionsTableTableAnnotationComposer,
      $$SessionsTableTableCreateCompanionBuilder,
      $$SessionsTableTableUpdateCompanionBuilder,
      (SessionsTableData, $$SessionsTableTableReferences),
      SessionsTableData,
      PrefetchHooks Function({bool mantraId, bool detectionsTableRefs})
    >;
typedef $$DetectionsTableTableCreateCompanionBuilder =
    DetectionsTableCompanion Function({
      Value<int> id,
      required String sessionId,
      required DateTime detectedAt,
      required double confidence,
      Value<String> engine,
    });
typedef $$DetectionsTableTableUpdateCompanionBuilder =
    DetectionsTableCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<DateTime> detectedAt,
      Value<double> confidence,
      Value<String> engine,
    });

final class $$DetectionsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DetectionsTableTable,
          DetectionsTableData
        > {
  $$DetectionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTableTable _sessionIdTable(_$AppDatabase db) =>
      db.sessionsTable.createAlias(
        $_aliasNameGenerator(db.detectionsTable.sessionId, db.sessionsTable.id),
      );

  $$SessionsTableTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableTableManager(
      $_db,
      $_db.sessionsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DetectionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DetectionsTableTable> {
  $$DetectionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableTableFilterComposer get sessionId {
    final $$SessionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableFilterComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetectionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DetectionsTableTable> {
  $$DetectionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engine => $composableBuilder(
    column: $table.engine,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableTableOrderingComposer get sessionId {
    final $$SessionsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableOrderingComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetectionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetectionsTableTable> {
  $$DetectionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get engine =>
      $composableBuilder(column: $table.engine, builder: (column) => column);

  $$SessionsTableTableAnnotationComposer get sessionId {
    final $$SessionsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetectionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetectionsTableTable,
          DetectionsTableData,
          $$DetectionsTableTableFilterComposer,
          $$DetectionsTableTableOrderingComposer,
          $$DetectionsTableTableAnnotationComposer,
          $$DetectionsTableTableCreateCompanionBuilder,
          $$DetectionsTableTableUpdateCompanionBuilder,
          (DetectionsTableData, $$DetectionsTableTableReferences),
          DetectionsTableData,
          PrefetchHooks Function({bool sessionId})
        > {
  $$DetectionsTableTableTableManager(
    _$AppDatabase db,
    $DetectionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetectionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetectionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetectionsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> engine = const Value.absent(),
              }) => DetectionsTableCompanion(
                id: id,
                sessionId: sessionId,
                detectedAt: detectedAt,
                confidence: confidence,
                engine: engine,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required DateTime detectedAt,
                required double confidence,
                Value<String> engine = const Value.absent(),
              }) => DetectionsTableCompanion.insert(
                id: id,
                sessionId: sessionId,
                detectedAt: detectedAt,
                confidence: confidence,
                engine: engine,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DetectionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$DetectionsTableTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$DetectionsTableTableReferences
                                        ._sessionIdTable(db)
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

typedef $$DetectionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetectionsTableTable,
      DetectionsTableData,
      $$DetectionsTableTableFilterComposer,
      $$DetectionsTableTableOrderingComposer,
      $$DetectionsTableTableAnnotationComposer,
      $$DetectionsTableTableCreateCompanionBuilder,
      $$DetectionsTableTableUpdateCompanionBuilder,
      (DetectionsTableData, $$DetectionsTableTableReferences),
      DetectionsTableData,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$DailyStatsTableTableCreateCompanionBuilder =
    DailyStatsTableCompanion Function({
      required int mantraId,
      required String date,
      Value<int> totalCount,
      Value<int> sessionsCount,
      Value<int> streakDays,
      Value<int> rowid,
    });
typedef $$DailyStatsTableTableUpdateCompanionBuilder =
    DailyStatsTableCompanion Function({
      Value<int> mantraId,
      Value<String> date,
      Value<int> totalCount,
      Value<int> sessionsCount,
      Value<int> streakDays,
      Value<int> rowid,
    });

final class $$DailyStatsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DailyStatsTableTable,
          DailyStatsTableData
        > {
  $$DailyStatsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MantraConfigTableTable _mantraIdTable(_$AppDatabase db) =>
      db.mantraConfigTable.createAlias(
        $_aliasNameGenerator(
          db.dailyStatsTable.mantraId,
          db.mantraConfigTable.id,
        ),
      );

  $$MantraConfigTableTableProcessedTableManager get mantraId {
    final $_column = $_itemColumn<int>('mantra_id')!;

    final manager = $$MantraConfigTableTableTableManager(
      $_db,
      $_db.mantraConfigTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mantraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyStatsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStatsTableTable> {
  $$DailyStatsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionsCount => $composableBuilder(
    column: $table.sessionsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnFilters(column),
  );

  $$MantraConfigTableTableFilterComposer get mantraId {
    final $$MantraConfigTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mantraId,
      referencedTable: $db.mantraConfigTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MantraConfigTableTableFilterComposer(
            $db: $db,
            $table: $db.mantraConfigTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyStatsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStatsTableTable> {
  $$DailyStatsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionsCount => $composableBuilder(
    column: $table.sessionsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnOrderings(column),
  );

  $$MantraConfigTableTableOrderingComposer get mantraId {
    final $$MantraConfigTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mantraId,
      referencedTable: $db.mantraConfigTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MantraConfigTableTableOrderingComposer(
            $db: $db,
            $table: $db.mantraConfigTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyStatsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStatsTableTable> {
  $$DailyStatsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionsCount => $composableBuilder(
    column: $table.sessionsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => column,
  );

  $$MantraConfigTableTableAnnotationComposer get mantraId {
    final $$MantraConfigTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mantraId,
          referencedTable: $db.mantraConfigTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MantraConfigTableTableAnnotationComposer(
                $db: $db,
                $table: $db.mantraConfigTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DailyStatsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyStatsTableTable,
          DailyStatsTableData,
          $$DailyStatsTableTableFilterComposer,
          $$DailyStatsTableTableOrderingComposer,
          $$DailyStatsTableTableAnnotationComposer,
          $$DailyStatsTableTableCreateCompanionBuilder,
          $$DailyStatsTableTableUpdateCompanionBuilder,
          (DailyStatsTableData, $$DailyStatsTableTableReferences),
          DailyStatsTableData,
          PrefetchHooks Function({bool mantraId})
        > {
  $$DailyStatsTableTableTableManager(
    _$AppDatabase db,
    $DailyStatsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStatsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStatsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyStatsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> mantraId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<int> sessionsCount = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStatsTableCompanion(
                mantraId: mantraId,
                date: date,
                totalCount: totalCount,
                sessionsCount: sessionsCount,
                streakDays: streakDays,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int mantraId,
                required String date,
                Value<int> totalCount = const Value.absent(),
                Value<int> sessionsCount = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStatsTableCompanion.insert(
                mantraId: mantraId,
                date: date,
                totalCount: totalCount,
                sessionsCount: sessionsCount,
                streakDays: streakDays,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyStatsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mantraId = false}) {
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
                    if (mantraId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mantraId,
                                referencedTable:
                                    $$DailyStatsTableTableReferences
                                        ._mantraIdTable(db),
                                referencedColumn:
                                    $$DailyStatsTableTableReferences
                                        ._mantraIdTable(db)
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

typedef $$DailyStatsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyStatsTableTable,
      DailyStatsTableData,
      $$DailyStatsTableTableFilterComposer,
      $$DailyStatsTableTableOrderingComposer,
      $$DailyStatsTableTableAnnotationComposer,
      $$DailyStatsTableTableCreateCompanionBuilder,
      $$DailyStatsTableTableUpdateCompanionBuilder,
      (DailyStatsTableData, $$DailyStatsTableTableReferences),
      DailyStatsTableData,
      PrefetchHooks Function({bool mantraId})
    >;
typedef $$PendingSyncsTableTableCreateCompanionBuilder =
    PendingSyncsTableCompanion Function({
      Value<int> id,
      required String sessionId,
      required String payload,
      required DateTime createdAt,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
    });
typedef $$PendingSyncsTableTableUpdateCompanionBuilder =
    PendingSyncsTableCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
    });

class $$PendingSyncsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingSyncsTableTable> {
  $$PendingSyncsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingSyncsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingSyncsTableTable> {
  $$PendingSyncsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingSyncsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingSyncsTableTable> {
  $$PendingSyncsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );
}

class $$PendingSyncsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingSyncsTableTable,
          PendingSyncsTableData,
          $$PendingSyncsTableTableFilterComposer,
          $$PendingSyncsTableTableOrderingComposer,
          $$PendingSyncsTableTableAnnotationComposer,
          $$PendingSyncsTableTableCreateCompanionBuilder,
          $$PendingSyncsTableTableUpdateCompanionBuilder,
          (
            PendingSyncsTableData,
            BaseReferences<
              _$AppDatabase,
              $PendingSyncsTableTable,
              PendingSyncsTableData
            >,
          ),
          PendingSyncsTableData,
          PrefetchHooks Function()
        > {
  $$PendingSyncsTableTableTableManager(
    _$AppDatabase db,
    $PendingSyncsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSyncsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingSyncsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingSyncsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
              }) => PendingSyncsTableCompanion(
                id: id,
                sessionId: sessionId,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required String payload,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
              }) => PendingSyncsTableCompanion.insert(
                id: id,
                sessionId: sessionId,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingSyncsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingSyncsTableTable,
      PendingSyncsTableData,
      $$PendingSyncsTableTableFilterComposer,
      $$PendingSyncsTableTableOrderingComposer,
      $$PendingSyncsTableTableAnnotationComposer,
      $$PendingSyncsTableTableCreateCompanionBuilder,
      $$PendingSyncsTableTableUpdateCompanionBuilder,
      (
        PendingSyncsTableData,
        BaseReferences<
          _$AppDatabase,
          $PendingSyncsTableTable,
          PendingSyncsTableData
        >,
      ),
      PendingSyncsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MantraConfigTableTableTableManager get mantraConfigTable =>
      $$MantraConfigTableTableTableManager(_db, _db.mantraConfigTable);
  $$SessionsTableTableTableManager get sessionsTable =>
      $$SessionsTableTableTableManager(_db, _db.sessionsTable);
  $$DetectionsTableTableTableManager get detectionsTable =>
      $$DetectionsTableTableTableManager(_db, _db.detectionsTable);
  $$DailyStatsTableTableTableManager get dailyStatsTable =>
      $$DailyStatsTableTableTableManager(_db, _db.dailyStatsTable);
  $$PendingSyncsTableTableTableManager get pendingSyncsTable =>
      $$PendingSyncsTableTableTableManager(_db, _db.pendingSyncsTable);
}
