import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_info.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/data/settings_controller.dart';
import 'routing/app_router.dart';

class MediVoxApp extends ConsumerWidget {
  const MediVoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final a = ref.watch(settingsProvider.select((s) => s.accessibility));
    return MaterialApp.router(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(highContrast: a.highContrast),
      routerConfig: router,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final scale =
            (mq.textScaler.scale(1) * a.effectiveTextScale).clamp(0.8, 2.4);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(scale.toDouble())),
          child: child!,
        );
      },
    );
  }
}
