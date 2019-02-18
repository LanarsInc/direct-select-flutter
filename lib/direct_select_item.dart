import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DirectSelectItem<T> extends StatefulWidget {
  final T value;
  final isSelected;
  final scale = ValueNotifier<double>(1.0);
  final Widget Function(BuildContext context, T value) listItemBuilder;
  final Widget Function(BuildContext context, T value) buttonItemBuilder;

  DirectSelectItem({Key key,
    @required this.value,
    @required this.listItemBuilder,
    @required this.buttonItemBuilder,
    this.isSelected = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectItemState<T>(scale: scale, isSelected: isSelected);
  }

  void updateScale(double scale) {
    this.scale.value = scale;
  }

  DirectSelectItem<T> getSelectedItem() {
    return DirectSelectItem<T>(
        value: value,
        buttonItemBuilder: buttonItemBuilder,
        listItemBuilder: listItemBuilder,
        isSelected: true);
  }
}

class DirectSelectItemState<T> extends State<DirectSelectItem<T>> {
  final bool isSelected;
  final ValueListenable scale;

  DirectSelectItemState({this.scale, this.isSelected = false});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
          height: 48.0,
          child: widget.buttonItemBuilder(context, widget.value),
          alignment: AlignmentDirectional.centerStart);
    } else {
      return ValueListenableBuilder<double>(
          valueListenable: scale,
          builder: (context, value, child) {
            return Container(
                height: 48.0,
                child: Transform.scale(
                    scale: value,
                    alignment: Alignment.centerLeft,
                    child: widget.listItemBuilder(context, widget.value)),
                alignment: AlignmentDirectional.centerStart);
          });
    }
  }
}
