import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/ui.dart';

class StepConditions extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const StepConditions({super.key, required this.selected, required this.onChanged});

  static const _conditions = {
    'type_1_diabetes': 'Type 1 Diabetes',
    'type_2_diabetes': 'Type 2 Diabetes',
    'hypertension': 'Hypertension',
    'celiac': 'Celiac Disease',
    'pcos': 'PCOS',
    'hypothyroid': 'Hypothyroidism',
    'pregnancy': 'Pregnancy',
    'heart_disease': 'Heart Disease',
    'ibs': 'IBS',
    'anemia': 'Anemia',
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
          const Eyebrow('Select any that apply'),
          const Gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _conditions.entries.map((e) {
              return TagChip(
                label: e.value,
                selected: selected.contains(e.key),
                onTap: () => _toggle(e.key),
              );
            }).toList(),
          ),
          const Gap(18),
          Text('None of these? Just continue. You can revise this anytime.', style: kCaption),
        ],
      ),
    );
  }
}
