import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rect_getter/rect_getter.dart';

/// Widget that defines direct select list appearance
/// Usage Example
///
///   DirectSelectItem<String> getDropDownMenuItem(String value) {
///    return DirectSelectItem<String>(
///        itemHeight: 56,
///        value: value,
///        itemBuilder: (context, value) {
///          return Text(value);
///        });
///   }
///
class DirectSelectItem<T> extends StatefulWidget {
  //Value of item
  final T value;

  //Defines is this item is selected
  final isSelected;

  //height of items in list
  final double itemHeight;

  //initial item scale
  final scale = ValueNotifier<double>(1.0);

  //opacity unselected item
  final opacity = ValueNotifier<double>(0.5);

  //the more value the MORE max scale DECREASES
  final scaleFactor;

  final Widget Function(BuildContext context, T value) itemBuilder;

  DirectSelectItem({
    Key key,
    this.scaleFactor = 4.0,
    @required this.value,
    @required this.itemBuilder,
    this.itemHeight = 48.0,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectItemState<T>(isSelected: isSelected);
  }

  void updateScale(double scale) {
    this.scale.value = scale;
  }

  void updateOpacity(double opacity) {
    this.opacity.value = opacity;
  }

  Widget getSelectedItem(GlobalKey<DirectSelectItemState> animatedStateKey,
      GlobalKey paddingGlobalKey) {
    return RectGetter(
      key: paddingGlobalKey,
      child: DirectSelectItem<T>(
        value: value,
        key: animatedStateKey,
        itemHeight: itemHeight,
        itemBuilder: itemBuilder,
        isSelected: true,
      ),
    );
  }
}

class DirectSelectItemState<T> extends State<DirectSelectItem<T>>
    with SingleTickerProviderStateMixin {
  final bool isSelected;

  AnimationController animationController;
  Animation _animation;
  Tween<double> _tween;

  DirectSelectItemState({this.isSelected = false});

  bool isScaled = false;

  Future runScaleTransition({@required bool reverse}) {
    if (reverse) {
      return animationController.reverse();
    } else {
      return animationController.forward(from: 0.0);
    }
  }

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(duration: Duration(milliseconds: 150), vsync: this);
    _tween = Tween(begin: 1.0, end: 1 + 1 / widget.scaleFactor);
    _animation = _tween.animate(animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.transparent,
              height: widget.itemHeight,
              alignment: AlignmentDirectional.centerStart,
              child: Transform.scale(
                  scale: _animation.value,
                  alignment: Alignment.topLeft,
                  child: widget.itemBuilder(context, widget.value)),
            ),
          ),
        ],
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: Container(
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
                        child: widget.itemBuilder(context, widget.value)),
                    alignment: AlignmentDirectional.centerStart),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }
}
