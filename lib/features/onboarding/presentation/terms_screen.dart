import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../data/settings_controller.dart';
import '../domain/legal_documents.dart';
import 'legal_document_view.dart';

class TermsScreen extends ConsumerStatefulWidget {
  const TermsScreen({super.key});
  @override
  ConsumerState<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<TermsScreen> {
  bool _agreed = false;

  Future<void> _continue() async {
    await ref.read(settingsProvider.notifier).acceptTerms();
    if (!mounted) return;
    final s = ref.read(settingsProvider);
    if (s.onboardingCompleted && s.privacyCurrent) {
      context.go('/home');
    } else {
      context.push('/privacy');
    }
  }

  @override
  Widget build(BuildContext context) {
    final updating = ref.watch(settingsProvider).onboardingCompleted;
    return OnboardingScaffold(
      title: updating ? 'Updated Terms and Conditions' : 'Terms and Conditions',
      subtitle: updating
          ? 'Our terms have changed. Please read and accept them to continue.'
          : 'Please read and accept the Terms and Conditions to continue.',
      step: updating ? null : 2,
      scrollable: false,
      bottom: CheckboxListTile(
        value: _agreed,
        onChanged: (v) => setState(() => _agreed = v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: const Text('I have read and agree to the Terms and Conditions'),
      ),
      primaryLabel: 'Continue',
      onPrimary: _agreed ? _continue : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const LegalDocumentView(
          sections: LegalDocuments.terms,
          version: LegalDocuments.termsVersion,
        ),
      ),
    );
  }
}
