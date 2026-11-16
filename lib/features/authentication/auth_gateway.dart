import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthResult {
  const AuthResult({required this.userId, this.displayName, this.email});
  final String userId;
  final String? displayName;
  final String? email;
}

class AuthNotConfiguredException implements Exception {
  const AuthNotConfiguredException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract class AuthGateway {
  Future<AuthResult> signInWithGoogle();
}

/// Milestone 1 default. The real implementation (Firebase Auth + Google
/// Sign-In) arrives in Milestone 5 and must initialise Firebase lazily,
/// only after the user picks Google mode. Until then we fail honestly
/// instead of pretending to sign in.
class NotConfiguredAuthGateway implements AuthGateway {
  const NotConfiguredAuthGateway();
  @override
  Future<AuthResult> signInWithGoogle() async {
    throw const AuthNotConfiguredException(
      'Google sign-in is not set up in this build yet. '
      'Please go back and choose Local Storage, or add your Firebase '
      'configuration (see README).',
    );
  }
}

final authGatewayProvider =
    Provider<AuthGateway>((ref) => const NotConfiguredAuthGateway());
