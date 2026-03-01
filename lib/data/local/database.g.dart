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
    requiredDuringInsert: true,
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
    defaultValue: const Constant(0.6),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    devanagari,
    romanized,
    targetCount,
    sensitivity,
    refractoryMs,
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
    } else if (isInserting) {
      context.missing(_targetCountMeta);
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
  const MantraConfigTableData({
    required this.id,
    required this.name,
    required this.devanagari,
    required this.romanized,
    required this.targetCount,
    required this.sensitivity,
    required this.refractoryMs,
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
  }) => MantraConfigTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    devanagari: devanagari ?? this.devanagari,
    romanized: romanized ?? this.romanized,
    targetCount: targetCount ?? this.targetCount,
    sensitivity: sensitivity ?? this.sensitivity,
    refractoryMs: refractoryMs ?? this.refractoryMs,
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
          ..write('refractoryMs: $refractoryMs')
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
          other.refractoryMs == this.refractoryMs);
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
  const MantraConfigTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.devanagari = const Value.absent(),
    this.romanized = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.sensitivity = const Value.absent(),
    this.refractoryMs = const Value.absent(),
  });
  MantraConfigTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String devanagari,
    required String romanized,
    required int targetCount,
    this.sensitivity = const Value.absent(),
    this.refractoryMs = const Value.absent(),
  }) : name = Value(name),
       devanagari = Value(devanagari),
       romanized = Value(romanized),
       targetCount = Value(targetCount);
  static Insertable<MantraConfigTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? devanagari,
    Expression<String>? romanized,
    Expression<int>? targetCount,
    Expression<double>? sensitivity,
    Expression<int>? refractoryMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (devanagari != null) 'devanagari': devanagari,
      if (romanized != null) 'romanized': romanized,
      if (targetCount != null) 'target_count': targetCount,
      if (sensitivity != null) 'sensitivity': sensitivity,
      if (refractoryMs != null) 'refractory_ms': refractoryMs,
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
  }) {
    return MantraConfigTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      devanagari: devanagari ?? this.devanagari,
      romanized: romanized ?? this.romanized,
      targetCount: targetCount ?? this.targetCount,
      sensitivity: sensitivity ?? this.sensitivity,
      refractoryMs: refractoryMs ?? this.refractoryMs,
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
          ..write('refractoryMs: $refractoryMs')
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mantraId,
    startedAt,
    endedAt,
    targetCount,
    achievedCount,
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
    } else if (isInserting) {
      context.missing(_achievedCountMeta);
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
        DriftSqlType.int,
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
    );
  }

  @override
  $SessionsTableTable createAlias(String alias) {
    return $SessionsTableTable(attachedDatabase, alias);
  }
}

class SessionsTableData extends DataClass
    implements Insertable<SessionsTableData> {
  final int id;
  final int mantraId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int targetCount;
  final int achievedCount;
  const SessionsTableData({
    required this.id,
    required this.mantraId,
    required this.startedAt,
    this.endedAt,
    required this.targetCount,
    required this.achievedCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mantra_id'] = Variable<int>(mantraId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['target_count'] = Variable<int>(targetCount);
    map['achieved_count'] = Variable<int>(achievedCount);
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
    );
  }

  factory SessionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionsTableData(
      id: serializer.fromJson<int>(json['id']),
      mantraId: serializer.fromJson<int>(json['mantraId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      achievedCount: serializer.fromJson<int>(json['achievedCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mantraId': serializer.toJson<int>(mantraId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'targetCount': serializer.toJson<int>(targetCount),
      'achievedCount': serializer.toJson<int>(achievedCount),
    };
  }

  SessionsTableData copyWith({
    int? id,
    int? mantraId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? targetCount,
    int? achievedCount,
  }) => SessionsTableData(
    id: id ?? this.id,
    mantraId: mantraId ?? this.mantraId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    targetCount: targetCount ?? this.targetCount,
    achievedCount: achievedCount ?? this.achievedCount,
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
          ..write('achievedCount: $achievedCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mantraId, startedAt, endedAt, targetCount, achievedCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionsTableData &&
          other.id == this.id &&
          other.mantraId == this.mantraId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.targetCount == this.targetCount &&
          other.achievedCount == this.achievedCount);
}

class SessionsTableCompanion extends UpdateCompanion<SessionsTableData> {
  final Value<int> id;
  final Value<int> mantraId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> targetCount;
  final Value<int> achievedCount;
  const SessionsTableCompanion({
    this.id = const Value.absent(),
    this.mantraId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.achievedCount = const Value.absent(),
  });
  SessionsTableCompanion.insert({
    this.id = const Value.absent(),
    required int mantraId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required int targetCount,
    required int achievedCount,
  }) : mantraId = Value(mantraId),
       startedAt = Value(startedAt),
       targetCount = Value(targetCount),
       achievedCount = Value(achievedCount);
  static Insertable<SessionsTableData> custom({
    Expression<int>? id,
    Expression<int>? mantraId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? targetCount,
    Expression<int>? achievedCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mantraId != null) 'mantra_id': mantraId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (targetCount != null) 'target_count': targetCount,
      if (achievedCount != null) 'achieved_count': achievedCount,
    });
  }

  SessionsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? mantraId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? targetCount,
    Value<int>? achievedCount,
  }) {
    return SessionsTableCompanion(
      id: id ?? this.id,
      mantraId: mantraId ?? this.mantraId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      targetCount: targetCount ?? this.targetCount,
      achievedCount: achievedCount ?? this.achievedCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
          ..write('achievedCount: $achievedCount')
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
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
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
    } else if (isInserting) {
      context.missing(_engineMeta);
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
        DriftSqlType.int,
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
  final int sessionId;
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
    map['session_id'] = Variable<int>(sessionId);
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
      sessionId: serializer.fromJson<int>(json['sessionId']),
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
      'sessionId': serializer.toJson<int>(sessionId),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'confidence': serializer.toJson<double>(confidence),
      'engine': serializer.toJson<String>(engine),
    };
  }

  DetectionsTableData copyWith({
    int? id,
    int? sessionId,
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
  final Value<int> sessionId;
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
    required int sessionId,
    required DateTime detectedAt,
    required double confidence,
    required String engine,
  }) : sessionId = Value(sessionId),
       detectedAt = Value(detectedAt),
       confidence = Value(confidence),
       engine = Value(engine);
  static Insertable<DetectionsTableData> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
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
    Value<int>? sessionId,
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
      map['session_id'] = Variable<int>(sessionId.value);
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MantraConfigTableTable mantraConfigTable =
      $MantraConfigTableTable(this);
  late final $SessionsTableTable sessionsTable = $SessionsTableTable(this);
  late final $DetectionsTableTable detectionsTable = $DetectionsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mantraConfigTable,
    sessionsTable,
    detectionsTable,
  ];
}

typedef $$MantraConfigTableTableCreateCompanionBuilder =
    MantraConfigTableCompanion Function({
      Value<int> id,
      required String name,
      required String devanagari,
      required String romanized,
      required int targetCount,
      Value<double> sensitivity,
      Value<int> refractoryMs,
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
          PrefetchHooks Function({bool sessionsTableRefs})
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
              }) => MantraConfigTableCompanion(
                id: id,
                name: name,
                devanagari: devanagari,
                romanized: romanized,
                targetCount: targetCount,
                sensitivity: sensitivity,
                refractoryMs: refractoryMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String devanagari,
                required String romanized,
                required int targetCount,
                Value<double> sensitivity = const Value.absent(),
                Value<int> refractoryMs = const Value.absent(),
              }) => MantraConfigTableCompanion.insert(
                id: id,
                name: name,
                devanagari: devanagari,
                romanized: romanized,
                targetCount: targetCount,
                sensitivity: sensitivity,
                refractoryMs: refractoryMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MantraConfigTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sessionsTableRefs) db.sessionsTable,
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.mantraId == item.id),
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
      PrefetchHooks Function({bool sessionsTableRefs})
    >;
typedef $$SessionsTableTableCreateCompanionBuilder =
    SessionsTableCompanion Function({
      Value<int> id,
      required int mantraId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required int targetCount,
      required int achievedCount,
    });
typedef $$SessionsTableTableUpdateCompanionBuilder =
    SessionsTableCompanion Function({
      Value<int> id,
      Value<int> mantraId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> targetCount,
      Value<int> achievedCount,
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
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

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
  ColumnFilters<int> get id => $composableBuilder(
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
  ColumnOrderings<int> get id => $composableBuilder(
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
  GeneratedColumn<int> get id =>
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
                Value<int> id = const Value.absent(),
                Value<int> mantraId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<int> achievedCount = const Value.absent(),
              }) => SessionsTableCompanion(
                id: id,
                mantraId: mantraId,
                startedAt: startedAt,
                endedAt: endedAt,
                targetCount: targetCount,
                achievedCount: achievedCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mantraId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required int targetCount,
                required int achievedCount,
              }) => SessionsTableCompanion.insert(
                id: id,
                mantraId: mantraId,
                startedAt: startedAt,
                endedAt: endedAt,
                targetCount: targetCount,
                achievedCount: achievedCount,
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
      required int sessionId,
      required DateTime detectedAt,
      required double confidence,
      required String engine,
    });
typedef $$DetectionsTableTableUpdateCompanionBuilder =
    DetectionsTableCompanion Function({
      Value<int> id,
      Value<int> sessionId,
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
    final $_column = $_itemColumn<int>('session_id')!;

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
                Value<int> sessionId = const Value.absent(),
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
                required int sessionId,
                required DateTime detectedAt,
                required double confidence,
                required String engine,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MantraConfigTableTableTableManager get mantraConfigTable =>
      $$MantraConfigTableTableTableManager(_db, _db.mantraConfigTable);
  $$SessionsTableTableTableManager get sessionsTable =>
      $$SessionsTableTableTableManager(_db, _db.sessionsTable);
  $$DetectionsTableTableTableManager get detectionsTable =>
      $$DetectionsTableTableTableManager(_db, _db.detectionsTable);
}
