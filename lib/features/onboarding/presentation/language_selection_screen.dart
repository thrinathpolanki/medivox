import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/onboarding_scaffold.dart';
import '../../localization/language_registry.dart';
import '../data/settings_controller.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});
  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String _query = '';
  late String _selected = ref.read(settingsProvider).preferredLanguage ?? 'en';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final list = supportedLanguages
        .where((l) =>
            q.isEmpty ||
            l.englishName.toLowerCase().contains(q) ||
            l.nativeName.toLowerCase().contains(q))
        .toList();
    final info = languageByCode(_selected);
    final scheme = Theme.of(context).colorScheme;

    return OnboardingScaffold(
      title: 'Select your language',
      subtitle: '22 Indian languages and English',
      step: 6,
      scrollable: false,
      primaryLabel: 'Continue',
      onPrimary: () async {
        await ref.read(settingsProvider.notifier).setLanguage(_selected);
        if (context.mounted) context.push('/accessibility');
      },
      bottom: info != null && info.ui != Capability.available
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  '${info.englishName} is saved as your preference. The app '
                  'screens are shown in English for now, and voice, text '
                  'recognition and offline support for this language are '
                  'not yet verified. Reviewed translations will be added later.',
                  style: TextStyle(color: scheme.onSurface),
                ),
              ),
            )
          : null,
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search language',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No language found'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final l = list[i];
                      final sel = l.code == _selected;
                      return Semantics(
                        button: true,
                        selected: sel,
                        label: '${l.englishName}, ${l.nativeName}',
                        child: ExcludeSemantics(
                          child: ListTile(
                            minVerticalPadding: 12,
                            selected: sel,
                            selectedTileColor:
                                scheme.primary.withValues(alpha: 0.12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            title: Text(l.nativeName,
                                textDirection: l.rtl
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            subtitle: Text(l.englishName),
                            trailing: sel
                                ? Icon(Icons.check_circle,
                                    color: scheme.primary)
                                : null,
                            onTap: () => setState(() => _selected = l.code),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
