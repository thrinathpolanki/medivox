import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleEntry {
  final String period; // 'morning' | 'afternoon' | 'night' | 'custom'
  final String time; // 'HH:mm'
  final String dosage;
  final String foodInstruction;
  final List<int> repeatDays;

  const ScheduleEntry({
    required this.period,
    required this.time,
    required this.dosage,
    required this.foodInstruction,
    required this.repeatDays,
  });

  ScheduleEntry copyWith({
    String? period,
    String? time,
    String? dosage,
    String? foodInstruction,
    List<int>? repeatDays,
  }) {
    return ScheduleEntry(
      period: period ?? this.period,
      time: time ?? this.time,
      dosage: dosage ?? this.dosage,
      foodInstruction: foodInstruction ?? this.foodInstruction,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }
}

class RegistrationState {
  // Stage 1
  final File? stripFront1;
  final File? stripFront2;
  final File? stripBack1;
  final File? stripBack2;
  final File? tablet1;
  final File? tablet2;

  // Stage 2
  final String medicineName;
  final String genericName;
  final String strength;
  final String composition;
  final String manufacturer;
  final String medicineType;
  final String notes;

  // Stage 3
  final List<ScheduleEntry> schedules;

  // Stage 4
  final bool saving;

  const RegistrationState({
    this.stripFront1,
    this.stripFront2,
    this.stripBack1,
    this.stripBack2,
    this.tablet1,
    this.tablet2,
    this.medicineName = '',
    this.genericName = '',
    this.strength = '',
    this.composition = '',
    this.manufacturer = '',
    this.medicineType = 'tablet',
    this.notes = '',
    this.schedules = const [],
    this.saving = false,
  });

  RegistrationState copyWith({
    File? stripFront1,
    File? stripFront2,
    File? stripBack1,
    File? stripBack2,
    File? tablet1,
    File? tablet2,
    String? medicineName,
    String? genericName,
    String? strength,
    String? composition,
    String? manufacturer,
    String? medicineType,
    String? notes,
    List<ScheduleEntry>? schedules,
    bool? saving,
  }) {
    return RegistrationState(
      stripFront1: stripFront1 ?? this.stripFront1,
      stripFront2: stripFront2 ?? this.stripFront2,
      stripBack1: stripBack1 ?? this.stripBack1,
      stripBack2: stripBack2 ?? this.stripBack2,
      tablet1: tablet1 ?? this.tablet1,
      tablet2: tablet2 ?? this.tablet2,
      medicineName: medicineName ?? this.medicineName,
      genericName: genericName ?? this.genericName,
      strength: strength ?? this.strength,
      composition: composition ?? this.composition,
      manufacturer: manufacturer ?? this.manufacturer,
      medicineType: medicineType ?? this.medicineType,
      notes: notes ?? this.notes,
      schedules: schedules ?? this.schedules,
      saving: saving ?? this.saving,
    );
  }

  bool get hasAtLeastOnePhoto =>
      stripFront1 != null || stripBack1 != null || tablet1 != null;

  bool get hasMinimumPhotos => (stripFront1 != null) && (stripBack1 != null);

  int get photoCount {
    int n = 0;
    if (stripFront1 != null) n++;
    if (stripFront2 != null) n++;
    if (stripBack1 != null) n++;
    if (stripBack2 != null) n++;
    if (tablet1 != null) n++;
    if (tablet2 != null) n++;
    return n;
  }
}

class RegistrationController extends Notifier<RegistrationState> {
  @override
  RegistrationState build() {
    return const RegistrationState();
  }

  void setPhoto(String slot, File file) {
    switch (slot) {
      case 'stripFront1':
        state = state.copyWith(stripFront1: file);
        break;
      case 'stripFront2':
        state = state.copyWith(stripFront2: file);
        break;
      case 'stripBack1':
        state = state.copyWith(stripBack1: file);
        break;
      case 'stripBack2':
        state = state.copyWith(stripBack2: file);
        break;
      case 'tablet1':
        state = state.copyWith(tablet1: file);
        break;
      case 'tablet2':
        state = state.copyWith(tablet2: file);
        break;
    }
  }

  void removePhoto(String slot) {
    switch (slot) {
      case 'stripFront1':
        state = state.copyWith(stripFront1: null);
        break;
      case 'stripFront2':
        state = state.copyWith(stripFront2: null);
        break;
      case 'stripBack1':
        state = state.copyWith(stripBack1: null);
        break;
      case 'stripBack2':
        state = state.copyWith(stripBack2: null);
        break;
      case 'tablet1':
        state = state.copyWith(tablet1: null);
        break;
      case 'tablet2':
        state = state.copyWith(tablet2: null);
        break;
    }
  }

  void setMedicineInfo({
    String? medicineName,
    String? genericName,
    String? strength,
    String? composition,
    String? manufacturer,
    String? medicineType,
    String? notes,
  }) {
    state = state.copyWith(
      medicineName: medicineName,
      genericName: genericName,
      strength: strength,
      composition: composition,
      manufacturer: manufacturer,
      medicineType: medicineType,
      notes: notes,
    );
  }

  void addSchedule(ScheduleEntry entry) {
    state = state.copyWith(schedules: [...state.schedules, entry]);
  }

  void removeSchedule(int index) {
    final list = [...state.schedules]..removeAt(index);
    state = state.copyWith(schedules: list);
  }

  void setSaving(bool saving) {
    state = state.copyWith(saving: saving);
  }

  void reset() {
    state = const RegistrationState();
  }
}

final registrationControllerProvider =
    NotifierProvider<RegistrationController, RegistrationState>(
  RegistrationController.new,
);
