import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/scan_provider.dart';
import '../../core/models/models.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/score_circle.dart';
import '../../widgets/ui.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _items = <ScanHistoryItem>[];
  int _page = 1;
  int _totalPages = 1;
  bool _loadingMore = false;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(scanHistoryProvider(_page));

    return Scaffold(
      child: Container(
        color: kBackground,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(
                  title: 'The Log',
                  caption: 'Every specimen you\'ve put on record.',
                ),
                const Gap(20),
                Expanded(
                  child: history.when(
                    loading: () => _items.isEmpty
                        ? const LoadingState(message: 'Opening the archive')
                        : _buildList(),
                    error: (e, _) => ErrorState(
                      message: 'The archive is unreachable right now.',
                      onRetry: () => ref.invalidate(scanHistoryProvider),
                    ),
                    data: (response) {
                      if (_page == 1) _items.clear();
                      final newIds = _items.map((i) => i.id).toSet();
                      for (final item in response.results) {
                        if (!newIds.contains(item.id)) _items.add(item);
                      }
                      _totalPages = response.pagination.totalPages;
                      _loadingMore = false;
                      return _buildList();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'Nothing on record',
        caption: 'Your scans land here, newest first.',
        actionLabel: 'Run a scan',
        onAction: () => context.push('/scan'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 110),
      itemCount: _items.length + (_page < _totalPages ? 1 : 0),
      separatorBuilder: (_, _) => const Gap(8),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _loadingMore
                  ? const LoadingState()
                  : AppButton(
                      label: 'Load older entries',
                      variant: AppButtonVariant.tonal,
                      expand: false,
                      height: 42,
                      onTap: () {
                        setState(() {
                          _loadingMore = true;
                          _page++;
                        });
                      },
                    ),
            ),
          );
        }

        final scan = _items[index];
        final score = scan.healthScore?.toDouble();
        return Entrance(
          index: index.clamp(0, 8),
          child: Panel(
            padding: const EdgeInsets.all(13),
            onTap: () => context.push('/result/${scan.id}'),
            child: Row(
              children: [
                if (score != null)
                  ScoreRing(score: score, size: 44, showLabel: false, animate: false)
                else
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kHairline),
                    ),
                    child: Center(child: Text('—', style: kMono(14, color: kOnSurfaceFaint))),
                  ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scan.itemName ?? 'Unidentified', style: kSubtitle.copyWith(fontSize: 14)),
                      const Gap(3),
                      Text(timeAgo(scan.createdAt), style: kCaption.copyWith(fontSize: 11.5)),
                    ],
                  ),
                ),
                if (scan.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: kSurfaceHigh,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: kHairline),
                    ),
                    child: Text(
                      scan.category!.toUpperCase(),
                      style: kMono(8.5, weight: FontWeight.w600, letterSpacing: 1.2, color: kOnSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
