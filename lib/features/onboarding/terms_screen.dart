import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Please read and accept our Terms & Conditions and Privacy Policy to continue using MediVox.\n\n'
                  '1. MediVox is an assistive tool and does not replace professional medical advice.\n'
                  '2. Always consult your doctor regarding medication.\n'
                  '3. Your data is stored securely according to your chosen storage mode.\n'
                  '4. You are responsible for verifying the medicines you scan.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            CheckboxListTile(
              title:
                  const Text('I have read and agree to the Terms & Conditions'),
              value: _accepted,
              onChanged: (val) {
                setState(() {
                  _accepted = val ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _accepted ? () => context.go('/storage') : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
