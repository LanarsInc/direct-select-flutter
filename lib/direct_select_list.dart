import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';

import './direct_select_container.dart';
import './direct_select_item.dart';

typedef DirectSelectItemsBuilder<T> = DirectSelectItem<T> Function(T value);

class PaddingItemController {
  GlobalKey paddingGlobalKey = RectGetter.createGlobalKey();
}

typedef ItemSelected = Future<dynamic> Function(DirectSelectList owner, double location);

/// Widget that contains items and responds to user's interaction
/// Usage Example
///
///     final dsl2 = DirectSelectList<String>(
///        values: _numbers,
///        itemBuilder: (String value) => getDropDownMenuItem(value),
///        focusedItemDecoration: _getDslDecoration());
///
class DirectSelectList<T> extends StatefulWidget {
  ///Item widgets
  final List<DirectSelectItem<T>> items;

  ///Current focused item overlay
  final Decoration focusedItemDecoration;

  ///Default selected item index
  final int defaultItemIndex;

  ///Notifies state about new item selected
  final ValueNotifier<int> selectedItem;

  ///Function to execute when item selected
  final Function(T value, int selectedIndex, BuildContext context) onItemSelectedListener;

  /// If true then LongPress is set to trigger the Drag instead of Tap (better in cases when you use DirectSelect inside of some Scrollable, ex. bottom sheet)
  final bool useLongPressGesture;

  ///Callback for action when user just tapped instead of hold and scroll
  final VoidCallback onUserTappedListener;

  ///Holds [GlobalKey] for [RectGetter]
  final PaddingItemController paddingItemController = PaddingItemController();

  DirectSelectList({
    Key key,
    @required List<T> values,
    @required DirectSelectItemsBuilder<T> itemBuilder,
    this.onItemSelectedListener,
    this.focusedItemDecoration,
    this.defaultItemIndex = 0,
    this.onUserTappedListener,
    this.useLongPressGesture = false,
  })  : items = values.map((val) => itemBuilder(val)).toList(),
        selectedItem = ValueNotifier<int>(defaultItemIndex),
        assert(defaultItemIndex + 1 <= values.length + 1),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectState<T>();
  }

  //TODO pass item height in this class and build items with that height
  double itemHeight() {
    if (items != null && items.isNotEmpty) {
      return items.first.itemHeight;
    }
    return 0.0;
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
  final GlobalKey<DirectSelectItemState> animatedStateKey = GlobalKey<DirectSelectItemState>();

  Future Function(DirectSelectList, double) onTapEventListener;
  void Function(double) onDragEventListener;

  bool isOverlayVisible = false;
  int lastSelectedItem;

  bool _isShowUpAnimationRunning = false;
  double longPressPosition;

  Map<int, Widget> selectedItemWidgets = Map();

  @override
  void initState() {
    super.initState();
    lastSelectedItem = widget.defaultItemIndex;
    _updateSelectItemWidget();
  }

  @override
  void didUpdateWidget(DirectSelectList oldWidget) {
    widget.paddingItemController.paddingGlobalKey = oldWidget.paddingItemController.paddingGlobalKey;
    _updateSelectItemWidget();
    super.didUpdateWidget(widget);
  }

  void _updateSelectItemWidget() {
    selectedItemWidgets.clear();
    for (int index = 0; index < widget.items.length; index++) {
      selectedItemWidgets.putIfAbsent(
        index,
        () => widget.items[index].getSelectedItem(
          animatedStateKey,
          widget.paddingItemController.paddingGlobalKey,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dsListener = DirectSelectContainer.of(context);
    assert(dsListener != null, "A DirectSelectList must inherit a DirectSelectContainer!");

    this.onTapEventListener = dsListener.toggleListOverlayVisibility;
    this.onDragEventListener = dsListener.performListDrag;
  }

  @override
  Widget build(BuildContext context) {
    widget.selectedItem.addListener(() {
      if (widget.onItemSelectedListener != null) {
        widget.onItemSelectedListener(widget.items[widget.selectedItem.value].value, widget.selectedItem.value, this.context);
      }
    });

    return ValueListenableBuilder<int>(
        valueListenable: widget.selectedItem,
        builder: (context, value, child) {
          final selectedItem = selectedItemWidgets[value];
          if (widget.useLongPressGesture) {
            return _buildGestureDetectorForLongPress(context, value, selectedItem);
          }
          return _buildGestureDetectorForDrag(context, value, selectedItem);
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
      //TODO fix to prevent stuck scale if selected item is the same as previous
      await onTapEventListener(widget, dy);
      if (lastSelectedItem == widget.selectedItem.value) {
        animatedStateKey.currentState.runScaleTransition(reverse: true);
      }
    }
  }

  _showListOverlay(double dy) {
    if (!isOverlayVisible) {
      isOverlayVisible = true;
      onTapEventListener(widget, _getItemTopPosition(context));
    } else {
      onDragEventListener(dy);
    }
  }

  _buildGestureDetectorForDrag(BuildContext context, int value, Widget child) {
    var transitionEnded = false;

    return GestureDetector(
        child: child,
        onTap: widget.onUserTappedListener,
        onTapDown: (tapDownDetails) async {
          if (!isOverlayVisible) {
            transitionEnded = false;
            _isShowUpAnimationRunning = true;
            await animatedStateKey.currentState.runScaleTransition(reverse: false);
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
  }

  _buildGestureDetectorForLongPress(BuildContext context, int value, Widget selectedItem) {
    var transitionEnded = false;
    return GestureDetector(
      child: selectedItem,
      onTap: widget.onUserTappedListener,
      onLongPressStart: (longPressDetails) async {
        if (!isOverlayVisible) {
          longPressPosition = longPressDetails.localPosition.dy;
          transitionEnded = false;
          _isShowUpAnimationRunning = true;
          await animatedStateKey.currentState.runScaleTransition(reverse: false);
          if (!transitionEnded) {
            await _showListOverlay(_getItemTopPosition(context));
            _isShowUpAnimationRunning = false;
            lastSelectedItem = value;
          }
        }
      },
      onLongPressEnd: (longPressEnd) async {
        await _hideListOverlay(_getItemTopPosition(context));
        animatedStateKey.currentState.runScaleTransition(reverse: true);
        transitionEnded = true;
        _dragEnd();
      },
      onLongPressMoveUpdate: (longPressDragDetails) async {
        if (!_isShowUpAnimationRunning) {
          final delta = longPressPosition - longPressDragDetails.localOffsetFromOrigin.dy;
          _showListOverlay(delta);
          longPressPosition = longPressDragDetails.localOffsetFromOrigin.dy;
        }
      },
      onLongPressUp: () {
        transitionEnded = true;
        _dragEnd();
      },
    );
  }
}
