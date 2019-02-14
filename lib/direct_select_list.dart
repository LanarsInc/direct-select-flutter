import 'package:flutter/material.dart';
import 'package:flutter_direct_select/direct_select_item.dart';

const double _kMenuItemHeight = 48.0;

class DirectSelectList<T> extends StatefulWidget {

  final List<DirectSelectItem> items;
  final DirectSelectState state = DirectSelectState();

  DirectSelectList({Key key, @required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  addOnTapEvent(Function(DirectSelectList owner) callback) {
    state.callback = callback;
  }

  addOnDragEvent(Function(double) callback) {
    state.dragCallback = callback;
  }
}

class DirectSelectState<T> extends State<DirectSelectList<T>> {

  void Function(DirectSelectList) callback;
  void Function(double) dragCallback;

  bool isShowing = false;
  var selectedItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
          child: widget.items[selectedItemIndex],
          onTapDown: (tapDownDetails) {
            _dragOverlay(tapDownDetails.globalPosition.dy);
          },
          onTapUp: (tapUpDetails) {
            _hideOverlay();
          },
          onVerticalDragEnd: (dragDetails) {
            _hideOverlay();
          },
          onVerticalDragUpdate: (dragInfo) {
            _dragOverlay(dragInfo.globalPosition.distance);
          }),
    );
  }

  _hideOverlay() {
    isShowing = false;
    callback(widget);
  }

  _dragOverlay(double dy) {
    if (!isShowing) {
      isShowing = true;
      callback(widget);
    } else {
      dragCallback(dy);
    }
  }

  int getCurrentElementIndex(ScrollNotification scrollNotification,
      double padding, double topOffset) {
    double scrollPixels = scrollNotification.metrics.pixels;

    int selectedElement = (scrollPixels / _kMenuItemHeight).round();
    final maxElementIndex = widget.items.length;

    if (selectedElement < 0) {
      selectedElement = 0;
    }
    print(selectedElement.toString());
    if (selectedElement >= maxElementIndex) {
      selectedElement = maxElementIndex - 1;
    }
    return selectedElement;
  }
}
