import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../audio/verse_channel.dart';
import '../../audio/verse_tracker.dart';
import '../../data/models/verse_mantra.dart';
import '../../data/sample_verses.dart';

// ──────────────────────────────────────────────────────────
// Verse list provider
// ──────────────────────────────────────────────────────────

/// All available verse mantras.
final verseListProvider = Provider<List<VerseMantra>>((ref) {
  return allVerses;
});

// ──────────────────────────────────────────────────────────
// Verse session state
// ──────────────────────────────────────────────────────────

/// Overall verse session phase.
enum VerseSessionPhase { idle, active, completed }

class VerseSessionState {
  final VerseSessionPhase phase;
  final VerseMantra? verse;
  final VerseTrackingState? tracking;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final double sensitivity;

  const VerseSessionState({
    this.phase = VerseSessionPhase.idle,
    this.verse,
    this.tracking,
    this.startedAt,
    this.endedAt,
    this.sensitivity = 0.5,
  });

  VerseSessionState copyWith({
    VerseSessionPhase? phase,
    VerseMantra? verse,
    VerseTrackingState? tracking,
    DateTime? startedAt,
    DateTime? endedAt,
    double? sensitivity,
  }) {
    return VerseSessionState(
      phase: phase ?? this.phase,
      verse: verse ?? this.verse,
      tracking: tracking ?? this.tracking,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      sensitivity: sensitivity ?? this.sensitivity,
    );
  }

  /// Duration of the session so far.
  Duration get elapsed {
    if (startedAt == null) return Duration.zero;
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt!);
  }
}

// ──────────────────────────────────────────────────────────
// Verse session notifier
// ──────────────────────────────────────────────────────────

final verseSessionProvider =
    StateNotifierProvider<VerseSessionNotifier, VerseSessionState>((ref) {
  return VerseSessionNotifier();
});

class VerseSessionNotifier extends StateNotifier<VerseSessionState> {
  VerseTracker? _tracker;
  StreamSubscription? _trackingSub;

  VerseSessionNotifier() : super(const VerseSessionState());

  /// Start a verse tracking session.
  Future<bool> startSession({
    required VerseMantra verse,
    double sensitivity = 0.5,
  }) async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) return false;

    // Create tracker
    _tracker = VerseTracker(verse: verse);

    // Listen for tracking state updates
    _trackingSub = _tracker!.stateStream.listen((trackingState) {
      state = state.copyWith(tracking: trackingState);

      // Auto-detect completion
      if (trackingState.isComplete &&
          state.phase == VerseSessionPhase.active) {
        _completeSession();
      }
    });

    // Start native audio engine
    await VerseAudioChannel.startEngine(
      totalWords: verse.totalWords,
      sensitivity: sensitivity,
    );

    // Start tracker listening
    _tracker!.startListening();

    state = VerseSessionState(
      phase: VerseSessionPhase.active,
      verse: verse,
      tracking: _tracker!.currentState,
      startedAt: DateTime.now(),
      sensitivity: sensitivity,
    );

    return true;
  }

  /// End the session manually.
  Future<void> endSession() async {
    await VerseAudioChannel.stopEngine();
    _tracker?.stopListening();
    _trackingSub?.cancel();

    state = state.copyWith(
      phase: VerseSessionPhase.completed,
      endedAt: DateTime.now(),
    );
  }

  /// Auto-called when verse is completely tracked.
  void _completeSession() {
    VerseAudioChannel.stopEngine();
    _tracker?.stopListening();
    _trackingSub?.cancel();

    state = state.copyWith(
      phase: VerseSessionPhase.completed,
      endedAt: DateTime.now(),
    );
  }

  /// User taps a word to re-sync the tracker.
  void jumpToWord(int globalIndex) {
    _tracker?.jumpToWord(globalIndex);
  }

  /// Manual tap-to-advance.
  void advanceOneWord() {
    _tracker?.advanceOneWord();
  }

  /// Update sensitivity mid-session.
  void updateSensitivity(double sensitivity) {
    state = state.copyWith(sensitivity: sensitivity);
    VerseAudioChannel.updateSensitivity(sensitivity);
  }

  /// Reset to idle.
  void reset() {
    _tracker?.dispose();
    _tracker = null;
    _trackingSub?.cancel();
    state = const VerseSessionState();
  }

  @override
  void dispose() {
    _tracker?.dispose();
    _trackingSub?.cancel();
    super.dispose();
  }
}
