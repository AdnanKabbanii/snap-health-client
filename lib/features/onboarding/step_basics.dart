import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/ui.dart';

class StepBasics extends StatelessWidget {
  final String? ageRange;
  final String? biologicalSex;
  final ValueChanged<String?> onAgeChanged;
  final ValueChanged<String?> onSexChanged;

  const StepBasics({
    super.key,
    required this.ageRange,
    required this.biologicalSex,
    required this.onAgeChanged,
    required this.onSexChanged,
  });

  static const _ageRanges = ['13-17', '18-25', '26-35', '36-45', '46-55', '56-65', '65+'];
  static const _sexOptions = [
    ('male', Icons.male_rounded, 'Male'),
    ('female', Icons.female_rounded, 'Female'),
    ('other', Icons.transgender_rounded, 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Age range'),
          const Gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ageRanges.map((age) {
              return TagChip(
                label: age,
                selected: ageRange == age,
                onTap: () => onAgeChanged(age),
              );
            }).toList(),
          ),

          const Gap(34),
          const Eyebrow('Biological sex'),
          const Gap(6),
          Text('Used only to weight medical reference ranges.', style: kCaption),
          const Gap(14),
          Row(
            children: _sexOptions.map((option) {
              final (sex, icon, label) = option;
              final selected = biologicalSex == sex;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: sex != 'other' ? 8 : 0),
                  child: Pressable(
                    onTap: () => onSexChanged(sex),
                    pressedScale: 0.95,
                    child: AnimatedContainer(
                      duration: kMotionBase,
                      curve: kCurveSnap,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: selected ? kSignal.withValues(alpha: 0.12) : kSurfaceHigh,
                        borderRadius: BorderRadius.circular(kRadiusMd),
                        border: Border.all(
                          color: selected ? kSignal : kHairline,
                          width: selected ? 1.2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(icon, color: selected ? kSignal : kOnSurfaceVariant, size: 26),
                          const Gap(8),
                          Text(
                            label.toUpperCase(),
                            style: kMono(10, weight: FontWeight.w600, letterSpacing: 1.4,
                                color: selected ? kSignal : kOnSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
