import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/community.dart';
import 'congregation_provider.dart';

/// Screen to browse / create congregation sessions.
class CongregationListScreen extends ConsumerWidget {
  const CongregationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final congState = ref.watch(congregationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Congregation'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active session banner
          if (congState is CongregationActive)
            _ActiveSessionBanner(
              session: congState.session,
              myCount: congState.myCount,
              onTap: () => context.push('/congregation/active'),
            ),

          // Create new session
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showCreateSheet(context, ref),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create Congregation',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'Host a group bhajan session',
                            style:
                                Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Join with code
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showJoinDialog(context),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.group_add,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Join with Code',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'Enter a 6-character join code',
                            style:
                                Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // How it works
          Text('How It Works',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _HowItWorksStep(
            number: '1',
            title: 'Create or Join',
            description:
                'Host a congregation or join an existing one with a code.',
          ),
          _HowItWorksStep(
            number: '2',
            title: 'Chant Together',
            description:
                'All participants chant simultaneously. Counts are merged in real-time.',
          ),
          _HowItWorksStep(
            number: '3',
            title: 'Reach the Goal',
            description:
                'Work together to reach the group target — 108, 1008, or more!',
          ),
          _HowItWorksStep(
            number: '4',
            title: 'Celebrate',
            description:
                'See collective impact and individual contributions.',
          ),

          const SizedBox(height: 24),

          // Chanting modes
          Text('Chanting Modes',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.groups,
            title: 'Free Chant',
            description: 'Everyone chants at their own pace.',
          ),
          _ModeCard(
            icon: Icons.sync,
            title: 'Synchronized',
            description: 'Follow the host\'s pace.',
          ),
          _ModeCard(
            icon: Icons.music_note,
            title: 'Verse Tracking',
            description: 'Karaoke-style group verse chanting.',
          ),
          _ModeCard(
            icon: Icons.swap_horiz,
            title: 'Relay',
            description: 'Take turns chanting lines.',
          ),
        ],
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateCongregationSheet(ref: ref),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join Congregation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Join Code',
            hintText: 'Enter 6-character code',
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Join feature requires cloud sync (coming soon)')),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _ActiveSessionBanner extends StatelessWidget {
  final CongregationSession session;
  final int myCount;
  final VoidCallback onTap;

  const _ActiveSessionBanner({
    required this.session,
    required this.myCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.play_circle_filled, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '${session.participantCount} participants · '
                      '${session.totalChants} chants',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text('$myCount',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('You', style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.colorScheme.primary,
            child: Text(number,
                style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Create Congregation Sheet
// ─────────────────────────────────────────────────────────

class _CreateCongregationSheet extends StatefulWidget {
  final WidgetRef ref;
  const _CreateCongregationSheet({required this.ref});

  @override
  State<_CreateCongregationSheet> createState() =>
      _CreateCongregationSheetState();
}

class _CreateCongregationSheetState
    extends State<_CreateCongregationSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  CongregationMode _mode = CongregationMode.freeChant;
  int _target = 108;
  bool _isPublic = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Congregation',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Session Name',
              hintText: 'e.g., Morning Bhajan Circle',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          // Mode selector
          DropdownButtonFormField<CongregationMode>(
            value: _mode,
            decoration: const InputDecoration(
              labelText: 'Chanting Mode',
              border: OutlineInputBorder(),
            ),
            items: CongregationMode.values
                .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(_modeName(m)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _mode = v!),
          ),
          const SizedBox(height: 12),
          // Target selector
          DropdownButtonFormField<int>(
            value: _target,
            decoration: const InputDecoration(
              labelText: 'Group Target',
              border: OutlineInputBorder(),
            ),
            items: [108, 540, 1008, 5000, 10008]
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text('$t chants'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _target = v!),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Public'),
            subtitle: const Text('Anyone can discover and join'),
            value: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _create,
            icon: const Icon(Icons.groups),
            label: const Text('Create & Start'),
          ),
        ],
      ),
    );
  }

  void _create() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a session name')),
      );
      return;
    }

    widget.ref.read(congregationProvider.notifier).createSession(
          name: name,
          description: _descController.text.trim(),
          mantra: const CongregationMantra(
            mantraId: 1,
            name: 'Om Namah Shivaya',
            devanagari: 'ॐ नमः शिवाय',
          ),
          mode: _mode,
          targetCount: _target,
          isPublic: _isPublic,
        );

    Navigator.pop(context);
    context.push('/congregation/active');
  }

  String _modeName(CongregationMode mode) {
    switch (mode) {
      case CongregationMode.freeChant:
        return 'Free Chant';
      case CongregationMode.synchronized:
        return 'Synchronized';
      case CongregationMode.verseTracking:
        return 'Verse Tracking';
      case CongregationMode.relay:
        return 'Relay';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
