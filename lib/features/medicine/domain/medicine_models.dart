import '../../../core/utils/format.dart';
import '../../../database/app_database.dart';

class MedicineConfig {
  /// Minimum photos needed before final submission (configurable).
  static const minImages = 2;
  static const maxImages = 6;
  static const minImageSide = 600; // px, shortest side
  static const medicineTypes = [
    'Tablet', 'Capsule', 'Syrup', 'Injection', 'Ointment', 'Drops', 'Inhaler', 'Other',
  ];
}

enum ImageSlot {
  stripFront1('strip_front', 1, 'Strip front 1'),
  stripFront2('strip_front', 2, 'Strip front 2'),
  stripBack1('strip_back', 1, 'Strip back 1'),
  stripBack2('strip_back', 2, 'Strip back 2'),
  tablet1('tablet', 1, 'Tablet 1'),
  tablet2('tablet', 2, 'Tablet 2');

  const ImageSlot(this.type, this.sequence, this.label);
  final String type;
  final int sequence;
  final String label;
}

enum SchedulePeriod {
  morning('Morning', 8, 0),
  afternoon('Afternoon', 14, 0),
  night('Night', 20, 0),
  custom('Custom', 12, 0);

  const SchedulePeriod(this.label, this.defaultHour, this.defaultMinute);
  final String label;
  final int defaultHour;
  final int defaultMinute;

  static SchedulePeriod byName(String n) => SchedulePeriod.values
      .firstWhere((e) => e.name == n, orElse: () => SchedulePeriod.custom);
}

enum FoodInstruction {
  beforeFood('Before food'),
  afterFood('After food'),
  withFood('With food'),
  asPrescribed('As prescribed');

  const FoodInstruction(this.label);
  final String label;

  static FoodInstruction byName(String n) => FoodInstruction.values
      .firstWhere((e) => e.name == n, orElse: () => FoodInstruction.asPrescribed);
}

class MedicineInfo {
  const MedicineInfo({
    this.name = '',
    this.genericName = '',
    this.strength = '',
    this.composition = '',
    this.manufacturer = '',
    this.medicineType = '',
    this.dosage = '',
    this.prescriptionReference = '',
    this.notes = '',
  });
  final String name,
      genericName,
      strength,
      composition,
      manufacturer,
      medicineType,
      dosage,
      prescriptionReference,
      notes;

  MedicineInfo copyWith({
    String? name,
    String? genericName,
    String? strength,
    String? composition,
    String? manufacturer,
    String? medicineType,
    String? dosage,
    String? prescriptionReference,
    String? notes,
  }) =>
      MedicineInfo(
        name: name ?? this.name,
        genericName: genericName ?? this.genericName,
        strength: strength ?? this.strength,
        composition: composition ?? this.composition,
        manufacturer: manufacturer ?? this.manufacturer,
        medicineType: medicineType ?? this.medicineType,
        dosage: dosage ?? this.dosage,
        prescriptionReference: prescriptionReference ?? this.prescriptionReference,
        notes: notes ?? this.notes,
      );

  factory MedicineInfo.fromMedicine(Medicine m) => MedicineInfo(
        name: m.medicineName,
        genericName: m.genericName ?? '',
        strength: m.strength ?? '',
        composition: m.composition ?? '',
        manufacturer: m.manufacturer ?? '',
        medicineType: m.medicineType ?? '',
        dosage: m.dosage ?? '',
        prescriptionReference: m.prescriptionReference ?? '',
        notes: m.notes ?? '',
      );
}

class ScheduleDraft {
  const ScheduleDraft({
    required this.id,
    required this.period,
    required this.hour,
    required this.minute,
    required this.startDate,
    this.dosage = '',
    this.food = FoodInstruction.asPrescribed,
    this.repeatDays = allDays,
    this.endDate,
    this.enabled = true,
  });

  static const allDays = [true, true, true, true, true, true, true];

  factory ScheduleDraft.create(String id, SchedulePeriod p) {
    final now = DateTime.now();
    return ScheduleDraft(
      id: id,
      period: p,
      hour: p.defaultHour,
      minute: p.defaultMinute,
      startDate: DateTime(now.year, now.month, now.day),
    );
  }

  factory ScheduleDraft.fromRow(MedicationSchedule s) {
    final parts = s.time.split(':');
    return ScheduleDraft(
      id: s.scheduleId,
      period: SchedulePeriod.byName(s.period),
      hour: int.tryParse(parts.first) ?? 0,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      startDate: s.startDate,
      dosage: s.dosage,
      food: FoodInstruction.byName(s.foodInstruction),
      repeatDays: [for (var i = 0; i < 7; i++) i < s.repeatRule.length && s.repeatRule[i] == '1'],
      endDate: s.endDate,
      enabled: s.enabled,
    );
  }

  final String id;
  final SchedulePeriod period;
  final int hour, minute;
  final DateTime startDate;
  final String dosage;
  final FoodInstruction food;
  final List<bool> repeatDays; // Mon..Sun
  final DateTime? endDate;
  final bool enabled;

  String get timeText => formatTime(hour, minute);
  String get repeatRule => repeatDays.map((d) => d ? '1' : '0').join();

  String get repeatText {
    if (repeatDays.every((d) => d)) return 'Every day';
    return [for (var i = 0; i < 7; i++) if (repeatDays[i]) weekdayShort[i]].join(', ');
  }

  /// Null when valid. Dosage must be typed by the user; never auto-filled.
  String? get error {
    if (dosage.trim().isEmpty) return 'Enter the dosage exactly as prescribed.';
    if (!repeatDays.any((d) => d)) return 'Choose at least one day.';
    if (endDate != null && endDate!.isBefore(startDate)) {
      return 'End date is before the start date.';
    }
    return null;
  }

  ScheduleDraft copyWith({
    SchedulePeriod? period,
    int? hour,
    int? minute,
    DateTime? startDate,
    String? dosage,
    FoodInstruction? food,
    List<bool>? repeatDays,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? enabled,
  }) =>
      ScheduleDraft(
        id: id,
        period: period ?? this.period,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        startDate: startDate ?? this.startDate,
        dosage: dosage ?? this.dosage,
        food: food ?? this.food,
        repeatDays: repeatDays ?? this.repeatDays,
        endDate: clearEndDate ? null : (endDate ?? this.endDate),
        enabled: enabled ?? this.enabled,
      );
}

class MedicineDraft {
  const MedicineDraft({
    this.info = const MedicineInfo(),
    this.images = const {},
    this.schedules = const [],
  });
  final MedicineInfo info;
  final Map<ImageSlot, String> images; // staged file paths
  final List<ScheduleDraft> schedules;

  bool get hasEnoughImages => images.length >= MedicineConfig.minImages;
  bool get schedulesValid => schedules.every((s) => s.error == null);

  MedicineDraft copyWith({
    MedicineInfo? info,
    Map<ImageSlot, String>? images,
    List<ScheduleDraft>? schedules,
  }) =>
      MedicineDraft(
        info: info ?? this.info,
        images: images ?? this.images,
        schedules: schedules ?? this.schedules,
      );
}

class MedicineDetail {
  const MedicineDetail(this.medicine, this.images, this.schedules);
  final Medicine medicine;
  final List<MedicineImage> images;
  final List<MedicationSchedule> schedules;

  static const _typeOrder = {'strip_front': 0, 'strip_back': 1, 'tablet': 2};

  List<MedicineImage> get sortedImages => [...images]..sort((a, b) {
      final t = (_typeOrder[a.imageType] ?? 9).compareTo(_typeOrder[b.imageType] ?? 9);
      return t != 0 ? t : a.imageSequence.compareTo(b.imageSequence);
    });

  String? get thumbnailPath => sortedImages.isEmpty ? null : sortedImages.first.localPath;

  List<MedicationSchedule> get sortedSchedules =>
      [...schedules]..sort((a, b) => a.time.compareTo(b.time));

  String get scheduleSummary {
    final active = schedules.where((s) => s.enabled).toList();
    if (schedules.isEmpty) return 'No schedule';
    if (active.isEmpty) return 'Reminders off';
    return '${active.length} scheduled ${active.length == 1 ? 'time' : 'times'}: '
        '${(active.map((s) => s.time).toList()..sort()).join(', ')}';
  }
}
