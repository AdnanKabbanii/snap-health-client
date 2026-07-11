import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/ui.dart';

class StepDiet extends StatelessWidget {
  final String? dietaryPreference;
  final List<String> allergies;
  final List<String> medications;
  final ValueChanged<String?> onDietChanged;
  final ValueChanged<List<String>> onAllergiesChanged;
  final ValueChanged<List<String>> onMedicationsChanged;

  const StepDiet({
    super.key,
    required this.dietaryPreference,
    required this.allergies,
    required this.medications,
    required this.onDietChanged,
    required this.onAllergiesChanged,
    required this.onMedicationsChanged,
  });

  static const _diets = ['none', 'vegan', 'vegetarian', 'keto', 'paleo', 'halal', 'kosher'];
  static const _allergens = ['gluten', 'dairy', 'peanuts', 'tree_nuts', 'soy', 'eggs', 'shellfish', 'fish'];
  static const _commonMeds = ['metformin', 'lisinopril', 'atorvastatin', 'levothyroxine', 'amlodipine', 'omeprazole', 'losartan', 'albuterol'];

  void _toggleAllergy(String key) {
    final updated = List<String>.from(allergies);
    updated.contains(key) ? updated.remove(key) : updated.add(key);
    onAllergiesChanged(updated);
  }

  void _toggleMedication(String key) {
    final updated = List<String>.from(medications);
    updated.contains(key) ? updated.remove(key) : updated.add(key);
    onMedicationsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Dietary preference'),
          const Gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _diets.map((diet) {
              final label = diet == 'none' ? 'No preference' : prettyKey(diet);
              return TagChip(
                label: label,
                selected: dietaryPreference == diet,
                onTap: () => onDietChanged(diet),
              );
            }).toList(),
          ),

          const Gap(30),
          Eyebrow('Allergies', color: kDanger),
          const Gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergens.map((a) {
              return TagChip(
                label: prettyKey(a),
                selected: allergies.contains(a),
                accent: kDanger,
                onTap: () => _toggleAllergy(a),
              );
            }).toList(),
          ),

          const Gap(30),
          const Eyebrow('Medications'),
          const Gap(6),
          Text('Lets us flag food–drug interactions before they happen.', style: kCaption),
          const Gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonMeds.map((med) {
              return TagChip(
                label: prettyKey(med),
                selected: medications.contains(med),
                accent: kAmber,
                onTap: () => _toggleMedication(med),
              );
            }).toList(),
          ),
          const Gap(24),
        ],
      ),
    );
  }
}
