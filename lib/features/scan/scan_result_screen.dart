import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/scan_provider.dart';
import '../../core/models/models.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/score_circle.dart';
import '../../widgets/effect_card.dart';
import '../../widgets/nutrition_card.dart';
import '../../widgets/sponsor_card.dart';
import '../../widgets/ui.dart';

const _healthKeywords = [
  'spike', 'insulin', 'crash', 'inflammation', 'sodium', 'sugar',
  'cholesterol', 'blood pressure', 'cortisol', 'metabolic', 'glucose',
  'glycemic', 'caffeine', 'saturated', 'processed', 'antioxidant',
  'fiber', 'protein', 'hydration', 'calories',
];

class ScanResultScreen extends ConsumerWidget {
  final String scanId;
  const ScanResultScreen({super.key, required this.scanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (scanId == 'active') return _buildFromActiveScan(context, ref);
    return _buildFromHistory(context, ref);
  }

  Widget _buildFromHistory(BuildContext context, WidgetRef ref) {
    final asyncScan = ref.watch(scanDetailProvider(scanId));

    return asyncScan.when(
      loading: () => Scaffold(
        child: Container(
          color: kBackground,
          child: const LoadingState(message: 'Pulling the file'),
        ),
      ),
      error: (e, _) => Scaffold(
        child: Container(
          color: kBackground,
          child: const EmptyState(
            icon: Icons.folder_off_outlined,
            title: 'Report not found',
            caption: 'This scan may have been deleted.',
          ),
        ),
      ),
      data: (detail) {
        final result = detail.result;
        return _buildResultView(
          context: context,
          itemName: detail.itemName,
          category: detail.category,
          confidence: result?.confidence.toInt(),
          score: detail.healthScore?.toDouble(),
          summary: result?.summary,
          effects: result?.effects ?? [],
          risks: result?.risks ?? [],
          benefits: result?.benefits ?? [],
          nutrition: result?.nutrition,
          tips: result?.actionableTips ?? [],
          goalAdvice: result?.goalAdvice ?? [],
          sponsor: null,
        );
      },
    );
  }

  Widget _buildFromActiveScan(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(activeScanProvider);
    return _buildResultView(
      context: context,
      itemName: scan.itemName,
      category: scan.category,
      confidence: scan.confidence,
      score: scan.score,
      summary: scan.summary,
      effects: scan.effects,
      risks: scan.risks,
      benefits: scan.benefits,
      nutrition: scan.nutrition,
      tips: scan.tips,
      goalAdvice: scan.goalAdvice,
      sponsor: scan.sponsor,
    );
  }

  Widget _buildRichSummary(String text) {
    final words = text.split(' ');
    final spans = <TextSpan>[];

    int i = 0;
    while (i < words.length) {
      bool matched = false;
      for (final keyword in _healthKeywords) {
        final kwWords = keyword.split(' ');
        if (i + kwWords.length <= words.length) {
          final slice = words.sublist(i, i + kwWords.length).join(' ').toLowerCase();
          final cleanSlice = slice.replaceAll(RegExp(r'[,.]'), '');
          if (cleanSlice == keyword) {
            final original = words.sublist(i, i + kwWords.length).join(' ');
            if (spans.isNotEmpty) spans.add(const TextSpan(text: ' '));
            spans.add(TextSpan(
              text: original,
              style: kSans(14.5, weight: FontWeight.w700, height: 1.65, color: kOnSurface),
            ));
            i += kwWords.length;
            matched = true;
            break;
          }
        }
      }
      if (!matched) {
        if (spans.isNotEmpty) spans.add(const TextSpan(text: ' '));
        spans.add(TextSpan(
          text: words[i],
          style: kSans(14.5, height: 1.65, color: kOnSurface.withValues(alpha: 0.82)),
        ));
        i++;
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  String _buildShareText({
    String? itemName,
    double? score,
    String? summary,
    required List<Benefit> benefits,
    required List<Risk> risks,
  }) {
    final sb = StringBuffer();
    sb.writeln('SnapHealth Lab Report');
    if (itemName != null) sb.writeln('Item: $itemName');
    if (score != null) sb.writeln('Score: ${score.toStringAsFixed(1)} / 10 — ${scoreToVerdict(score)}');
    if (summary != null) sb.writeln('\n$summary');
    if (benefits.isNotEmpty) {
      sb.writeln('\nWorking in your favor:');
      for (final b in benefits.take(2)) {
        sb.writeln('+ ${b.title}');
      }
    }
    if (risks.isNotEmpty) {
      sb.writeln('\nWatch out for:');
      for (final r in risks.take(2)) {
        sb.writeln('- ${r.title}');
      }
    }
    sb.writeln('\nScanned with SnapHealth');
    return sb.toString();
  }

  Widget _section({required int index, required String label, Color? labelColor, required List<Widget> children}) {
    return Entrance(
      index: index,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(label, color: labelColor),
            const Gap(12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildResultView({
    required BuildContext context,
    String? itemName,
    String? category,
    int? confidence,
    double? score,
    String? summary,
    required List<Effect> effects,
    required List<Risk> risks,
    required List<Benefit> benefits,
    Nutrition? nutrition,
    required List<String> tips,
    required List<GoalAdvice> goalAdvice,
    Sponsor? sponsor,
  }) {
    var sectionIndex = 0;

    return Scaffold(
      child: Container(
        color: kBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      IconSquare(
                        icon: Icons.arrow_back_rounded,
                        size: 40,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      if (confidence != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                          decoration: BoxDecoration(
                            color: kSurfaceHigh,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: kHairline),
                          ),
                          child: Text('ID $confidence%', style: kLabel.copyWith(fontSize: 9.5)),
                        ),
                        const Gap(8),
                      ],
                      IconSquare(
                        icon: Icons.ios_share_rounded,
                        size: 40,
                        onTap: () {
                          final text = _buildShareText(
                            itemName: itemName, score: score, summary: summary,
                            benefits: benefits, risks: risks,
                          );
                          Share.share(text, subject: itemName ?? 'SnapHealth Lab Report');
                        },
                      ),
                    ],
                  ),
                ),

                Entrance(
                  index: sectionIndex++,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(child: Eyebrow('Lab report${category != null ? ' — $category' : ''}')),
                        const Gap(12),
                        if (itemName != null)
                          Text(itemName, style: kSerif(27), textAlign: TextAlign.center),
                        const Gap(24),
                        if (score != null) ...[
                          ScoreRing(score: score, size: 158),
                          const Gap(14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: scoreToColor(score).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: scoreToColor(score).withValues(alpha: 0.35)),
                            ),
                            child: Text(
                              scoreToVerdict(score).toUpperCase(),
                              style: kMono(10.5, weight: FontWeight.w600, letterSpacing: 1.6,
                                  color: scoreToColor(score)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Gap(30),

                if (summary != null)
                  _section(
                    index: sectionIndex++,
                    label: 'The verdict',
                    children: [
                      Panel(child: _buildRichSummary(summary)),
                    ],
                  ),

                if (effects.isNotEmpty)
                  _section(
                    index: sectionIndex++,
                    label: 'What it does to you',
                    children: effects
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: EffectCard(effect: e),
                            ))
                        .toList(),
                  ),

                if (nutrition != null)
                  _section(
                    index: sectionIndex++,
                    label: 'By the numbers',
                    children: [NutritionCard(nutrition: nutrition)],
                  ),

                if (risks.isNotEmpty)
                  _section(
                    index: sectionIndex++,
                    label: 'Watch out for',
                    labelColor: kDanger,
                    children: risks
                        .map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _FlagCard(title: r.title, body: r.description, color: kDanger),
                            ))
                        .toList(),
                  ),

                if (benefits.isNotEmpty)
                  _section(
                    index: sectionIndex++,
                    label: 'Working in your favor',
                    labelColor: kSignal,
                    children: benefits
                        .map((b) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _FlagCard(title: b.title, body: b.description, color: kSignal),
                            ))
                        .toList(),
                  ),

                if (sponsor != null)
                  _section(
                    index: sectionIndex++,
                    label: 'Smarter swap',
                    labelColor: kSignal,
                    children: [SponsorCard(sponsor: sponsor)],
                  ),

                if (tips.isNotEmpty)
                  _section(
                    index: sectionIndex++,
                    label: 'Make it work',
                    children: [
                      Panel(
                        child: Column(
                          children: tips
                              .map((t) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Icon(Icons.east_rounded, size: 14, color: kSignal),
                                        ),
                                        const Gap(10),
                                        Expanded(child: Text(t, style: kBody)),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),

                if (goalAdvice.isNotEmpty)
                  _section(
                    index: sectionIndex++,
                    label: 'Against your goals',
                    children: goalAdvice
                        .map((g) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Panel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.goal.replaceAll('_', ' ').toUpperCase(),
                                      style: kLabel.copyWith(color: kSignal, fontSize: 9.5),
                                    ),
                                    const Gap(6),
                                    Text(g.advice, style: kBody.copyWith(color: kOnSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlagCard extends StatelessWidget {
  final String title;
  final String body;
  final Color color;

  const _FlagCard({required this.title, required this.body, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kSurfaceLow,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kHairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 34,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: kSubtitle.copyWith(fontSize: 14)),
                const Gap(4),
                Text(body, style: kBody.copyWith(fontSize: 13, color: kOnSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
