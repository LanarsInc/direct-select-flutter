import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DirectSelectItem<T> extends StatefulWidget {
  final T value;
  final isSelected;
  final double itemHeight;
  final scale = ValueNotifier<double>(1.0);
  final opacity = ValueNotifier<double>(0.5);
  final runScale = ValueNotifier<int>(1);
  final double inListPadding;

  final Widget Function(BuildContext context, T value) listItemBuilder;
  final Widget Function(BuildContext context, T value) buttonItemBuilder;

  DirectSelectItem(
      {Key key,
      @required this.value,
      @required this.listItemBuilder,
      @required this.buttonItemBuilder,
      this.inListPadding = 40,
      this.itemHeight = 48.0,
      this.isSelected = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectItemState<T>(scale: scale, isSelected: isSelected);
  }

  void updateScale(double scale) {
    this.scale.value = scale;
  }

  void updateOpacity(double opacity) {
    this.opacity.value = opacity;
  }

  DirectSelectItem<T> getSelectedItem() {
    return DirectSelectItem<T>(
      value: value,
      itemHeight: itemHeight,
      buttonItemBuilder: buttonItemBuilder,
      listItemBuilder: listItemBuilder,
      isSelected: true,
    );
  }
}

class DirectSelectItemState<T> extends State<DirectSelectItem<T>>
    with SingleTickerProviderStateMixin {
  final bool isSelected;
  final ValueListenable scale;

  AnimationController animationController;

  DirectSelectItemState({this.scale, this.isSelected = false});

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
          height: widget.itemHeight,
          child: widget.buttonItemBuilder(context, widget.value),
          alignment: AlignmentDirectional.centerStart);
    } else {
      return Container(
        padding: EdgeInsets.only(left: widget.inListPadding),
        child: ValueListenableBuilder<double>(
            valueListenable: widget.scale,
            builder: (context, value, child) {
              return Opacity(
                opacity: widget.opacity.value,
                child: Container(
                    height: widget.itemHeight,
                    child: Transform.scale(
                        scale: value,
                        alignment: Alignment.topLeft,
                        child: widget.listItemBuilder(context, widget.value)),
                    alignment: AlignmentDirectional.centerStart),
              );
            }),
      );
    }
  }
}
