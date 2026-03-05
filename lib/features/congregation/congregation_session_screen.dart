import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/community.dart';
import '../../audio/audio_channel.dart';
import 'congregation_provider.dart';

/// Active congregation session screen — real-time group chanting.
class CongregationSessionScreen extends ConsumerStatefulWidget {
  const CongregationSessionScreen({super.key});

  @override
  ConsumerState<CongregationSessionScreen> createState() =>
      _CongregationSessionScreenState();
}

class _CongregationSessionScreenState
    extends ConsumerState<CongregationSessionScreen> {
  StreamSubscription? _detectionSub;
  bool _isChanting = false;

  @override
  void dispose() {
    _detectionSub?.cancel();
    if (_isChanting) {
      AudioChannel.stopEngine();
    }
    super.dispose();
  }

  void _startChanting() async {
    final state = ref.read(congregationProvider);
    if (state is! CongregationActive) return;

    ref.read(congregationProvider.notifier).startCongregation();

    // Start audio engine for detection
    await AudioChannel.startEngine(
      mantras: [
        {
          'name': state.session.mantra.name,
          'id': state.session.mantra.mantraId ?? 1,
          'sensitivity': 0.3,
        }
      ],
      threshold: 0.3,
      mode: 'ensemble',
    );

    // Listen to raw segment stream — for congregation, accept any
    // segment with enough energy (no full ensemble needed for group mode)
    _detectionSub = AudioChannel.segmentStream.listen((segment) {
      if (segment.peakEnergy > 0.05) {
        ref.read(congregationProvider.notifier).onChantDetected();
      }
    });

    setState(() => _isChanting = true);
  }

  void _stopChanting() async {
    await AudioChannel.stopEngine();
    _detectionSub?.cancel();
    ref.read(congregationProvider.notifier).endCongregation();
    setState(() => _isChanting = false);
  }

  @override
  Widget build(BuildContext context) {
    final congState = ref.watch(congregationProvider);
    final theme = Theme.of(context);

    if (congState is CongregationCompleted) {
      return _CompletedView(
        session: congState.session,
        participants: congState.participants,
        myCount: congState.myCount,
        onDone: () {
          ref.read(congregationProvider.notifier).reset();
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
      );
    }

    if (congState is! CongregationActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('Congregation')),
        body: const Center(child: Text('No active session')),
      );
    }

    final session = congState.session;
    final participants = congState.participants;
    final myCount = congState.myCount;
    final progress = session.targetCount > 0
        ? session.totalChants / session.targetCount
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.name),
        centerTitle: true,
        actions: [
          if (session.joinCode != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Join code: ${session.joinCode}'),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Group progress header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer
                  .withAlpha(80),
            ),
            child: Column(
              children: [
                Text(
                  '${session.totalChants}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Group Chants',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (session.targetCount > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.totalChants} / ${session.targetCount} '
                    '(${(progress * 100).round()}%)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      icon: Icons.people,
                      value: '${participants.length}',
                      label: 'Participants',
                    ),
                    const SizedBox(width: 16),
                    _StatChip(
                      icon: Icons.timer,
                      value: _formatDuration(session.elapsed),
                      label: 'Duration',
                    ),
                    const SizedBox(width: 16),
                    _StatChip(
                      icon: Icons.person,
                      value: '$myCount',
                      label: 'My Count',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Participants list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 8),
                  child: Text('Participants',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                ...participants.map((p) => _ParticipantTile(
                      participant: p,
                      isMe: p.odUserId == 'local_user',
                    )),
                const SizedBox(height: 16),

                // Recent updates
                if (congState.recentUpdates.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    child: Text('Activity',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  ...congState.recentUpdates.reversed
                      .take(10)
                      .map((u) => _UpdateTile(update: u)),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: session.isActive && _isChanting
                    ? FilledButton.icon(
                        onPressed: _stopChanting,
                        icon: const Icon(Icons.stop),
                        label: const Text('End Session'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(52),
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: _startChanting,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Chanting'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }
}

// ─────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(value,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final CongregationParticipant participant;
  final bool isMe;
  const _ParticipantTile({required this.participant, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isMe ? theme.colorScheme.primaryContainer.withAlpha(60) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMe
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          child: Text(
            participant.displayName[0].toUpperCase(),
            style: TextStyle(
              color: isMe
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(participant.displayName),
            if (isMe)
              const Text(' (You)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            if (participant.isHost) ...[
              const SizedBox(width: 4),
              Icon(Icons.star, size: 16, color: Colors.amber.shade700),
            ],
          ],
        ),
        trailing: Text(
          '${participant.chantCount}',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _UpdateTile extends StatelessWidget {
  final CongregationUpdate update;
  const _UpdateTile({required this.update});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (update.type) {
      case CongregationUpdateType.participantJoined:
        icon = Icons.person_add;
        break;
      case CongregationUpdateType.participantLeft:
        icon = Icons.person_remove;
        break;
      case CongregationUpdateType.milestoneReached:
        icon = Icons.celebration;
        break;
      case CongregationUpdateType.sessionStarted:
        icon = Icons.play_arrow;
        break;
      case CongregationUpdateType.sessionCompleted:
        icon = Icons.check_circle;
        break;
      default:
        icon = Icons.info_outline;
    }

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, size: 18),
      title: Text(update.message ?? '',
          style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Completed View
// ─────────────────────────────────────────────────────────

class _CompletedView extends StatelessWidget {
  final CongregationSession session;
  final List<CongregationParticipant> participants;
  final int myCount;
  final VoidCallback onDone;

  const _CompletedView({
    required this.session,
    required this.participants,
    required this.myCount,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<CongregationParticipant>.from(participants)
      ..sort((a, b) => b.chantCount.compareTo(a.chantCount));

    return Scaffold(
      appBar: AppBar(title: const Text('Session Complete')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text('🎉', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Congregation Complete!',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Center(child: Text(session.name)),
          const SizedBox(height: 24),

          // Stats row
          Row(
            children: [
              _CompletedStat(
                  label: 'Total', value: '${session.totalChants}'),
              _CompletedStat(
                  label: 'Participants',
                  value: '${participants.length}'),
              _CompletedStat(label: 'Your Count', value: '$myCount'),
              _CompletedStat(
                label: 'Duration',
                value: '${session.elapsed.inMinutes}m',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Leaderboard
          Text('Leaderboard',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...sorted.asMap().entries.map((entry) {
            final idx = entry.key;
            final p = entry.value;
            final medal =
                idx == 0 ? '🥇' : (idx == 1 ? '🥈' : (idx == 2 ? '🥉' : ''));
            return ListTile(
              leading: Text(medal.isNotEmpty ? medal : '${idx + 1}',
                  style: const TextStyle(fontSize: 20)),
              title: Text(p.displayName),
              trailing: Text('${p.chantCount}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            );
          }),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onDone,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _CompletedStat extends StatelessWidget {
  final String label;
  final String value;
  const _CompletedStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
