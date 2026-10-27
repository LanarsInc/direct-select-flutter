import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/material.dart';

import 'selector_field.dart';

class CompactSelector extends StatefulWidget {
  const CompactSelector({super.key, required this.values});

  final List<String> values;

  @override
  State<CompactSelector> createState() => _CompactSelectorState();
}

class _CompactSelectorState extends State<CompactSelector> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: DirectSelectList<String>(
              values: widget.values,
              defaultItemIndex: _selectedIndex,
              itemBuilder: (value) => SelectorItem<String>(value: value),
              focusedItemDecoration: selectorFocusedItemDecoration,
              onItemSelectedListener: (_, index, _) => setState(() => _selectedIndex = index),
            ),
          ),
          const DropdownIcon(),
        ],
      ),
    );
  }
}
