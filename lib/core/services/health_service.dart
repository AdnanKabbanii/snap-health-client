import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:health/health.dart';
import '../models/models.dart';

class HealthService {
  final _health = Health();
  bool _authorized = false;

  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  bool get isAvailable => !kIsWeb;
  bool get isAuthorized => _authorized;

  String get sourceName {
    if (kIsWeb) return 'manual';
    if (Platform.isIOS) return 'apple_health';
    return 'health_connect';
  }

  Future<bool> requestPermissions() async {
    if (!isAvailable) return false;
    try {
      final permissions = _types.map((_) => HealthDataAccess.READ).toList();
      _authorized = await _health.requestAuthorization(_types, permissions: permissions);
      return _authorized;
    } catch (_) {
      return false;
    }
  }

  Future<HealthMetrics?> fetchMetrics() async {
    if (!isAvailable || !_authorized) return null;

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    try {
      final data = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: sevenDaysAgo,
        endTime: now,
      );

      int totalSteps = 0;
      int stepDays = 0;
      final heartRates = <double>[];
      double totalSleep = 0;
      int sleepDays = 0;
      double? latestWeight;
      double? latestHeight;
      int? latestSystolic;
      int? latestDiastolic;
      int totalCalories = 0;
      int calorieDays = 0;

      for (final point in data) {
        final value = point.value;
        switch (point.type) {
          case HealthDataType.STEPS:
            if (value is NumericHealthValue) {
              totalSteps += value.numericValue.toInt();
              stepDays++;
            }
            break;
          case HealthDataType.HEART_RATE:
            if (value is NumericHealthValue) heartRates.add(value.numericValue.toDouble());
            break;
          case HealthDataType.SLEEP_ASLEEP:
            if (value is NumericHealthValue) {
              totalSleep += value.numericValue.toDouble();
              sleepDays++;
            }
            break;
          case HealthDataType.WEIGHT:
            if (value is NumericHealthValue) latestWeight = value.numericValue.toDouble();
            break;
          case HealthDataType.HEIGHT:
            if (value is NumericHealthValue) latestHeight = value.numericValue.toDouble() * 100;
            break;
          case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
            if (value is NumericHealthValue) latestSystolic = value.numericValue.toInt();
            break;
          case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
            if (value is NumericHealthValue) latestDiastolic = value.numericValue.toInt();
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            if (value is NumericHealthValue) {
              totalCalories += value.numericValue.toInt();
              calorieDays++;
            }
            break;
          default:
            break;
        }
      }

      return HealthMetrics(
        stepsDaily: stepDays > 0 ? totalSteps ~/ stepDays : null,
        restingHeartRate: heartRates.isNotEmpty ? (heartRates.reduce((a, b) => a + b) / heartRates.length).round() : null,
        sleepHoursAvg: sleepDays > 0 ? double.parse((totalSleep / sleepDays).toStringAsFixed(1)) : null,
        weightKg: latestWeight,
        heightCm: latestHeight,
        bloodPressureSystolic: latestSystolic,
        bloodPressureDiastolic: latestDiastolic,
        activeCaloriesDaily: calorieDays > 0 ? totalCalories ~/ calorieDays : null,
        source: sourceName,
      );
    } catch (_) {
      return null;
    }
  }
}

final healthService = HealthService();
