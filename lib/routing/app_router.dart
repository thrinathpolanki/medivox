import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/data/settings_controller.dart';
import '../features/onboarding/domain/app_settings.dart';
import '../features/onboarding/domain/storage_mode.dart';
import '../features/onboarding/presentation/accessibility_setup_screen.dart';
import '../features/onboarding/presentation/google_sign_in_screen.dart';
import '../features/onboarding/presentation/language_selection_screen.dart';
import '../features/onboarding/presentation/local_profile_setup_screen.dart';
import '../features/onboarding/presentation/onboarding_complete_screen.dart';
import '../features/onboarding/presentation/privacy_policy_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/storage_selection_screen.dart';
import '../features/onboarding/presentation/terms_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';

const onboardingRoutes = [
  '/welcome',
  '/terms',
  '/privacy',
  '/storage',
  '/google-signin',
  '/local-profile',
  '/language',
  '/accessibility',
  '/complete',
];

/// Pure redirect logic (unit-tested). Rules:
///  * Never depends on connectivity, so losing internet never sends anyone
///    back to onboarding.
///  * Completed users never see storage selection again on launch.
///  * A revised legal document forces re-acknowledgement.
String? onboardingRedirect(AppSettings s, String loc) {
  if (loc == '/splash') return null;
  final isLegal = loc == '/terms' || loc == '/privacy';

  if (s.onboardingCompleted) {
    if (!s.legalCurrent) {
      if (isLegal) return null;
      return s.termsCurrent ? '/privacy' : '/terms';
    }
    if (isLegal) return null;
    if (onboardingRoutes.contains(loc)) return '/home';
    return null;
  }

  if (!onboardingRoutes.contains(loc)) return '/welcome';
  switch (loc) {
    case '/welcome':
    case '/terms':
      return null;
    case '/privacy':
      return s.termsCurrent ? null : '/terms';
    case '/storage':
    case '/google-signin':
    case '/local-profile':
      if (!s.termsCurrent) return '/terms';
      if (!s.privacyCurrent) return '/privacy';
      return null;
    default: // /language, /accessibility, /complete
      if (!s.termsCurrent) return '/terms';
      if (!s.privacyCurrent) return '/privacy';
      if (s.storageMode == StorageMode.none) return '/storage';
      return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AppSettings>(settingsProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) =>
        onboardingRedirect(ref.read(settingsProvider), state.matchedLocation),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsScreen()),
      GoRoute(
          path: '/privacy', builder: (_, __) => const PrivacyPolicyScreen()),
      GoRoute(
          path: '/storage', builder: (_, __) => const StorageSelectionScreen()),
      GoRoute(
          path: '/google-signin',
          builder: (_, __) => const GoogleSignInScreen()),
      GoRoute(
          path: '/local-profile',
          builder: (_, __) => const LocalProfileSetupScreen()),
      GoRoute(
          path: '/language',
          builder: (_, __) => const LanguageSelectionScreen()),
      GoRoute(
          path: '/accessibility',
          builder: (_, __) => const AccessibilitySetupScreen()),
      GoRoute(
          path: '/complete',
          builder: (_, __) => const OnboardingCompleteScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
  );
});
