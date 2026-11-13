import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../reminders/services/reminder_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _rescheduleOnOpen();
  }

  Future<void> _rescheduleOnOpen() async {
    // Wait until after first frame so providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(AppConstants.prefUserId) ?? 'local-user';
      final scheduler = ref.read(reminderSchedulerProvider);
      // This ensures alarms are restored after reboot or app kill
      await scheduler.scheduleAllMedicinesForUser(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediVox'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, User',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  'Scan Medicine',
                  Icons.camera_alt,
                  () => context.push('/scan'),
                ),
                _buildActionCard(
                  context,
                  'Add Medicine',
                  Icons.add_circle,
                  () => context.push('/add-medicine'),
                ),
                _buildActionCard(
                  context,
                  'My Medicines',
                  Icons.medication,
                  () => context.push('/medicines'),
                ),
                _buildActionCard(
                  context,
                  "Today's Schedule",
                  Icons.calendar_today,
                  () => context.push(
                    '/todays-schedule',
                  ), // <-- Wired up to the new screen
                ),
                _buildActionCard(context, 'Reminders', Icons.alarm, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminders coming in Phase 6'),
                    ),
                  );
                }),
                _buildActionCard(
                  context,
                  'Reports',
                  Icons.bar_chart,
                  () => context.push('/adherence'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice Assistant coming in Phase 6')),
          );
        },
        icon: const Icon(Icons.mic),
        label: const Text('Voice Assistant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Scan'),
          NavigationDestination(
            icon: Icon(Icons.medication),
            label: 'Medicines',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.push('/scan');
              break;
            case 2:
              context.push('/medicines');
              break;
            case 3:
              context.push('/caregiver');
              break;
          }
        },
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
