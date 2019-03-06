import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rect_getter/rect_getter.dart';


class DirectSelectItem<T> extends StatefulWidget {
  final T value;
  final isSelected;
  final double itemHeight;
  final scale = ValueNotifier<double>(1.0);
  final opacity = ValueNotifier<double>(0.5);
  GlobalKey globalKey;

  final Widget Function(BuildContext context, T value) itemBuilder;

  DirectSelectItem(
      {Key key,
        this.globalKey,
      @required this.value,
        @required this.itemBuilder,
      this.itemHeight = 48.0,
      this.isSelected = false})
      : super(key: key);

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

  DirectSelectItem<T> getSelectedItem(
      GlobalKey<DirectSelectItemState> animatedStateKey) {
    globalKey = RectGetter.createGlobalKey();
    return DirectSelectItem<T>(
      value: value,
      globalKey: globalKey,
      key: animatedStateKey,
      itemHeight: itemHeight,
      itemBuilder: itemBuilder,
      isSelected: true,
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
    //TODO use user defined scale factor
    _tween = Tween(begin: 1.0, end: 1 + 1 / 4.0);
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
            child: RectGetter(
              key: widget.globalKey,
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
          ),
        ],
      );
    } else {
      return Container(
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
            }),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }
}
