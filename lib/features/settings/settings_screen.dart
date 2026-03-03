import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../notifications/notification_service.dart';
import '../../core/sarvam_config.dart';

/// Settings screen — calibration, daily reminder, Sarvam AI, about.
/// Cloud sync (Supabase) is disabled for local-only builds.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 6, minute: 0);
  bool _reminderEnabled = false;
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sarvamConfig = ref.watch(sarvamConfigProvider);

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

          // ── Sarvam.ai ASR ──
          _SectionHeader(title: 'Sarvam.ai — Voice Recognition'),
          SwitchListTile(
            secondary: const Icon(Icons.record_voice_over),
            title: const Text('Enhanced Detection'),
            subtitle: Text(sarvamConfig.isReady
                ? 'Active — using Sarvam ASR for mantra verification'
                : sarvamConfig.hasValidKey
                    ? 'API key saved — toggle to enable'
                    : 'Add your Sarvam.ai API key to enable'),
            value: sarvamConfig.isEnabled && sarvamConfig.hasValidKey,
            onChanged: sarvamConfig.hasValidKey
                ? (v) =>
                    ref.read(sarvamConfigProvider.notifier).setEnabled(v)
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('API Key'),
            subtitle: Text(sarvamConfig.hasValidKey
                ? '••••••${sarvamConfig.apiKey!.substring(sarvamConfig.apiKey!.length - 4)}'
                : 'Not set'),
            trailing: const Icon(Icons.edit),
            onTap: () => _showApiKeyDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('Primary Language'),
            subtitle: Text(_languageName(sarvamConfig.languageCode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context),
          ),
          if (sarvamConfig.usageSeconds > 0)
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Usage'),
              subtitle: Text(
                '${(sarvamConfig.usageSeconds / 60).toStringAsFixed(1)} min — '
                '₹${sarvamConfig.estimatedCostRupees.toStringAsFixed(2)} est. cost',
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Sarvam.ai provides high-accuracy speech recognition for 23 '
              'Indian languages including Sanskrit. Free ₹1,000 credits '
              'on signup at sarvam.ai.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
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
            subtitle: Text('v1.1.0 — Community Edition'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final sarvamConfig = ref.read(sarvamConfigProvider);
    _apiKeyController.text = sarvamConfig.apiKey ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sarvam.ai API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Get your API key from sarvam.ai dashboard. '
              'New accounts get ₹1,000 free credits.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter your Sarvam API key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(sarvamConfigProvider.notifier)
                  .setApiKey(_apiKeyController.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final languages = {
      SarvamConstants.sanskrit: 'Sanskrit',
      SarvamConstants.hindi: 'Hindi',
      SarvamConstants.tamil: 'Tamil',
      SarvamConstants.telugu: 'Telugu',
      SarvamConstants.kannada: 'Kannada',
      SarvamConstants.malayalam: 'Malayalam',
      SarvamConstants.bengali: 'Bengali',
      SarvamConstants.marathi: 'Marathi',
      SarvamConstants.gujarati: 'Gujarati',
      SarvamConstants.punjabi: 'Punjabi',
      SarvamConstants.english: 'English (India)',
    };

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select Language',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ...languages.entries.map((e) => ListTile(
                  title: Text(e.value),
                  subtitle: Text(e.key),
                  trailing: ref.read(sarvamConfigProvider).languageCode ==
                          e.key
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    ref
                        .read(sarvamConfigProvider.notifier)
                        .setLanguage(e.key);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _languageName(String code) {
    const names = {
      'sa-IN': 'Sanskrit',
      'hi-IN': 'Hindi',
      'ta-IN': 'Tamil',
      'te-IN': 'Telugu',
      'kn-IN': 'Kannada',
      'ml-IN': 'Malayalam',
      'bn-IN': 'Bengali',
      'mr-IN': 'Marathi',
      'gu-IN': 'Gujarati',
      'pa-IN': 'Punjabi',
      'en-IN': 'English (India)',
    };
    return names[code] ?? code;
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
