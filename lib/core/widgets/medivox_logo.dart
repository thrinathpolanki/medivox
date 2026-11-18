import 'package:flutter/material.dart';

import '../constants/app_info.dart';
import '../theme/app_theme.dart';

/// Placeholder vector logo. Replace with the official brand asset when available.
class MediVoxLogo extends StatelessWidget {
  const MediVoxLogo({super.key, this.size = 48, this.showTagline = false});
  final double size;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: showTagline ? '${AppInfo.name}. ${AppInfo.tagline}' : AppInfo.name,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(size * 0.28),
                  ),
                  child: Icon(Icons.graphic_eq, color: Colors.white, size: size * 0.6),
                ),
                SizedBox(width: size * 0.2),
                Text.rich(
                  const TextSpan(children: [
                    TextSpan(text: 'Medi', style: TextStyle(color: AppColors.navy)),
                    TextSpan(text: 'Vox', style: TextStyle(color: AppColors.teal)),
                  ]),
                  style: TextStyle(fontSize: size * 0.8, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            if (showTagline) ...[
              const SizedBox(height: 8),
              const Text(AppInfo.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.navy, fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}
