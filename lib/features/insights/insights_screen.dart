import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/gamification_provider.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/score_circle.dart';
import '../../widgets/ui.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(weeklyInsightsProvider);

    return Scaffold(
      child: Container(
        color: kBackground,
        child: SafeArea(
          bottom: false,
          child: insights.when(
            loading: () => const LoadingState(message: 'Compiling your trends'),
            error: (e, _) => ErrorState(
              message: 'Trends are unreachable right now.',
              onRetry: () => ref.invalidate(weeklyInsightsProvider),
            ),
            data: (data) {
              final stats = data.stats;
              final gamification = data.gamification;
              final categories = data.categories;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Entrance(
                      index: 0,
                      child: ScreenHeader(
                        title: 'Trends',
                        caption: 'Your last seven days, quantified.',
                      ),
                    ),
                    const Gap(24),

                    Entrance(
                      index: 1,
                      child: Panel(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text('7-DAY AVERAGE', style: kLabel),
                            const Gap(18),
                            if (stats.avgScore > 0)
                              ScoreRing(score: stats.avgScore.toDouble(), size: 132)
                            else
                              Text('—', style: kMono(44, color: kOnSurfaceFaint)),
                            if (stats.avgScore > 0) ...[
                              const Gap(14),
                              Text(
                                scoreToVerdict(stats.avgScore.toDouble()),
                                style: kTitle.copyWith(fontSize: 17),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Gap(10),

                    Entrance(
                      index: 2,
                      child: Row(
                        children: [
                          Expanded(child: StatCard(label: 'Scans', value: '${stats.totalScans}')),
                          const Gap(10),
                          Expanded(
                            child: StatCard(
                              label: 'Best',
                              value: stats.maxScore > 0 ? '${stats.maxScore}' : '—',
                              accent: kSignal,
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: StatCard(
                              label: 'Worst',
                              value: stats.totalScans > 0 ? '${stats.minScore}' : '—',
                              accent: kDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),

                    if (gamification != null)
                      Entrance(
                        index: 3,
                        child: Panel(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('LEVEL ${gamification.level}', style: kLabel.copyWith(color: kSignal)),
                                    const Gap(4),
                                    Text('${gamification.xpTotal} XP total', style: kSubtitle),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 18,
                                    color: gamification.currentStreak > 0 ? kAmber : kOnSurfaceFaint,
                                  ),
                                  const Gap(6),
                                  Text(
                                    '${gamification.currentStreak}-day streak',
                                    style: kReadout.copyWith(fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const Gap(28),

                    if (categories.isNotEmpty)
                      Entrance(
                        index: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Eyebrow('By category'),
                            const Gap(12),
                            Panel(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: categories.map((cat) {
                                  final avg = cat.avgScore.toDouble();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                prettyKey(cat.category ?? 'other'),
                                                style: kSubtitle.copyWith(fontSize: 13.5),
                                              ),
                                            ),
                                            Text('${cat.count}×', style: kCaption.copyWith(fontSize: 11.5)),
                                            const Gap(12),
                                            Text(
                                              avg > 0 ? avg.toStringAsFixed(1) : '—',
                                              style: kMono(13, weight: FontWeight.w600, color: scoreToColor(avg)),
                                            ),
                                          ],
                                        ),
                                        const Gap(7),
                                        ProgressTrack(value: avg / 10, color: scoreToColor(avg), height: 4),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const Gap(28),
                          ],
                        ),
                      ),

                    if (data.recentScans.isNotEmpty)
                      Entrance(
                        index: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Eyebrow('Recent entries'),
                            const Gap(12),
                            ...data.recentScans.map((s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Panel(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        if (s.healthScore != null)
                                          ScoreRing(
                                            score: s.healthScore!.toDouble(),
                                            size: 36,
                                            showLabel: false,
                                            animate: false,
                                          ),
                                        const Gap(12),
                                        Expanded(
                                          child: Text(s.itemName ?? '', style: kBody.copyWith(fontSize: 14)),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
