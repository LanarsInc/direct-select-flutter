import 'package:example/food_data.dart';
import 'package:flutter/material.dart';

import 'compact_selector.dart';

class ReminderSentence extends StatelessWidget {
  const ReminderSentence({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Remind me'),
        CompactSelector(values: reminderCounts),
        const Text('times a day'),
      ],
    );
  }
}

class FoodFilterBar extends StatelessWidget {
  const FoodFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            CompactSelector(values: cuisineFilters),
            CompactSelector(values: priceFilters),
            CompactSelector(values: ratingFilters),
          ],
        ),
      ),
    );
  }
}
