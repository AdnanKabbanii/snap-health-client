import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../core/providers/gamification_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/score_circle.dart';
import '../../widgets/ui.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _checkingIn = false;
  bool _checkedIn = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Still up';
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _checkin() async {
    if (_checkedIn || _checkingIn) return;
    setState(() => _checkingIn = true);
    try {
      final result = await apiService.checkin();
      ref.invalidate(weeklyInsightsProvider);
      ref.invalidate(gamificationProvider);
      if (mounted) {
        setState(() => _checkedIn = true);
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                result.leveledUp ? 'Level up — +10 XP banked' : 'Checked in — +10 XP',
                style: kSubtitle,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted && e.toString().contains('429')) {
        setState(() => _checkedIn = true);
      }
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final gamification = ref.watch(gamificationProvider);
    final insights = ref.watch(weeklyInsightsProvider);
    final challenges = ref.watch(challengesProvider);

    final name = profile?.displayName?.split(' ').first;

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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_dateLine().toUpperCase(), style: kLabel),
                            const Gap(8),
                            Text(
                              name != null ? '$_greeting,\n$name.' : '$_greeting.',
                              style: kHeadline.copyWith(fontSize: 28),
                            ),
                          ],
                        ),
                      ),
                      gamification.maybeWhen(
                        data: (g) => _StreakBadge(streak: g.currentStreak),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const Gap(24),

                Entrance(
                  index: 1,
                  child: insights.when(
                    loading: () => const Panel(
                      padding: EdgeInsets.symmetric(vertical: 56),
                      child: LoadingState(message: 'Reading your week'),
                    ),
                    error: (e, _) => Panel(
                      child: ErrorState(
                        message: 'Your weekly report is unreachable right now.',
                        onRetry: () => ref.invalidate(weeklyInsightsProvider),
                      ),
                    ),
                    data: (data) => _WeekPanel(
                      avgScore: data.stats.avgScore.toDouble(),
                      totalScans: data.stats.totalScans,
                      level: data.gamification?.level ?? 1,
                    ),
                  ),
                ),
                const Gap(12),

                Entrance(
                  index: 2,
                  child: Panel(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          _checkedIn ? Icons.task_alt_rounded : Icons.radar_rounded,
                          size: 20,
                          color: _checkedIn ? kSignal : kOnSurfaceVariant,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            _checkedIn ? 'Logged for today. Streak safe.' : 'Daily check-in keeps your streak alive.',
                            style: kBody.copyWith(fontSize: 13.5),
                          ),
                        ),
                        const Gap(12),
                        if (!_checkedIn)
                          AppButton(
                            label: _checkingIn ? '' : 'Check in',
                            loading: _checkingIn,
                            onTap: _checkin,
                            expand: false,
                            height: 38,
                          ),
                      ],
                    ),
                  ),
                ),
                const Gap(28),

                Entrance(
                  index: 3,
                  child: challenges.maybeWhen(
                    data: (list) {
                      if (list.isEmpty) return const SizedBox.shrink();
                      final preview = list.take(2).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow(
                            'This week\'s protocol',
                            trailing: Pressable(
                              onTap: () => context.push('/challenges'),
                              child: Text('ALL', style: kLabel.copyWith(color: kSignal)),
                            ),
                          ),
                          const Gap(12),
                          ...preview.map((c) {
                            final progress = c.progress?.progress ?? 0;
                            final done = c.progress?.completed ?? false;
                            final pct = (progress / c.challenge.targetValue).clamp(0.0, 1.0);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Panel(
                                padding: const EdgeInsets.all(14),
                                onTap: () => context.push('/challenges'),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(c.challenge.title, style: kSubtitle.copyWith(fontSize: 14)),
                                          const Gap(8),
                                          ProgressTrack(value: pct, color: done ? kSignal : kAmber),
                                        ],
                                      ),
                                    ),
                                    const Gap(14),
                                    Text(
                                      done ? 'DONE' : '$progress/${c.challenge.targetValue}',
                                      style: kReadout.copyWith(color: done ? kSignal : kOnSurfaceVariant, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const Gap(20),
                        ],
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                ),

                Entrance(
                  index: 4,
                  child: insights.maybeWhen(
                    data: (data) {
                      if (data.recentScans.isEmpty) {
                        return Panel(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: EmptyState(
                            icon: Icons.center_focus_strong_rounded,
                            title: 'Nothing on record yet',
                            caption: 'Point the lens at anything you eat, drink, or take. We\'ll run the analysis.',
                            actionLabel: 'Run first scan',
                            onAction: () => context.push('/scan'),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow(
                            'Latest specimens',
                            trailing: Pressable(
                              onTap: () => context.go('/history'),
                              child: Text('LOG', style: kLabel.copyWith(color: kSignal)),
                            ),
                          ),
                          const Gap(12),
                          ...data.recentScans.take(3).map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Panel(
                                  padding: const EdgeInsets.all(13),
                                  onTap: () => context.push('/result/${s.id}'),
                                  child: Row(
                                    children: [
                                      if (s.healthScore != null)
                                        ScoreRing(score: s.healthScore!.toDouble(), size: 42, showLabel: false, animate: false)
                                      else
                                        const SizedBox(width: 42, height: 42),
                                      const Gap(14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(s.itemName ?? 'Unidentified', style: kSubtitle.copyWith(fontSize: 14)),
                                            const Gap(2),
                                            Text(timeAgo(s.createdAt), style: kCaption.copyWith(fontSize: 11.5)),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right_rounded, size: 18, color: kOnSurfaceFaint),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _dateLine() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return '${days[now.weekday - 1]} · ${months[now.month - 1]} ${now.day}';
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    final lit = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: lit ? kAmber.withValues(alpha: 0.12) : kSurfaceHigh,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: lit ? kAmber.withValues(alpha: 0.35) : kHairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 15, color: lit ? kAmber : kOnSurfaceFaint),
          const Gap(5),
          Text('$streak', style: kMono(13, weight: FontWeight.w600, color: lit ? kAmber : kOnSurfaceFaint)),
        ],
      ),
    );
  }
}

class _WeekPanel extends StatelessWidget {
  final double avgScore;
  final int totalScans;
  final int level;

  const _WeekPanel({required this.avgScore, required this.totalScans, required this.level});

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (avgScore > 0)
            ScoreRing(score: avgScore, size: 108)
          else
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kHairline, width: 1.5),
              ),
              child: Center(child: Text('—', style: kMono(30, color: kOnSurfaceFaint))),
            ),
          const Gap(22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('7-DAY AVERAGE', style: kLabel.copyWith(fontSize: 9.5)),
                const Gap(4),
                Text(
                  avgScore > 0 ? scoreToVerdict(avgScore) : 'No data yet',
                  style: kTitle.copyWith(fontSize: 19),
                ),
                const Gap(14),
                Row(
                  children: [
                    _MiniStat(label: 'Scans', value: '$totalScans'),
                    const Gap(20),
                    _MiniStat(label: 'Level', value: '$level'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: kMono(19, weight: FontWeight.w600)),
        const Gap(2),
        Text(label.toUpperCase(), style: kLabel.copyWith(fontSize: 8.5)),
      ],
    );
  }
}
