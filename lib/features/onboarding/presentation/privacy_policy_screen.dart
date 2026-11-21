import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../data/settings_controller.dart';
import '../domain/legal_documents.dart';
import 'legal_document_view.dart';

class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  ConsumerState<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {
  bool _agreed = false;

  Future<void> _continue() async {
    await ref.read(settingsProvider.notifier).acknowledgePrivacy();
    if (!mounted) return;
    if (ref.read(settingsProvider).onboardingCompleted) {
      context.go('/home');
    } else {
      context.push('/storage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final updating = ref.watch(settingsProvider).onboardingCompleted;
    return OnboardingScaffold(
      title: updating ? 'Updated Privacy Policy' : 'Privacy Policy',
      subtitle: 'How MediVox handles your information.',
      step: updating ? null : 3,
      scrollable: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const LegalDocumentView(
          sections: LegalDocuments.privacy,
          version: LegalDocuments.privacyVersion,
        ),
      ),
      bottom: CheckboxListTile(
        value: _agreed,
        onChanged: (v) => setState(() => _agreed = v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: const Text('I have read and understood the Privacy Policy'),
      ),
      primaryLabel: 'Continue',
      onPrimary: _agreed ? _continue : null,
    );
  }
}
