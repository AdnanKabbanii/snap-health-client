import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/scan_provider.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/score_circle.dart';
import '../../widgets/ui.dart';

const _stages = [
  'Imaging specimen',
  'Identifying compounds',
  'Cross-referencing database',
  'Personalizing to your profile',
];

class ScanningScreen extends ConsumerStatefulWidget {
  final List<int> imageBytes;
  final String? barcode;
  const ScanningScreen({super.key, required this.imageBytes, this.barcode});

  @override
  ConsumerState<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends ConsumerState<ScanningScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  int _stage = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeScanProvider.notifier).startScan(
            Uint8List.fromList(widget.imageBytes),
            barcode: widget.barcode,
          );
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _retryScan() {
    setState(() => _stage = 0);
    ref.read(activeScanProvider.notifier).startScan(
          Uint8List.fromList(widget.imageBytes),
          barcode: widget.barcode,
        );
  }

  void _updateStage(ScanState scan) {
    int newStage = 0;
    if (scan.itemName != null) newStage = 1;
    if (scan.score != null) newStage = 2;
    if (scan.isDone || scan.effects.isNotEmpty) newStage = 3;
    if (newStage > _stage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _stage = newStage);
      });
    }
  }

  void _close() {
    ref.read(activeScanProvider.notifier).reset();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(activeScanProvider);
    _updateStage(scan);
    final imageBytes = Uint8List.fromList(widget.imageBytes);

    return Scaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => Container(color: kBackground),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kBackground.withValues(alpha: 0.82),
                    kBackground.withValues(alpha: 0.95),
                    kBackground,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Eyebrow(scan.isDone ? 'Analysis complete' : 'Analysis running',
                          color: scan.isDone ? kSignal : null),
                      const Spacer(),
                      IconSquare(icon: Icons.close_rounded, size: 38, onTap: _close),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (scan.score != null)
                          ScoreRing(score: scan.score!, size: 170)
                        else
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (context, child) {
                              final scale = 1.0 + _pulse.value * 0.05;
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: kSignal.withValues(alpha: 0.25 + _pulse.value * 0.6),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 104,
                                        height: 104,
                                        child: Image.memory(imageBytes, fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        const Gap(28),

                        if (scan.itemName != null) ...[
                          Text(
                            scan.itemName!,
                            style: kSerif(25),
                            textAlign: TextAlign.center,
                          ),
                          const Gap(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (scan.category != null) ...[
                                _Pill(text: scan.category!.toUpperCase()),
                                const Gap(8),
                              ],
                              _Pill(text: '+15 XP', color: kSignal),
                            ],
                          ),
                        ],

                        if (scan.summary != null && scan.isDone) ...[
                          const Gap(22),
                          Panel(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              scan.summary!,
                              style: kBody.copyWith(fontSize: 13.5),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],

                        if (!scan.isDone && scan.error == null) ...[
                          const Gap(34),
                          _StageChecklist(stage: _stage, pulse: _pulse),
                        ],

                        if (scan.error != null) ...[
                          const Gap(24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: kDanger.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(kRadiusMd),
                              border: Border.all(color: kDanger.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              scan.error!,
                              style: kBody.copyWith(color: kDanger, fontSize: 13.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Gap(20),
                          AppButton(label: 'Run it again', onTap: _retryScan, expand: false, height: 46),
                          const Gap(12),
                          Pressable(
                            onTap: _close,
                            child: Text('CANCEL', style: kLabel.copyWith(color: kOnSurfaceFaint)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (scan.isDone)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: Column(
                      children: [
                        AppButton(
                          label: scan.score != null
                              ? 'Open full report — ${scoreToLabel(scan.score!)}'
                              : 'Open full report',
                          icon: Icons.description_outlined,
                          onTap: () => context.push('/result/active'),
                        ),
                        const Gap(14),
                        Pressable(
                          onTap: _close,
                          child: Text('SCAN ANOTHER', style: kLabel.copyWith(color: kOnSurfaceVariant)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color? color;
  const _Pill({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: c != null ? c.withValues(alpha: 0.13) : kSurfaceHigh.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: c?.withValues(alpha: 0.35) ?? kHairline),
      ),
      child: Text(
        text,
        style: kMono(9.5, weight: FontWeight.w600, letterSpacing: 1.4,
            color: c ?? kOnSurfaceVariant),
      ),
    );
  }
}

class _StageChecklist extends StatelessWidget {
  final int stage;
  final AnimationController pulse;
  const _StageChecklist({required this.stage, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_stages.length, (i) {
        final done = i < stage;
        final current = i == stage;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: done
                    ? Icon(Icons.check_circle_rounded, size: 18, color: kSignal)
                    : current
                        ? AnimatedBuilder(
                            animation: pulse,
                            builder: (_, _) => Icon(
                              Icons.circle,
                              size: 10 + pulse.value * 3,
                              color: kSignal.withValues(alpha: 0.5 + pulse.value * 0.5),
                            ),
                          )
                        : Icon(Icons.circle_outlined, size: 13, color: kOnSurfaceFaint),
              ),
              const Gap(12),
              Text(
                _stages[i],
                style: kMono(
                  12,
                  weight: current ? FontWeight.w600 : FontWeight.w400,
                  color: done
                      ? kOnSurfaceVariant
                      : current
                          ? kOnSurface
                          : kOnSurfaceFaint,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
