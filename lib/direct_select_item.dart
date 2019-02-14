import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double _kMenuItemHeight = 48.0;

class DirectSelectItem<T> extends StatefulWidget {
  final T value;
  final Widget child;

  DirectSelectItem({Key key, this.value, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectItemState();
  }
}

class DirectSelectItemState<T> extends State<DirectSelectItem<T>>
    with SingleTickerProviderStateMixin {
  bool isSelected = false;

  void setSelected() {
    setState(() {
      isSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: widget.child,
        decoration: isSelected
            ? BoxDecoration(color: Colors.redAccent.withOpacity(0.3))
            : BoxDecoration(color: Colors.black38),
        alignment: AlignmentDirectional.centerStart,
        height: _kMenuItemHeight);
  }
}
