import 'package:flutter/material.dart';
import 'package:flutter_direct_select/direct_select_item.dart';

class DirectSelectList<T> extends StatefulWidget {
  final List<DirectSelectItem> items;
  final DirectSelectState state = DirectSelectState();
  final itemHeight;
  final Function(T, BuildContext context) itemSelected;
  final Decoration focusedItemDecoration;

  DirectSelectList({Key key,
    @required this.items,
    this.itemSelected,
    this.itemHeight = 48.0,
    this.focusedItemDecoration})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  setOnTapEventListener(
      Function(DirectSelectList owner, double location) onTapEventListener) {
    state.onTapEventListener = onTapEventListener;
  }

  setOnDragEvent(Function(double) callback) {
    state.onDragEventListener = callback;
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
  void Function(DirectSelectList, double) onTapEventListener;
  void Function(double) onDragEventListener;

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
            _showListOverlay(getItemTopPosition(context));
          },
          onTapUp: (tapUpDetails) {
            _hideListOverlay(getItemTopPosition(context));
          },
          onVerticalDragEnd: (dragDetails) {
            _hideListOverlay(0);
          },
          onVerticalDragUpdate: (dragInfo) {
            _showListOverlay(dragInfo.primaryDelta);
          }),
    );
  }

  double getItemTopPosition(BuildContext context) {
    final RenderBox itemBox = context.findRenderObject();
    final Rect itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;
    return itemRect.top;
  }

  _hideListOverlay(double dy) {
    isShowing = false;
    onTapEventListener(widget, dy);
  }

  _showListOverlay(double dy) {
    if (!isShowing) {
      isShowing = true;
      onTapEventListener(widget, getItemTopPosition(context));
    } else {
      onDragEventListener(dy);
    }
  }
}
