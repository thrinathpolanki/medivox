import 'legal_documents.dart';
import 'storage_mode.dart';

class AccessibilitySettings {
  const AccessibilitySettings({
    this.voiceNavigation = true,
    this.screenReaderSupport = true,
    this.largeText = false,
    this.highContrast = false,
    this.hapticFeedback = true,
    this.screenFreeReminders = true,
    this.fontScale = 1.0,
    this.speechRate = 0.5,
    this.speechVolume = 1.0,
  });

  final bool voiceNavigation;
  final bool screenReaderSupport;
  final bool largeText;
  final bool highContrast;
  final bool hapticFeedback;
  final bool screenFreeReminders;
  final double fontScale; // 0.8 - 1.6
  final double speechRate; // 0.0 - 1.0
  final double speechVolume; // 0.0 - 1.0

  double get effectiveTextScale => fontScale * (largeText ? 1.25 : 1.0);

  AccessibilitySettings copyWith({
    bool? voiceNavigation,
    bool? screenReaderSupport,
    bool? largeText,
    bool? highContrast,
    bool? hapticFeedback,
    bool? screenFreeReminders,
    double? fontScale,
    double? speechRate,
    double? speechVolume,
  }) =>
      AccessibilitySettings(
        voiceNavigation: voiceNavigation ?? this.voiceNavigation,
        screenReaderSupport: screenReaderSupport ?? this.screenReaderSupport,
        largeText: largeText ?? this.largeText,
        highContrast: highContrast ?? this.highContrast,
        hapticFeedback: hapticFeedback ?? this.hapticFeedback,
        screenFreeReminders: screenFreeReminders ?? this.screenFreeReminders,
        fontScale: fontScale ?? this.fontScale,
        speechRate: speechRate ?? this.speechRate,
        speechVolume: speechVolume ?? this.speechVolume,
      );
}

class AppSettings {
  const AppSettings({
    this.firstLaunchCompleted = false,
    this.termsAccepted = false,
    this.termsVersion,
    this.termsAcceptedAt,
    this.privacyAcknowledged = false,
    this.privacyVersion,
    this.privacyAcknowledgedAt,
    this.storageMode = StorageMode.none,
    this.localProfileId,
    this.displayName,
    this.googleUserId,
    this.preferredLanguage,
    this.accessibility = const AccessibilitySettings(),
    this.onboardingCompleted = false,
  });

  final bool firstLaunchCompleted;
  final bool termsAccepted;
  final String? termsVersion;
  final DateTime? termsAcceptedAt;
  final bool privacyAcknowledged;
  final String? privacyVersion;
  final DateTime? privacyAcknowledgedAt;
  final StorageMode storageMode;
  final String? localProfileId;
  final String? displayName;
  final String? googleUserId;
  final String? preferredLanguage; // language code, e.g. "en", "hi"
  final AccessibilitySettings accessibility;
  final bool onboardingCompleted;

  bool get termsCurrent =>
      termsAccepted && termsVersion == LegalDocuments.termsVersion;
  bool get privacyCurrent =>
      privacyAcknowledged && privacyVersion == LegalDocuments.privacyVersion;
  bool get legalCurrent => termsCurrent && privacyCurrent;

  AppSettings copyWith({
    bool? firstLaunchCompleted,
    bool? termsAccepted,
    String? termsVersion,
    DateTime? termsAcceptedAt,
    bool? privacyAcknowledged,
    String? privacyVersion,
    DateTime? privacyAcknowledgedAt,
    StorageMode? storageMode,
    String? localProfileId,
    String? displayName,
    String? googleUserId,
    String? preferredLanguage,
    AccessibilitySettings? accessibility,
    bool? onboardingCompleted,
  }) =>
      AppSettings(
        firstLaunchCompleted: firstLaunchCompleted ?? this.firstLaunchCompleted,
        termsAccepted: termsAccepted ?? this.termsAccepted,
        termsVersion: termsVersion ?? this.termsVersion,
        termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
        privacyAcknowledged: privacyAcknowledged ?? this.privacyAcknowledged,
        privacyVersion: privacyVersion ?? this.privacyVersion,
        privacyAcknowledgedAt:
            privacyAcknowledgedAt ?? this.privacyAcknowledgedAt,
        storageMode: storageMode ?? this.storageMode,
        localProfileId: localProfileId ?? this.localProfileId,
        displayName: displayName ?? this.displayName,
        googleUserId: googleUserId ?? this.googleUserId,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        accessibility: accessibility ?? this.accessibility,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      );
}
