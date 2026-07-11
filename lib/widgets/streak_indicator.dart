import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../core/theme/app_theme.dart';

class StreakIndicator extends StatelessWidget {
  final int streak;

  const StreakIndicator({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final lit = streak > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department_rounded,
          color: lit ? kAmber : kOnSurfaceFaint,
          size: 18,
        ),
        const Gap(5),
        Text(
          '$streak day${streak == 1 ? '' : 's'}',
          style: kMono(13, weight: FontWeight.w600, color: lit ? kOnSurface : kOnSurfaceFaint),
        ),
      ],
    );
  }
}
