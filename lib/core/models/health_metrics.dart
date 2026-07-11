import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_metrics.freezed.dart';
part 'health_metrics.g.dart';

@freezed
abstract class HealthMetrics with _$HealthMetrics {
  const factory HealthMetrics({
    String? id,
    String? userId,
    int? stepsDaily,
    int? restingHeartRate,
    double? sleepHoursAvg,
    double? weightKg,
    double? heightCm,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? activeCaloriesDaily,
    String? lastSyncedAt,
    String? source,
  }) = _HealthMetrics;

  factory HealthMetrics.fromJson(Map<String, dynamic> json) =>
      _$HealthMetricsFromJson(json);
}
