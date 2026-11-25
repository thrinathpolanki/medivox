import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/dose_models.dart';

/// Status is shown with an icon AND text, never colour alone.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final DoseStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      DoseStatus.taken => (Icons.check_circle, AppColors.success),
      DoseStatus.missed => (Icons.cancel, AppColors.error),
      DoseStatus.skipped => (Icons.skip_next, AppColors.warning),
      DoseStatus.snoozed => (Icons.snooze, AppColors.navy),
      DoseStatus.pending => (Icons.schedule, AppColors.navy),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 4),
      Text(status.label, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
    ]);
  }
}
