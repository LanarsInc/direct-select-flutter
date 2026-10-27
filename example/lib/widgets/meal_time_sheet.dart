import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:example/food_data.dart';
import 'package:flutter/material.dart';

import 'selector_field.dart';

class MealTimeSheetButton extends StatelessWidget {
  const MealTimeSheetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => const MealTimeSheet(),
        ),
        child: const Text('CHOOSE MEAL TIME'),
      ),
    );
  }
}

class MealTimeSheet extends StatefulWidget {
  const MealTimeSheet({super.key});

  @override
  State<MealTimeSheet> createState() => _MealTimeSheetState();
}

class _MealTimeSheetState extends State<MealTimeSheet> {
  int _selectedMealTimeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DirectSelectContainer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Column(
          children: [
            const FieldLabel('Meal time'),
            SelectorField<String>(
              values: mealTimes,
              selectedIndex: _selectedMealTimeIndex,
              openOnLongPress: true,
              onSelected: (index) => setState(() => _selectedMealTimeIndex = index),
            ),
          ],
        ),
      ),
    );
  }
}
