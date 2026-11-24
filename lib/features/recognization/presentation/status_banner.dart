import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/recognition_models.dart';

/// Icon + words + colour, so meaning never depends on colour alone.
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.icon, required this.color, required this.text, this.detail});
  final IconData icon;
  final Color color;
  final String text;
  final String? detail;

  factory StatusBanner.forStatus(PackageStatus s, String headline, {String? detail}) {
    final (icon, color) = switch (s) {
      PackageStatus.confirmed => (Icons.verified, AppColors.success),
      PackageStatus.likely => (Icons.check_circle_outline, AppColors.success),
      PackageStatus.possible => (Icons.help_outline, AppColors.warning),
      PackageStatus.conflict => (Icons.warning_amber_rounded, AppColors.error),
      PackageStatus.ambiguous => (Icons.help_outline, AppColors.warning),
      PackageStatus.unmatched => (Icons.search_off, AppColors.navy),
      PackageStatus.unreadable => (Icons.visibility_off, AppColors.error),
    };
    return StatusBanner(icon: icon, color: color, text: headline, detail: detail);
  }

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        container: true,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                if (detail != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(detail!)),
              ]),
            ),
          ]),
        ),
      );
}
