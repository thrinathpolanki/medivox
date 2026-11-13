import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../database/app_database.dart';
import '../../../database/database_provider.dart';

final allProfilesProvider = FutureProvider<List<UserProfile>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.select(db.userProfiles).get();
});

final activeProfileIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(AppConstants.prefUserId) ?? 'local-user';
});

class CaregiverModeScreen extends ConsumerWidget {
  const CaregiverModeScreen({super.key});

  Future<void> _addFamilyMember(
      BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Family Member'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g., Mom, Dad, Grandfather',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok != true || nameCtrl.text.trim().isEmpty) return;

    final db = ref.read(databaseProvider);
    final newId = 'family-${const Uuid().v4()}';
    await db.into(db.userProfiles).insert(UserProfilesCompanion.insert(
      userId: newId,
      displayName: Value(nameCtrl.text.trim()),
      storageMode: 'local',
      createdAt: DateTime.now(),
    ));

    ref.invalidate(allProfilesProvider);
  }

  Future<void> _switchTo(BuildContext context, String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefUserId, profileId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Switched profile. Reopen Home for fresh data.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(allProfilesProvider);
    final activeAsync = ref.watch(activeProfileIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Mode')),
      body: profilesAsync.when(
        data: (profiles) {
          final activeId = activeAsync.valueOrNull;
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: profiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final p = profiles[i];
                    final isActive = p.userId == activeId;
                    return Card(
                      color: isActive ? Colors.teal.shade50 : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? Colors.teal
                              : Colors.grey.shade400,
                          child: Text(
                            (p.displayName ?? '?')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(p.displayName ?? 'Unnamed'),
                        subtitle: Text(isActive ? 'Active profile' : 'Tap to switch'),
                        trailing: isActive
                            ? const Icon(Icons.check_circle, color: Colors.teal)
                            : null,
                        onTap: () => _switchTo(context, p.userId),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add_alt),
                  onPressed: () => _addFamilyMember(context, ref),
                  label: const Text('Add Family Member'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
