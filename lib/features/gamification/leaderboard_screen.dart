import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';
import '../../widgets/ui.dart';

final leaderboardWeeklyProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return apiService.getLeaderboardWeekly();
});

final leaderboardAllTimeProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return apiService.getLeaderboardAllTime();
});

final leaderboardStreakProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return apiService.getLeaderboardStreak();
});

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Container(
        color: kBackground,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    IconSquare(
                      icon: Icons.arrow_back_rounded,
                      size: 38,
                      onTap: () => context.pop(),
                    ),
                    const Gap(16),
                    Text('Rankings', style: kHeadline.copyWith(fontSize: 24)),
                  ],
                ),
              ),
              const Gap(18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SegmentedTabs(
                  labels: const ['This week', 'All time', 'Streaks'],
                  index: _tabIndex,
                  onChanged: (i) => setState(() => _tabIndex = i),
                ),
              ),
              const Gap(16),
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: const [
                    _LeaderboardList(kind: _BoardKind.weekly),
                    _LeaderboardList(kind: _BoardKind.allTime),
                    _LeaderboardList(kind: _BoardKind.streak),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _BoardKind { weekly, allTime, streak }

class _LeaderboardList extends ConsumerWidget {
  final _BoardKind kind;

  const _LeaderboardList({required this.kind});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = switch (kind) {
      _BoardKind.weekly => leaderboardWeeklyProvider,
      _BoardKind.allTime => leaderboardAllTimeProvider,
      _BoardKind.streak => leaderboardStreakProvider,
    };
    final unitLabel = kind == _BoardKind.streak ? 'days' : 'xp';
    final async = ref.watch(provider);

    return async.when(
      loading: () => const LoadingState(message: 'Tallying'),
      error: (e, _) => ErrorState(
        message: 'Rankings are unreachable right now.',
        onRetry: () => ref.invalidate(provider),
      ),
      data: (entries) => entries.isEmpty
          ? const EmptyState(
              icon: Icons.leaderboard_rounded,
              title: 'No entries yet',
              caption: 'Be the first on the board this week.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final entry = entries[i];
                final value = kind == _BoardKind.streak ? entry.currentStreak : entry.xp;
                final isTop3 = entry.rank <= 3;

                return Entrance(
                  index: i.clamp(0, 10),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: isTop3 ? kSurfaceHigh : kSurfaceLow,
                        borderRadius: BorderRadius.circular(kRadiusMd),
                        border: Border.all(
                          color: isTop3 ? _rankColor(entry.rank).withValues(alpha: 0.4) : kHairline,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 34,
                            child: Text(
                              '${entry.rank}',
                              style: kMono(
                                isTop3 ? 17 : 14,
                                weight: isTop3 ? FontWeight.w700 : FontWeight.w400,
                                color: isTop3 ? _rankColor(entry.rank) : kOnSurfaceFaint,
                              ),
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: kSurfaceHighest,
                              shape: BoxShape.circle,
                              border: Border.all(color: kHairline),
                            ),
                            child: Center(
                              child: Text(
                                entry.displayName.isNotEmpty
                                    ? entry.displayName.substring(0, 1).toUpperCase()
                                    : '?',
                                style: kMono(13, weight: FontWeight.w600, color: kOnSurfaceVariant),
                              ),
                            ),
                          ),
                          const Gap(13),
                          Expanded(child: Text(entry.displayName, style: kSubtitle.copyWith(fontSize: 14))),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('$value', style: kMono(16, weight: FontWeight.w600)),
                              Text(unitLabel.toUpperCase(), style: kLabel.copyWith(fontSize: 8)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFE8C547);
    if (rank == 2) return const Color(0xFFB8C0CC);
    return const Color(0xFFCB8D5E);
  }
}
