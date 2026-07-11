import 'package:freezed_annotation/freezed_annotation.dart';

part 'gamification.freezed.dart';
part 'gamification.g.dart';

@freezed
abstract class Badge with _$Badge {
  const factory Badge({
    required String id,
    required String name,
    String? icon,
    String? earnedAt,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}

@freezed
abstract class XpProgress with _$XpProgress {
  const factory XpProgress({
    required int current,
    required int needed,
    required int level,
  }) = _XpProgress;

  factory XpProgress.fromJson(Map<String, dynamic> json) =>
      _$XpProgressFromJson(json);
}

@freezed
abstract class GamificationStatus with _$GamificationStatus {
  const factory GamificationStatus({
    required String id,
    required String userId,
    required int xpTotal,
    required int level,
    required int currentStreak,
    required int longestStreak,
    @Default(0) int streakShields,
    String? lastScanDate,
    @Default([]) List<Badge> badges,
    String? levelTitle,
    XpProgress? xpProgress,
    @Default(0) int totalBadgeCount,
    String? referralCode,
    String? createdAt,
    String? updatedAt,
  }) = _GamificationStatus;

  factory GamificationStatus.fromJson(Map<String, dynamic> json) =>
      _$GamificationStatusFromJson(json);
}

@freezed
abstract class CheckinResponse with _$CheckinResponse {
  const factory CheckinResponse({
    required int streak,
    required int longestStreak,
    required int xpTotal,
    required int level,
    @Default(0) int streakShields,
    @Default(false) bool leveledUp,
    @Default(false) bool shieldUsed,
    @Default([]) List<Badge> newBadges,
  }) = _CheckinResponse;

  factory CheckinResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckinResponseFromJson(json);
}

@freezed
abstract class WeeklyChallenge with _$WeeklyChallenge {
  const factory WeeklyChallenge({
    required String id,
    required String title,
    required String description,
    required String type,
    required int targetValue,
    required int xpReward,
    String? icon,
    String? weekStart,
  }) = _WeeklyChallenge;

  factory WeeklyChallenge.fromJson(Map<String, dynamic> json) =>
      _$WeeklyChallengeFromJson(json);
}

@freezed
abstract class ChallengeProgress with _$ChallengeProgress {
  const factory ChallengeProgress({
    String? id,
    required int progress,
    required bool completed,
    String? completedAt,
  }) = _ChallengeProgress;

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) =>
      _$ChallengeProgressFromJson(json);
}

@freezed
abstract class ChallengeWithProgress with _$ChallengeWithProgress {
  const factory ChallengeWithProgress({
    required WeeklyChallenge challenge,
    ChallengeProgress? progress,
  }) = _ChallengeWithProgress;

  factory ChallengeWithProgress.fromJson(Map<String, dynamic> json) =>
      _$ChallengeWithProgressFromJson(json);
}

@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required int rank,
    required String userId,
    required String displayName,
    @Default(0) int xp,
    @Default(0) int level,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}

