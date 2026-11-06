import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/terms_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/storage_selection_screen.dart';
import '../features/onboarding/language_selection_screen.dart';
import '../features/onboarding/accessibility_setup_screen.dart';
import '../features/onboarding/onboarding_complete_screen.dart';
import '../features/home/home_screen.dart';
import '../features/medicine_add/screens/medicine_photo_capture_screen.dart';
import '../features/medicine_add/screens/medicine_information_screen.dart';
import '../features/medicine_add/screens/medicine_schedule_setup_screen.dart';
import '../features/medicine_add/screens/medicine_review_screen.dart';
import '../features/medicine_add/screens/medicine_saved_screen.dart';
import '../features/medicine_list/my_medicines_screen.dart';
import '../features/medicine_detail/medicine_detail_screen.dart';
import '../features/medicine_scan/screens/medicine_scan_screen.dart';
import '../features/medicine_scan/screens/scan_result_screen.dart';
import '../features/medicine_scan/services/matching_engine.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Onboarding
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsScreen()),
      GoRoute(
          path: '/storage', builder: (_, __) => const StorageSelectionScreen()),
      GoRoute(
          path: '/language',
          builder: (_, __) => const LanguageSelectionScreen()),
      GoRoute(
          path: '/accessibility',
          builder: (_, __) => const AccessibilitySetupScreen()),
      GoRoute(
          path: '/onboarding-complete',
          builder: (_, __) => const OnboardingCompleteScreen()),

      // Main
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
          path: '/medicines', builder: (_, __) => const MyMedicinesScreen()),
      GoRoute(
        path: '/medicines/:id',
        builder: (_, state) => MedicineDetailScreen(
          medicineId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/scan',
        builder: (_, __) => const MedicineScanScreen(),
      ),
      GoRoute(
        path: '/scan/result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ScanResultScreen(
            imageFile: extra['file'] as File,
            result: extra['result'] as MatchingResult,
          );
        },
      ),

      // Add medicine flow
      GoRoute(
          path: '/add-medicine',
          builder: (_, __) => const MedicinePhotoCaptureScreen()),
      GoRoute(
          path: '/add-medicine/info',
          builder: (_, __) => const MedicineInformationScreen()),
      GoRoute(
          path: '/add-medicine/schedule',
          builder: (_, __) => const MedicineScheduleSetupScreen()),
      GoRoute(
          path: '/add-medicine/review',
          builder: (_, __) => const MedicineReviewScreen()),
      GoRoute(
          path: '/add-medicine/saved',
          builder: (_, __) => const MedicineSavedScreen()),

      // Phase 4 placeholder
      GoRoute(
          path: '/scan',
          builder: (_, __) =>
              const Scaffold(body: Center(child: Text('Scan (Phase 4)')))),
    ],
  );
});
