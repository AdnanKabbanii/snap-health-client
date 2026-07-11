import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/health_provider.dart';
import '../../widgets/ui.dart';

class HealthConnectScreen extends ConsumerStatefulWidget {
  const HealthConnectScreen({super.key});

  @override
  ConsumerState<HealthConnectScreen> createState() => _HealthConnectScreenState();
}

class _HealthConnectScreenState extends ConsumerState<HealthConnectScreen> {
  bool _syncing = false;

  String get _platformName {
    if (kIsWeb) return 'Health Data';
    if (Platform.isIOS) return 'Apple Health';
    return 'Health Connect';
  }

  Future<void> _connect() async {
    setState(() => _syncing = true);
    final success = await ref.read(healthMetricsProvider.notifier).connectAndSync();
    if (mounted) {
      setState(() => _syncing = false);
      if (!success) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text('Permission denied or no data available', style: kBody),
            ),
          ),
        );
      }
    }
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);
    await ref.read(healthMetricsProvider.notifier).syncNow();
    if (mounted) setState(() => _syncing = false);
  }

  Future<void> _disconnect() async {
    await ref.read(healthMetricsProvider.notifier).disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(healthMetricsProvider);

    return Scaffold(
      child: Container(
        color: kBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconSquare(
                      icon: Icons.arrow_back_rounded,
                      size: 38,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Gap(16),
                    Text('Biometrics', style: kHeadline.copyWith(fontSize: 24)),
                  ],
                ),
                const Gap(8),
                Text('Live body data sharpens every verdict we give you.', style: kCaption),
                const Gap(24),

                metricsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: LoadingState(message: 'Checking the link'),
                  ),
                  error: (e, _) => ErrorState(
                    message: 'Could not read health data. Check permissions and retry.',
                    onRetry: () => ref.invalidate(healthMetricsProvider),
                  ),
                  data: (metrics) {
                    if (metrics == null) return _buildDisconnected();
                    return _buildConnected(metrics);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisconnected() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          padding: const EdgeInsets.all(26),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: kSignal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: kSignal.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.monitor_heart_outlined, size: 28, color: kSignal),
              ),
              const Gap(18),
              Text('Not linked yet', style: kTitle.copyWith(fontSize: 18)),
              const Gap(8),
              Text(
                'Link $_platformName and your scans get scored against your real numbers — not population averages.',
                style: kBody.copyWith(color: kOnSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Gap(22),
              AppButton(
                label: 'Link $_platformName',
                icon: Icons.link_rounded,
                loading: _syncing,
                onTap: _connect,
              ),
            ],
          ),
        ),
        const Gap(26),
        const Eyebrow('What we read'),
        const Gap(12),
        Panel(
          child: Column(
            children: _dataTypes
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(item.$2, size: 17, color: kOnSurfaceVariant),
                          const Gap(12),
                          Text(item.$1, style: kBody.copyWith(fontSize: 13.5)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 13, color: kOnSurfaceFaint),
            const Gap(7),
            Text('Read-only. We never write to your health data.', style: kCaption.copyWith(fontSize: 11.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildConnected(HealthMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 20, color: kSignal),
              const Gap(13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Linked to $_platformName', style: kSubtitle.copyWith(fontSize: 14.5)),
                    if (metrics.lastSyncedAt != null)
                      Text('Last synced ${metrics.lastSyncedAt}', style: kCaption.copyWith(fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(26),

        const Eyebrow('Current readings'),
        const Gap(12),

        _metricRow('Daily steps', metrics.stepsDaily?.toString(), Icons.directions_walk_rounded),
        _metricRow('Resting heart rate', metrics.restingHeartRate != null ? '${metrics.restingHeartRate} bpm' : null, Icons.favorite_rounded),
        _metricRow('Average sleep', metrics.sleepHoursAvg != null ? '${metrics.sleepHoursAvg} hrs' : null, Icons.bedtime_rounded),
        _metricRow('Weight', metrics.weightKg != null ? '${metrics.weightKg} kg' : null, Icons.monitor_weight_rounded),
        _metricRow('Height', metrics.heightCm != null ? '${metrics.heightCm} cm' : null, Icons.height_rounded),
        _metricRow('Blood pressure', metrics.bloodPressureSystolic != null ? '${metrics.bloodPressureSystolic}/${metrics.bloodPressureDiastolic}' : null, Icons.monitor_heart_rounded),
        _metricRow('Active calories', metrics.activeCaloriesDaily?.toString(), Icons.local_fire_department_rounded),

        const Gap(28),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: _syncing ? 'Syncing' : 'Sync now',
                variant: AppButtonVariant.tonal,
                loading: _syncing,
                height: 46,
                onTap: _sync,
              ),
            ),
            const Gap(10),
            AppButton(
              label: 'Unlink',
              variant: AppButtonVariant.ghost,
              expand: false,
              height: 46,
              onTap: _disconnect,
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricRow(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Panel(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: kOnSurfaceVariant),
            const Gap(13),
            Text(label, style: kBody.copyWith(fontSize: 13.5)),
            const Spacer(),
            Text(value ?? '—', style: kReadout.copyWith(fontSize: 13, color: value != null ? kOnSurface : kOnSurfaceFaint)),
          ],
        ),
      ),
    );
  }

  static const _dataTypes = [
    ('Steps', Icons.directions_walk_rounded),
    ('Heart rate', Icons.favorite_rounded),
    ('Sleep duration', Icons.bedtime_rounded),
    ('Weight', Icons.monitor_weight_rounded),
    ('Height', Icons.height_rounded),
    ('Blood pressure', Icons.monitor_heart_rounded),
    ('Active calories', Icons.local_fire_department_rounded),
  ];
}
