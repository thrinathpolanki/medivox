import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../localization/language_registry.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedCode = 'en';

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLanguage, _selectedCode);
    if (mounted) context.go('/accessibility');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Language')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Choose your preferred language for the app interface and voice guidance.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: LanguageRegistry.all.length,
              itemBuilder: (context, index) {
                final lang = LanguageRegistry.all[index];
                final isSelected = lang.code == _selectedCode;
                return ListTile(
                  title: Text(
                    lang.nativeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(lang.englishName),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => setState(() => _selectedCode = lang.code),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _continue,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
