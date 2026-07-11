import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../core/models/models.dart';
import '../core/theme/app_theme.dart';
import 'ui.dart';

class EffectCard extends StatelessWidget {
  final Effect effect;

  const EffectCard({super.key, required this.effect});

  IconData _systemIcon(BodySystem system) {
    return switch (system) {
      BodySystem.insulin => Icons.water_drop_rounded,
      BodySystem.bloodPressure => Icons.favorite_rounded,
      BodySystem.sleep => Icons.bedtime_rounded,
      BodySystem.metabolism => Icons.local_fire_department_rounded,
      BodySystem.inflammation => Icons.warning_rounded,
      BodySystem.gut => Icons.spa_rounded,
      BodySystem.energy => Icons.bolt_rounded,
      BodySystem.cholesterol => Icons.monitor_heart_rounded,
      BodySystem.hydration => Icons.opacity_rounded,
      BodySystem.cortisol => Icons.psychology_rounded,
      BodySystem.boneDensity => Icons.accessibility_new_rounded,
      BodySystem.liver => Icons.healing_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final directionIcon = switch (effect.direction) {
      EffectDirection.increase => Icons.north_east_rounded,
      EffectDirection.decrease => Icons.south_east_rounded,
      EffectDirection.neutral => Icons.remove_rounded,
    };
    final directionColor = switch (effect.direction) {
      EffectDirection.increase => kDanger,
      EffectDirection.decrease => kSignal,
      EffectDirection.neutral => kOnSurfaceVariant,
    };
    final mag = effect.magnitude.toDouble();
    final severe = effect.warningLevel == WarningLevel.critical || effect.warningLevel == WarningLevel.danger;

    return Panel(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_systemIcon(effect.bodySystem), size: 18, color: kOnSurfaceVariant),
              const Gap(10),
              Expanded(
                child: Text(
                  effect.bodySystem.name
                      .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
                      .trim()
                      .toUpperCase(),
                  style: kMono(11, weight: FontWeight.w600, letterSpacing: 1.4),
                ),
              ),
              Icon(directionIcon, size: 15, color: directionColor),
              const Gap(5),
              Text(
                '${mag.toStringAsFixed(0)}/10',
                style: kMono(12.5, weight: FontWeight.w600, color: directionColor),
              ),
            ],
          ),
          const Gap(10),
          ProgressTrack(value: mag / 10, color: directionColor, height: 3.5),
          if (effect.description.isNotEmpty) ...[
            const Gap(10),
            Text(effect.description, style: kBody.copyWith(fontSize: 13, color: kOnSurfaceVariant)),
          ],
          if (effect.personalizedNote != null) ...[
            const Gap(12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: (severe ? kDanger : kAmber).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(kRadiusSm),
                border: Border.all(color: (severe ? kDanger : kAmber).withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    severe ? Icons.error_rounded : Icons.person_pin_rounded,
                    size: 15,
                    color: severe ? kDanger : kAmber,
                  ),
                  const Gap(9),
                  Expanded(
                    child: Text(
                      effect.personalizedNote!,
                      style: kBody.copyWith(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
