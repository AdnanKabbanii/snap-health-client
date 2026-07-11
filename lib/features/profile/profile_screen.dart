import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/gamification_provider.dart';
import '../../core/providers/health_provider.dart';
import '../../core/models/models.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/ui.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final gamificationAsync = ref.watch(gamificationProvider);

    return Scaffold(
      child: Container(
        color: kBackground,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Entrance(
                  index: 0,
                  child: ScreenHeader(
                    title: 'You',
                    caption: 'The profile every scan is scored against.',
                    trailing: IconSquare(
                      icon: Icons.tune_rounded,
                      onTap: () => context.push('/settings'),
                    ),
                  ),
                ),
                const Gap(22),

                profileAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: LoadingState(message: 'Opening your file'),
                  ),
                  error: (e, _) => ErrorState(
                    message: 'Your profile is unreachable right now.',
                    onRetry: () => ref.invalidate(profileProvider),
                  ),
                  data: (profile) {
                    if (profile == null) {
                      return EmptyState(
                        icon: Icons.person_search_rounded,
                        title: 'No profile on file',
                        actionLabel: 'Calibrate now',
                        onAction: () => context.push('/onboarding'),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Entrance(
                          index: 1,
                          child: Panel(
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: kSignal.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: kSignal.withValues(alpha: 0.3)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _initials(profile),
                                      style: kMono(16, weight: FontWeight.w600, color: kSignal),
                                    ),
                                  ),
                                ),
                                const Gap(14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(profile.displayName ?? 'Unnamed subject', style: kSubtitle),
                                      const Gap(2),
                                      Text(profile.email, style: kCaption),
                                    ],
                                  ),
                                ),
                                Pressable(
                                  onTap: () => context.push('/onboarding'),
                                  child: Text('EDIT', style: kLabel.copyWith(color: kSignal)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(24),

                        Entrance(
                          index: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Eyebrow('Calibration data'),
                              const Gap(12),
                              Panel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _Datum(label: 'Age', value: profile.ageRange ?? '—'),
                                        const Gap(28),
                                        _Datum(label: 'Sex', value: profile.biologicalSex ?? '—'),
                                        const Gap(28),
                                        _Datum(label: 'Diet', value: profile.dietaryPreference ?? '—'),
                                      ],
                                    ),
                                    if (profile.conditions.isNotEmpty) ...[
                                      const Gap(16),
                                      _ChipGroup(label: 'Conditions', items: profile.conditions),
                                    ],
                                    if (profile.goals.isNotEmpty) ...[
                                      const Gap(14),
                                      _ChipGroup(label: 'Goals', items: profile.goals, accent: kSignal),
                                    ],
                                    if (profile.allergies.isNotEmpty) ...[
                                      const Gap(14),
                                      _ChipGroup(label: 'Allergies', items: profile.allergies, accent: kDanger),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const Gap(10),

                Entrance(
                  index: 3,
                  child: ref.watch(healthMetricsProvider).when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                        data: (metrics) => Panel(
                          onTap: () => context.push('/profile/health'),
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Icon(
                                metrics != null ? Icons.monitor_heart_rounded : Icons.add_link_rounded,
                                size: 20,
                                color: metrics != null ? kSignal : kOnSurfaceVariant,
                              ),
                              const Gap(13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      metrics != null ? 'Biometrics connected' : 'Connect biometrics',
                                      style: kSubtitle.copyWith(fontSize: 14),
                                    ),
                                    Text(
                                      metrics != null
                                          ? '${metrics.source ?? 'Live'} — tap to review'
                                          : 'Apple Health or Health Connect',
                                      style: kCaption.copyWith(fontSize: 11.5),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 18, color: kOnSurfaceFaint),
                            ],
                          ),
                        ),
                      ),
                ),
                const Gap(24),

                gamificationAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (gam) => Entrance(index: 4, child: _StandingSection(gam: gam)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initials(UserProfile profile) {
    final name = profile.displayName;
    if (name == null || name.trim().isEmpty) return profile.email.substring(0, 1).toUpperCase();
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _Datum extends StatelessWidget {
  final String label;
  final String value;
  const _Datum({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: kLabel.copyWith(fontSize: 8.5)),
        const Gap(4),
        Text(prettyKey(value), style: kReadout.copyWith(fontSize: 13.5)),
      ],
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color? accent;

  const _ChipGroup({required this.label, required this.items, this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: kLabel.copyWith(fontSize: 8.5)),
        const Gap(8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) {
            final a = accent;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: a != null ? a.withValues(alpha: 0.1) : kSurfaceHigh,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: a?.withValues(alpha: 0.3) ?? kHairline),
              ),
              child: Text(
                prettyKey(item),
                style: kSans(12, color: a ?? kOnSurfaceVariant),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StandingSection extends StatelessWidget {
  final GamificationStatus gam;
  const _StandingSection({required this.gam});

  @override
  Widget build(BuildContext context) {
    final xpProgress = gam.xpProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Standing'),
        const Gap(12),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Level ${gam.level}', style: kSerif(23)),
                        const Gap(2),
                        Text(gam.levelTitle ?? 'Health Rookie', style: kCaption),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 18,
                        color: gam.currentStreak > 0 ? kAmber : kOnSurfaceFaint,
                      ),
                      const Gap(5),
                      Text('${gam.currentStreak}', style: kMono(15, weight: FontWeight.w600,
                          color: gam.currentStreak > 0 ? kAmber : kOnSurfaceFaint)),
                      if (gam.streakShields > 0) ...[
                        const Gap(10),
                        Icon(Icons.shield_rounded, size: 15, color: kSignal),
                        const Gap(3),
                        Text('${gam.streakShields}', style: kMono(13, color: kSignal)),
                      ],
                    ],
                  ),
                ],
              ),
              if (xpProgress != null) ...[
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${xpProgress.current} / ${xpProgress.needed} XP',
                        style: kMono(11, color: kOnSurfaceVariant)),
                    if (gam.level < 100)
                      Text('NEXT: LVL ${gam.level + 1}', style: kLabel.copyWith(fontSize: 9)),
                  ],
                ),
                const Gap(8),
                ProgressTrack(
                  value: xpProgress.needed > 0
                      ? (xpProgress.current / xpProgress.needed).clamp(0.0, 1.0)
                      : 1.0,
                ),
              ],
            ],
          ),
        ),
        const Gap(10),

        Row(
          children: [
            Expanded(
              child: Panel(
                onTap: () => context.push('/challenges'),
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  children: [
                    Icon(Icons.flag_rounded, size: 22, color: kAmber),
                    const Gap(8),
                    Text('PROTOCOL', style: kLabel.copyWith(fontSize: 9.5)),
                  ],
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Panel(
                onTap: () => context.push('/leaderboard'),
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  children: [
                    Icon(Icons.leaderboard_rounded, size: 22, color: kSignal),
                    const Gap(8),
                    Text('RANKINGS', style: kLabel.copyWith(fontSize: 9.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Gap(24),

        Eyebrow(
          'Badges',
          trailing: gam.totalBadgeCount > 0
              ? Text('${gam.badges.length} / ${gam.totalBadgeCount}', style: kMono(11, color: kOnSurfaceVariant))
              : null,
        ),
        const Gap(12),
        if (gam.badges.isEmpty)
          Text('None earned yet. Keep scanning.', style: kCaption)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: gam.badges
                .map((b) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: kAmber.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: kAmber.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.military_tech_rounded, size: 14, color: kAmber),
                          const Gap(6),
                          Text(b.name, style: kSans(12.5)),
                        ],
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }
}
