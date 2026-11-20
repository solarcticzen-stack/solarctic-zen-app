// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $IceSessionsTable extends IceSessions
    with TableInfo<$IceSessionsTable, IceSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IceSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryModeMeta = const VerificationMeta(
    'entryMode',
  );
  @override
  late final GeneratedColumn<String> entryMode = GeneratedColumn<String>(
    'entry_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta(
    'startedAtMs',
  );
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMsMeta = const VerificationMeta(
    'endedAtMs',
  );
  @override
  late final GeneratedColumn<int> endedAtMs = GeneratedColumn<int>(
    'ended_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _utcOffsetMinMeta = const VerificationMeta(
    'utcOffsetMin',
  );
  @override
  late final GeneratedColumn<int> utcOffsetMin = GeneratedColumn<int>(
    'utc_offset_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tzNameMeta = const VerificationMeta('tzName');
  @override
  late final GeneratedColumn<String> tzName = GeneratedColumn<String>(
    'tz_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSMeta = const VerificationMeta(
    'durationS',
  );
  @override
  late final GeneratedColumn<int> durationS = GeneratedColumn<int>(
    'duration_s',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waterTempCMeta = const VerificationMeta(
    'waterTempC',
  );
  @override
  late final GeneratedColumn<double> waterTempC = GeneratedColumn<double>(
    'water_temp_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feelingBeforeMeta = const VerificationMeta(
    'feelingBefore',
  );
  @override
  late final GeneratedColumn<int> feelingBefore = GeneratedColumn<int>(
    'feeling_before',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feelingAfterMeta = const VerificationMeta(
    'feelingAfter',
  );
  @override
  late final GeneratedColumn<int> feelingAfter = GeneratedColumn<int>(
    'feeling_after',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _countdownSMeta = const VerificationMeta(
    'countdownS',
  );
  @override
  late final GeneratedColumn<int> countdownS = GeneratedColumn<int>(
    'countdown_s',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warmupExerciseIdMeta = const VerificationMeta(
    'warmupExerciseId',
  );
  @override
  late final GeneratedColumn<String> warmupExerciseId = GeneratedColumn<String>(
    'warmup_exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warmupDoneMeta = const VerificationMeta(
    'warmupDone',
  );
  @override
  late final GeneratedColumn<bool> warmupDone = GeneratedColumn<bool>(
    'warmup_done',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("warmup_done" IN (0, 1))',
    ),
  );
  static const VerificationMeta _overcomeRatingMeta = const VerificationMeta(
    'overcomeRating',
  );
  @override
  late final GeneratedColumn<int> overcomeRating = GeneratedColumn<int>(
    'overcome_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _duringRatingMeta = const VerificationMeta(
    'duringRating',
  );
  @override
  late final GeneratedColumn<int> duringRating = GeneratedColumn<int>(
    'during_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    entryMode,
    startedAtMs,
    endedAtMs,
    utcOffsetMin,
    tzName,
    localDate,
    durationS,
    waterTempC,
    feelingBefore,
    feelingAfter,
    notes,
    countdownS,
    warmupExerciseId,
    warmupDone,
    overcomeRating,
    duringRating,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ice_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<IceSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('entry_mode')) {
      context.handle(
        _entryModeMeta,
        entryMode.isAcceptableOrUnknown(data['entry_mode']!, _entryModeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryModeMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
        _startedAtMsMeta,
        startedAtMs.isAcceptableOrUnknown(
          data['started_at_ms']!,
          _startedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('ended_at_ms')) {
      context.handle(
        _endedAtMsMeta,
        endedAtMs.isAcceptableOrUnknown(data['ended_at_ms']!, _endedAtMsMeta),
      );
    }
    if (data.containsKey('utc_offset_min')) {
      context.handle(
        _utcOffsetMinMeta,
        utcOffsetMin.isAcceptableOrUnknown(
          data['utc_offset_min']!,
          _utcOffsetMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utcOffsetMinMeta);
    }
    if (data.containsKey('tz_name')) {
      context.handle(
        _tzNameMeta,
        tzName.isAcceptableOrUnknown(data['tz_name']!, _tzNameMeta),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('duration_s')) {
      context.handle(
        _durationSMeta,
        durationS.isAcceptableOrUnknown(data['duration_s']!, _durationSMeta),
      );
    }
    if (data.containsKey('water_temp_c')) {
      context.handle(
        _waterTempCMeta,
        waterTempC.isAcceptableOrUnknown(
          data['water_temp_c']!,
          _waterTempCMeta,
        ),
      );
    }
    if (data.containsKey('feeling_before')) {
      context.handle(
        _feelingBeforeMeta,
        feelingBefore.isAcceptableOrUnknown(
          data['feeling_before']!,
          _feelingBeforeMeta,
        ),
      );
    }
    if (data.containsKey('feeling_after')) {
      context.handle(
        _feelingAfterMeta,
        feelingAfter.isAcceptableOrUnknown(
          data['feeling_after']!,
          _feelingAfterMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('countdown_s')) {
      context.handle(
        _countdownSMeta,
        countdownS.isAcceptableOrUnknown(data['countdown_s']!, _countdownSMeta),
      );
    }
    if (data.containsKey('warmup_exercise_id')) {
      context.handle(
        _warmupExerciseIdMeta,
        warmupExerciseId.isAcceptableOrUnknown(
          data['warmup_exercise_id']!,
          _warmupExerciseIdMeta,
        ),
      );
    }
    if (data.containsKey('warmup_done')) {
      context.handle(
        _warmupDoneMeta,
        warmupDone.isAcceptableOrUnknown(data['warmup_done']!, _warmupDoneMeta),
      );
    }
    if (data.containsKey('overcome_rating')) {
      context.handle(
        _overcomeRatingMeta,
        overcomeRating.isAcceptableOrUnknown(
          data['overcome_rating']!,
          _overcomeRatingMeta,
        ),
      );
    }
    if (data.containsKey('during_rating')) {
      context.handle(
        _duringRatingMeta,
        duringRating.isAcceptableOrUnknown(
          data['during_rating']!,
          _duringRatingMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IceSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IceSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      entryMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_mode'],
      )!,
      startedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_ms'],
      )!,
      endedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at_ms'],
      ),
      utcOffsetMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utc_offset_min'],
      )!,
      tzName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tz_name'],
      ),
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      durationS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_s'],
      ),
      waterTempC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}water_temp_c'],
      ),
      feelingBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feeling_before'],
      ),
      feelingAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feeling_after'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      countdownS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}countdown_s'],
      ),
      warmupExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warmup_exercise_id'],
      ),
      warmupDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}warmup_done'],
      ),
      overcomeRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overcome_rating'],
      ),
      duringRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}during_rating'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $IceSessionsTable createAlias(String alias) {
    return $IceSessionsTable(attachedDatabase, alias);
  }
}

class IceSessionRow extends DataClass implements Insertable<IceSessionRow> {
  final String id;
  final String status;
  final String entryMode;
  final int startedAtMs;
  final int? endedAtMs;
  final int utcOffsetMin;
  final String? tzName;

  /// `YYYY-MM-DD` in Lokalzeit beim Start.
  final String localDate;

  /// Netto-Dauer in Sekunden (Cache für Abfragen; Quelle ist Start/Ende/Pausen).
  final int? durationS;
  final double? waterTempC;
  final int? feelingBefore;
  final int? feelingAfter;
  final String? notes;
  final int? countdownS;

  /// Seit Schema-Version 2 (A20 Aufwärm-Impuls).
  final String? warmupExerciseId;
  final bool? warmupDone;

  /// Seit Schema-Version 3 (N-005): Überwindung vorher, Erleben im Wasser.
  final int? overcomeRating;
  final int? duringRating;
  final int createdAtMs;
  final int updatedAtMs;
  final int? deletedAtMs;
  final int version;
  const IceSessionRow({
    required this.id,
    required this.status,
    required this.entryMode,
    required this.startedAtMs,
    this.endedAtMs,
    required this.utcOffsetMin,
    this.tzName,
    required this.localDate,
    this.durationS,
    this.waterTempC,
    this.feelingBefore,
    this.feelingAfter,
    this.notes,
    this.countdownS,
    this.warmupExerciseId,
    this.warmupDone,
    this.overcomeRating,
    this.duringRating,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<String>(status);
    map['entry_mode'] = Variable<String>(entryMode);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    if (!nullToAbsent || endedAtMs != null) {
      map['ended_at_ms'] = Variable<int>(endedAtMs);
    }
    map['utc_offset_min'] = Variable<int>(utcOffsetMin);
    if (!nullToAbsent || tzName != null) {
      map['tz_name'] = Variable<String>(tzName);
    }
    map['local_date'] = Variable<String>(localDate);
    if (!nullToAbsent || durationS != null) {
      map['duration_s'] = Variable<int>(durationS);
    }
    if (!nullToAbsent || waterTempC != null) {
      map['water_temp_c'] = Variable<double>(waterTempC);
    }
    if (!nullToAbsent || feelingBefore != null) {
      map['feeling_before'] = Variable<int>(feelingBefore);
    }
    if (!nullToAbsent || feelingAfter != null) {
      map['feeling_after'] = Variable<int>(feelingAfter);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || countdownS != null) {
      map['countdown_s'] = Variable<int>(countdownS);
    }
    if (!nullToAbsent || warmupExerciseId != null) {
      map['warmup_exercise_id'] = Variable<String>(warmupExerciseId);
    }
    if (!nullToAbsent || warmupDone != null) {
      map['warmup_done'] = Variable<bool>(warmupDone);
    }
    if (!nullToAbsent || overcomeRating != null) {
      map['overcome_rating'] = Variable<int>(overcomeRating);
    }
    if (!nullToAbsent || duringRating != null) {
      map['during_rating'] = Variable<int>(duringRating);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  IceSessionsCompanion toCompanion(bool nullToAbsent) {
    return IceSessionsCompanion(
      id: Value(id),
      status: Value(status),
      entryMode: Value(entryMode),
      startedAtMs: Value(startedAtMs),
      endedAtMs: endedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtMs),
      utcOffsetMin: Value(utcOffsetMin),
      tzName: tzName == null && nullToAbsent
          ? const Value.absent()
          : Value(tzName),
      localDate: Value(localDate),
      durationS: durationS == null && nullToAbsent
          ? const Value.absent()
          : Value(durationS),
      waterTempC: waterTempC == null && nullToAbsent
          ? const Value.absent()
          : Value(waterTempC),
      feelingBefore: feelingBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(feelingBefore),
      feelingAfter: feelingAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(feelingAfter),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      countdownS: countdownS == null && nullToAbsent
          ? const Value.absent()
          : Value(countdownS),
      warmupExerciseId: warmupExerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(warmupExerciseId),
      warmupDone: warmupDone == null && nullToAbsent
          ? const Value.absent()
          : Value(warmupDone),
      overcomeRating: overcomeRating == null && nullToAbsent
          ? const Value.absent()
          : Value(overcomeRating),
      duringRating: duringRating == null && nullToAbsent
          ? const Value.absent()
          : Value(duringRating),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
      version: Value(version),
    );
  }

  factory IceSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IceSessionRow(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      entryMode: serializer.fromJson<String>(json['entryMode']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      endedAtMs: serializer.fromJson<int?>(json['endedAtMs']),
      utcOffsetMin: serializer.fromJson<int>(json['utcOffsetMin']),
      tzName: serializer.fromJson<String?>(json['tzName']),
      localDate: serializer.fromJson<String>(json['localDate']),
      durationS: serializer.fromJson<int?>(json['durationS']),
      waterTempC: serializer.fromJson<double?>(json['waterTempC']),
      feelingBefore: serializer.fromJson<int?>(json['feelingBefore']),
      feelingAfter: serializer.fromJson<int?>(json['feelingAfter']),
      notes: serializer.fromJson<String?>(json['notes']),
      countdownS: serializer.fromJson<int?>(json['countdownS']),
      warmupExerciseId: serializer.fromJson<String?>(json['warmupExerciseId']),
      warmupDone: serializer.fromJson<bool?>(json['warmupDone']),
      overcomeRating: serializer.fromJson<int?>(json['overcomeRating']),
      duringRating: serializer.fromJson<int?>(json['duringRating']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(status),
      'entryMode': serializer.toJson<String>(entryMode),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'endedAtMs': serializer.toJson<int?>(endedAtMs),
      'utcOffsetMin': serializer.toJson<int>(utcOffsetMin),
      'tzName': serializer.toJson<String?>(tzName),
      'localDate': serializer.toJson<String>(localDate),
      'durationS': serializer.toJson<int?>(durationS),
      'waterTempC': serializer.toJson<double?>(waterTempC),
      'feelingBefore': serializer.toJson<int?>(feelingBefore),
      'feelingAfter': serializer.toJson<int?>(feelingAfter),
      'notes': serializer.toJson<String?>(notes),
      'countdownS': serializer.toJson<int?>(countdownS),
      'warmupExerciseId': serializer.toJson<String?>(warmupExerciseId),
      'warmupDone': serializer.toJson<bool?>(warmupDone),
      'overcomeRating': serializer.toJson<int?>(overcomeRating),
      'duringRating': serializer.toJson<int?>(duringRating),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'version': serializer.toJson<int>(version),
    };
  }

  IceSessionRow copyWith({
    String? id,
    String? status,
    String? entryMode,
    int? startedAtMs,
    Value<int?> endedAtMs = const Value.absent(),
    int? utcOffsetMin,
    Value<String?> tzName = const Value.absent(),
    String? localDate,
    Value<int?> durationS = const Value.absent(),
    Value<double?> waterTempC = const Value.absent(),
    Value<int?> feelingBefore = const Value.absent(),
    Value<int?> feelingAfter = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> countdownS = const Value.absent(),
    Value<String?> warmupExerciseId = const Value.absent(),
    Value<bool?> warmupDone = const Value.absent(),
    Value<int?> overcomeRating = const Value.absent(),
    Value<int?> duringRating = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
    Value<int?> deletedAtMs = const Value.absent(),
    int? version,
  }) => IceSessionRow(
    id: id ?? this.id,
    status: status ?? this.status,
    entryMode: entryMode ?? this.entryMode,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    endedAtMs: endedAtMs.present ? endedAtMs.value : this.endedAtMs,
    utcOffsetMin: utcOffsetMin ?? this.utcOffsetMin,
    tzName: tzName.present ? tzName.value : this.tzName,
    localDate: localDate ?? this.localDate,
    durationS: durationS.present ? durationS.value : this.durationS,
    waterTempC: waterTempC.present ? waterTempC.value : this.waterTempC,
    feelingBefore: feelingBefore.present
        ? feelingBefore.value
        : this.feelingBefore,
    feelingAfter: feelingAfter.present ? feelingAfter.value : this.feelingAfter,
    notes: notes.present ? notes.value : this.notes,
    countdownS: countdownS.present ? countdownS.value : this.countdownS,
    warmupExerciseId: warmupExerciseId.present
        ? warmupExerciseId.value
        : this.warmupExerciseId,
    warmupDone: warmupDone.present ? warmupDone.value : this.warmupDone,
    overcomeRating: overcomeRating.present
        ? overcomeRating.value
        : this.overcomeRating,
    duringRating: duringRating.present ? duringRating.value : this.duringRating,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    version: version ?? this.version,
  );
  IceSessionRow copyWithCompanion(IceSessionsCompanion data) {
    return IceSessionRow(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      entryMode: data.entryMode.present ? data.entryMode.value : this.entryMode,
      startedAtMs: data.startedAtMs.present
          ? data.startedAtMs.value
          : this.startedAtMs,
      endedAtMs: data.endedAtMs.present ? data.endedAtMs.value : this.endedAtMs,
      utcOffsetMin: data.utcOffsetMin.present
          ? data.utcOffsetMin.value
          : this.utcOffsetMin,
      tzName: data.tzName.present ? data.tzName.value : this.tzName,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      durationS: data.durationS.present ? data.durationS.value : this.durationS,
      waterTempC: data.waterTempC.present
          ? data.waterTempC.value
          : this.waterTempC,
      feelingBefore: data.feelingBefore.present
          ? data.feelingBefore.value
          : this.feelingBefore,
      feelingAfter: data.feelingAfter.present
          ? data.feelingAfter.value
          : this.feelingAfter,
      notes: data.notes.present ? data.notes.value : this.notes,
      countdownS: data.countdownS.present
          ? data.countdownS.value
          : this.countdownS,
      warmupExerciseId: data.warmupExerciseId.present
          ? data.warmupExerciseId.value
          : this.warmupExerciseId,
      warmupDone: data.warmupDone.present
          ? data.warmupDone.value
          : this.warmupDone,
      overcomeRating: data.overcomeRating.present
          ? data.overcomeRating.value
          : this.overcomeRating,
      duringRating: data.duringRating.present
          ? data.duringRating.value
          : this.duringRating,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IceSessionRow(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('entryMode: $entryMode, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('utcOffsetMin: $utcOffsetMin, ')
          ..write('tzName: $tzName, ')
          ..write('localDate: $localDate, ')
          ..write('durationS: $durationS, ')
          ..write('waterTempC: $waterTempC, ')
          ..write('feelingBefore: $feelingBefore, ')
          ..write('feelingAfter: $feelingAfter, ')
          ..write('notes: $notes, ')
          ..write('countdownS: $countdownS, ')
          ..write('warmupExerciseId: $warmupExerciseId, ')
          ..write('warmupDone: $warmupDone, ')
          ..write('overcomeRating: $overcomeRating, ')
          ..write('duringRating: $duringRating, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    status,
    entryMode,
    startedAtMs,
    endedAtMs,
    utcOffsetMin,
    tzName,
    localDate,
    durationS,
    waterTempC,
    feelingBefore,
    feelingAfter,
    notes,
    countdownS,
    warmupExerciseId,
    warmupDone,
    overcomeRating,
    duringRating,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
    version,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IceSessionRow &&
          other.id == this.id &&
          other.status == this.status &&
          other.entryMode == this.entryMode &&
          other.startedAtMs == this.startedAtMs &&
          other.endedAtMs == this.endedAtMs &&
          other.utcOffsetMin == this.utcOffsetMin &&
          other.tzName == this.tzName &&
          other.localDate == this.localDate &&
          other.durationS == this.durationS &&
          other.waterTempC == this.waterTempC &&
          other.feelingBefore == this.feelingBefore &&
          other.feelingAfter == this.feelingAfter &&
          other.notes == this.notes &&
          other.countdownS == this.countdownS &&
          other.warmupExerciseId == this.warmupExerciseId &&
          other.warmupDone == this.warmupDone &&
          other.overcomeRating == this.overcomeRating &&
          other.duringRating == this.duringRating &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.deletedAtMs == this.deletedAtMs &&
          other.version == this.version);
}

class IceSessionsCompanion extends UpdateCompanion<IceSessionRow> {
  final Value<String> id;
  final Value<String> status;
  final Value<String> entryMode;
  final Value<int> startedAtMs;
  final Value<int?> endedAtMs;
  final Value<int> utcOffsetMin;
  final Value<String?> tzName;
  final Value<String> localDate;
  final Value<int?> durationS;
  final Value<double?> waterTempC;
  final Value<int?> feelingBefore;
  final Value<int?> feelingAfter;
  final Value<String?> notes;
  final Value<int?> countdownS;
  final Value<String?> warmupExerciseId;
  final Value<bool?> warmupDone;
  final Value<int?> overcomeRating;
  final Value<int?> duringRating;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int?> deletedAtMs;
  final Value<int> version;
  final Value<int> rowid;
  const IceSessionsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.entryMode = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.endedAtMs = const Value.absent(),
    this.utcOffsetMin = const Value.absent(),
    this.tzName = const Value.absent(),
    this.localDate = const Value.absent(),
    this.durationS = const Value.absent(),
    this.waterTempC = const Value.absent(),
    this.feelingBefore = const Value.absent(),
    this.feelingAfter = const Value.absent(),
    this.notes = const Value.absent(),
    this.countdownS = const Value.absent(),
    this.warmupExerciseId = const Value.absent(),
    this.warmupDone = const Value.absent(),
    this.overcomeRating = const Value.absent(),
    this.duringRating = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IceSessionsCompanion.insert({
    required String id,
    required String status,
    required String entryMode,
    required int startedAtMs,
    this.endedAtMs = const Value.absent(),
    required int utcOffsetMin,
    this.tzName = const Value.absent(),
    required String localDate,
    this.durationS = const Value.absent(),
    this.waterTempC = const Value.absent(),
    this.feelingBefore = const Value.absent(),
    this.feelingAfter = const Value.absent(),
    this.notes = const Value.absent(),
    this.countdownS = const Value.absent(),
    this.warmupExerciseId = const Value.absent(),
    this.warmupDone = const Value.absent(),
    this.overcomeRating = const Value.absent(),
    this.duringRating = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.deletedAtMs = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       entryMode = Value(entryMode),
       startedAtMs = Value(startedAtMs),
       utcOffsetMin = Value(utcOffsetMin),
       localDate = Value(localDate),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<IceSessionRow> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<String>? entryMode,
    Expression<int>? startedAtMs,
    Expression<int>? endedAtMs,
    Expression<int>? utcOffsetMin,
    Expression<String>? tzName,
    Expression<String>? localDate,
    Expression<int>? durationS,
    Expression<double>? waterTempC,
    Expression<int>? feelingBefore,
    Expression<int>? feelingAfter,
    Expression<String>? notes,
    Expression<int>? countdownS,
    Expression<String>? warmupExerciseId,
    Expression<bool>? warmupDone,
    Expression<int>? overcomeRating,
    Expression<int>? duringRating,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? deletedAtMs,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (entryMode != null) 'entry_mode': entryMode,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (endedAtMs != null) 'ended_at_ms': endedAtMs,
      if (utcOffsetMin != null) 'utc_offset_min': utcOffsetMin,
      if (tzName != null) 'tz_name': tzName,
      if (localDate != null) 'local_date': localDate,
      if (durationS != null) 'duration_s': durationS,
      if (waterTempC != null) 'water_temp_c': waterTempC,
      if (feelingBefore != null) 'feeling_before': feelingBefore,
      if (feelingAfter != null) 'feeling_after': feelingAfter,
      if (notes != null) 'notes': notes,
      if (countdownS != null) 'countdown_s': countdownS,
      if (warmupExerciseId != null) 'warmup_exercise_id': warmupExerciseId,
      if (warmupDone != null) 'warmup_done': warmupDone,
      if (overcomeRating != null) 'overcome_rating': overcomeRating,
      if (duringRating != null) 'during_rating': duringRating,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IceSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? status,
    Value<String>? entryMode,
    Value<int>? startedAtMs,
    Value<int?>? endedAtMs,
    Value<int>? utcOffsetMin,
    Value<String?>? tzName,
    Value<String>? localDate,
    Value<int?>? durationS,
    Value<double?>? waterTempC,
    Value<int?>? feelingBefore,
    Value<int?>? feelingAfter,
    Value<String?>? notes,
    Value<int?>? countdownS,
    Value<String?>? warmupExerciseId,
    Value<bool?>? warmupDone,
    Value<int?>? overcomeRating,
    Value<int?>? duringRating,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int?>? deletedAtMs,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return IceSessionsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      entryMode: entryMode ?? this.entryMode,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      endedAtMs: endedAtMs ?? this.endedAtMs,
      utcOffsetMin: utcOffsetMin ?? this.utcOffsetMin,
      tzName: tzName ?? this.tzName,
      localDate: localDate ?? this.localDate,
      durationS: durationS ?? this.durationS,
      waterTempC: waterTempC ?? this.waterTempC,
      feelingBefore: feelingBefore ?? this.feelingBefore,
      feelingAfter: feelingAfter ?? this.feelingAfter,
      notes: notes ?? this.notes,
      countdownS: countdownS ?? this.countdownS,
      warmupExerciseId: warmupExerciseId ?? this.warmupExerciseId,
      warmupDone: warmupDone ?? this.warmupDone,
      overcomeRating: overcomeRating ?? this.overcomeRating,
      duringRating: duringRating ?? this.duringRating,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (entryMode.present) {
      map['entry_mode'] = Variable<String>(entryMode.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (endedAtMs.present) {
      map['ended_at_ms'] = Variable<int>(endedAtMs.value);
    }
    if (utcOffsetMin.present) {
      map['utc_offset_min'] = Variable<int>(utcOffsetMin.value);
    }
    if (tzName.present) {
      map['tz_name'] = Variable<String>(tzName.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (durationS.present) {
      map['duration_s'] = Variable<int>(durationS.value);
    }
    if (waterTempC.present) {
      map['water_temp_c'] = Variable<double>(waterTempC.value);
    }
    if (feelingBefore.present) {
      map['feeling_before'] = Variable<int>(feelingBefore.value);
    }
    if (feelingAfter.present) {
      map['feeling_after'] = Variable<int>(feelingAfter.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (countdownS.present) {
      map['countdown_s'] = Variable<int>(countdownS.value);
    }
    if (warmupExerciseId.present) {
      map['warmup_exercise_id'] = Variable<String>(warmupExerciseId.value);
    }
    if (warmupDone.present) {
      map['warmup_done'] = Variable<bool>(warmupDone.value);
    }
    if (overcomeRating.present) {
      map['overcome_rating'] = Variable<int>(overcomeRating.value);
    }
    if (duringRating.present) {
      map['during_rating'] = Variable<int>(duringRating.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IceSessionsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('entryMode: $entryMode, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('utcOffsetMin: $utcOffsetMin, ')
          ..write('tzName: $tzName, ')
          ..write('localDate: $localDate, ')
          ..write('durationS: $durationS, ')
          ..write('waterTempC: $waterTempC, ')
          ..write('feelingBefore: $feelingBefore, ')
          ..write('feelingAfter: $feelingAfter, ')
          ..write('notes: $notes, ')
          ..write('countdownS: $countdownS, ')
          ..write('warmupExerciseId: $warmupExerciseId, ')
          ..write('warmupDone: $warmupDone, ')
          ..write('overcomeRating: $overcomeRating, ')
          ..write('duringRating: $duringRating, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionPausesTable extends SessionPauses
    with TableInfo<$SessionPausesTable, PauseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionPausesTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES ice_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pausedAtMsMeta = const VerificationMeta(
    'pausedAtMs',
  );
  @override
  late final GeneratedColumn<int> pausedAtMs = GeneratedColumn<int>(
    'paused_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resumedAtMsMeta = const VerificationMeta(
    'resumedAtMs',
  );
  @override
  late final GeneratedColumn<int> resumedAtMs = GeneratedColumn<int>(
    'resumed_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [sessionId, pausedAtMs, resumedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_pauses';
  @override
  VerificationContext validateIntegrity(
    Insertable<PauseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('paused_at_ms')) {
      context.handle(
        _pausedAtMsMeta,
        pausedAtMs.isAcceptableOrUnknown(
          data['paused_at_ms']!,
          _pausedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pausedAtMsMeta);
    }
    if (data.containsKey('resumed_at_ms')) {
      context.handle(
        _resumedAtMsMeta,
        resumedAtMs.isAcceptableOrUnknown(
          data['resumed_at_ms']!,
          _resumedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, pausedAtMs};
  @override
  PauseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PauseRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      pausedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_at_ms'],
      )!,
      resumedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resumed_at_ms'],
      ),
    );
  }

  @override
  $SessionPausesTable createAlias(String alias) {
    return $SessionPausesTable(attachedDatabase, alias);
  }
}

class PauseRow extends DataClass implements Insertable<PauseRow> {
  final String sessionId;
  final int pausedAtMs;
  final int? resumedAtMs;
  const PauseRow({
    required this.sessionId,
    required this.pausedAtMs,
    this.resumedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['paused_at_ms'] = Variable<int>(pausedAtMs);
    if (!nullToAbsent || resumedAtMs != null) {
      map['resumed_at_ms'] = Variable<int>(resumedAtMs);
    }
    return map;
  }

  SessionPausesCompanion toCompanion(bool nullToAbsent) {
    return SessionPausesCompanion(
      sessionId: Value(sessionId),
      pausedAtMs: Value(pausedAtMs),
      resumedAtMs: resumedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(resumedAtMs),
    );
  }

  factory PauseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PauseRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      pausedAtMs: serializer.fromJson<int>(json['pausedAtMs']),
      resumedAtMs: serializer.fromJson<int?>(json['resumedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'pausedAtMs': serializer.toJson<int>(pausedAtMs),
      'resumedAtMs': serializer.toJson<int?>(resumedAtMs),
    };
  }

  PauseRow copyWith({
    String? sessionId,
    int? pausedAtMs,
    Value<int?> resumedAtMs = const Value.absent(),
  }) => PauseRow(
    sessionId: sessionId ?? this.sessionId,
    pausedAtMs: pausedAtMs ?? this.pausedAtMs,
    resumedAtMs: resumedAtMs.present ? resumedAtMs.value : this.resumedAtMs,
  );
  PauseRow copyWithCompanion(SessionPausesCompanion data) {
    return PauseRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      pausedAtMs: data.pausedAtMs.present
          ? data.pausedAtMs.value
          : this.pausedAtMs,
      resumedAtMs: data.resumedAtMs.present
          ? data.resumedAtMs.value
          : this.resumedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PauseRow(')
          ..write('sessionId: $sessionId, ')
          ..write('pausedAtMs: $pausedAtMs, ')
          ..write('resumedAtMs: $resumedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, pausedAtMs, resumedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PauseRow &&
          other.sessionId == this.sessionId &&
          other.pausedAtMs == this.pausedAtMs &&
          other.resumedAtMs == this.resumedAtMs);
}

class SessionPausesCompanion extends UpdateCompanion<PauseRow> {
  final Value<String> sessionId;
  final Value<int> pausedAtMs;
  final Value<int?> resumedAtMs;
  final Value<int> rowid;
  const SessionPausesCompanion({
    this.sessionId = const Value.absent(),
    this.pausedAtMs = const Value.absent(),
    this.resumedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionPausesCompanion.insert({
    required String sessionId,
    required int pausedAtMs,
    this.resumedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       pausedAtMs = Value(pausedAtMs);
  static Insertable<PauseRow> custom({
    Expression<String>? sessionId,
    Expression<int>? pausedAtMs,
    Expression<int>? resumedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (pausedAtMs != null) 'paused_at_ms': pausedAtMs,
      if (resumedAtMs != null) 'resumed_at_ms': resumedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionPausesCompanion copyWith({
    Value<String>? sessionId,
    Value<int>? pausedAtMs,
    Value<int?>? resumedAtMs,
    Value<int>? rowid,
  }) {
    return SessionPausesCompanion(
      sessionId: sessionId ?? this.sessionId,
      pausedAtMs: pausedAtMs ?? this.pausedAtMs,
      resumedAtMs: resumedAtMs ?? this.resumedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (pausedAtMs.present) {
      map['paused_at_ms'] = Variable<int>(pausedAtMs.value);
    }
    if (resumedAtMs.present) {
      map['resumed_at_ms'] = Variable<int>(resumedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionPausesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('pausedAtMs: $pausedAtMs, ')
          ..write('resumedAtMs: $resumedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String? value;
  const SettingRow({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  SettingRow copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => SettingRow(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  SettingRow copyWithCompanion(AppSettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionnaireResultsTable extends QuestionnaireResults
    with TableInfo<$QuestionnaireResultsTable, QuestionnaireRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionnaireResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredAtMsMeta = const VerificationMeta(
    'answeredAtMs',
  );
  @override
  late final GeneratedColumn<int> answeredAtMs = GeneratedColumn<int>(
    'answered_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answersMeta = const VerificationMeta(
    'answers',
  );
  @override
  late final GeneratedColumn<String> answers = GeneratedColumn<String>(
    'answers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    answeredAtMs,
    answers,
    score,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questionnaire_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionnaireRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('answered_at_ms')) {
      context.handle(
        _answeredAtMsMeta,
        answeredAtMs.isAcceptableOrUnknown(
          data['answered_at_ms']!,
          _answeredAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMsMeta);
    }
    if (data.containsKey('answers')) {
      context.handle(
        _answersMeta,
        answers.isAcceptableOrUnknown(data['answers']!, _answersMeta),
      );
    } else if (isInserting) {
      context.missing(_answersMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionnaireRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionnaireRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      answeredAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_at_ms'],
      )!,
      answers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
    );
  }

  @override
  $QuestionnaireResultsTable createAlias(String alias) {
    return $QuestionnaireResultsTable(attachedDatabase, alias);
  }
}

class QuestionnaireRow extends DataClass
    implements Insertable<QuestionnaireRow> {
  final String id;
  final String kind;
  final int answeredAtMs;

  /// Antworten als kommagetrennte Zahlen, z. B. «4,3,5,2,4».
  final String answers;
  final double score;
  const QuestionnaireRow({
    required this.id,
    required this.kind,
    required this.answeredAtMs,
    required this.answers,
    required this.score,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['answered_at_ms'] = Variable<int>(answeredAtMs);
    map['answers'] = Variable<String>(answers);
    map['score'] = Variable<double>(score);
    return map;
  }

  QuestionnaireResultsCompanion toCompanion(bool nullToAbsent) {
    return QuestionnaireResultsCompanion(
      id: Value(id),
      kind: Value(kind),
      answeredAtMs: Value(answeredAtMs),
      answers: Value(answers),
      score: Value(score),
    );
  }

  factory QuestionnaireRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionnaireRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      answeredAtMs: serializer.fromJson<int>(json['answeredAtMs']),
      answers: serializer.fromJson<String>(json['answers']),
      score: serializer.fromJson<double>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'answeredAtMs': serializer.toJson<int>(answeredAtMs),
      'answers': serializer.toJson<String>(answers),
      'score': serializer.toJson<double>(score),
    };
  }

  QuestionnaireRow copyWith({
    String? id,
    String? kind,
    int? answeredAtMs,
    String? answers,
    double? score,
  }) => QuestionnaireRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    answeredAtMs: answeredAtMs ?? this.answeredAtMs,
    answers: answers ?? this.answers,
    score: score ?? this.score,
  );
  QuestionnaireRow copyWithCompanion(QuestionnaireResultsCompanion data) {
    return QuestionnaireRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      answeredAtMs: data.answeredAtMs.present
          ? data.answeredAtMs.value
          : this.answeredAtMs,
      answers: data.answers.present ? data.answers.value : this.answers,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionnaireRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('answeredAtMs: $answeredAtMs, ')
          ..write('answers: $answers, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, answeredAtMs, answers, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionnaireRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.answeredAtMs == this.answeredAtMs &&
          other.answers == this.answers &&
          other.score == this.score);
}

class QuestionnaireResultsCompanion extends UpdateCompanion<QuestionnaireRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<int> answeredAtMs;
  final Value<String> answers;
  final Value<double> score;
  final Value<int> rowid;
  const QuestionnaireResultsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.answeredAtMs = const Value.absent(),
    this.answers = const Value.absent(),
    this.score = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionnaireResultsCompanion.insert({
    required String id,
    required String kind,
    required int answeredAtMs,
    required String answers,
    required double score,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       answeredAtMs = Value(answeredAtMs),
       answers = Value(answers),
       score = Value(score);
  static Insertable<QuestionnaireRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<int>? answeredAtMs,
    Expression<String>? answers,
    Expression<double>? score,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (answeredAtMs != null) 'answered_at_ms': answeredAtMs,
      if (answers != null) 'answers': answers,
      if (score != null) 'score': score,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionnaireResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<int>? answeredAtMs,
    Value<String>? answers,
    Value<double>? score,
    Value<int>? rowid,
  }) {
    return QuestionnaireResultsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      answeredAtMs: answeredAtMs ?? this.answeredAtMs,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (answeredAtMs.present) {
      map['answered_at_ms'] = Variable<int>(answeredAtMs.value);
    }
    if (answers.present) {
      map['answers'] = Variable<String>(answers.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionnaireResultsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('answeredAtMs: $answeredAtMs, ')
          ..write('answers: $answers, ')
          ..write('score: $score, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IceSessionsTable iceSessions = $IceSessionsTable(this);
  late final $SessionPausesTable sessionPauses = $SessionPausesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $QuestionnaireResultsTable questionnaireResults =
      $QuestionnaireResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    iceSessions,
    sessionPauses,
    appSettings,
    questionnaireResults,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ice_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_pauses', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$IceSessionsTableCreateCompanionBuilder =
    IceSessionsCompanion Function({
      required String id,
      required String status,
      required String entryMode,
      required int startedAtMs,
      Value<int?> endedAtMs,
      required int utcOffsetMin,
      Value<String?> tzName,
      required String localDate,
      Value<int?> durationS,
      Value<double?> waterTempC,
      Value<int?> feelingBefore,
      Value<int?> feelingAfter,
      Value<String?> notes,
      Value<int?> countdownS,
      Value<String?> warmupExerciseId,
      Value<bool?> warmupDone,
      Value<int?> overcomeRating,
      Value<int?> duringRating,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$IceSessionsTableUpdateCompanionBuilder =
    IceSessionsCompanion Function({
      Value<String> id,
      Value<String> status,
      Value<String> entryMode,
      Value<int> startedAtMs,
      Value<int?> endedAtMs,
      Value<int> utcOffsetMin,
      Value<String?> tzName,
      Value<String> localDate,
      Value<int?> durationS,
      Value<double?> waterTempC,
      Value<int?> feelingBefore,
      Value<int?> feelingAfter,
      Value<String?> notes,
      Value<int?> countdownS,
      Value<String?> warmupExerciseId,
      Value<bool?> warmupDone,
      Value<int?> overcomeRating,
      Value<int?> duringRating,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> version,
      Value<int> rowid,
    });

final class $$IceSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $IceSessionsTable, IceSessionRow> {
  $$IceSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionPausesTable, List<PauseRow>>
  _sessionPausesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionPauses,
    aliasName: 'ice_sessions__id__session_pauses__session_id',
  );

  $$SessionPausesTableProcessedTableManager get sessionPausesRefs {
    final manager = $$SessionPausesTableTableManager(
      $_db,
      $_db.sessionPauses,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionPausesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IceSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $IceSessionsTable> {
  $$IceSessionsTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryMode => $composableBuilder(
    column: $table.entryMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get utcOffsetMin => $composableBuilder(
    column: $table.utcOffsetMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tzName => $composableBuilder(
    column: $table.tzName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationS => $composableBuilder(
    column: $table.durationS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waterTempC => $composableBuilder(
    column: $table.waterTempC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feelingBefore => $composableBuilder(
    column: $table.feelingBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feelingAfter => $composableBuilder(
    column: $table.feelingAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countdownS => $composableBuilder(
    column: $table.countdownS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warmupExerciseId => $composableBuilder(
    column: $table.warmupExerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get warmupDone => $composableBuilder(
    column: $table.warmupDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overcomeRating => $composableBuilder(
    column: $table.overcomeRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duringRating => $composableBuilder(
    column: $table.duringRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionPausesRefs(
    Expression<bool> Function($$SessionPausesTableFilterComposer f) f,
  ) {
    final $$SessionPausesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionPauses,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionPausesTableFilterComposer(
            $db: $db,
            $table: $db.sessionPauses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IceSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $IceSessionsTable> {
  $$IceSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryMode => $composableBuilder(
    column: $table.entryMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get utcOffsetMin => $composableBuilder(
    column: $table.utcOffsetMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tzName => $composableBuilder(
    column: $table.tzName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationS => $composableBuilder(
    column: $table.durationS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waterTempC => $composableBuilder(
    column: $table.waterTempC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feelingBefore => $composableBuilder(
    column: $table.feelingBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feelingAfter => $composableBuilder(
    column: $table.feelingAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countdownS => $composableBuilder(
    column: $table.countdownS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warmupExerciseId => $composableBuilder(
    column: $table.warmupExerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get warmupDone => $composableBuilder(
    column: $table.warmupDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overcomeRating => $composableBuilder(
    column: $table.overcomeRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duringRating => $composableBuilder(
    column: $table.duringRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IceSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IceSessionsTable> {
  $$IceSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get entryMode =>
      $composableBuilder(column: $table.entryMode, builder: (column) => column);

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAtMs =>
      $composableBuilder(column: $table.endedAtMs, builder: (column) => column);

  GeneratedColumn<int> get utcOffsetMin => $composableBuilder(
    column: $table.utcOffsetMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tzName =>
      $composableBuilder(column: $table.tzName, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get durationS =>
      $composableBuilder(column: $table.durationS, builder: (column) => column);

  GeneratedColumn<double> get waterTempC => $composableBuilder(
    column: $table.waterTempC,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feelingBefore => $composableBuilder(
    column: $table.feelingBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feelingAfter => $composableBuilder(
    column: $table.feelingAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get countdownS => $composableBuilder(
    column: $table.countdownS,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warmupExerciseId => $composableBuilder(
    column: $table.warmupExerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get warmupDone => $composableBuilder(
    column: $table.warmupDone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get overcomeRating => $composableBuilder(
    column: $table.overcomeRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duringRating => $composableBuilder(
    column: $table.duringRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  Expression<T> sessionPausesRefs<T extends Object>(
    Expression<T> Function($$SessionPausesTableAnnotationComposer a) f,
  ) {
    final $$SessionPausesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionPauses,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionPausesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionPauses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IceSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IceSessionsTable,
          IceSessionRow,
          $$IceSessionsTableFilterComposer,
          $$IceSessionsTableOrderingComposer,
          $$IceSessionsTableAnnotationComposer,
          $$IceSessionsTableCreateCompanionBuilder,
          $$IceSessionsTableUpdateCompanionBuilder,
          (IceSessionRow, $$IceSessionsTableReferences),
          IceSessionRow,
          PrefetchHooks Function({bool sessionPausesRefs})
        > {
  $$IceSessionsTableTableManager(_$AppDatabase db, $IceSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IceSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IceSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IceSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> entryMode = const Value.absent(),
                Value<int> startedAtMs = const Value.absent(),
                Value<int?> endedAtMs = const Value.absent(),
                Value<int> utcOffsetMin = const Value.absent(),
                Value<String?> tzName = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int?> durationS = const Value.absent(),
                Value<double?> waterTempC = const Value.absent(),
                Value<int?> feelingBefore = const Value.absent(),
                Value<int?> feelingAfter = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> countdownS = const Value.absent(),
                Value<String?> warmupExerciseId = const Value.absent(),
                Value<bool?> warmupDone = const Value.absent(),
                Value<int?> overcomeRating = const Value.absent(),
                Value<int?> duringRating = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IceSessionsCompanion(
                id: id,
                status: status,
                entryMode: entryMode,
                startedAtMs: startedAtMs,
                endedAtMs: endedAtMs,
                utcOffsetMin: utcOffsetMin,
                tzName: tzName,
                localDate: localDate,
                durationS: durationS,
                waterTempC: waterTempC,
                feelingBefore: feelingBefore,
                feelingAfter: feelingAfter,
                notes: notes,
                countdownS: countdownS,
                warmupExerciseId: warmupExerciseId,
                warmupDone: warmupDone,
                overcomeRating: overcomeRating,
                duringRating: duringRating,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String status,
                required String entryMode,
                required int startedAtMs,
                Value<int?> endedAtMs = const Value.absent(),
                required int utcOffsetMin,
                Value<String?> tzName = const Value.absent(),
                required String localDate,
                Value<int?> durationS = const Value.absent(),
                Value<double?> waterTempC = const Value.absent(),
                Value<int?> feelingBefore = const Value.absent(),
                Value<int?> feelingAfter = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> countdownS = const Value.absent(),
                Value<String?> warmupExerciseId = const Value.absent(),
                Value<bool?> warmupDone = const Value.absent(),
                Value<int?> overcomeRating = const Value.absent(),
                Value<int?> duringRating = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IceSessionsCompanion.insert(
                id: id,
                status: status,
                entryMode: entryMode,
                startedAtMs: startedAtMs,
                endedAtMs: endedAtMs,
                utcOffsetMin: utcOffsetMin,
                tzName: tzName,
                localDate: localDate,
                durationS: durationS,
                waterTempC: waterTempC,
                feelingBefore: feelingBefore,
                feelingAfter: feelingAfter,
                notes: notes,
                countdownS: countdownS,
                warmupExerciseId: warmupExerciseId,
                warmupDone: warmupDone,
                overcomeRating: overcomeRating,
                duringRating: duringRating,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IceSessionsTable, IceSessionRow>(table),
                  $$IceSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionPausesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sessionPausesRefs) db.sessionPauses,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionPausesRefs)
                    await $_getPrefetchedDataByColumns<
                      IceSessionRow,
                      $IceSessionsTable,
                      PauseRow,
                      $SessionPausesTable
                    >(
                      currentTable: table,
                      referencedTable: $$IceSessionsTableReferences
                          ._sessionPausesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$IceSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).sessionPausesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IceSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IceSessionsTable,
      IceSessionRow,
      $$IceSessionsTableFilterComposer,
      $$IceSessionsTableOrderingComposer,
      $$IceSessionsTableAnnotationComposer,
      $$IceSessionsTableCreateCompanionBuilder,
      $$IceSessionsTableUpdateCompanionBuilder,
      (IceSessionRow, $$IceSessionsTableReferences),
      IceSessionRow,
      PrefetchHooks Function({bool sessionPausesRefs})
    >;
typedef $$SessionPausesTableCreateCompanionBuilder =
    SessionPausesCompanion Function({
      required String sessionId,
      required int pausedAtMs,
      Value<int?> resumedAtMs,
      Value<int> rowid,
    });
typedef $$SessionPausesTableUpdateCompanionBuilder =
    SessionPausesCompanion Function({
      Value<String> sessionId,
      Value<int> pausedAtMs,
      Value<int?> resumedAtMs,
      Value<int> rowid,
    });

final class $$SessionPausesTableReferences
    extends BaseReferences<_$AppDatabase, $SessionPausesTable, PauseRow> {
  $$SessionPausesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IceSessionsTable _sessionIdTable(_$AppDatabase db) => db.iceSessions
      .createAlias('session_pauses__session_id__ice_sessions__id');

  $$IceSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$IceSessionsTableTableManager(
      $_db,
      $_db.iceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionPausesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionPausesTable> {
  $$SessionPausesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pausedAtMs => $composableBuilder(
    column: $table.pausedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resumedAtMs => $composableBuilder(
    column: $table.resumedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$IceSessionsTableFilterComposer get sessionId {
    final $$IceSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.iceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IceSessionsTableFilterComposer(
            $db: $db,
            $table: $db.iceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionPausesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionPausesTable> {
  $$SessionPausesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pausedAtMs => $composableBuilder(
    column: $table.pausedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resumedAtMs => $composableBuilder(
    column: $table.resumedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$IceSessionsTableOrderingComposer get sessionId {
    final $$IceSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.iceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IceSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.iceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionPausesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionPausesTable> {
  $$SessionPausesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pausedAtMs => $composableBuilder(
    column: $table.pausedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resumedAtMs => $composableBuilder(
    column: $table.resumedAtMs,
    builder: (column) => column,
  );

  $$IceSessionsTableAnnotationComposer get sessionId {
    final $$IceSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.iceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IceSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.iceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionPausesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionPausesTable,
          PauseRow,
          $$SessionPausesTableFilterComposer,
          $$SessionPausesTableOrderingComposer,
          $$SessionPausesTableAnnotationComposer,
          $$SessionPausesTableCreateCompanionBuilder,
          $$SessionPausesTableUpdateCompanionBuilder,
          (PauseRow, $$SessionPausesTableReferences),
          PauseRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionPausesTableTableManager(_$AppDatabase db, $SessionPausesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionPausesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionPausesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionPausesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<int> pausedAtMs = const Value.absent(),
                Value<int?> resumedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionPausesCompanion(
                sessionId: sessionId,
                pausedAtMs: pausedAtMs,
                resumedAtMs: resumedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required int pausedAtMs,
                Value<int?> resumedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionPausesCompanion.insert(
                sessionId: sessionId,
                pausedAtMs: pausedAtMs,
                resumedAtMs: resumedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionPausesTable, PauseRow>(table),
                  $$SessionPausesTableReferences(db, table, e),
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
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionPausesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionPausesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
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

typedef $$SessionPausesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionPausesTable,
      PauseRow,
      $$SessionPausesTableFilterComposer,
      $$SessionPausesTableOrderingComposer,
      $$SessionPausesTableAnnotationComposer,
      $$SessionPausesTableCreateCompanionBuilder,
      $$SessionPausesTableUpdateCompanionBuilder,
      (PauseRow, $$SessionPausesTableReferences),
      PauseRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          SettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      SettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$QuestionnaireResultsTableCreateCompanionBuilder =
    QuestionnaireResultsCompanion Function({
      required String id,
      required String kind,
      required int answeredAtMs,
      required String answers,
      required double score,
      Value<int> rowid,
    });
typedef $$QuestionnaireResultsTableUpdateCompanionBuilder =
    QuestionnaireResultsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<int> answeredAtMs,
      Value<String> answers,
      Value<double> score,
      Value<int> rowid,
    });

class $$QuestionnaireResultsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionnaireResultsTable> {
  $$QuestionnaireResultsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredAtMs => $composableBuilder(
    column: $table.answeredAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionnaireResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionnaireResultsTable> {
  $$QuestionnaireResultsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAtMs => $composableBuilder(
    column: $table.answeredAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionnaireResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionnaireResultsTable> {
  $$QuestionnaireResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get answeredAtMs => $composableBuilder(
    column: $table.answeredAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answers =>
      $composableBuilder(column: $table.answers, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);
}

class $$QuestionnaireResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionnaireResultsTable,
          QuestionnaireRow,
          $$QuestionnaireResultsTableFilterComposer,
          $$QuestionnaireResultsTableOrderingComposer,
          $$QuestionnaireResultsTableAnnotationComposer,
          $$QuestionnaireResultsTableCreateCompanionBuilder,
          $$QuestionnaireResultsTableUpdateCompanionBuilder,
          (
            QuestionnaireRow,
            BaseReferences<
              _$AppDatabase,
              $QuestionnaireResultsTable,
              QuestionnaireRow
            >,
          ),
          QuestionnaireRow,
          PrefetchHooks Function()
        > {
  $$QuestionnaireResultsTableTableManager(
    _$AppDatabase db,
    $QuestionnaireResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionnaireResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionnaireResultsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$QuestionnaireResultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> answeredAtMs = const Value.absent(),
                Value<String> answers = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionnaireResultsCompanion(
                id: id,
                kind: kind,
                answeredAtMs: answeredAtMs,
                answers: answers,
                score: score,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required int answeredAtMs,
                required String answers,
                required double score,
                Value<int> rowid = const Value.absent(),
              }) => QuestionnaireResultsCompanion.insert(
                id: id,
                kind: kind,
                answeredAtMs: answeredAtMs,
                answers: answers,
                score: score,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestionnaireResultsTable, QuestionnaireRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $QuestionnaireResultsTable,
                    QuestionnaireRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionnaireResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionnaireResultsTable,
      QuestionnaireRow,
      $$QuestionnaireResultsTableFilterComposer,
      $$QuestionnaireResultsTableOrderingComposer,
      $$QuestionnaireResultsTableAnnotationComposer,
      $$QuestionnaireResultsTableCreateCompanionBuilder,
      $$QuestionnaireResultsTableUpdateCompanionBuilder,
      (
        QuestionnaireRow,
        BaseReferences<
          _$AppDatabase,
          $QuestionnaireResultsTable,
          QuestionnaireRow
        >,
      ),
      QuestionnaireRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IceSessionsTableTableManager get iceSessions =>
      $$IceSessionsTableTableManager(_db, _db.iceSessions);
  $$SessionPausesTableTableManager get sessionPauses =>
      $$SessionPausesTableTableManager(_db, _db.sessionPauses);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$QuestionnaireResultsTableTableManager get questionnaireResults =>
      $$QuestionnaireResultsTableTableManager(_db, _db.questionnaireResults);
}
