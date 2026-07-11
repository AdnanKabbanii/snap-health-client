import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../core/models/models.dart';
import '../core/theme/app_theme.dart';
import 'ui.dart';

class NutritionCard extends StatelessWidget {
  final Nutrition nutrition;

  const NutritionCard({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final items = <_NutrientItem>[];

    void add(String label, String unit, num? value) {
      if (value != null) items.add(_NutrientItem(label, unit, value));
    }

    add('Calories', 'kcal', nutrition.calories);
    add('Carbs', 'g', nutrition.carbsG);
    add('Sugar', 'g', nutrition.sugarG);
    add('Sodium', 'mg', nutrition.sodiumMg);
    add('Protein', 'g', nutrition.proteinG);
    add('Fat', 'g', nutrition.fatG);
    add('Fiber', 'g', nutrition.fiberG);

    if (items.isEmpty) return const SizedBox.shrink();

    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i += 2)
            Row(
              children: [
                Expanded(child: _NutrientCell(item: items[i])),
                if (i + 1 < items.length) ...[
                  Container(width: 1, height: 44, color: kHairline),
                  Expanded(child: _NutrientCell(item: items[i + 1])),
                ] else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
        ],
      ),
    );
  }
}

class _NutrientCell extends StatelessWidget {
  final _NutrientItem item;
  const _NutrientCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(item.label.toUpperCase(), style: kLabel.copyWith(fontSize: 9)),
          ),
          Text(
            item.value.toStringAsFixed(item.value == item.value.roundToDouble() ? 0 : 1),
            style: kMono(17, weight: FontWeight.w600),
          ),
          const Gap(3),
          Text(item.unit, style: kCaption.copyWith(fontSize: 10.5)),
        ],
      ),
    );
  }
}

class _NutrientItem {
  final String label;
  final String unit;
  final num value;
  _NutrientItem(this.label, this.unit, this.value);
}
