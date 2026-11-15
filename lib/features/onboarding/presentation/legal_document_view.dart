import 'package:flutter/material.dart';

import '../domain/legal_documents.dart';

class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView(
      {super.key, required this.sections, required this.version});
  final List<LegalSection> sections;
  final String version;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Version $version', style: t.labelLarge),
          const SizedBox(height: 12),
          for (final s in sections) ...[
            Semantics(
              header: true,
              child: Text(s.heading,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 4),
            Text(s.body, style: t.bodyLarge?.copyWith(height: 1.4)),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
