import 'package:freezed_annotation/freezed_annotation.dart';

part 'history.freezed.dart';
part 'history.g.dart';

@freezed
abstract class ScanHistoryItem with _$ScanHistoryItem {
  const factory ScanHistoryItem({
    required String id,
    String? itemName,
    String? category,
    num? healthScore,
    String? imageUrl,
    required String createdAt,
  }) = _ScanHistoryItem;

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$ScanHistoryItemFromJson(json);
}

@freezed
abstract class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    required int page,
    required int limit,
    required int total,
    required int totalPages,
  }) = _PaginationMeta;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}

@freezed
abstract class ScanHistoryResponse with _$ScanHistoryResponse {
  const factory ScanHistoryResponse({
    required List<ScanHistoryItem> results,
    required PaginationMeta pagination,
  }) = _ScanHistoryResponse;

  factory ScanHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$ScanHistoryResponseFromJson(json);
}

@freezed
abstract class InsightsStats with _$InsightsStats {
  const factory InsightsStats({
    @Default(0) int totalScans,
    @Default(0) num avgScore,
    @Default(0) num minScore,
    @Default(0) num maxScore,
  }) = _InsightsStats;

  factory InsightsStats.fromJson(Map<String, dynamic> json) =>
      _$InsightsStatsFromJson(json);
}

@freezed
abstract class CategoryBreakdown with _$CategoryBreakdown {
  const factory CategoryBreakdown({
    String? category,
    @Default(0) int count,
    @Default(0) num avgScore,
  }) = _CategoryBreakdown;

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      _$CategoryBreakdownFromJson(json);
}

@freezed
abstract class InsightsPeriod with _$InsightsPeriod {
  const factory InsightsPeriod({
    required String from,
    required String to,
  }) = _InsightsPeriod;

  factory InsightsPeriod.fromJson(Map<String, dynamic> json) =>
      _$InsightsPeriodFromJson(json);
}

@freezed
abstract class GamificationSummary with _$GamificationSummary {
  const factory GamificationSummary({
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int xpTotal,
    @Default(1) int level,
  }) = _GamificationSummary;

  factory GamificationSummary.fromJson(Map<String, dynamic> json) =>
      _$GamificationSummaryFromJson(json);
}

@freezed
abstract class WeeklyInsights with _$WeeklyInsights {
  const factory WeeklyInsights({
    required InsightsPeriod period,
    required InsightsStats stats,
    @Default([]) List<CategoryBreakdown> categories,
    @Default([]) List<ScanHistoryItem> recentScans,
    GamificationSummary? gamification,
  }) = _WeeklyInsights;

  factory WeeklyInsights.fromJson(Map<String, dynamic> json) =>
      _$WeeklyInsightsFromJson(json);
}
