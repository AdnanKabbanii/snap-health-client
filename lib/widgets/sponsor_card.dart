import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../core/models/models.dart';
import '../core/theme/app_theme.dart';

class SponsorCard extends StatelessWidget {
  final Sponsor sponsor;

  const SponsorCard({super.key, required this.sponsor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSignal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kSignal.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kSignal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.swap_horiz_rounded, size: 22, color: kSignal),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sponsor.name, style: kSubtitle.copyWith(fontSize: 14.5)),
                if (sponsor.tagline != null) ...[
                  const Gap(2),
                  Text(sponsor.tagline!, style: kCaption.copyWith(fontSize: 12)),
                ],
              ],
            ),
          ),
          if (sponsor.healthScore != null) ...[
            const Gap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${sponsor.healthScore}', style: kMono(18, weight: FontWeight.w600, color: kSignal)),
                Text('SCORE', style: kLabel.copyWith(fontSize: 7.5)),
              ],
            ),
          ],
          const Gap(6),
          Icon(Icons.chevron_right_rounded, size: 18, color: kOnSurfaceFaint),
        ],
      ),
    );
  }
}
