import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double _kMenuItemHeight = 48.0;

class DirectSelectItem<T> extends StatefulWidget {
  final T value;
  final isSelected;
  final Widget Function(BuildContext context, T value) listItemBuilder;
  final Widget Function(BuildContext context, T value) selectedItemBuilder;

  DirectSelectItemState<T> state;
  double scale = 1.0;

  DirectSelectItem({Key key,
    this.value,
    @required this.listItemBuilder,
    @required this.selectedItemBuilder,
    this.isSelected = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = DirectSelectItemState(scale: scale, isSelected: isSelected);
    return state;
  }

  void updateScale(double scale) {
    scale = scale;
    state.setScale(scale);
  }

  DirectSelectItem<T> getSelectedItem() {
    return DirectSelectItem(
        value: value,
        selectedItemBuilder: selectedItemBuilder,
        listItemBuilder: listItemBuilder,
        isSelected: true);
  }
}

class DirectSelectItemState<T> extends State<DirectSelectItem<T>>
    with SingleTickerProviderStateMixin {
  bool isSelected = false;
  double scale = 1.0;

  DirectSelectItemState({this.scale, this.isSelected});

  @override
  void initState() {
    super.initState();
  }

  void setScale(double scale) {
    setState(() {
      this.scale = scale;
    });
  }

  void setSelected() {
    setState(() {
      isSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
          child: widget.selectedItemBuilder(context, widget.value),
          alignment: AlignmentDirectional.centerStart,
          height: _kMenuItemHeight);
    } else {
      return Container(
          child: Transform.scale(
              scale: scale,
              alignment: Alignment.centerLeft,
              child: widget.listItemBuilder(context, widget.value)),
          alignment: AlignmentDirectional.centerStart,
          height: _kMenuItemHeight);
    }
  }
}
