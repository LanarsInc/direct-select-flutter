import 'package:flutter/material.dart';
import 'package:flutter_direct_select/direct_select_item.dart';

class DirectSelectList<T> extends StatefulWidget {
  final List<DirectSelectItem> items;
  final DirectSelectState state = DirectSelectState();
  final itemHeight = 48.0;
  final Function(T, BuildContext context) itemSelected;
  final Decoration focusedItemDecoration;

  DirectSelectList({Key key,
    @required this.items,
    this.itemSelected,
    this.focusedItemDecoration})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  addOnTapEvent(Function(DirectSelectList owner, double location) callback) {
    state.callback = callback;
  }

  addOnDragEvent(Function(double) callback) {
    state.dragCallback = callback;
  }

  int getSelectedItemIndex() {
    return state.selectedItemIndex;
  }

  void setSelectedItemIndex(int index) {
    state.selectedItemIndex = index;
  }

  void commitSelection() {
    state.commitSelection();
  }

  T getSelectedItem() {
    return items[state.selectedItemIndex].value;
  }
}

class DirectSelectState<T> extends State<DirectSelectList<T>> {
  void Function(DirectSelectList, double) callback;
  void Function(double) dragCallback;

  bool isShowing = false;
  var selectedItemIndex = 0;

  void commitSelection() {
    setState(() {});
    if (this.widget.itemSelected != null) {
      this
          .widget
          .itemSelected(widget.items[selectedItemIndex].value, this.context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
          child: widget.items[selectedItemIndex].getSelectedItem(),
          onTapDown: (tapDownDetails) {
            _dragOverlay(getItemTopPosition(context));
          },
          onTapUp: (tapUpDetails) {
            _hideOverlay(getItemTopPosition(context));
          },
          onVerticalDragEnd: (dragDetails) {
            _hideOverlay(0);
          },
          onVerticalDragUpdate: (dragInfo) {
            _dragOverlay(dragInfo.primaryDelta);
          }),
    );
  }

  double getItemTopPosition(BuildContext context) {
    final RenderBox itemBox = context.findRenderObject();
    final Rect itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;
    return itemRect.top;
  }

  _hideOverlay(double dy) {
    isShowing = false;
    callback(widget, dy);
  }

  _dragOverlay(double dy) {
    if (!isShowing) {
      isShowing = true;
      callback(widget, dy);
    } else {
      dragCallback(dy);
    }
  }
}
