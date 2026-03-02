import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/remote/supabase_service.dart';
import '../../notifications/notification_service.dart';

/// Settings screen — calibration, auth, daily reminder, about.
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
    final isLoggedIn = SupabaseService.isAuthenticated;

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
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                  SupabaseService.currentUser?.email ?? 'Logged in'),
              subtitle: const Text('Tap to sign out'),
              trailing: const Icon(Icons.logout),
              onTap: () async {
                await SupabaseService.signOut();
                if (mounted) setState(() {});
              },
            )
          else ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign In'),
              subtitle: const Text('Sync your data across devices'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSignInDialog(context),
            ),
          ],

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

  void _showSignInDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sign In', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                try {
                  await SupabaseService.signIn(
                    email: emailCtrl.text.trim(),
                    password: passCtrl.text,
                  );
                  if (mounted) {
                    Navigator.pop(ctx);
                    setState(() {});
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                try {
                  await SupabaseService.signUp(
                    email: emailCtrl.text.trim(),
                    password: passCtrl.text,
                  );
                  if (mounted) {
                    Navigator.pop(ctx);
                    setState(() {});
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    await SupabaseService.signInWithGoogle();
                    if (mounted) Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                  tooltip: 'Google',
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () async {
                    await SupabaseService.signInWithApple();
                    if (mounted) Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.apple, size: 32),
                  tooltip: 'Apple',
                ),
              ],
            ),
          ],
        ),
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
