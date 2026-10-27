import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/material.dart';

const selectorFocusedItemDecoration = BoxDecoration(
  border: BorderDirectional(
    top: BorderSide(color: Colors.black12),
    bottom: BorderSide(color: Colors.black12),
  ),
);

const _shadowDecoration = BoxDecoration(
  boxShadow: [BoxShadow(color: Color(0x0F000000), spreadRadius: 4, blurRadius: 15)],
);

class SelectorField<T> extends StatelessWidget {
  const SelectorField({
    super.key,
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    this.itemLabel,
    this.showDropdownIcon = true,
  });

  final List<T> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String Function(T value)? itemLabel;
  final bool showDropdownIcon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _shadowDecoration,
      child: Card(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 22),
                child: DirectSelectList<T>(
                  values: values,
                  defaultItemIndex: selectedIndex,
                  itemBuilder: (value) => SelectorItem<T>(value: value, label: itemLabel?.call(value)),
                  focusedItemDecoration: selectorFocusedItemDecoration,
                  onUserTappedListener: () =>
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Hold and drag instead of tap'))),
                  onItemSelectedListener: (_, index, _) => onSelected(index),
                ),
              ),
            ),
            if (showDropdownIcon) const DropdownIcon(),
          ],
        ),
      ),
    );
  }
}

class SelectorItem<T> extends DirectSelectItem<T> {
  SelectorItem({super.key, required super.value, String? label})
    : super(itemHeight: 56, itemBuilder: (context, value) => Text(label ?? value.toString()));
}

class DropdownIcon extends StatelessWidget {
  const DropdownIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.only(end: 8),
      child: Icon(Icons.unfold_more, color: Colors.blueAccent),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
      child: Align(alignment: AlignmentDirectional.centerStart, child: Text(text)),
    );
  }
}
