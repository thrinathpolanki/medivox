import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.record_voice_over,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to MediVox',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your intelligent medicine companion.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              _buildFeatureRow(Icons.mic, 'Voice assistance'),
              _buildFeatureRow(Icons.camera_alt, 'Medicine identification'),
              _buildFeatureRow(Icons.alarm, 'Smart reminders'),
              _buildFeatureRow(Icons.translate, 'Multilingual support'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/terms'),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF102C50)),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
