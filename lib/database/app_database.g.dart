// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageModeMeta =
      const VerificationMeta('storageMode');
  @override
  late final GeneratedColumn<String> storageMode = GeneratedColumn<String>(
      'storage_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _preferredLanguageMeta =
      const VerificationMeta('preferredLanguage');
  @override
  late final GeneratedColumn<String> preferredLanguage =
      GeneratedColumn<String>('preferred_language', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('en'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [userId, displayName, storageMode, preferredLanguage, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('storage_mode')) {
      context.handle(
          _storageModeMeta,
          storageMode.isAcceptableOrUnknown(
              data['storage_mode']!, _storageModeMeta));
    } else if (isInserting) {
      context.missing(_storageModeMeta);
    }
    if (data.containsKey('preferred_language')) {
      context.handle(
          _preferredLanguageMeta,
          preferredLanguage.isAcceptableOrUnknown(
              data['preferred_language']!, _preferredLanguageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
      storageMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_mode'])!,
      preferredLanguage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preferred_language'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String userId;
  final String? displayName;
  final String storageMode;
  final String preferredLanguage;
  final DateTime createdAt;
  const UserProfile(
      {required this.userId,
      this.displayName,
      required this.storageMode,
      required this.preferredLanguage,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['storage_mode'] = Variable<String>(storageMode);
    map['preferred_language'] = Variable<String>(preferredLanguage);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      userId: Value(userId),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      storageMode: Value(storageMode),
      preferredLanguage: Value(preferredLanguage),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      storageMode: serializer.fromJson<String>(json['storageMode']),
      preferredLanguage: serializer.fromJson<String>(json['preferredLanguage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String?>(displayName),
      'storageMode': serializer.toJson<String>(storageMode),
      'preferredLanguage': serializer.toJson<String>(preferredLanguage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfile copyWith(
          {String? userId,
          Value<String?> displayName = const Value.absent(),
          String? storageMode,
          String? preferredLanguage,
          DateTime? createdAt}) =>
      UserProfile(
        userId: userId ?? this.userId,
        displayName: displayName.present ? displayName.value : this.displayName,
        storageMode: storageMode ?? this.storageMode,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        createdAt: createdAt ?? this.createdAt,
      );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      storageMode:
          data.storageMode.present ? data.storageMode.value : this.storageMode,
      preferredLanguage: data.preferredLanguage.present
          ? data.preferredLanguage.value
          : this.preferredLanguage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('storageMode: $storageMode, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId, displayName, storageMode, preferredLanguage, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.storageMode == this.storageMode &&
          other.preferredLanguage == this.preferredLanguage &&
          other.createdAt == this.createdAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> userId;
  final Value<String?> displayName;
  final Value<String> storageMode;
  final Value<String> preferredLanguage;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.storageMode = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String userId,
    this.displayName = const Value.absent(),
    required String storageMode,
    this.preferredLanguage = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        storageMode = Value(storageMode),
        createdAt = Value(createdAt);
  static Insertable<UserProfile> custom({
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? storageMode,
    Expression<String>? preferredLanguage,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (storageMode != null) 'storage_mode': storageMode,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith(
      {Value<String>? userId,
      Value<String?>? displayName,
      Value<String>? storageMode,
      Value<String>? preferredLanguage,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UserProfilesCompanion(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      storageMode: storageMode ?? this.storageMode,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (storageMode.present) {
      map['storage_mode'] = Variable<String>(storageMode.value);
    }
    if (preferredLanguage.present) {
      map['preferred_language'] = Variable<String>(preferredLanguage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('storageMode: $storageMode, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicinesTable extends Medicines
    with TableInfo<$MedicinesTable, Medicine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _medicineIdMeta =
      const VerificationMeta('medicineId');
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
      'medicine_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _medicineNameMeta =
      const VerificationMeta('medicineName');
  @override
  late final GeneratedColumn<String> medicineName = GeneratedColumn<String>(
      'medicine_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _genericNameMeta =
      const VerificationMeta('genericName');
  @override
  late final GeneratedColumn<String> genericName = GeneratedColumn<String>(
      'generic_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _strengthMeta =
      const VerificationMeta('strength');
  @override
  late final GeneratedColumn<String> strength = GeneratedColumn<String>(
      'strength', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _compositionMeta =
      const VerificationMeta('composition');
  @override
  late final GeneratedColumn<String> composition = GeneratedColumn<String>(
      'composition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _manufacturerMeta =
      const VerificationMeta('manufacturer');
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
      'manufacturer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _medicineTypeMeta =
      const VerificationMeta('medicineType');
  @override
  late final GeneratedColumn<String> medicineType = GeneratedColumn<String>(
      'medicine_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
      'dosage', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reminderEnabledMeta =
      const VerificationMeta('reminderEnabled');
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
      'reminder_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reminder_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        medicineId,
        userId,
        medicineName,
        genericName,
        strength,
        composition,
        manufacturer,
        medicineType,
        dosage,
        notes,
        reminderEnabled,
        createdAt,
        updatedAt,
        revision,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(Insertable<Medicine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('medicine_id')) {
      context.handle(
          _medicineIdMeta,
          medicineId.isAcceptableOrUnknown(
              data['medicine_id']!, _medicineIdMeta));
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('medicine_name')) {
      context.handle(
          _medicineNameMeta,
          medicineName.isAcceptableOrUnknown(
              data['medicine_name']!, _medicineNameMeta));
    } else if (isInserting) {
      context.missing(_medicineNameMeta);
    }
    if (data.containsKey('generic_name')) {
      context.handle(
          _genericNameMeta,
          genericName.isAcceptableOrUnknown(
              data['generic_name']!, _genericNameMeta));
    }
    if (data.containsKey('strength')) {
      context.handle(_strengthMeta,
          strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta));
    }
    if (data.containsKey('composition')) {
      context.handle(
          _compositionMeta,
          composition.isAcceptableOrUnknown(
              data['composition']!, _compositionMeta));
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
          _manufacturerMeta,
          manufacturer.isAcceptableOrUnknown(
              data['manufacturer']!, _manufacturerMeta));
    }
    if (data.containsKey('medicine_type')) {
      context.handle(
          _medicineTypeMeta,
          medicineType.isAcceptableOrUnknown(
              data['medicine_type']!, _medicineTypeMeta));
    }
    if (data.containsKey('dosage')) {
      context.handle(_dosageMeta,
          dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
          _reminderEnabledMeta,
          reminderEnabled.isAcceptableOrUnknown(
              data['reminder_enabled']!, _reminderEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {medicineId};
  @override
  Medicine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medicine(
      medicineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medicine_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      medicineName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medicine_name'])!,
      genericName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}generic_name']),
      strength: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}strength']),
      composition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}composition']),
      manufacturer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manufacturer']),
      medicineType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medicine_type']),
      dosage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      reminderEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}reminder_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $MedicinesTable createAlias(String alias) {
    return $MedicinesTable(attachedDatabase, alias);
  }
}

class Medicine extends DataClass implements Insertable<Medicine> {
  final String medicineId;
  final String userId;
  final String medicineName;
  final String? genericName;
  final String? strength;
  final String? composition;
  final String? manufacturer;
  final String? medicineType;
  final String? dosage;
  final String? notes;
  final bool reminderEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int revision;
  final String syncStatus;
  const Medicine(
      {required this.medicineId,
      required this.userId,
      required this.medicineName,
      this.genericName,
      this.strength,
      this.composition,
      this.manufacturer,
      this.medicineType,
      this.dosage,
      this.notes,
      required this.reminderEnabled,
      required this.createdAt,
      required this.updatedAt,
      required this.revision,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['medicine_id'] = Variable<String>(medicineId);
    map['user_id'] = Variable<String>(userId);
    map['medicine_name'] = Variable<String>(medicineName);
    if (!nullToAbsent || genericName != null) {
      map['generic_name'] = Variable<String>(genericName);
    }
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<String>(strength);
    }
    if (!nullToAbsent || composition != null) {
      map['composition'] = Variable<String>(composition);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || medicineType != null) {
      map['medicine_type'] = Variable<String>(medicineType);
    }
    if (!nullToAbsent || dosage != null) {
      map['dosage'] = Variable<String>(dosage);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['revision'] = Variable<int>(revision);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  MedicinesCompanion toCompanion(bool nullToAbsent) {
    return MedicinesCompanion(
      medicineId: Value(medicineId),
      userId: Value(userId),
      medicineName: Value(medicineName),
      genericName: genericName == null && nullToAbsent
          ? const Value.absent()
          : Value(genericName),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      composition: composition == null && nullToAbsent
          ? const Value.absent()
          : Value(composition),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      medicineType: medicineType == null && nullToAbsent
          ? const Value.absent()
          : Value(medicineType),
      dosage:
          dosage == null && nullToAbsent ? const Value.absent() : Value(dosage),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      reminderEnabled: Value(reminderEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
      syncStatus: Value(syncStatus),
    );
  }

  factory Medicine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medicine(
      medicineId: serializer.fromJson<String>(json['medicineId']),
      userId: serializer.fromJson<String>(json['userId']),
      medicineName: serializer.fromJson<String>(json['medicineName']),
      genericName: serializer.fromJson<String?>(json['genericName']),
      strength: serializer.fromJson<String?>(json['strength']),
      composition: serializer.fromJson<String?>(json['composition']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      medicineType: serializer.fromJson<String?>(json['medicineType']),
      dosage: serializer.fromJson<String?>(json['dosage']),
      notes: serializer.fromJson<String?>(json['notes']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'medicineId': serializer.toJson<String>(medicineId),
      'userId': serializer.toJson<String>(userId),
      'medicineName': serializer.toJson<String>(medicineName),
      'genericName': serializer.toJson<String?>(genericName),
      'strength': serializer.toJson<String?>(strength),
      'composition': serializer.toJson<String?>(composition),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'medicineType': serializer.toJson<String?>(medicineType),
      'dosage': serializer.toJson<String?>(dosage),
      'notes': serializer.toJson<String?>(notes),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'revision': serializer.toJson<int>(revision),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Medicine copyWith(
          {String? medicineId,
          String? userId,
          String? medicineName,
          Value<String?> genericName = const Value.absent(),
          Value<String?> strength = const Value.absent(),
          Value<String?> composition = const Value.absent(),
          Value<String?> manufacturer = const Value.absent(),
          Value<String?> medicineType = const Value.absent(),
          Value<String?> dosage = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? reminderEnabled,
          DateTime? createdAt,
          DateTime? updatedAt,
          int? revision,
          String? syncStatus}) =>
      Medicine(
        medicineId: medicineId ?? this.medicineId,
        userId: userId ?? this.userId,
        medicineName: medicineName ?? this.medicineName,
        genericName: genericName.present ? genericName.value : this.genericName,
        strength: strength.present ? strength.value : this.strength,
        composition: composition.present ? composition.value : this.composition,
        manufacturer:
            manufacturer.present ? manufacturer.value : this.manufacturer,
        medicineType:
            medicineType.present ? medicineType.value : this.medicineType,
        dosage: dosage.present ? dosage.value : this.dosage,
        notes: notes.present ? notes.value : this.notes,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        revision: revision ?? this.revision,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Medicine copyWithCompanion(MedicinesCompanion data) {
    return Medicine(
      medicineId:
          data.medicineId.present ? data.medicineId.value : this.medicineId,
      userId: data.userId.present ? data.userId.value : this.userId,
      medicineName: data.medicineName.present
          ? data.medicineName.value
          : this.medicineName,
      genericName:
          data.genericName.present ? data.genericName.value : this.genericName,
      strength: data.strength.present ? data.strength.value : this.strength,
      composition:
          data.composition.present ? data.composition.value : this.composition,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      medicineType: data.medicineType.present
          ? data.medicineType.value
          : this.medicineType,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      notes: data.notes.present ? data.notes.value : this.notes,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medicine(')
          ..write('medicineId: $medicineId, ')
          ..write('userId: $userId, ')
          ..write('medicineName: $medicineName, ')
          ..write('genericName: $genericName, ')
          ..write('strength: $strength, ')
          ..write('composition: $composition, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('medicineType: $medicineType, ')
          ..write('dosage: $dosage, ')
          ..write('notes: $notes, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      medicineId,
      userId,
      medicineName,
      genericName,
      strength,
      composition,
      manufacturer,
      medicineType,
      dosage,
      notes,
      reminderEnabled,
      createdAt,
      updatedAt,
      revision,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medicine &&
          other.medicineId == this.medicineId &&
          other.userId == this.userId &&
          other.medicineName == this.medicineName &&
          other.genericName == this.genericName &&
          other.strength == this.strength &&
          other.composition == this.composition &&
          other.manufacturer == this.manufacturer &&
          other.medicineType == this.medicineType &&
          other.dosage == this.dosage &&
          other.notes == this.notes &&
          other.reminderEnabled == this.reminderEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision &&
          other.syncStatus == this.syncStatus);
}

class MedicinesCompanion extends UpdateCompanion<Medicine> {
  final Value<String> medicineId;
  final Value<String> userId;
  final Value<String> medicineName;
  final Value<String?> genericName;
  final Value<String?> strength;
  final Value<String?> composition;
  final Value<String?> manufacturer;
  final Value<String?> medicineType;
  final Value<String?> dosage;
  final Value<String?> notes;
  final Value<bool> reminderEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> revision;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const MedicinesCompanion({
    this.medicineId = const Value.absent(),
    this.userId = const Value.absent(),
    this.medicineName = const Value.absent(),
    this.genericName = const Value.absent(),
    this.strength = const Value.absent(),
    this.composition = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.medicineType = const Value.absent(),
    this.dosage = const Value.absent(),
    this.notes = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicinesCompanion.insert({
    required String medicineId,
    required String userId,
    required String medicineName,
    this.genericName = const Value.absent(),
    this.strength = const Value.absent(),
    this.composition = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.medicineType = const Value.absent(),
    this.dosage = const Value.absent(),
    this.notes = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.revision = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : medicineId = Value(medicineId),
        userId = Value(userId),
        medicineName = Value(medicineName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Medicine> custom({
    Expression<String>? medicineId,
    Expression<String>? userId,
    Expression<String>? medicineName,
    Expression<String>? genericName,
    Expression<String>? strength,
    Expression<String>? composition,
    Expression<String>? manufacturer,
    Expression<String>? medicineType,
    Expression<String>? dosage,
    Expression<String>? notes,
    Expression<bool>? reminderEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? revision,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (medicineId != null) 'medicine_id': medicineId,
      if (userId != null) 'user_id': userId,
      if (medicineName != null) 'medicine_name': medicineName,
      if (genericName != null) 'generic_name': genericName,
      if (strength != null) 'strength': strength,
      if (composition != null) 'composition': composition,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (medicineType != null) 'medicine_type': medicineType,
      if (dosage != null) 'dosage': dosage,
      if (notes != null) 'notes': notes,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicinesCompanion copyWith(
      {Value<String>? medicineId,
      Value<String>? userId,
      Value<String>? medicineName,
      Value<String?>? genericName,
      Value<String?>? strength,
      Value<String?>? composition,
      Value<String?>? manufacturer,
      Value<String?>? medicineType,
      Value<String?>? dosage,
      Value<String?>? notes,
      Value<bool>? reminderEnabled,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? revision,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return MedicinesCompanion(
      medicineId: medicineId ?? this.medicineId,
      userId: userId ?? this.userId,
      medicineName: medicineName ?? this.medicineName,
      genericName: genericName ?? this.genericName,
      strength: strength ?? this.strength,
      composition: composition ?? this.composition,
      manufacturer: manufacturer ?? this.manufacturer,
      medicineType: medicineType ?? this.medicineType,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (medicineName.present) {
      map['medicine_name'] = Variable<String>(medicineName.value);
    }
    if (genericName.present) {
      map['generic_name'] = Variable<String>(genericName.value);
    }
    if (strength.present) {
      map['strength'] = Variable<String>(strength.value);
    }
    if (composition.present) {
      map['composition'] = Variable<String>(composition.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (medicineType.present) {
      map['medicine_type'] = Variable<String>(medicineType.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesCompanion(')
          ..write('medicineId: $medicineId, ')
          ..write('userId: $userId, ')
          ..write('medicineName: $medicineName, ')
          ..write('genericName: $genericName, ')
          ..write('strength: $strength, ')
          ..write('composition: $composition, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('medicineType: $medicineType, ')
          ..write('dosage: $dosage, ')
          ..write('notes: $notes, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicineImagesTable extends MedicineImages
    with TableInfo<$MedicineImagesTable, MedicineImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicineImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _imageIdMeta =
      const VerificationMeta('imageId');
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
      'image_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _medicineIdMeta =
      const VerificationMeta('medicineId');
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
      'medicine_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES medicines (medicine_id) ON DELETE CASCADE'));
  static const VerificationMeta _imageTypeMeta =
      const VerificationMeta('imageType');
  @override
  late final GeneratedColumn<String> imageType = GeneratedColumn<String>(
      'image_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageSequenceMeta =
      const VerificationMeta('imageSequence');
  @override
  late final GeneratedColumn<int> imageSequence = GeneratedColumn<int>(
      'image_sequence', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cloudPathMeta =
      const VerificationMeta('cloudPath');
  @override
  late final GeneratedColumn<String> cloudPath = GeneratedColumn<String>(
      'cloud_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        imageId,
        medicineId,
        imageType,
        imageSequence,
        localPath,
        cloudPath,
        checksum,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicine_images';
  @override
  VerificationContext validateIntegrity(Insertable<MedicineImage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta));
    } else if (isInserting) {
      context.missing(_imageIdMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
          _medicineIdMeta,
          medicineId.isAcceptableOrUnknown(
              data['medicine_id']!, _medicineIdMeta));
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('image_type')) {
      context.handle(_imageTypeMeta,
          imageType.isAcceptableOrUnknown(data['image_type']!, _imageTypeMeta));
    } else if (isInserting) {
      context.missing(_imageTypeMeta);
    }
    if (data.containsKey('image_sequence')) {
      context.handle(
          _imageSequenceMeta,
          imageSequence.isAcceptableOrUnknown(
              data['image_sequence']!, _imageSequenceMeta));
    } else if (isInserting) {
      context.missing(_imageSequenceMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('cloud_path')) {
      context.handle(_cloudPathMeta,
          cloudPath.isAcceptableOrUnknown(data['cloud_path']!, _cloudPathMeta));
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {imageId};
  @override
  MedicineImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicineImage(
      imageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_id'])!,
      medicineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medicine_id'])!,
      imageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_type'])!,
      imageSequence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}image_sequence'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      cloudPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_path']),
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MedicineImagesTable createAlias(String alias) {
    return $MedicineImagesTable(attachedDatabase, alias);
  }
}

class MedicineImage extends DataClass implements Insertable<MedicineImage> {
  final String imageId;
  final String medicineId;
  final String imageType;
  final int imageSequence;
  final String localPath;
  final String? cloudPath;
  final String? checksum;
  final DateTime createdAt;
  const MedicineImage(
      {required this.imageId,
      required this.medicineId,
      required this.imageType,
      required this.imageSequence,
      required this.localPath,
      this.cloudPath,
      this.checksum,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['image_id'] = Variable<String>(imageId);
    map['medicine_id'] = Variable<String>(medicineId);
    map['image_type'] = Variable<String>(imageType);
    map['image_sequence'] = Variable<int>(imageSequence);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || cloudPath != null) {
      map['cloud_path'] = Variable<String>(cloudPath);
    }
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicineImagesCompanion toCompanion(bool nullToAbsent) {
    return MedicineImagesCompanion(
      imageId: Value(imageId),
      medicineId: Value(medicineId),
      imageType: Value(imageType),
      imageSequence: Value(imageSequence),
      localPath: Value(localPath),
      cloudPath: cloudPath == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudPath),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      createdAt: Value(createdAt),
    );
  }

  factory MedicineImage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicineImage(
      imageId: serializer.fromJson<String>(json['imageId']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      imageType: serializer.fromJson<String>(json['imageType']),
      imageSequence: serializer.fromJson<int>(json['imageSequence']),
      localPath: serializer.fromJson<String>(json['localPath']),
      cloudPath: serializer.fromJson<String?>(json['cloudPath']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'imageId': serializer.toJson<String>(imageId),
      'medicineId': serializer.toJson<String>(medicineId),
      'imageType': serializer.toJson<String>(imageType),
      'imageSequence': serializer.toJson<int>(imageSequence),
      'localPath': serializer.toJson<String>(localPath),
      'cloudPath': serializer.toJson<String?>(cloudPath),
      'checksum': serializer.toJson<String?>(checksum),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicineImage copyWith(
          {String? imageId,
          String? medicineId,
          String? imageType,
          int? imageSequence,
          String? localPath,
          Value<String?> cloudPath = const Value.absent(),
          Value<String?> checksum = const Value.absent(),
          DateTime? createdAt}) =>
      MedicineImage(
        imageId: imageId ?? this.imageId,
        medicineId: medicineId ?? this.medicineId,
        imageType: imageType ?? this.imageType,
        imageSequence: imageSequence ?? this.imageSequence,
        localPath: localPath ?? this.localPath,
        cloudPath: cloudPath.present ? cloudPath.value : this.cloudPath,
        checksum: checksum.present ? checksum.value : this.checksum,
        createdAt: createdAt ?? this.createdAt,
      );
  MedicineImage copyWithCompanion(MedicineImagesCompanion data) {
    return MedicineImage(
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      medicineId:
          data.medicineId.present ? data.medicineId.value : this.medicineId,
      imageType: data.imageType.present ? data.imageType.value : this.imageType,
      imageSequence: data.imageSequence.present
          ? data.imageSequence.value
          : this.imageSequence,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      cloudPath: data.cloudPath.present ? data.cloudPath.value : this.cloudPath,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicineImage(')
          ..write('imageId: $imageId, ')
          ..write('medicineId: $medicineId, ')
          ..write('imageType: $imageType, ')
          ..write('imageSequence: $imageSequence, ')
          ..write('localPath: $localPath, ')
          ..write('cloudPath: $cloudPath, ')
          ..write('checksum: $checksum, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(imageId, medicineId, imageType, imageSequence,
      localPath, cloudPath, checksum, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicineImage &&
          other.imageId == this.imageId &&
          other.medicineId == this.medicineId &&
          other.imageType == this.imageType &&
          other.imageSequence == this.imageSequence &&
          other.localPath == this.localPath &&
          other.cloudPath == this.cloudPath &&
          other.checksum == this.checksum &&
          other.createdAt == this.createdAt);
}

class MedicineImagesCompanion extends UpdateCompanion<MedicineImage> {
  final Value<String> imageId;
  final Value<String> medicineId;
  final Value<String> imageType;
  final Value<int> imageSequence;
  final Value<String> localPath;
  final Value<String?> cloudPath;
  final Value<String?> checksum;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MedicineImagesCompanion({
    this.imageId = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.imageType = const Value.absent(),
    this.imageSequence = const Value.absent(),
    this.localPath = const Value.absent(),
    this.cloudPath = const Value.absent(),
    this.checksum = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicineImagesCompanion.insert({
    required String imageId,
    required String medicineId,
    required String imageType,
    required int imageSequence,
    required String localPath,
    this.cloudPath = const Value.absent(),
    this.checksum = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : imageId = Value(imageId),
        medicineId = Value(medicineId),
        imageType = Value(imageType),
        imageSequence = Value(imageSequence),
        localPath = Value(localPath),
        createdAt = Value(createdAt);
  static Insertable<MedicineImage> custom({
    Expression<String>? imageId,
    Expression<String>? medicineId,
    Expression<String>? imageType,
    Expression<int>? imageSequence,
    Expression<String>? localPath,
    Expression<String>? cloudPath,
    Expression<String>? checksum,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (imageId != null) 'image_id': imageId,
      if (medicineId != null) 'medicine_id': medicineId,
      if (imageType != null) 'image_type': imageType,
      if (imageSequence != null) 'image_sequence': imageSequence,
      if (localPath != null) 'local_path': localPath,
      if (cloudPath != null) 'cloud_path': cloudPath,
      if (checksum != null) 'checksum': checksum,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicineImagesCompanion copyWith(
      {Value<String>? imageId,
      Value<String>? medicineId,
      Value<String>? imageType,
      Value<int>? imageSequence,
      Value<String>? localPath,
      Value<String?>? cloudPath,
      Value<String?>? checksum,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MedicineImagesCompanion(
      imageId: imageId ?? this.imageId,
      medicineId: medicineId ?? this.medicineId,
      imageType: imageType ?? this.imageType,
      imageSequence: imageSequence ?? this.imageSequence,
      localPath: localPath ?? this.localPath,
      cloudPath: cloudPath ?? this.cloudPath,
      checksum: checksum ?? this.checksum,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (imageType.present) {
      map['image_type'] = Variable<String>(imageType.value);
    }
    if (imageSequence.present) {
      map['image_sequence'] = Variable<int>(imageSequence.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (cloudPath.present) {
      map['cloud_path'] = Variable<String>(cloudPath.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicineImagesCompanion(')
          ..write('imageId: $imageId, ')
          ..write('medicineId: $medicineId, ')
          ..write('imageType: $imageType, ')
          ..write('imageSequence: $imageSequence, ')
          ..write('localPath: $localPath, ')
          ..write('cloudPath: $cloudPath, ')
          ..write('checksum: $checksum, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationSchedulesTable extends MedicationSchedules
    with TableInfo<$MedicationSchedulesTable, MedicationSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scheduleIdMeta =
      const VerificationMeta('scheduleId');
  @override
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
      'schedule_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _medicineIdMeta =
      const VerificationMeta('medicineId');
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
      'medicine_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES medicines (medicine_id) ON DELETE CASCADE'));
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
      'time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
      'dosage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _foodInstructionMeta =
      const VerificationMeta('foodInstruction');
  @override
  late final GeneratedColumn<String> foodInstruction = GeneratedColumn<String>(
      'food_instruction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _repeatDaysMeta =
      const VerificationMeta('repeatDays');
  @override
  late final GeneratedColumn<String> repeatDays = GeneratedColumn<String>(
      'repeat_days', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        scheduleId,
        medicineId,
        period,
        time,
        dosage,
        foodInstruction,
        repeatDays,
        timezone,
        startDate,
        endDate,
        enabled,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_schedules';
  @override
  VerificationContext validateIntegrity(Insertable<MedicationSchedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('schedule_id')) {
      context.handle(
          _scheduleIdMeta,
          scheduleId.isAcceptableOrUnknown(
              data['schedule_id']!, _scheduleIdMeta));
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
          _medicineIdMeta,
          medicineId.isAcceptableOrUnknown(
              data['medicine_id']!, _medicineIdMeta));
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(_dosageMeta,
          dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta));
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('food_instruction')) {
      context.handle(
          _foodInstructionMeta,
          foodInstruction.isAcceptableOrUnknown(
              data['food_instruction']!, _foodInstructionMeta));
    } else if (isInserting) {
      context.missing(_foodInstructionMeta);
    }
    if (data.containsKey('repeat_days')) {
      context.handle(
          _repeatDaysMeta,
          repeatDays.isAcceptableOrUnknown(
              data['repeat_days']!, _repeatDaysMeta));
    } else if (isInserting) {
      context.missing(_repeatDaysMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scheduleId};
  @override
  MedicationSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationSchedule(
      scheduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}schedule_id'])!,
      medicineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medicine_id'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
      dosage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage'])!,
      foodInstruction: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}food_instruction'])!,
      repeatDays: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repeat_days'])!,
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MedicationSchedulesTable createAlias(String alias) {
    return $MedicationSchedulesTable(attachedDatabase, alias);
  }
}

class MedicationSchedule extends DataClass
    implements Insertable<MedicationSchedule> {
  final String scheduleId;
  final String medicineId;
  final String period;
  final String time;
  final String dosage;
  final String foodInstruction;
  final String repeatDays;
  final String timezone;
  final DateTime startDate;
  final DateTime? endDate;
  final bool enabled;
  final DateTime createdAt;
  const MedicationSchedule(
      {required this.scheduleId,
      required this.medicineId,
      required this.period,
      required this.time,
      required this.dosage,
      required this.foodInstruction,
      required this.repeatDays,
      required this.timezone,
      required this.startDate,
      this.endDate,
      required this.enabled,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['schedule_id'] = Variable<String>(scheduleId);
    map['medicine_id'] = Variable<String>(medicineId);
    map['period'] = Variable<String>(period);
    map['time'] = Variable<String>(time);
    map['dosage'] = Variable<String>(dosage);
    map['food_instruction'] = Variable<String>(foodInstruction);
    map['repeat_days'] = Variable<String>(repeatDays);
    map['timezone'] = Variable<String>(timezone);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicationSchedulesCompanion toCompanion(bool nullToAbsent) {
    return MedicationSchedulesCompanion(
      scheduleId: Value(scheduleId),
      medicineId: Value(medicineId),
      period: Value(period),
      time: Value(time),
      dosage: Value(dosage),
      foodInstruction: Value(foodInstruction),
      repeatDays: Value(repeatDays),
      timezone: Value(timezone),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
    );
  }

  factory MedicationSchedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationSchedule(
      scheduleId: serializer.fromJson<String>(json['scheduleId']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      period: serializer.fromJson<String>(json['period']),
      time: serializer.fromJson<String>(json['time']),
      dosage: serializer.fromJson<String>(json['dosage']),
      foodInstruction: serializer.fromJson<String>(json['foodInstruction']),
      repeatDays: serializer.fromJson<String>(json['repeatDays']),
      timezone: serializer.fromJson<String>(json['timezone']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scheduleId': serializer.toJson<String>(scheduleId),
      'medicineId': serializer.toJson<String>(medicineId),
      'period': serializer.toJson<String>(period),
      'time': serializer.toJson<String>(time),
      'dosage': serializer.toJson<String>(dosage),
      'foodInstruction': serializer.toJson<String>(foodInstruction),
      'repeatDays': serializer.toJson<String>(repeatDays),
      'timezone': serializer.toJson<String>(timezone),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicationSchedule copyWith(
          {String? scheduleId,
          String? medicineId,
          String? period,
          String? time,
          String? dosage,
          String? foodInstruction,
          String? repeatDays,
          String? timezone,
          DateTime? startDate,
          Value<DateTime?> endDate = const Value.absent(),
          bool? enabled,
          DateTime? createdAt}) =>
      MedicationSchedule(
        scheduleId: scheduleId ?? this.scheduleId,
        medicineId: medicineId ?? this.medicineId,
        period: period ?? this.period,
        time: time ?? this.time,
        dosage: dosage ?? this.dosage,
        foodInstruction: foodInstruction ?? this.foodInstruction,
        repeatDays: repeatDays ?? this.repeatDays,
        timezone: timezone ?? this.timezone,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        enabled: enabled ?? this.enabled,
        createdAt: createdAt ?? this.createdAt,
      );
  MedicationSchedule copyWithCompanion(MedicationSchedulesCompanion data) {
    return MedicationSchedule(
      scheduleId:
          data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
      medicineId:
          data.medicineId.present ? data.medicineId.value : this.medicineId,
      period: data.period.present ? data.period.value : this.period,
      time: data.time.present ? data.time.value : this.time,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      foodInstruction: data.foodInstruction.present
          ? data.foodInstruction.value
          : this.foodInstruction,
      repeatDays:
          data.repeatDays.present ? data.repeatDays.value : this.repeatDays,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationSchedule(')
          ..write('scheduleId: $scheduleId, ')
          ..write('medicineId: $medicineId, ')
          ..write('period: $period, ')
          ..write('time: $time, ')
          ..write('dosage: $dosage, ')
          ..write('foodInstruction: $foodInstruction, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('timezone: $timezone, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      scheduleId,
      medicineId,
      period,
      time,
      dosage,
      foodInstruction,
      repeatDays,
      timezone,
      startDate,
      endDate,
      enabled,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationSchedule &&
          other.scheduleId == this.scheduleId &&
          other.medicineId == this.medicineId &&
          other.period == this.period &&
          other.time == this.time &&
          other.dosage == this.dosage &&
          other.foodInstruction == this.foodInstruction &&
          other.repeatDays == this.repeatDays &&
          other.timezone == this.timezone &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt);
}

class MedicationSchedulesCompanion extends UpdateCompanion<MedicationSchedule> {
  final Value<String> scheduleId;
  final Value<String> medicineId;
  final Value<String> period;
  final Value<String> time;
  final Value<String> dosage;
  final Value<String> foodInstruction;
  final Value<String> repeatDays;
  final Value<String> timezone;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MedicationSchedulesCompanion({
    this.scheduleId = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.period = const Value.absent(),
    this.time = const Value.absent(),
    this.dosage = const Value.absent(),
    this.foodInstruction = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.timezone = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationSchedulesCompanion.insert({
    required String scheduleId,
    required String medicineId,
    required String period,
    required String time,
    required String dosage,
    required String foodInstruction,
    required String repeatDays,
    required String timezone,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.enabled = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : scheduleId = Value(scheduleId),
        medicineId = Value(medicineId),
        period = Value(period),
        time = Value(time),
        dosage = Value(dosage),
        foodInstruction = Value(foodInstruction),
        repeatDays = Value(repeatDays),
        timezone = Value(timezone),
        startDate = Value(startDate),
        createdAt = Value(createdAt);
  static Insertable<MedicationSchedule> custom({
    Expression<String>? scheduleId,
    Expression<String>? medicineId,
    Expression<String>? period,
    Expression<String>? time,
    Expression<String>? dosage,
    Expression<String>? foodInstruction,
    Expression<String>? repeatDays,
    Expression<String>? timezone,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (medicineId != null) 'medicine_id': medicineId,
      if (period != null) 'period': period,
      if (time != null) 'time': time,
      if (dosage != null) 'dosage': dosage,
      if (foodInstruction != null) 'food_instruction': foodInstruction,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (timezone != null) 'timezone': timezone,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationSchedulesCompanion copyWith(
      {Value<String>? scheduleId,
      Value<String>? medicineId,
      Value<String>? period,
      Value<String>? time,
      Value<String>? dosage,
      Value<String>? foodInstruction,
      Value<String>? repeatDays,
      Value<String>? timezone,
      Value<DateTime>? startDate,
      Value<DateTime?>? endDate,
      Value<bool>? enabled,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MedicationSchedulesCompanion(
      scheduleId: scheduleId ?? this.scheduleId,
      medicineId: medicineId ?? this.medicineId,
      period: period ?? this.period,
      time: time ?? this.time,
      dosage: dosage ?? this.dosage,
      foodInstruction: foodInstruction ?? this.foodInstruction,
      repeatDays: repeatDays ?? this.repeatDays,
      timezone: timezone ?? this.timezone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (foodInstruction.present) {
      map['food_instruction'] = Variable<String>(foodInstruction.value);
    }
    if (repeatDays.present) {
      map['repeat_days'] = Variable<String>(repeatDays.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationSchedulesCompanion(')
          ..write('scheduleId: $scheduleId, ')
          ..write('medicineId: $medicineId, ')
          ..write('period: $period, ')
          ..write('time: $time, ')
          ..write('dosage: $dosage, ')
          ..write('foodInstruction: $foodInstruction, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('timezone: $timezone, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DoseHistoryTable extends DoseHistory
    with TableInfo<$DoseHistoryTable, DoseHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoseHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _doseIdMeta = const VerificationMeta('doseId');
  @override
  late final GeneratedColumn<String> doseId = GeneratedColumn<String>(
      'dose_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduleIdMeta =
      const VerificationMeta('scheduleId');
  @override
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
      'schedule_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _actionAtMeta =
      const VerificationMeta('actionAt');
  @override
  late final GeneratedColumn<DateTime> actionAt = GeneratedColumn<DateTime>(
      'action_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [doseId, scheduleId, scheduledAt, actionAt, status, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dose_history';
  @override
  VerificationContext validateIntegrity(Insertable<DoseHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dose_id')) {
      context.handle(_doseIdMeta,
          doseId.isAcceptableOrUnknown(data['dose_id']!, _doseIdMeta));
    } else if (isInserting) {
      context.missing(_doseIdMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
          _scheduleIdMeta,
          scheduleId.isAcceptableOrUnknown(
              data['schedule_id']!, _scheduleIdMeta));
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('action_at')) {
      context.handle(_actionAtMeta,
          actionAt.isAcceptableOrUnknown(data['action_at']!, _actionAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {doseId};
  @override
  DoseHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoseHistoryData(
      doseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dose_id'])!,
      scheduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}schedule_id'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at'])!,
      actionAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}action_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $DoseHistoryTable createAlias(String alias) {
    return $DoseHistoryTable(attachedDatabase, alias);
  }
}

class DoseHistoryData extends DataClass implements Insertable<DoseHistoryData> {
  final String doseId;
  final String scheduleId;
  final DateTime scheduledAt;
  final DateTime? actionAt;
  final String status;
  final String? notes;
  const DoseHistoryData(
      {required this.doseId,
      required this.scheduleId,
      required this.scheduledAt,
      this.actionAt,
      required this.status,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dose_id'] = Variable<String>(doseId);
    map['schedule_id'] = Variable<String>(scheduleId);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || actionAt != null) {
      map['action_at'] = Variable<DateTime>(actionAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DoseHistoryCompanion toCompanion(bool nullToAbsent) {
    return DoseHistoryCompanion(
      doseId: Value(doseId),
      scheduleId: Value(scheduleId),
      scheduledAt: Value(scheduledAt),
      actionAt: actionAt == null && nullToAbsent
          ? const Value.absent()
          : Value(actionAt),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory DoseHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoseHistoryData(
      doseId: serializer.fromJson<String>(json['doseId']),
      scheduleId: serializer.fromJson<String>(json['scheduleId']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      actionAt: serializer.fromJson<DateTime?>(json['actionAt']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'doseId': serializer.toJson<String>(doseId),
      'scheduleId': serializer.toJson<String>(scheduleId),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'actionAt': serializer.toJson<DateTime?>(actionAt),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DoseHistoryData copyWith(
          {String? doseId,
          String? scheduleId,
          DateTime? scheduledAt,
          Value<DateTime?> actionAt = const Value.absent(),
          String? status,
          Value<String?> notes = const Value.absent()}) =>
      DoseHistoryData(
        doseId: doseId ?? this.doseId,
        scheduleId: scheduleId ?? this.scheduleId,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        actionAt: actionAt.present ? actionAt.value : this.actionAt,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
      );
  DoseHistoryData copyWithCompanion(DoseHistoryCompanion data) {
    return DoseHistoryData(
      doseId: data.doseId.present ? data.doseId.value : this.doseId,
      scheduleId:
          data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      actionAt: data.actionAt.present ? data.actionAt.value : this.actionAt,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoseHistoryData(')
          ..write('doseId: $doseId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('actionAt: $actionAt, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(doseId, scheduleId, scheduledAt, actionAt, status, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoseHistoryData &&
          other.doseId == this.doseId &&
          other.scheduleId == this.scheduleId &&
          other.scheduledAt == this.scheduledAt &&
          other.actionAt == this.actionAt &&
          other.status == this.status &&
          other.notes == this.notes);
}

class DoseHistoryCompanion extends UpdateCompanion<DoseHistoryData> {
  final Value<String> doseId;
  final Value<String> scheduleId;
  final Value<DateTime> scheduledAt;
  final Value<DateTime?> actionAt;
  final Value<String> status;
  final Value<String?> notes;
  final Value<int> rowid;
  const DoseHistoryCompanion({
    this.doseId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.actionAt = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoseHistoryCompanion.insert({
    required String doseId,
    required String scheduleId,
    required DateTime scheduledAt,
    this.actionAt = const Value.absent(),
    required String status,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : doseId = Value(doseId),
        scheduleId = Value(scheduleId),
        scheduledAt = Value(scheduledAt),
        status = Value(status);
  static Insertable<DoseHistoryData> custom({
    Expression<String>? doseId,
    Expression<String>? scheduleId,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? actionAt,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (doseId != null) 'dose_id': doseId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (actionAt != null) 'action_at': actionAt,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoseHistoryCompanion copyWith(
      {Value<String>? doseId,
      Value<String>? scheduleId,
      Value<DateTime>? scheduledAt,
      Value<DateTime?>? actionAt,
      Value<String>? status,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return DoseHistoryCompanion(
      doseId: doseId ?? this.doseId,
      scheduleId: scheduleId ?? this.scheduleId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      actionAt: actionAt ?? this.actionAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (doseId.present) {
      map['dose_id'] = Variable<String>(doseId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (actionAt.present) {
      map['action_at'] = Variable<DateTime>(actionAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoseHistoryCompanion(')
          ..write('doseId: $doseId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('actionAt: $actionAt, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageEmbeddingsTable extends ImageEmbeddings
    with TableInfo<$ImageEmbeddingsTable, ImageEmbedding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _embeddingIdMeta =
      const VerificationMeta('embeddingId');
  @override
  late final GeneratedColumn<String> embeddingId = GeneratedColumn<String>(
      'embedding_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _medicineIdMeta =
      const VerificationMeta('medicineId');
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
      'medicine_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES medicines (medicine_id) ON DELETE CASCADE'));
  static const VerificationMeta _imageIdMeta =
      const VerificationMeta('imageId');
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
      'image_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES medicine_images (image_id) ON DELETE CASCADE'));
  static const VerificationMeta _vectorJsonMeta =
      const VerificationMeta('vectorJson');
  @override
  late final GeneratedColumn<String> vectorJson = GeneratedColumn<String>(
      'vector_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [embeddingId, medicineId, imageId, vectorJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_embeddings';
  @override
  VerificationContext validateIntegrity(Insertable<ImageEmbedding> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('embedding_id')) {
      context.handle(
          _embeddingIdMeta,
          embeddingId.isAcceptableOrUnknown(
              data['embedding_id']!, _embeddingIdMeta));
    } else if (isInserting) {
      context.missing(_embeddingIdMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
          _medicineIdMeta,
          medicineId.isAcceptableOrUnknown(
              data['medicine_id']!, _medicineIdMeta));
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta));
    } else if (isInserting) {
      context.missing(_imageIdMeta);
    }
    if (data.containsKey('vector_json')) {
      context.handle(
          _vectorJsonMeta,
          vectorJson.isAcceptableOrUnknown(
              data['vector_json']!, _vectorJsonMeta));
    } else if (isInserting) {
      context.missing(_vectorJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {embeddingId};
  @override
  ImageEmbedding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageEmbedding(
      embeddingId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}embedding_id'])!,
      medicineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medicine_id'])!,
      imageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_id'])!,
      vectorJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vector_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ImageEmbeddingsTable createAlias(String alias) {
    return $ImageEmbeddingsTable(attachedDatabase, alias);
  }
}

class ImageEmbedding extends DataClass implements Insertable<ImageEmbedding> {
  final String embeddingId;
  final String medicineId;
  final String imageId;
  final String vectorJson;
  final DateTime createdAt;
  const ImageEmbedding(
      {required this.embeddingId,
      required this.medicineId,
      required this.imageId,
      required this.vectorJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['embedding_id'] = Variable<String>(embeddingId);
    map['medicine_id'] = Variable<String>(medicineId);
    map['image_id'] = Variable<String>(imageId);
    map['vector_json'] = Variable<String>(vectorJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ImageEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return ImageEmbeddingsCompanion(
      embeddingId: Value(embeddingId),
      medicineId: Value(medicineId),
      imageId: Value(imageId),
      vectorJson: Value(vectorJson),
      createdAt: Value(createdAt),
    );
  }

  factory ImageEmbedding.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageEmbedding(
      embeddingId: serializer.fromJson<String>(json['embeddingId']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      imageId: serializer.fromJson<String>(json['imageId']),
      vectorJson: serializer.fromJson<String>(json['vectorJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'embeddingId': serializer.toJson<String>(embeddingId),
      'medicineId': serializer.toJson<String>(medicineId),
      'imageId': serializer.toJson<String>(imageId),
      'vectorJson': serializer.toJson<String>(vectorJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ImageEmbedding copyWith(
          {String? embeddingId,
          String? medicineId,
          String? imageId,
          String? vectorJson,
          DateTime? createdAt}) =>
      ImageEmbedding(
        embeddingId: embeddingId ?? this.embeddingId,
        medicineId: medicineId ?? this.medicineId,
        imageId: imageId ?? this.imageId,
        vectorJson: vectorJson ?? this.vectorJson,
        createdAt: createdAt ?? this.createdAt,
      );
  ImageEmbedding copyWithCompanion(ImageEmbeddingsCompanion data) {
    return ImageEmbedding(
      embeddingId:
          data.embeddingId.present ? data.embeddingId.value : this.embeddingId,
      medicineId:
          data.medicineId.present ? data.medicineId.value : this.medicineId,
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      vectorJson:
          data.vectorJson.present ? data.vectorJson.value : this.vectorJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageEmbedding(')
          ..write('embeddingId: $embeddingId, ')
          ..write('medicineId: $medicineId, ')
          ..write('imageId: $imageId, ')
          ..write('vectorJson: $vectorJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(embeddingId, medicineId, imageId, vectorJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageEmbedding &&
          other.embeddingId == this.embeddingId &&
          other.medicineId == this.medicineId &&
          other.imageId == this.imageId &&
          other.vectorJson == this.vectorJson &&
          other.createdAt == this.createdAt);
}

class ImageEmbeddingsCompanion extends UpdateCompanion<ImageEmbedding> {
  final Value<String> embeddingId;
  final Value<String> medicineId;
  final Value<String> imageId;
  final Value<String> vectorJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ImageEmbeddingsCompanion({
    this.embeddingId = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.imageId = const Value.absent(),
    this.vectorJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageEmbeddingsCompanion.insert({
    required String embeddingId,
    required String medicineId,
    required String imageId,
    required String vectorJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : embeddingId = Value(embeddingId),
        medicineId = Value(medicineId),
        imageId = Value(imageId),
        vectorJson = Value(vectorJson),
        createdAt = Value(createdAt);
  static Insertable<ImageEmbedding> custom({
    Expression<String>? embeddingId,
    Expression<String>? medicineId,
    Expression<String>? imageId,
    Expression<String>? vectorJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (embeddingId != null) 'embedding_id': embeddingId,
      if (medicineId != null) 'medicine_id': medicineId,
      if (imageId != null) 'image_id': imageId,
      if (vectorJson != null) 'vector_json': vectorJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageEmbeddingsCompanion copyWith(
      {Value<String>? embeddingId,
      Value<String>? medicineId,
      Value<String>? imageId,
      Value<String>? vectorJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ImageEmbeddingsCompanion(
      embeddingId: embeddingId ?? this.embeddingId,
      medicineId: medicineId ?? this.medicineId,
      imageId: imageId ?? this.imageId,
      vectorJson: vectorJson ?? this.vectorJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (embeddingId.present) {
      map['embedding_id'] = Variable<String>(embeddingId.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
    }
    if (vectorJson.present) {
      map['vector_json'] = Variable<String>(vectorJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageEmbeddingsCompanion(')
          ..write('embeddingId: $embeddingId, ')
          ..write('medicineId: $medicineId, ')
          ..write('imageId: $imageId, ')
          ..write('vectorJson: $vectorJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  late final $MedicineImagesTable medicineImages = $MedicineImagesTable(this);
  late final $MedicationSchedulesTable medicationSchedules =
      $MedicationSchedulesTable(this);
  late final $DoseHistoryTable doseHistory = $DoseHistoryTable(this);
  late final $ImageEmbeddingsTable imageEmbeddings =
      $ImageEmbeddingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        userProfiles,
        medicines,
        medicineImages,
        medicationSchedules,
        doseHistory,
        imageEmbeddings
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('medicines',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('medicine_images', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('medicines',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('medication_schedules', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('medicines',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('image_embeddings', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('medicine_images',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('image_embeddings', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$UserProfilesTableCreateCompanionBuilder = UserProfilesCompanion
    Function({
  required String userId,
  Value<String?> displayName,
  required String storageMode,
  Value<String> preferredLanguage,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UserProfilesTableUpdateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<String> userId,
  Value<String?> displayName,
  Value<String> storageMode,
  Value<String> preferredLanguage,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get storageMode => $composableBuilder(
      column: $table.storageMode, builder: (column) => column);

  GeneratedColumn<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()> {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<String> storageMode = const Value.absent(),
            Value<String> preferredLanguage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion(
            userId: userId,
            displayName: displayName,
            storageMode: storageMode,
            preferredLanguage: preferredLanguage,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<String?> displayName = const Value.absent(),
            required String storageMode,
            Value<String> preferredLanguage = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion.insert(
            userId: userId,
            displayName: displayName,
            storageMode: storageMode,
            preferredLanguage: preferredLanguage,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$UserProfilesTable, UserProfile>(table),
                    BaseReferences<_$AppDatabase, $UserProfilesTable,
                        UserProfile>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()>;
typedef $$MedicinesTableCreateCompanionBuilder = MedicinesCompanion Function({
  required String medicineId,
  required String userId,
  required String medicineName,
  Value<String?> genericName,
  Value<String?> strength,
  Value<String?> composition,
  Value<String?> manufacturer,
  Value<String?> medicineType,
  Value<String?> dosage,
  Value<String?> notes,
  Value<bool> reminderEnabled,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> revision,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$MedicinesTableUpdateCompanionBuilder = MedicinesCompanion Function({
  Value<String> medicineId,
  Value<String> userId,
  Value<String> medicineName,
  Value<String?> genericName,
  Value<String?> strength,
  Value<String?> composition,
  Value<String?> manufacturer,
  Value<String?> medicineType,
  Value<String?> dosage,
  Value<String?> notes,
  Value<bool> reminderEnabled,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> revision,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$MedicinesTableReferences
    extends BaseReferences<_$AppDatabase, $MedicinesTable, Medicine> {
  $$MedicinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MedicineImagesTable, List<MedicineImage>>
      _medicineImagesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.medicineImages,
              aliasName:
                  'medicines__medicine_id__medicine_images__medicine_id');

  $$MedicineImagesTableProcessedTableManager get medicineImagesRefs {
    final manager = $$MedicineImagesTableTableManager($_db, $_db.medicineImages)
        .filter((f) => f.medicineId.medicineId
            .sqlEquals($_itemColumn<String>('medicine_id')!));

    final cache = $_typedResult.readTableOrNull(_medicineImagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MedicationSchedulesTable,
      List<MedicationSchedule>> _medicationSchedulesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.medicationSchedules,
          aliasName:
              'medicines__medicine_id__medication_schedules__medicine_id');

  $$MedicationSchedulesTableProcessedTableManager get medicationSchedulesRefs {
    final manager =
        $$MedicationSchedulesTableTableManager($_db, $_db.medicationSchedules)
            .filter((f) => f.medicineId.medicineId
                .sqlEquals($_itemColumn<String>('medicine_id')!));

    final cache =
        $_typedResult.readTableOrNull(_medicationSchedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ImageEmbeddingsTable, List<ImageEmbedding>>
      _imageEmbeddingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.imageEmbeddings,
              aliasName:
                  'medicines__medicine_id__image_embeddings__medicine_id');

  $$ImageEmbeddingsTableProcessedTableManager get imageEmbeddingsRefs {
    final manager =
        $$ImageEmbeddingsTableTableManager($_db, $_db.imageEmbeddings).filter(
            (f) => f.medicineId.medicineId
                .sqlEquals($_itemColumn<String>('medicine_id')!));

    final cache =
        $_typedResult.readTableOrNull(_imageEmbeddingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MedicinesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get medicineId => $composableBuilder(
      column: $table.medicineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicineName => $composableBuilder(
      column: $table.medicineName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get genericName => $composableBuilder(
      column: $table.genericName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get composition => $composableBuilder(
      column: $table.composition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicineType => $composableBuilder(
      column: $table.medicineType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
      column: $table.reminderEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  Expression<bool> medicineImagesRefs(
      Expression<bool> Function($$MedicineImagesTableFilterComposer f) f) {
    final $$MedicineImagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicineImages,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicineImagesTableFilterComposer(
              $db: $db,
              $table: $db.medicineImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> medicationSchedulesRefs(
      Expression<bool> Function($$MedicationSchedulesTableFilterComposer f) f) {
    final $$MedicationSchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicationSchedules,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationSchedulesTableFilterComposer(
              $db: $db,
              $table: $db.medicationSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> imageEmbeddingsRefs(
      Expression<bool> Function($$ImageEmbeddingsTableFilterComposer f) f) {
    final $$ImageEmbeddingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.imageEmbeddings,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImageEmbeddingsTableFilterComposer(
              $db: $db,
              $table: $db.imageEmbeddings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MedicinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get medicineId => $composableBuilder(
      column: $table.medicineId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicineName => $composableBuilder(
      column: $table.medicineName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get genericName => $composableBuilder(
      column: $table.genericName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get composition => $composableBuilder(
      column: $table.composition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicineType => $composableBuilder(
      column: $table.medicineType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
      column: $table.reminderEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$MedicinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get medicineId => $composableBuilder(
      column: $table.medicineId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get medicineName => $composableBuilder(
      column: $table.medicineName, builder: (column) => column);

  GeneratedColumn<String> get genericName => $composableBuilder(
      column: $table.genericName, builder: (column) => column);

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get composition => $composableBuilder(
      column: $table.composition, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => column);

  GeneratedColumn<String> get medicineType => $composableBuilder(
      column: $table.medicineType, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
      column: $table.reminderEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  Expression<T> medicineImagesRefs<T extends Object>(
      Expression<T> Function($$MedicineImagesTableAnnotationComposer a) f) {
    final $$MedicineImagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicineImages,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicineImagesTableAnnotationComposer(
              $db: $db,
              $table: $db.medicineImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> medicationSchedulesRefs<T extends Object>(
      Expression<T> Function($$MedicationSchedulesTableAnnotationComposer a)
          f) {
    final $$MedicationSchedulesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.medicineId,
            referencedTable: $db.medicationSchedules,
            getReferencedColumn: (t) => t.medicineId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MedicationSchedulesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.medicationSchedules,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> imageEmbeddingsRefs<T extends Object>(
      Expression<T> Function($$ImageEmbeddingsTableAnnotationComposer a) f) {
    final $$ImageEmbeddingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.imageEmbeddings,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImageEmbeddingsTableAnnotationComposer(
              $db: $db,
              $table: $db.imageEmbeddings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MedicinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicinesTable,
    Medicine,
    $$MedicinesTableFilterComposer,
    $$MedicinesTableOrderingComposer,
    $$MedicinesTableAnnotationComposer,
    $$MedicinesTableCreateCompanionBuilder,
    $$MedicinesTableUpdateCompanionBuilder,
    (Medicine, $$MedicinesTableReferences),
    Medicine,
    PrefetchHooks Function(
        {bool medicineImagesRefs,
        bool medicationSchedulesRefs,
        bool imageEmbeddingsRefs})> {
  $$MedicinesTableTableManager(_$AppDatabase db, $MedicinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> medicineId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> medicineName = const Value.absent(),
            Value<String?> genericName = const Value.absent(),
            Value<String?> strength = const Value.absent(),
            Value<String?> composition = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> medicineType = const Value.absent(),
            Value<String?> dosage = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> reminderEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicinesCompanion(
            medicineId: medicineId,
            userId: userId,
            medicineName: medicineName,
            genericName: genericName,
            strength: strength,
            composition: composition,
            manufacturer: manufacturer,
            medicineType: medicineType,
            dosage: dosage,
            notes: notes,
            reminderEnabled: reminderEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            revision: revision,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String medicineId,
            required String userId,
            required String medicineName,
            Value<String?> genericName = const Value.absent(),
            Value<String?> strength = const Value.absent(),
            Value<String?> composition = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> medicineType = const Value.absent(),
            Value<String?> dosage = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> reminderEnabled = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> revision = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicinesCompanion.insert(
            medicineId: medicineId,
            userId: userId,
            medicineName: medicineName,
            genericName: genericName,
            strength: strength,
            composition: composition,
            manufacturer: manufacturer,
            medicineType: medicineType,
            dosage: dosage,
            notes: notes,
            reminderEnabled: reminderEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            revision: revision,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MedicinesTable, Medicine>(table),
                    $$MedicinesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {medicineImagesRefs = false,
              medicationSchedulesRefs = false,
              imageEmbeddingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (medicineImagesRefs) db.medicineImages,
                if (medicationSchedulesRefs) db.medicationSchedules,
                if (imageEmbeddingsRefs) db.imageEmbeddings
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (medicineImagesRefs)
                    await $_getPrefetchedDataByColumns<
                            Medicine,
                            $MedicinesTable,
                            MedicineImage,
                            $MedicineImagesTable>(
                        currentTable: table,
                        referencedTable: $$MedicinesTableReferences
                            ._medicineImagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MedicinesTableReferences(db, table, p0)
                                .medicineImagesRefs,
                        currentColumn: 'medicine_id',
                        referencedColumn: 'medicine_id',
                        typedResults: items),
                  if (medicationSchedulesRefs)
                    await $_getPrefetchedDataByColumns<
                            Medicine,
                            $MedicinesTable,
                            MedicationSchedule,
                            $MedicationSchedulesTable>(
                        currentTable: table,
                        referencedTable: $$MedicinesTableReferences
                            ._medicationSchedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MedicinesTableReferences(db, table, p0)
                                .medicationSchedulesRefs,
                        currentColumn: 'medicine_id',
                        referencedColumn: 'medicine_id',
                        typedResults: items),
                  if (imageEmbeddingsRefs)
                    await $_getPrefetchedDataByColumns<
                            Medicine,
                            $MedicinesTable,
                            ImageEmbedding,
                            $ImageEmbeddingsTable>(
                        currentTable: table,
                        referencedTable: $$MedicinesTableReferences
                            ._imageEmbeddingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MedicinesTableReferences(db, table, p0)
                                .imageEmbeddingsRefs,
                        currentColumn: 'medicine_id',
                        referencedColumn: 'medicine_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MedicinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicinesTable,
    Medicine,
    $$MedicinesTableFilterComposer,
    $$MedicinesTableOrderingComposer,
    $$MedicinesTableAnnotationComposer,
    $$MedicinesTableCreateCompanionBuilder,
    $$MedicinesTableUpdateCompanionBuilder,
    (Medicine, $$MedicinesTableReferences),
    Medicine,
    PrefetchHooks Function(
        {bool medicineImagesRefs,
        bool medicationSchedulesRefs,
        bool imageEmbeddingsRefs})>;
typedef $$MedicineImagesTableCreateCompanionBuilder = MedicineImagesCompanion
    Function({
  required String imageId,
  required String medicineId,
  required String imageType,
  required int imageSequence,
  required String localPath,
  Value<String?> cloudPath,
  Value<String?> checksum,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MedicineImagesTableUpdateCompanionBuilder = MedicineImagesCompanion
    Function({
  Value<String> imageId,
  Value<String> medicineId,
  Value<String> imageType,
  Value<int> imageSequence,
  Value<String> localPath,
  Value<String?> cloudPath,
  Value<String?> checksum,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$MedicineImagesTableReferences
    extends BaseReferences<_$AppDatabase, $MedicineImagesTable, MedicineImage> {
  $$MedicineImagesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) => db.medicines
      .createAlias('medicine_images__medicine_id__medicines__medicine_id');

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<String>('medicine_id')!;

    final manager = $$MedicinesTableTableManager($_db, $_db.medicines)
        .filter((f) => f.medicineId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ImageEmbeddingsTable, List<ImageEmbedding>>
      _imageEmbeddingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.imageEmbeddings,
              aliasName:
                  'medicine_images__image_id__image_embeddings__image_id');

  $$ImageEmbeddingsTableProcessedTableManager get imageEmbeddingsRefs {
    final manager =
        $$ImageEmbeddingsTableTableManager($_db, $_db.imageEmbeddings).filter(
            (f) =>
                f.imageId.imageId.sqlEquals($_itemColumn<String>('image_id')!));

    final cache =
        $_typedResult.readTableOrNull(_imageEmbeddingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MedicineImagesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicineImagesTable> {
  $$MedicineImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get imageId => $composableBuilder(
      column: $table.imageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageType => $composableBuilder(
      column: $table.imageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get imageSequence => $composableBuilder(
      column: $table.imageSequence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudPath => $composableBuilder(
      column: $table.cloudPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicines,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicinesTableFilterComposer(
              $db: $db,
              $table: $db.medicines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> imageEmbeddingsRefs(
      Expression<bool> Function($$ImageEmbeddingsTableFilterComposer f) f) {
    final $$ImageEmbeddingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.imageEmbeddings,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImageEmbeddingsTableFilterComposer(
              $db: $db,
              $table: $db.imageEmbeddings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MedicineImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicineImagesTable> {
  $$MedicineImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get imageId => $composableBuilder(
      column: $table.imageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageType => $composableBuilder(
      column: $table.imageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get imageSequence => $composableBuilder(
      column: $table.imageSequence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudPath => $composableBuilder(
      column: $table.cloudPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicines,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicinesTableOrderingComposer(
              $db: $db,
              $table: $db.medicines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MedicineImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicineImagesTable> {
  $$MedicineImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get imageId =>
      $composableBuilder(column: $table.imageId, builder: (column) => column);

  GeneratedColumn<String> get imageType =>
      $composableBuilder(column: $table.imageType, builder: (column) => column);

  GeneratedColumn<int> get imageSequence => $composableBuilder(
      column: $table.imageSequence, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get cloudPath =>
      $composableBuilder(column: $table.cloudPath, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicines,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicinesTableAnnotationComposer(
              $db: $db,
              $table: $db.medicines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> imageEmbeddingsRefs<T extends Object>(
      Expression<T> Function($$ImageEmbeddingsTableAnnotationComposer a) f) {
    final $$ImageEmbeddingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.imageEmbeddings,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImageEmbeddingsTableAnnotationComposer(
              $db: $db,
              $table: $db.imageEmbeddings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MedicineImagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicineImagesTable,
    MedicineImage,
    $$MedicineImagesTableFilterComposer,
    $$MedicineImagesTableOrderingComposer,
    $$MedicineImagesTableAnnotationComposer,
    $$MedicineImagesTableCreateCompanionBuilder,
    $$MedicineImagesTableUpdateCompanionBuilder,
    (MedicineImage, $$MedicineImagesTableReferences),
    MedicineImage,
    PrefetchHooks Function({bool medicineId, bool imageEmbeddingsRefs})> {
  $$MedicineImagesTableTableManager(
      _$AppDatabase db, $MedicineImagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicineImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicineImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicineImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> imageId = const Value.absent(),
            Value<String> medicineId = const Value.absent(),
            Value<String> imageType = const Value.absent(),
            Value<int> imageSequence = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String?> cloudPath = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicineImagesCompanion(
            imageId: imageId,
            medicineId: medicineId,
            imageType: imageType,
            imageSequence: imageSequence,
            localPath: localPath,
            cloudPath: cloudPath,
            checksum: checksum,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String imageId,
            required String medicineId,
            required String imageType,
            required int imageSequence,
            required String localPath,
            Value<String?> cloudPath = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicineImagesCompanion.insert(
            imageId: imageId,
            medicineId: medicineId,
            imageType: imageType,
            imageSequence: imageSequence,
            localPath: localPath,
            cloudPath: cloudPath,
            checksum: checksum,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MedicineImagesTable, MedicineImage>(table),
                    $$MedicineImagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {medicineId = false, imageEmbeddingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (imageEmbeddingsRefs) db.imageEmbeddings
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (medicineId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.medicineId,
                    referencedTable:
                        $$MedicineImagesTableReferences._medicineIdTable(db),
                    referencedColumn: $$MedicineImagesTableReferences
                        ._medicineIdTable(db)
                        .medicineId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (imageEmbeddingsRefs)
                    await $_getPrefetchedDataByColumns<
                            MedicineImage,
                            $MedicineImagesTable,
                            ImageEmbedding,
                            $ImageEmbeddingsTable>(
                        currentTable: table,
                        referencedTable: $$MedicineImagesTableReferences
                            ._imageEmbeddingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MedicineImagesTableReferences(db, table, p0)
                                .imageEmbeddingsRefs,
                        currentColumn: 'image_id',
                        referencedColumn: 'image_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MedicineImagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicineImagesTable,
    MedicineImage,
    $$MedicineImagesTableFilterComposer,
    $$MedicineImagesTableOrderingComposer,
    $$MedicineImagesTableAnnotationComposer,
    $$MedicineImagesTableCreateCompanionBuilder,
    $$MedicineImagesTableUpdateCompanionBuilder,
    (MedicineImage, $$MedicineImagesTableReferences),
    MedicineImage,
    PrefetchHooks Function({bool medicineId, bool imageEmbeddingsRefs})>;
typedef $$MedicationSchedulesTableCreateCompanionBuilder
    = MedicationSchedulesCompanion Function({
  required String scheduleId,
  required String medicineId,
  required String period,
  required String time,
  required String dosage,
  required String foodInstruction,
  required String repeatDays,
  required String timezone,
  required DateTime startDate,
  Value<DateTime?> endDate,
  Value<bool> enabled,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MedicationSchedulesTableUpdateCompanionBuilder
    = MedicationSchedulesCompanion Function({
  Value<String> scheduleId,
  Value<String> medicineId,
  Value<String> period,
  Value<String> time,
  Value<String> dosage,
  Value<String> foodInstruction,
  Value<String> repeatDays,
  Value<String> timezone,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<bool> enabled,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$MedicationSchedulesTableReferences extends BaseReferences<
    _$AppDatabase, $MedicationSchedulesTable, MedicationSchedule> {
  $$MedicationSchedulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) => db.medicines
      .createAlias('medication_schedules__medicine_id__medicines__medicine_id');

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<String>('medicine_id')!;

    final manager = $$MedicinesTableTableManager($_db, $_db.medicines)
        .filter((f) => f.medicineId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MedicationSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scheduleId => $composableBuilder(
      column: $table.scheduleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodInstruction => $composableBuilder(
      column: $table.foodInstruction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeatDays => $composableBuilder(
      column: $table.repeatDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicines,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicinesTableFilterComposer(
              $db: $db,
              $table: $db.medicines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MedicationSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scheduleId => $composableBuilder(
      column: $table.scheduleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodInstruction => $composableBuilder(
      column: $table.foodInstruction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeatDays => $composableBuilder(
      column: $table.repeatDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicines,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicinesTableOrderingComposer(
              $db: $db,
              $table: $db.medicines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MedicationSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scheduleId => $composableBuilder(
      column: $table.scheduleId, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get foodInstruction => $composableBuilder(
      column: $table.foodInstruction, builder: (column) => column);

  GeneratedColumn<String> get repeatDays => $composableBuilder(
      column: $table.repeatDays, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicines,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicinesTableAnnotationComposer(
              $db: $db,
              $table: $db.medicines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MedicationSchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicationSchedulesTable,
    MedicationSchedule,
    $$MedicationSchedulesTableFilterComposer,
    $$MedicationSchedulesTableOrderingComposer,
    $$MedicationSchedulesTableAnnotationComposer,
    $$MedicationSchedulesTableCreateCompanionBuilder,
    $$MedicationSchedulesTableUpdateCompanionBuilder,
    (MedicationSchedule, $$MedicationSchedulesTableReferences),
    MedicationSchedule,
    PrefetchHooks Function({bool medicineId})> {
  $$MedicationSchedulesTableTableManager(
      _$AppDatabase db, $MedicationSchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationSchedulesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationSchedulesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> scheduleId = const Value.absent(),
            Value<String> medicineId = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<String> dosage = const Value.absent(),
            Value<String> foodInstruction = const Value.absent(),
            Value<String> repeatDays = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationSchedulesCompanion(
            scheduleId: scheduleId,
            medicineId: medicineId,
            period: period,
            time: time,
            dosage: dosage,
            foodInstruction: foodInstruction,
            repeatDays: repeatDays,
            timezone: timezone,
            startDate: startDate,
            endDate: endDate,
            enabled: enabled,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String scheduleId,
            required String medicineId,
            required String period,
            required String time,
            required String dosage,
            required String foodInstruction,
            required String repeatDays,
            required String timezone,
            required DateTime startDate,
            Value<DateTime?> endDate = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationSchedulesCompanion.insert(
            scheduleId: scheduleId,
            medicineId: medicineId,
            period: period,
            time: time,
            dosage: dosage,
            foodInstruction: foodInstruction,
            repeatDays: repeatDays,
            timezone: timezone,
            startDate: startDate,
            endDate: endDate,
            enabled: enabled,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MedicationSchedulesTable, MedicationSchedule>(
                        table),
                    $$MedicationSchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({medicineId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (medicineId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.medicineId,
                    referencedTable: $$MedicationSchedulesTableReferences
                        ._medicineIdTable(db),
                    referencedColumn: $$MedicationSchedulesTableReferences
                        ._medicineIdTable(db)
                        .medicineId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MedicationSchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicationSchedulesTable,
    MedicationSchedule,
    $$MedicationSchedulesTableFilterComposer,
    $$MedicationSchedulesTableOrderingComposer,
    $$MedicationSchedulesTableAnnotationComposer,
    $$MedicationSchedulesTableCreateCompanionBuilder,
    $$MedicationSchedulesTableUpdateCompanionBuilder,
    (MedicationSchedule, $$MedicationSchedulesTableReferences),
    MedicationSchedule,
    PrefetchHooks Function({bool medicineId})>;
typedef $$DoseHistoryTableCreateCompanionBuilder = DoseHistoryCompanion
    Function({
  required String doseId,
  required String scheduleId,
  required DateTime scheduledAt,
  Value<DateTime?> actionAt,
  required String status,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$DoseHistoryTableUpdateCompanionBuilder = DoseHistoryCompanion
    Function({
  Value<String> doseId,
  Value<String> scheduleId,
  Value<DateTime> scheduledAt,
  Value<DateTime?> actionAt,
  Value<String> status,
  Value<String?> notes,
  Value<int> rowid,
});

class $$DoseHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $DoseHistoryTable> {
  $$DoseHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get doseId => $composableBuilder(
      column: $table.doseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduleId => $composableBuilder(
      column: $table.scheduleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get actionAt => $composableBuilder(
      column: $table.actionAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$DoseHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $DoseHistoryTable> {
  $$DoseHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get doseId => $composableBuilder(
      column: $table.doseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduleId => $composableBuilder(
      column: $table.scheduleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get actionAt => $composableBuilder(
      column: $table.actionAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$DoseHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoseHistoryTable> {
  $$DoseHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get doseId =>
      $composableBuilder(column: $table.doseId, builder: (column) => column);

  GeneratedColumn<String> get scheduleId => $composableBuilder(
      column: $table.scheduleId, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<DateTime> get actionAt =>
      $composableBuilder(column: $table.actionAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$DoseHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DoseHistoryTable,
    DoseHistoryData,
    $$DoseHistoryTableFilterComposer,
    $$DoseHistoryTableOrderingComposer,
    $$DoseHistoryTableAnnotationComposer,
    $$DoseHistoryTableCreateCompanionBuilder,
    $$DoseHistoryTableUpdateCompanionBuilder,
    (
      DoseHistoryData,
      BaseReferences<_$AppDatabase, $DoseHistoryTable, DoseHistoryData>
    ),
    DoseHistoryData,
    PrefetchHooks Function()> {
  $$DoseHistoryTableTableManager(_$AppDatabase db, $DoseHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoseHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoseHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoseHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> doseId = const Value.absent(),
            Value<String> scheduleId = const Value.absent(),
            Value<DateTime> scheduledAt = const Value.absent(),
            Value<DateTime?> actionAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DoseHistoryCompanion(
            doseId: doseId,
            scheduleId: scheduleId,
            scheduledAt: scheduledAt,
            actionAt: actionAt,
            status: status,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String doseId,
            required String scheduleId,
            required DateTime scheduledAt,
            Value<DateTime?> actionAt = const Value.absent(),
            required String status,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DoseHistoryCompanion.insert(
            doseId: doseId,
            scheduleId: scheduleId,
            scheduledAt: scheduledAt,
            actionAt: actionAt,
            status: status,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DoseHistoryTable, DoseHistoryData>(table),
                    BaseReferences<_$AppDatabase, $DoseHistoryTable,
                        DoseHistoryData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DoseHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DoseHistoryTable,
    DoseHistoryData,
    $$DoseHistoryTableFilterComposer,
    $$DoseHistoryTableOrderingComposer,
    $$DoseHistoryTableAnnotationComposer,
    $$DoseHistoryTableCreateCompanionBuilder,
    $$DoseHistoryTableUpdateCompanionBuilder,
    (
      DoseHistoryData,
      BaseReferences<_$AppDatabase, $DoseHistoryTable, DoseHistoryData>
    ),
    DoseHistoryData,
    PrefetchHooks Function()>;
typedef $$ImageEmbeddingsTableCreateCompanionBuilder = ImageEmbeddingsCompanion
    Function({
  required String embeddingId,
  required String medicineId,
  required String imageId,
  required String vectorJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ImageEmbeddingsTableUpdateCompanionBuilder = ImageEmbeddingsCompanion
    Function({
  Value<String> embeddingId,
  Value<String> medicineId,
  Value<String> imageId,
  Value<String> vectorJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$ImageEmbeddingsTableReferences extends BaseReferences<
    _$AppDatabase, $ImageEmbeddingsTable, ImageEmbedding> {
  $$ImageEmbeddingsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) => db.medicines
      .createAlias('image_embeddings__medicine_id__medicines__medicine_id');

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<String>('medicine_id')!;

    final manager = $$MedicinesTableTableManager($_db, $_db.medicines)
        .filter((f) => f.medicineId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MedicineImagesTable _imageIdTable(_$AppDatabase db) =>
      db.medicineImages
          .createAlias('image_embeddings__image_id__medicine_images__image_id');

  $$MedicineImagesTableProcessedTableManager get imageId {
    final $_column = $_itemColumn<String>('image_id')!;

    final manager = $$MedicineImagesTableTableManager($_db, $_db.medicineImages)
        .filter((f) => f.imageId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_imageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ImageEmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $ImageEmbeddingsTable> {
  $$ImageEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get embeddingId => $composableBuilder(
      column: $table.embeddingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vectorJson => $composableBuilder(
      column: $table.vectorJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicines,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicinesTableFilterComposer(
              $db: $db,
              $table: $db.medicines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MedicineImagesTableFilterComposer get imageId {
    final $$MedicineImagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.medicineImages,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicineImagesTableFilterComposer(
              $db: $db,
              $table: $db.medicineImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ImageEmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageEmbeddingsTable> {
  $$ImageEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get embeddingId => $composableBuilder(
      column: $table.embeddingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vectorJson => $composableBuilder(
      column: $table.vectorJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicines,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicinesTableOrderingComposer(
              $db: $db,
              $table: $db.medicines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MedicineImagesTableOrderingComposer get imageId {
    final $$MedicineImagesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.medicineImages,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicineImagesTableOrderingComposer(
              $db: $db,
              $table: $db.medicineImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ImageEmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageEmbeddingsTable> {
  $$ImageEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get embeddingId => $composableBuilder(
      column: $table.embeddingId, builder: (column) => column);

  GeneratedColumn<String> get vectorJson => $composableBuilder(
      column: $table.vectorJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicineId,
        referencedTable: $db.medicines,
        getReferencedColumn: (t) => t.medicineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicinesTableAnnotationComposer(
              $db: $db,
              $table: $db.medicines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MedicineImagesTableAnnotationComposer get imageId {
    final $$MedicineImagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.medicineImages,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicineImagesTableAnnotationComposer(
              $db: $db,
              $table: $db.medicineImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ImageEmbeddingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImageEmbeddingsTable,
    ImageEmbedding,
    $$ImageEmbeddingsTableFilterComposer,
    $$ImageEmbeddingsTableOrderingComposer,
    $$ImageEmbeddingsTableAnnotationComposer,
    $$ImageEmbeddingsTableCreateCompanionBuilder,
    $$ImageEmbeddingsTableUpdateCompanionBuilder,
    (ImageEmbedding, $$ImageEmbeddingsTableReferences),
    ImageEmbedding,
    PrefetchHooks Function({bool medicineId, bool imageId})> {
  $$ImageEmbeddingsTableTableManager(
      _$AppDatabase db, $ImageEmbeddingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageEmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageEmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> embeddingId = const Value.absent(),
            Value<String> medicineId = const Value.absent(),
            Value<String> imageId = const Value.absent(),
            Value<String> vectorJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageEmbeddingsCompanion(
            embeddingId: embeddingId,
            medicineId: medicineId,
            imageId: imageId,
            vectorJson: vectorJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String embeddingId,
            required String medicineId,
            required String imageId,
            required String vectorJson,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageEmbeddingsCompanion.insert(
            embeddingId: embeddingId,
            medicineId: medicineId,
            imageId: imageId,
            vectorJson: vectorJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ImageEmbeddingsTable, ImageEmbedding>(table),
                    $$ImageEmbeddingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({medicineId = false, imageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (medicineId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.medicineId,
                    referencedTable:
                        $$ImageEmbeddingsTableReferences._medicineIdTable(db),
                    referencedColumn: $$ImageEmbeddingsTableReferences
                        ._medicineIdTable(db)
                        .medicineId,
                  ) as T;
                }
                if (imageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.imageId,
                    referencedTable:
                        $$ImageEmbeddingsTableReferences._imageIdTable(db),
                    referencedColumn: $$ImageEmbeddingsTableReferences
                        ._imageIdTable(db)
                        .imageId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ImageEmbeddingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ImageEmbeddingsTable,
    ImageEmbedding,
    $$ImageEmbeddingsTableFilterComposer,
    $$ImageEmbeddingsTableOrderingComposer,
    $$ImageEmbeddingsTableAnnotationComposer,
    $$ImageEmbeddingsTableCreateCompanionBuilder,
    $$ImageEmbeddingsTableUpdateCompanionBuilder,
    (ImageEmbedding, $$ImageEmbeddingsTableReferences),
    ImageEmbedding,
    PrefetchHooks Function({bool medicineId, bool imageId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$MedicinesTableTableManager get medicines =>
      $$MedicinesTableTableManager(_db, _db.medicines);
  $$MedicineImagesTableTableManager get medicineImages =>
      $$MedicineImagesTableTableManager(_db, _db.medicineImages);
  $$MedicationSchedulesTableTableManager get medicationSchedules =>
      $$MedicationSchedulesTableTableManager(_db, _db.medicationSchedules);
  $$DoseHistoryTableTableManager get doseHistory =>
      $$DoseHistoryTableTableManager(_db, _db.doseHistory);
  $$ImageEmbeddingsTableTableManager get imageEmbeddings =>
      $$ImageEmbeddingsTableTableManager(_db, _db.imageEmbeddings);
}
