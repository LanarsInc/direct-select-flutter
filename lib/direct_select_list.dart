import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef DirectSelectItemsBuilder<T> = DirectSelectItem<T>? Function(T value);

class PaddingItemController {
  GlobalKey paddingGlobalKey = GlobalKey();

  /// Bounds of the selected item in global coordinates, or null while it is not laid out yet
  Rect? get paddingItemRect {
    final renderObject = paddingGlobalKey.currentContext?.findRenderObject();
    if (renderObject == null || !renderObject.attached) {
      return null;
    }
    final topLeft = MatrixUtils.transformPoint(
      renderObject.getTransformTo(null),
      Offset.zero,
    );
    return topLeft & renderObject.semanticBounds.size;
  }
}

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
  ///Item widgets
  final List<DirectSelectItem<T>> items;

  ///Current focused item overlay
  final Decoration? focusedItemDecoration;

  ///Default selected item index
  final int defaultItemIndex;

  ///Notifies state about new item selected
  final ValueNotifier<int> selectedItem;

  ///Function to execute when item selected
  final Function(T value, int selectedIndex, BuildContext context)?
      onItemSelectedListener;

  ///Callback for action when user just tapped instead of hold and scroll
  final VoidCallback? onUserTappedListener;

  ///Holds [GlobalKey] used to measure the selected item position
  final PaddingItemController paddingItemController = PaddingItemController();

  DirectSelectList({
    Key? key,
    required List<T> values,
    required DirectSelectItemsBuilder<T> itemBuilder,
    this.onItemSelectedListener,
    this.focusedItemDecoration,
    this.defaultItemIndex = 0,
    this.onUserTappedListener,
  })  : items = values.map((val) => itemBuilder(val)).toNotNullableList(),
        selectedItem = ValueNotifier<int>(defaultItemIndex),
        assert(defaultItemIndex + 1 <= values.length + 1),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectState<T>();
  }

  //TODO pass item height in this class and build items with that height
  double itemHeight() {
    if (items.isNotEmpty) {
      return items.first.itemHeight;
    }
    return 0.0;
  }

  int getSelectedItemIndex() {
    return selectedItem.value;
  }

  void setSelectedItemIndex(int index) {
    if (index != selectedItem.value) {
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

  late Future Function(DirectSelectList, double) onOverlayShowRequested;
  late Future Function(double) onOverlayHideRequested;
  late void Function(double) onDragEventListener;

  bool isOverlayVisible = false;
  int? lastSelectedItem;

  bool _isShowUpAnimationRunning = false;

  Map<int, Widget> selectedItemWidgets = Map();

  @override
  void initState() {
    super.initState();
    lastSelectedItem = widget.defaultItemIndex;
    _updateSelectItemWidget();
  }

  @override
  void didUpdateWidget(DirectSelectList oldWidget) {
    widget.paddingItemController.paddingGlobalKey =
        oldWidget.paddingItemController.paddingGlobalKey;
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

    this.onOverlayShowRequested = dsListener.showListOverlay;
    this.onOverlayHideRequested = dsListener.hideListOverlay;
    this.onDragEventListener = dsListener.performListDrag;
  }

  @override
  Widget build(BuildContext context) {
    widget.selectedItem.addListener(() {
      if (widget.onItemSelectedListener != null) {
        widget.onItemSelectedListener?.call(
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
              onTap: () {
                if (widget.onUserTappedListener != null) {
                  widget.onUserTappedListener?.call();
                }
              },
              onTapDown: (tapDownDetails) async {
                if (!isOverlayVisible) {
                  transitionEnded = false;
                  _isShowUpAnimationRunning = true;
                  await animatedStateKey.currentState
                      ?.runScaleTransition(reverse: false);
                  _isShowUpAnimationRunning = false;
                  if (!transitionEnded) {
                    await _showListOverlay(_getItemTopPosition(context));
                    lastSelectedItem = value;
                  }
                }
              },
              onTapUp: (tapUpDetails) async {
                await _hideListOverlay(_getItemTopPosition(context));
                animatedStateKey.currentState
                    ?.runScaleTransition(reverse: true);
              },
              onVerticalDragEnd: (dragDetails) async {
                transitionEnded = true;
                _dragEnd();
              },
              onVerticalDragCancel: () {
                transitionEnded = true;
                _isShowUpAnimationRunning = false;
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
    animatedStateKey.currentState?.runScaleTransition(reverse: true);
  }

  double _getItemTopPosition(BuildContext context) {
    final RenderBox itemBox = context.findRenderObject() as RenderBox;
    final Rect itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;
    return itemRect.top;
  }

  _hideListOverlay(double dy) async {
    if (isOverlayVisible) {
      isOverlayVisible = false;
      //TODO fix to prevent stuck scale if selected item is the same as previous
      await onOverlayHideRequested(dy);
      if (lastSelectedItem == widget.selectedItem.value) {
        animatedStateKey.currentState?.runScaleTransition(reverse: true);
      }
    }
  }

  _showListOverlay(double? dy) {
    if (!isOverlayVisible) {
      isOverlayVisible = true;
      onOverlayShowRequested(widget, _getItemTopPosition(context));
    } else if (dy != null) {
      onDragEventListener(dy);
    }
  }
}

extension _ListHelper on Iterable {
  List<T> toNotNullableList<T>() {
    var data = this.toList();
    return data.contains(null) ? List<T>.empty() : data.cast<T>();
  }
}
