import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/models.dart';
import '../services/health_service.dart';

final healthMetricsProvider = AsyncNotifierProvider<HealthMetricsNotifier, HealthMetrics?>(
  HealthMetricsNotifier.new,
);

class HealthMetricsNotifier extends AsyncNotifier<HealthMetrics?> {
  @override
  Future<HealthMetrics?> build() async {
    try {
      return await apiService.getHealthMetrics();
    } catch (_) {
      return null;
    }
  }

  Future<bool> connectAndSync() async {
    final granted = await healthService.requestPermissions();
    if (!granted) return false;

    final metrics = await healthService.fetchMetrics();
    if (metrics == null) return false;

    await apiService.updateHealthMetrics(metrics);
    ref.invalidateSelf();
    return true;
  }

  Future<void> syncNow() async {
    final metrics = await healthService.fetchMetrics();
    if (metrics == null) return;
    await apiService.updateHealthMetrics(metrics);
    ref.invalidateSelf();
  }

  Future<void> disconnect() async {
    await apiService.deleteHealthMetrics();
    ref.invalidateSelf();
  }
}
