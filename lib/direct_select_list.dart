import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_direct_select/direct_select_item.dart';

typedef DirectSelectItemsBuilder<T> = DirectSelectItem<T> Function(T value);

class DirectSelectList<T> extends StatefulWidget {
  final List<DirectSelectItem<T>> items;
  final Decoration focusedItemDecoration;
  final int defaultItemIndex;
  final ValueNotifier<int> selectedItem;

  final Function(T value, BuildContext context) onItemSelectedListener;
  //todo find better way to notify parent widget about gesture events to make this class immutable

  void Function(DirectSelectList, double) onTapEventListener;
  void Function(double) onDragEventListener;

  DirectSelectList({Key key,
    @required List<T> values,
    @required DirectSelectItemsBuilder<T> itemBuilder,
    this.onItemSelectedListener,
    this.focusedItemDecoration,
    this.defaultItemIndex = 0})
      : items = values.map((val) => itemBuilder(val)).toList(),
        selectedItem = ValueNotifier<int>(defaultItemIndex),
        assert(defaultItemIndex + 1 <= values.length + 1),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectState<T>(
        onTapEventListener, onDragEventListener);
  }

  //todo pass item height in this class and build items with that height
  double itemHeight() {
    if (items != null && items.isNotEmpty) {
      return items.first.itemHeight;
    }
    return 0.0;
  }

  setOnTapEventListener(Function(DirectSelectList owner, double location) onTapEventListener) {
    this.onTapEventListener = onTapEventListener;
  }

  setOnDragEvent(Function(double) onDragEventListener) {
    this.onDragEventListener = onDragEventListener;
  }

  void refreshDefaultValue() {

  }

  int getSelectedItemIndex() {
    if (selectedItem != null) {
      return selectedItem.value;
    } else {
      return 0;
    }
  }

  void setSelectedItemIndex(int index) {
    if (selectedItem != null) {
      selectedItem.value = index;
    }
  }

  T getSelectedItem() {
    return items[selectedItem.value].value;
  }
}

class DirectSelectState<T> extends State<DirectSelectList<T>> {
  bool isShowing = false;
  final void Function(DirectSelectList, double) onTapEventListener;
  final void Function(double) onDragEventListener;

  DirectSelectState(this.onTapEventListener, this.onDragEventListener);

  @override
  Widget build(BuildContext context) {
    widget.selectedItem.addListener(() {
      if (widget.onItemSelectedListener != null) {
        widget.onItemSelectedListener(
            widget.items[widget.selectedItem.value].value, this.context);
      }
    });

    return ValueListenableBuilder<int>(
        valueListenable: widget.selectedItem,
        builder: (context, value, child) {
          return GestureDetector(
              child: widget.items[value].getSelectedItem(),
              onTapDown: (tapDownDetails) {
                _showListOverlay(_getItemTopPosition(context));
              },
              onTapUp: (tapUpDetails) {
                _hideListOverlay(_getItemTopPosition(context));
              },
              onVerticalDragEnd: (dragDetails) {
                _hideListOverlay(_getItemTopPosition(context));
              },
              onVerticalDragUpdate: (dragInfo) {
                _showListOverlay(dragInfo.primaryDelta);
              });
        });
  }

  double _getItemTopPosition(BuildContext context) {
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
      onTapEventListener(widget, _getItemTopPosition(context));
    } else {
      onDragEventListener(dy);
    }
  }
}
