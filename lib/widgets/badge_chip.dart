import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../core/models/models.dart';
import '../core/theme/app_theme.dart';

class BadgeChip extends StatelessWidget {
  final Badge badge;

  const BadgeChip({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(badge.name, style: kSans(12.5)),
        ],
      ),
    );
  }
}
