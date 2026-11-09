import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class StorageSelectionScreen extends ConsumerWidget {
  const StorageSelectionScreen({super.key});

  Future<void> _selectMode(
      BuildContext context, WidgetRef ref, String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefStorageMode, mode);

    if (!context.mounted) return; // <-- ADD THIS GUARD

    context.go('/language');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage Selection')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'How would you like to store your data?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildStorageCard(
              context,
              title: 'Local Storage',
              description:
                  'Keep all your data on this device. No cloud account required. Works offline.',
              icon: Icons.phone_android,
              onTap: () => _selectMode(context, ref, 'local'),
            ),
            const SizedBox(height: 16),
            _buildStorageCard(
              context,
              title: 'Continue with Google',
              description:
                  'Sign in to securely save your data in the cloud. Access across devices.',
              icon: Icons.cloud,
              onTap: () => _selectMode(context, ref, 'google'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
