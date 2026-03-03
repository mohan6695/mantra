import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../notifications/notification_service.dart';

/// Settings screen — calibration, daily reminder, about.
/// Cloud sync (Supabase) is disabled for local-only builds.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 6, minute: 0);
  bool _reminderEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Account ──
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.cloud_off),
            title: const Text('Cloud Sync'),
            subtitle: const Text('Coming soon — local-only for now'),
          ),

          const Divider(),

          // ── Calibration ──
          _SectionHeader(title: 'Voice Calibration'),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Recalibrate'),
            subtitle: const Text('Adjust detection for your voice'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/calibration'),
          ),

          const Divider(),

          // ── Notifications ──
          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Daily Reminder'),
            subtitle: Text(_reminderEnabled
                ? 'At ${_reminderTime.format(context)}'
                : 'Off'),
            value: _reminderEnabled,
            onChanged: (v) {
              setState(() => _reminderEnabled = v);
              if (v) {
                NotificationService.scheduleDailyReminder(_reminderTime);
              }
            },
          ),
          if (_reminderEnabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('Reminder Time'),
              trailing: Text(_reminderTime.format(context)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (picked != null) {
                  setState(() => _reminderTime = picked);
                  NotificationService.scheduleDailyReminder(picked);
                }
              },
            ),

          const Divider(),

          // ── About ──
          _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Mantra Counter'),
            subtitle: Text('v1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
