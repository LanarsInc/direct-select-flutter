import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_direct_select/direct_select_item.dart';

typedef DirectSelectItemsBuilder<T> = DirectSelectItem<T> Function(T value);

typedef ItemSelected = Future<dynamic> Function(
    DirectSelectList owner, double location);

class DirectSelectList<T> extends StatefulWidget {
  final List<DirectSelectItem<T>> items;
  final Decoration focusedItemDecoration;
  final int defaultItemIndex;
  final ValueNotifier<int> selectedItem;

  final Function(T value, BuildContext context) onItemSelectedListener;

  //todo find better way to notify parent widget about gesture events to make this class immutable

  Future Function(DirectSelectList, double) onTapEventListener;
  void Function(double) onDragEventListener;

  DirectSelectList(
      {Key key,
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
      onTapEventListener,
      onDragEventListener,
    );
  }

  //todo pass item height in this class and build items with that height
  double itemHeight() {
    if (items != null && items.isNotEmpty) {
      return items.first.itemHeight;
    }
    return 0.0;
  }

  setOnTapEventListener(ItemSelected onTapEventListener) {
    this.onTapEventListener = onTapEventListener;
  }

  setOnDragEvent(Function(double) onDragEventListener) {
    this.onDragEventListener = onDragEventListener;
  }

  void refreshDefaultValue() {}

  int getSelectedItemIndex() {
    if (selectedItem != null) {
      return selectedItem.value;
    } else {
      return 0;
    }
  }

  void setSelectedItemIndex(int index) {
    if (selectedItem != null && index != selectedItem.value) {
      selectedItem.value = index;
    }
  }

  T getSelectedItem() {
    return items[selectedItem.value].value;
  }
}

class DirectSelectState<T> extends State<DirectSelectList<T>> {
  final GlobalKey<DirectSelectItemState> animatedStateKey =
  GlobalKey<DirectSelectItemState>();

  final Future Function(DirectSelectList, double) onTapEventListener;
  final void Function(double) onDragEventListener;

  bool isOverlayVisible = false;

  DirectSelectState(this.onTapEventListener, this.onDragEventListener);

  int lastSelectedItem;

  Map<int, DirectSelectItem<T>> selectedItemWidgets;

  @override
  void initState() {
    super.initState();
    lastSelectedItem = widget.defaultItemIndex;
    selectedItemWidgets = Map();
    for (int i = 0; i < widget.items.length; i++) {
      selectedItemWidgets.putIfAbsent(
          i, () => widget.items[i].getSelectedItem(animatedStateKey));
    }
  }

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
          final selectedItem = selectedItemWidgets[value];
          return GestureDetector(
              child: selectedItem,
              onTapDown: (tapDownDetails) async {
                animatedStateKey.currentState.runScaleTransition(
                    reverse: false);
                _showListOverlay(_getItemTopPosition(context));
                lastSelectedItem = value;
              },
              onTapUp: (tapUpDetails) {
                animatedStateKey.currentState.runScaleTransition(reverse: true);
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

  _hideListOverlay(double dy) async {
    isOverlayVisible = false;
    //fix to prevent stuck scale if selected item is the same as previous
    onTapEventListener(widget, dy).then((v) {
      if (lastSelectedItem == widget.selectedItem.value) {
        animatedStateKey.currentState.runScaleTransition(reverse: true);
      }
    });
  }

  _showListOverlay(double dy) {
    if (!isOverlayVisible) {
      isOverlayVisible = true;
      onTapEventListener(widget, _getItemTopPosition(context));
    } else {
      onDragEventListener(dy);
    }
  }
}
