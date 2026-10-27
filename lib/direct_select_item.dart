import 'package:flutter/material.dart';

/// Widget that defines direct select list appearance
/// Usage Example
///
/// ```dart
/// DirectSelectItem<String> getDropDownMenuItem(String value) {
///   return DirectSelectItem<String>(
///       itemHeight: 56,
///       value: value,
///       itemBuilder: (context, value) {
///         return Text(value);
///       });
/// }
/// ```
class DirectSelectItem<T> extends StatefulWidget {
  ///Value of item
  final T value;

  ///Defines is this item is selected
  final bool isSelected;

  ///Height of items in list
  final double itemHeight;

  ///Initial item scale
  final scale = ValueNotifier<double>(1.0);

  ///Opacity unselected item
  final opacity = ValueNotifier<double>(0.5);

  ///the more value the MORE max scale DECREASES
  final num scaleFactor;

  ///Item builder
  final Widget Function(BuildContext context, T value) itemBuilder;

  DirectSelectItem({
    super.key,
    this.scaleFactor = 4.0,
    required this.value,
    required this.itemBuilder,
    this.itemHeight = 48.0,
    this.isSelected = false,
  });

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
    return KeyedSubtree(
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

  late AnimationController animationController;
  late Animation _animation;
  late Tween<double> _tween;

  DirectSelectItemState({this.isSelected = false});

  bool isScaled = false;

  Future runScaleTransition({required bool reverse}) {
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
      return Align(
        heightFactor: 1.0,
        child: ColoredBox(
          color: Colors.transparent,
          child: _ScaledItem(
            height: widget.itemHeight,
            scale: _animation.value,
            child: widget.itemBuilder(context, widget.value),
          ),
        ),
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: ValueListenableBuilder<double>(
          valueListenable: widget.scale,
          builder: (context, value, child) {
            return Opacity(
              opacity: widget.opacity.value,
              child: _ScaledItem(
                height: widget.itemHeight,
                scale: value,
                child: widget.itemBuilder(context, widget.value),
              ),
            );
          },
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

class _ScaledItem extends StatelessWidget {
  final double height;
  final double scale;
  final Widget child;

  const _ScaledItem({
    required this.height,
    required this.scale,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: child,
        ),
      ),
    );
  }
}
