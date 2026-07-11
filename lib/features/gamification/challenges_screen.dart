import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/gamification_provider.dart';
import '../../core/models/models.dart';
import '../../widgets/ui.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);

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
                      onTap: () => context.pop(),
                    ),
                    const Gap(16),
                    Expanded(child: Text('The Protocol', style: kHeadline.copyWith(fontSize: 24))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: kSurfaceHigh,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: kHairline),
                      ),
                      child: Text(_daysLeftText(), style: kLabel.copyWith(fontSize: 9)),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  'A fresh set drops every Monday. Clear them for bonus XP.',
                  style: kCaption,
                ),
                const Gap(24),
                challengesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: LoadingState(message: 'Loading this week'),
                  ),
                  error: (e, _) => ErrorState(
                    message: 'The protocol is unreachable right now.',
                    onRetry: () => ref.invalidate(challengesProvider),
                  ),
                  data: (challenges) => challenges.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: EmptyState(
                            icon: Icons.flag_outlined,
                            title: 'Nothing scheduled',
                            caption: 'No challenges this week. Check back Monday.',
                          ),
                        )
                      : Column(
                          children: challenges.indexed
                              .map((entry) => Entrance(
                                    index: entry.$1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: _ChallengeCard(item: entry.$2),
                                    ),
                                  ))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _daysLeftText() {
    final now = DateTime.now();
    final daysUntilSunday = 7 - now.weekday;
    return '${daysUntilSunday}D LEFT';
  }
}

class _ChallengeCard extends StatelessWidget {
  final ChallengeWithProgress item;

  const _ChallengeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final challenge = item.challenge;
    final progress = item.progress;
    final completed = progress?.completed ?? false;
    final current = progress?.progress ?? 0;
    final target = challenge.targetValue;
    final pct = (current / target).clamp(0.0, 1.0);

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed ? Icons.task_alt_rounded : Icons.flag_outlined,
                color: completed ? kSignal : kOnSurfaceVariant,
                size: 19,
              ),
              const Gap(11),
              Expanded(child: Text(challenge.title, style: kSubtitle.copyWith(fontSize: 14.5))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: kSignal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('+${challenge.xpReward} XP',
                    style: kMono(9.5, weight: FontWeight.w600, letterSpacing: 0.8, color: kSignal)),
              ),
            ],
          ),
          const Gap(8),
          Text(challenge.description, style: kBody.copyWith(fontSize: 13, color: kOnSurfaceVariant)),
          const Gap(14),
          Row(
            children: [
              Expanded(child: ProgressTrack(value: pct, color: completed ? kSignal : kAmber)),
              const Gap(12),
              Text(
                completed ? 'CLEARED' : '$current / $target',
                style: kMono(11, weight: FontWeight.w600, color: completed ? kSignal : kOnSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
