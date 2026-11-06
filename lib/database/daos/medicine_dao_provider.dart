import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database_provider.dart';
import 'medicine_dao.dart';

final medicineDaoProvider = Provider<MedicineDao>((ref) {
  return MedicineDao(ref.watch(databaseProvider));
});
