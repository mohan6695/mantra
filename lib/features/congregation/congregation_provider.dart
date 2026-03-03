import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/community.dart';

// ──────────────────────────────────────────────────────────
// Congregation state
// ──────────────────────────────────────────────────────────

sealed class CongregationState {
  const CongregationState();
}

class CongregationIdle extends CongregationState {
  const CongregationIdle();
}

class CongregationLoading extends CongregationState {
  const CongregationLoading();
}

class CongregationActive extends CongregationState {
  final CongregationSession session;
  final List<CongregationParticipant> participants;
  final int myCount;
  final List<CongregationUpdate> recentUpdates;

  const CongregationActive({
    required this.session,
    required this.participants,
    required this.myCount,
    required this.recentUpdates,
  });

  CongregationActive copyWith({
    CongregationSession? session,
    List<CongregationParticipant>? participants,
    int? myCount,
    List<CongregationUpdate>? recentUpdates,
  }) {
    return CongregationActive(
      session: session ?? this.session,
      participants: participants ?? this.participants,
      myCount: myCount ?? this.myCount,
      recentUpdates: recentUpdates ?? this.recentUpdates,
    );
  }
}

class CongregationCompleted extends CongregationState {
  final CongregationSession session;
  final List<CongregationParticipant> participants;
  final int myCount;

  const CongregationCompleted({
    required this.session,
    required this.participants,
    required this.myCount,
  });
}

class CongregationError extends CongregationState {
  final String message;
  const CongregationError(this.message);
}

// ──────────────────────────────────────────────────────────
// Provider
// ──────────────────────────────────────────────────────────

final congregationProvider =
    StateNotifierProvider<CongregationNotifier, CongregationState>((ref) {
  return CongregationNotifier();
});

/// Available public congregation sessions.
final availableCongregationsProvider =
    StateProvider<List<CongregationSession>>((ref) => []);

// ──────────────────────────────────────────────────────────
// Notifier
// ──────────────────────────────────────────────────────────

class CongregationNotifier extends StateNotifier<CongregationState> {
  Timer? _simulationTimer;
  int _simCount = 0;

  CongregationNotifier() : super(const CongregationIdle());

  /// Create a new congregation session (host).
  Future<void> createSession({
    required String name,
    required String description,
    required CongregationMantra mantra,
    required CongregationMode mode,
    required int targetCount,
    required bool isPublic,
  }) async {
    state = const CongregationLoading();

    // In offline-first mode, we simulate a local congregation session.
    // When cloud sync is enabled, this would create via API.
    final session = CongregationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      hostUserId: 'local_user',
      hostName: 'You',
      mantra: mantra,
      mode: mode,
      status: CongregationStatus.waiting,
      createdAt: DateTime.now(),
      targetCount: targetCount,
      participantCount: 1,
      totalChants: 0,
      joinCode: _generateJoinCode(),
      isPublic: isPublic,
    );

    state = CongregationActive(
      session: session,
      participants: [
        CongregationParticipant(
          odUserId: 'local_user',
          displayName: 'You',
          chantCount: 0,
          isHost: true,
          joinedAt: DateTime.now(),
        ),
      ],
      myCount: 0,
      recentUpdates: [
        CongregationUpdate(
          type: CongregationUpdateType.sessionStarted,
          message: 'Session "$name" created. Waiting for participants...',
        ),
      ],
    );
  }

  /// Start the congregation (begin chanting).
  void startCongregation() {
    if (state is! CongregationActive) return;
    final active = state as CongregationActive;

    final updatedSession = CongregationSession(
      id: active.session.id,
      name: active.session.name,
      description: active.session.description,
      hostUserId: active.session.hostUserId,
      hostName: active.session.hostName,
      mantra: active.session.mantra,
      mode: active.session.mode,
      status: CongregationStatus.active,
      createdAt: active.session.createdAt,
      startedAt: DateTime.now(),
      targetCount: active.session.targetCount,
      participantCount: active.session.participantCount,
      totalChants: 0,
      joinCode: active.session.joinCode,
      isPublic: active.session.isPublic,
    );

    state = active.copyWith(
      session: updatedSession,
      recentUpdates: [
        ...active.recentUpdates,
        const CongregationUpdate(
          type: CongregationUpdateType.sessionStarted,
          message: 'Congregation started! Begin chanting.',
        ),
      ],
    );

    // Simulate other participants for demo
    _startSimulatedParticipants();
  }

  /// Record a chant detection from the local user.
  void onChantDetected() {
    if (state is! CongregationActive) return;
    final active = state as CongregationActive;
    if (!active.session.isActive) return;

    final newCount = active.myCount + 1;
    final newTotal = active.session.totalChants + 1;

    // Update local participant
    final updatedParticipants = active.participants.map((p) {
      if (p.odUserId == 'local_user') {
        return CongregationParticipant(
          odUserId: p.odUserId,
          displayName: p.displayName,
          avatarUrl: p.avatarUrl,
          chantCount: newCount,
          isHost: p.isHost,
          isActive: p.isActive,
          joinedAt: p.joinedAt,
        );
      }
      return p;
    }).toList();

    final updatedSession = CongregationSession(
      id: active.session.id,
      name: active.session.name,
      description: active.session.description,
      hostUserId: active.session.hostUserId,
      hostName: active.session.hostName,
      mantra: active.session.mantra,
      mode: active.session.mode,
      status: active.session.status,
      createdAt: active.session.createdAt,
      startedAt: active.session.startedAt,
      endedAt: active.session.endedAt,
      targetCount: active.session.targetCount,
      participantCount: updatedParticipants.length,
      totalChants: newTotal,
      joinCode: active.session.joinCode,
      isPublic: active.session.isPublic,
    );

    // Milestone check
    final updates = List<CongregationUpdate>.from(active.recentUpdates);
    if (newTotal % 108 == 0) {
      updates.add(CongregationUpdate(
        type: CongregationUpdateType.milestoneReached,
        totalChants: newTotal,
        message: 'Group reached ${newTotal} chants! 🎉',
      ));
    }

    state = active.copyWith(
      session: updatedSession,
      participants: updatedParticipants,
      myCount: newCount,
      recentUpdates: updates,
    );

    // Check if target reached
    if (newTotal >= active.session.targetCount &&
        active.session.targetCount > 0) {
      endCongregation();
    }
  }

  /// End the congregation session.
  void endCongregation() {
    _simulationTimer?.cancel();
    if (state is! CongregationActive) return;
    final active = state as CongregationActive;

    state = CongregationCompleted(
      session: CongregationSession(
        id: active.session.id,
        name: active.session.name,
        description: active.session.description,
        hostUserId: active.session.hostUserId,
        hostName: active.session.hostName,
        mantra: active.session.mantra,
        mode: active.session.mode,
        status: CongregationStatus.completed,
        createdAt: active.session.createdAt,
        startedAt: active.session.startedAt,
        endedAt: DateTime.now(),
        targetCount: active.session.targetCount,
        participantCount: active.session.participantCount,
        totalChants: active.session.totalChants,
        joinCode: active.session.joinCode,
        isPublic: active.session.isPublic,
      ),
      participants: active.participants,
      myCount: active.myCount,
    );
  }

  /// Reset to idle.
  void reset() {
    _simulationTimer?.cancel();
    state = const CongregationIdle();
  }

  /// Simulate other participants chanting (for demo/offline mode).
  void _startSimulatedParticipants() {
    if (state is! CongregationActive) return;
    final active = state as CongregationActive;

    // Add simulated participants
    final simNames = ['Priya', 'Arjun', 'Meera', 'Ravi'];
    final simParticipants = <CongregationParticipant>[
      ...active.participants,
      ...simNames.map((name) => CongregationParticipant(
            odUserId: 'sim_${name.toLowerCase()}',
            displayName: name,
            chantCount: 0,
            isHost: false,
            joinedAt: DateTime.now(),
          )),
    ];

    state = active.copyWith(
      participants: simParticipants,
      recentUpdates: [
        ...active.recentUpdates,
        ...simNames.map((name) => CongregationUpdate(
              type: CongregationUpdateType.participantJoined,
              displayName: name,
              message: '$name joined the congregation',
            )),
      ],
    );

    // Periodically increment simulated participants' counts
    _simCount = 0;
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (state is! CongregationActive) {
        _simulationTimer?.cancel();
        return;
      }
      final current = state as CongregationActive;
      _simCount++;

      final updatedParticipants = current.participants.map((p) {
        if (p.odUserId.startsWith('sim_')) {
          return CongregationParticipant(
            odUserId: p.odUserId,
            displayName: p.displayName,
            avatarUrl: p.avatarUrl,
            chantCount: p.chantCount + 1,
            isHost: p.isHost,
            isActive: p.isActive,
            joinedAt: p.joinedAt,
          );
        }
        return p;
      }).toList();

      final simAdded = simNames.length;
      final newTotal = current.session.totalChants + simAdded;

      state = current.copyWith(
        participants: updatedParticipants,
        session: CongregationSession(
          id: current.session.id,
          name: current.session.name,
          description: current.session.description,
          hostUserId: current.session.hostUserId,
          hostName: current.session.hostName,
          mantra: current.session.mantra,
          mode: current.session.mode,
          status: current.session.status,
          createdAt: current.session.createdAt,
          startedAt: current.session.startedAt,
          targetCount: current.session.targetCount,
          participantCount: updatedParticipants.length,
          totalChants: newTotal,
          joinCode: current.session.joinCode,
          isPublic: current.session.isPublic,
        ),
      );
    });
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
            6, (i) => chars[(rng ~/ (i + 1)) % chars.length])
        .join();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
