/// Community, leaderboard, and congregation data models.
///
/// These models support:
/// 1. Global/regional leaderboards per mantra
/// 2. Congregation (group bhajan) sessions
/// 3. Personal achievements and milestones
/// 4. Community challenges

// ──────────────────────────────────────────────────────────
// Leaderboard models
// ──────────────────────────────────────────────────────────

/// A single leaderboard entry for a user's mantra count.
class LeaderboardEntry {
  final String rank;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int totalCount;
  final int todayCount;
  final int streakDays;
  final int weeklyCount;
  final DateTime lastActive;
  final String? region;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.totalCount,
    required this.todayCount,
    required this.streakDays,
    required this.weeklyCount,
    required this.lastActive,
    this.region,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank']?.toString() ?? '0',
      userId: json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Anonymous',
      avatarUrl: json['avatar_url'] as String?,
      totalCount: json['total_count'] as int? ?? 0,
      todayCount: json['today_count'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      weeklyCount: json['weekly_count'] as int? ?? 0,
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'] as String)
          : DateTime.now(),
      region: json['region'] as String?,
    );
  }
}

/// Leaderboard for a specific mantra with different time ranges.
class MantraLeaderboard {
  final int mantraId;
  final String mantraName;
  final LeaderboardTimeRange timeRange;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUser;
  final DateTime fetchedAt;

  const MantraLeaderboard({
    required this.mantraId,
    required this.mantraName,
    required this.timeRange,
    required this.entries,
    this.currentUser,
    required this.fetchedAt,
  });
}

enum LeaderboardTimeRange { today, thisWeek, thisMonth, allTime }

// ──────────────────────────────────────────────────────────
// Achievement models
// ──────────────────────────────────────────────────────────

/// A personal achievement / badge.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int targetValue;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.targetValue,
    required this.currentValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progress => targetValue > 0 ? currentValue / targetValue : 0.0;
}

enum AchievementCategory {
  streak, // Consecutive day milestones
  count, // Total chant milestones
  accuracy, // ASR accuracy milestones
  verse, // Verse completion milestones
  community, // Social/group milestones
  devotion, // Time-based devotion milestones
}

// ──────────────────────────────────────────────────────────
// Congregation (group bhajan) models
// ──────────────────────────────────────────────────────────

/// A congregation (group bhajan) session.
class CongregationSession {
  final String id;
  final String name;
  final String? description;
  final String hostUserId;
  final String hostName;
  final CongregationMantra mantra;
  final CongregationMode mode;
  final CongregationStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int targetCount;
  final int participantCount;
  final int totalChants;
  final String? joinCode;
  final String? region;
  final bool isPublic;

  const CongregationSession({
    required this.id,
    required this.name,
    this.description,
    required this.hostUserId,
    required this.hostName,
    required this.mantra,
    required this.mode,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    required this.targetCount,
    required this.participantCount,
    required this.totalChants,
    this.joinCode,
    this.region,
    this.isPublic = true,
  });

  bool get isActive => status == CongregationStatus.active;
  bool get isCompleted => status == CongregationStatus.completed;
  Duration get elapsed {
    if (startedAt == null) return Duration.zero;
    return (endedAt ?? DateTime.now()).difference(startedAt!);
  }
}

/// Mantra being chanted in a congregation.
class CongregationMantra {
  final int? mantraId; // null for verse mantras
  final String? verseId; // null for short mantras
  final String name;
  final String devanagari;
  final bool isVerse;

  const CongregationMantra({
    this.mantraId,
    this.verseId,
    required this.name,
    required this.devanagari,
    this.isVerse = false,
  });
}

/// How the congregation chants together.
enum CongregationMode {
  /// Everyone chants independently, counts merged.
  freeChant,

  /// Synchronized — host sets pace, all follow.
  synchronized,

  /// Verse mode — karaoke-style group tracking.
  verseTracking,

  /// Relay — participants take turns chanting lines.
  relay,
}

enum CongregationStatus { waiting, active, paused, completed }

/// A participant in a congregation session.
class CongregationParticipant {
  final String odUserId;
  final String displayName;
  final String? avatarUrl;
  final int chantCount;
  final bool isHost;
  final bool isActive;
  final double? accuracy; // ASR accuracy if using Sarvam
  final DateTime joinedAt;

  const CongregationParticipant({
    required this.odUserId,
    required this.displayName,
    this.avatarUrl,
    required this.chantCount,
    this.isHost = false,
    this.isActive = true,
    this.accuracy,
    required this.joinedAt,
  });
}

/// Real-time update from a congregation session.
class CongregationUpdate {
  final CongregationUpdateType type;
  final String? userId;
  final String? displayName;
  final int? count;
  final int? totalChants;
  final int? participantCount;
  final String? message;

  const CongregationUpdate({
    required this.type,
    this.userId,
    this.displayName,
    this.count,
    this.totalChants,
    this.participantCount,
    this.message,
  });
}

enum CongregationUpdateType {
  participantJoined,
  participantLeft,
  chantDetected,
  milestoneReached,
  sessionStarted,
  sessionPaused,
  sessionResumed,
  sessionCompleted,
  hostMessage,
}

// ──────────────────────────────────────────────────────────
// Community challenge models
// ──────────────────────────────────────────────────────────

/// A community challenge (e.g. "1 lakh Om Namah Shivaya this Maha Shivaratri")
class CommunityChallenge {
  final String id;
  final String title;
  final String description;
  final String? mantraName;
  final int? mantraId;
  final int globalTarget;
  final int globalProgress;
  final int myContribution;
  final int participantCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? badgeId;
  final String? festivalName;

  const CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    this.mantraName,
    this.mantraId,
    required this.globalTarget,
    required this.globalProgress,
    required this.myContribution,
    required this.participantCount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.badgeId,
    this.festivalName,
  });

  double get progress =>
      globalTarget > 0 ? globalProgress / globalTarget : 0.0;
  bool get isCompleted => globalProgress >= globalTarget;
  Duration get timeRemaining => endDate.difference(DateTime.now());
}
