import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:flutter/material.dart';

import 'food_data.dart';
import 'widgets/nutrition_summary.dart';
import 'widgets/page_header.dart';
import 'widgets/selected_food_title.dart';
import 'widgets/selector_field.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  int _selectedMealIndex = 0;
  int _selectedFoodIndex = 0;
  int _selectedFoodVariantIndex = 0;
  int _selectedPortionCountIndex = 0;
  int _selectedPortionSizeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(caption: 'Journal', title: 'Add Food'),
      body: DirectSelectContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              SelectedFoodTitle(
                foodVariant: foodVariants[_selectedFoodVariantIndex],
                portionCount: portionCounts[_selectedPortionCountIndex],
                portionSize: portionSizes[_selectedPortionSizeIndex],
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: NutritionSummary(values: nutritionValues),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const FieldLabel('To which meal?'),
                    SelectorField<String>(
                      values: meals,
                      selectedIndex: _selectedMealIndex,
                      onSelected: (index) => setState(() => _selectedMealIndex = index),
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel('Search our database by name'),
                    SelectorField<String>(
                      values: food,
                      selectedIndex: _selectedFoodIndex,
                      onSelected: (index) => setState(() => _selectedFoodIndex = index),
                    ),
                    const SizedBox(height: 8),
                    SelectorField<String>(
                      values: foodVariants,
                      selectedIndex: _selectedFoodVariantIndex,
                      onSelected: (index) => setState(() => _selectedFoodVariantIndex = index),
                    ),
                    const SizedBox(height: 31),
                    const FieldLabel('How Much?'),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SelectorField<String>(
                            values: portionCounts,
                            selectedIndex: _selectedPortionCountIndex,
                            showDropdownIcon: false,
                            onSelected: (index) => setState(() => _selectedPortionCountIndex = index),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: SelectorField<String>(
                            values: portionSizes,
                            selectedIndex: _selectedPortionSizeIndex,
                            onSelected: (index) => setState(() => _selectedPortionSizeIndex = index),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: () {}, child: const Text('ADD TO JOURNAL')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
