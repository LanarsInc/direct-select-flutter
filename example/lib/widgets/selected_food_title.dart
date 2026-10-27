import 'package:flutter/material.dart';

class SelectedFoodTitle extends StatelessWidget {
  const SelectedFoodTitle({
    super.key,
    required this.foodVariant,
    required this.portionCount,
    required this.portionSize,
  });

  final String foodVariant;
  final String portionCount;
  final String portionSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(foodVariant, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text('$portionCount   $portionSize'),
        ],
      ),
    );
  }
}
