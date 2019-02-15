import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double _kMenuItemHeight = 48.0;

class DirectSelectItem<T> extends StatefulWidget {
  final T value;
  final Widget child;

  DirectSelectItemState state;
  double scale = 1.0;

  DirectSelectItem({Key key, this.value, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = DirectSelectItemState(scale: scale);
    return state;
  }

  void updateScale(double scale) {
    scale = scale;
    state.setScale(scale);
  }
}

class DirectSelectItemState<T> extends State<DirectSelectItem<T>>
    with SingleTickerProviderStateMixin {
  bool isSelected = false;
  double scale = 1.0;

  DirectSelectItemState({this.scale});

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
    return Container(
        child: Transform.scale(
            scale: scale,
            alignment: Alignment.centerLeft,
            child: widget.child),
        decoration: isSelected
            ? BoxDecoration(color: Colors.redAccent.withOpacity(0.3))
            : BoxDecoration(color: Colors.black38),
        alignment: AlignmentDirectional.centerStart,
        height: _kMenuItemHeight);
  }
}
