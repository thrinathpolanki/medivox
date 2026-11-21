import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../../authentication/auth_gateway.dart';
import '../data/settings_controller.dart';

class GoogleSignInScreen extends ConsumerStatefulWidget {
  const GoogleSignInScreen({super.key});
  @override
  ConsumerState<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends ConsumerState<GoogleSignInScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(authGatewayProvider).signInWithGoogle();
      await ref.read(settingsProvider.notifier).setGoogleAccount(result);
      if (mounted) context.push('/language');
    } on AuthNotConfiguredException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Sign-in failed. Check your connection and try again, or choose Local Storage.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OnboardingScaffold(
      title: 'Continue with Google',
      subtitle: 'Sign in to securely back up and sync your data.',
      step: 5,
      primaryLabel: _loading ? 'Signing in…' : 'Continue with Google',
      onPrimary: _loading ? null : _signIn,
      secondaryLabel: 'Choose another storage option',
      onSecondary: () => context.go('/storage'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Bullet(Icons.lock_outline, 'Your data is securely stored'),
          const _Bullet(Icons.devices, 'Accessible across devices'),
          const _Bullet(Icons.wifi_off, 'Works offline with a local copy'),
          if (_error != null) ...[
            const SizedBox(height: 20),
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.error),
                ),
                child: Text(_error!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
        ]),
      );
}
