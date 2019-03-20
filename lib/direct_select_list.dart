import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';

typedef DirectSelectItemsBuilder<T> = DirectSelectItem<T> Function(T value);

typedef ItemSelected = Future<dynamic> Function(
    DirectSelectList owner, double location);

/// Widget that contains items and responds to user's interaction
/// Usage Example
///
///     final dsl2 = DirectSelectList<String>(
///        values: _numbers,
///        itemBuilder: (String value) => getDropDownMenuItem(value),
///        focusedItemDecoration: _getDslDecoration());
///
class DirectSelectList<T> extends StatefulWidget {
  //Item widgets
  final List<DirectSelectItem<T>> items;

  //Current focused item overlay
  final Decoration focusedItemDecoration;

  //Default selected item index
  final int defaultItemIndex;

  //Notifies state about new item selected
  final ValueNotifier<int> selectedItem;

  //Function to execute when item selected
  final Function(T value, int selectedIndex, BuildContext context)
  onItemSelectedListener;

  //todo find better way to notify parent widget about gesture events to make this class immutable
  Future Function(DirectSelectList, double) onTapEventListener;
  void Function(double) onDragEventListener;

  GlobalKey paddingGlobalKey = RectGetter.createGlobalKey();

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
    return DirectSelectState<T>(onTapEventListener, onDragEventListener);
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

  bool _isShowUpAnimationRunning = false;

  Map<int, Widget> selectedItemWidgets;

  @override
  void initState() {
    super.initState();
    lastSelectedItem = widget.defaultItemIndex;
    selectedItemWidgets = Map();
    for (int i = 0; i < widget.items.length; i++) {
      selectedItemWidgets.putIfAbsent(
          i,
              () =>
              widget.items[i]
                  .getSelectedItem(animatedStateKey, widget.paddingGlobalKey));
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.selectedItem.addListener(() {
      if (widget.onItemSelectedListener != null) {
        widget.onItemSelectedListener(
            widget.items[widget.selectedItem.value].value,
            widget.selectedItem.value,
            this.context);
      }
    });

    bool transitionEnded = false;

    return ValueListenableBuilder<int>(
        valueListenable: widget.selectedItem,
        builder: (context, value, child) {
          final selectedItem = selectedItemWidgets[value];
          return GestureDetector(
              child: selectedItem,
              onTapDown: (tapDownDetails) async {
                if (!isOverlayVisible) {
                  transitionEnded = false;
                  _isShowUpAnimationRunning = true;
                  await animatedStateKey.currentState
                      .runScaleTransition(reverse: false);
                  if (!transitionEnded) {
                    await _showListOverlay(_getItemTopPosition(context));
                    _isShowUpAnimationRunning = false;
                    lastSelectedItem = value;
                  }
                }
              },
              onTapUp: (tapUpDetails) async {
                await _hideListOverlay(_getItemTopPosition(context));
                animatedStateKey.currentState.runScaleTransition(reverse: true);
              },
              onVerticalDragEnd: (dragDetails) async {
                transitionEnded = true;
                _dragEnd();
              },
              onHorizontalDragEnd: (horizontalDetails) async {
                transitionEnded = true;
                _dragEnd();
              },
              onVerticalDragUpdate: (dragInfo) {
                if (!_isShowUpAnimationRunning) {
                  _showListOverlay(dragInfo.primaryDelta);
                }
              });
        });
  }

  void _dragEnd() async {
    await _hideListOverlay(_getItemTopPosition(context));
    animatedStateKey.currentState.runScaleTransition(reverse: true);
  }

  double _getItemTopPosition(BuildContext context) {
    final RenderBox itemBox = context.findRenderObject();
    final Rect itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;
    return itemRect.top;
  }

  _hideListOverlay(double dy) async {
    if (isOverlayVisible) {
      isOverlayVisible = false;
      //fix to prevent stuck scale if selected item is the same as previous
      await onTapEventListener(widget, dy);
      if (lastSelectedItem == widget.selectedItem.value) {
        animatedStateKey.currentState.runScaleTransition(reverse: true);
      }
    }
  }

  @override
  void didUpdateWidget(DirectSelectList oldWidget) {
    widget.paddingGlobalKey = oldWidget.paddingGlobalKey;
    super.didUpdateWidget(oldWidget);
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
