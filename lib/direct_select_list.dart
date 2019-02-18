import 'package:flutter/material.dart';
import 'package:flutter_direct_select/direct_select_item.dart';

class DirectSelectList<T> extends StatefulWidget {
  final List<DirectSelectItem> items;
  final DirectSelectState state = DirectSelectState();
  final itemHeight;
  final selectedItem = ValueNotifier<int>(0);
  final Function(T, BuildContext context) itemSelected;
  final Decoration focusedItemDecoration;

  void Function(DirectSelectList, double) onTapEventListener;
  void Function(double) onDragEventListener;

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
    this.onTapEventListener = onTapEventListener;
  }

  setOnDragEvent(Function(double) onDragEventListener) {
    this.onDragEventListener = onDragEventListener;
  }

  int getSelectedItemIndex() {
    return selectedItem.value;
  }

  void setSelectedItemIndex(int index) {
    selectedItem.value = index;
  }

  void commitSelection() {
    state.commitSelection();
  }

  T getSelectedItem() {
    return items[selectedItem.value].value;
  }
}

class DirectSelectState<T> extends State<DirectSelectList<T>> {
  bool isShowing = false;

  void commitSelection() {
    setState(() {});
    if (widget.itemSelected != null) {
      widget.itemSelected(
          widget.items[widget.selectedItem.value].value, this.context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
          child: widget.items[widget.selectedItem.value].getSelectedItem(),
          onTapDown: (tapDownDetails) {
            _showListOverlay(getItemTopPosition(context));
          },
          onTapUp: (tapUpDetails) {
            _hideListOverlay(getItemTopPosition(context));
          },
          onVerticalDragEnd: (dragDetails) {
            _hideListOverlay(getItemTopPosition(context));
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
    widget.onTapEventListener(widget, dy);
  }

  _showListOverlay(double dy) {
    if (!isShowing) {
      isShowing = true;
      widget.onTapEventListener(widget, getItemTopPosition(context));
    } else {
      widget.onDragEventListener(dy);
    }
  }
}
