import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../widgets/ui.dart';

class StepGoals extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const StepGoals({super.key, required this.selected, required this.onChanged});

  static const _goals = {
    'lose_weight': 'Lose weight',
    'build_muscle': 'Build muscle',
    'sleep_better': 'Sleep better',
    'manage_blood_sugar': 'Manage blood sugar',
    'eat_cleaner': 'Eat cleaner',
    'reduce_inflammation': 'Reduce inflammation',
    'boost_energy': 'Boost energy',
    'improve_gut_health': 'Improve gut health',
  };

  void _toggle(String key) {
    final updated = List<String>.from(selected);
    updated.contains(key) ? updated.remove(key) : updated.add(key);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Pick your targets'),
          const Gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goals.entries.map((e) {
              return TagChip(
                label: e.value,
                selected: selected.contains(e.key),
                onTap: () => _toggle(e.key),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
