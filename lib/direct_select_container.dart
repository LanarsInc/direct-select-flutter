import 'dart:async';

import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:rect_getter/rect_getter.dart';

/// Root widget for direct select.
/// This widget displays lists of direct selects.
/// Usage Example
///
///    return Scaffold(
///      body: DirectSelectContainer(
///        child: Padding(
///          padding: const EdgeInsets.all(16.0),
///          child: Column(
///            mainAxisSize: MainAxisSize.min,
///            verticalDirection: VerticalDirection.down,
///            children: <Widget>[
///              SizedBox(height: 150.0),
///              Padding(
///                padding: const EdgeInsets.all(8.0),
///                child: Column(
///                  children: <Widget>[
///                    Container(
///                        alignment: AlignmentDirectional.centerStart,
///                        margin: EdgeInsets.only(left: 4),
///                        child: Text("City")),
///                    Padding(
///                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
///                      child: Card(
///                          child: Row(
///                        mainAxisSize: MainAxisSize.max,
///                        children: <Widget>[
///                          Expanded(
///                              child: Padding(
///                                  child: DirectSelectList<String>(
///                                  values: _cities,
///                                  defaultItemIndex: 3,
///                                   itemBuilder: (String value) => getDropDownMenuItem(value),
///                                   focusedItemDecoration: _getDslDecoration(),
///                                   onItemSelectedListener: (item, context) {
///                                       Scaffold.of(context).showSnackBar(SnackBar(content: Text(item)));
///                                   }),
///                                  padding: EdgeInsets.only(left: 12))),
///                          Padding(
///                            padding: EdgeInsets.only(right: 8),
///                            child: Icon(
///                              Icons.unfold_more,
///                              color: Colors.black38,
///                            ),
///                          )
///                        ],
///                      )),
///                    ),
///                  ],
///                ),
///              ),
///            ],
///          ),
///        ),
///      ),
///    );
///
class DirectSelectContainer extends StatefulWidget {
  ///Actually content of screen
  final Widget child;

  ///How fast list is scrolled
  final int dragSpeedMultiplier;

  ///Decoration for the DSL container
  final Decoration? decoration;

  const DirectSelectContainer({
    Key? key,
    required this.child,
    this.dragSpeedMultiplier = 2,
    this.decoration,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectContainerState();
  }

  static DirectSelectGestureEventListeners of(BuildContext context) {
    if (context.dependOnInheritedWidgetOfExactType<
            _InheritedContainerListeners>() ==
        null) {
      throw Exception(
          "A DirectSelectList must inherit a DirectSelectContainer!");
    }
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedContainerListeners>()!
        .listeners;
  }
}

class DirectSelectContainerState extends State<DirectSelectContainer>
    with SingleTickerProviderStateMixin
    implements DirectSelectGestureEventListeners {
  bool isOverlayVisible = false;

  late ScrollController _scrollController;
  DirectSelectList _currentList =
      DirectSelectList(itemBuilder: (val) => null, values: []);
  double _currentScrollLocation = 0;

  double _adjustedTopOffset = 0.0;

  late AnimationController fadeAnimationController;

  int lastSelectedItem = 0;

  double listPadding = 0.0;

  final scrollToListElementAnimationDuration = Duration(milliseconds: 200);
  final fadeAnimationDuration = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();

    fadeAnimationController = AnimationController(
      duration: fadeAnimationDuration,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    double topOffset = 0.0;
    RenderObject? object = context.findRenderObject();
    if (object?.parentData is ContainerBoxParentData) {
      topOffset = (object!.parentData as ContainerBoxParentData).offset.dy;
    }

    listPadding = MediaQuery.of(context).size.height;

    _adjustedTopOffset = _currentScrollLocation - topOffset;
    _scrollController = ScrollController(
        initialScrollOffset: listPadding -
            _currentScrollLocation +
            topOffset +
            _currentList.getSelectedItemIndex() * _currentList.itemHeight());

    return Stack(
      children: <Widget>[
        _InheritedContainerListeners(
          listeners: this,
          child: widget.child,
        ),
        Visibility(
          visible: isOverlayVisible,
          child: FadeTransition(
            opacity: fadeAnimationController
                .drive(CurveTween(curve: Curves.easeOut)),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      _getListWidget(),
                      _getSelectionOverlayWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _getListWidget() {
    var paddingLeft = 0.0;

    if (_currentList.items.isNotEmpty) {
      Rect? rect = RectGetter.getRectFromKey(
          _currentList.paddingItemController.paddingGlobalKey);
      if (rect != null) {
        paddingLeft = rect.left;
      }
    }

    final Decoration dslContainerDecoration = widget.decoration ??
        BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor);

    return Container(
        decoration: dslContainerDecoration,
        child: ListView.builder(
          padding: EdgeInsets.only(left: paddingLeft),
          controller: _scrollController,
          itemCount: _currentList.items.length + 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0 || index == _currentList.items.length + 1) {
              return Container(height: listPadding);
            }
            final item = _currentList.items[index - 1];
            final normalScale = 1.0;
            if (lastSelectedItem == index - 1) {
              item.updateScale(_calculateNewScale(normalScale));
            } else {
              item.updateScale(normalScale);
            }
            return item;
          },
        ));
  }

  Widget _getSelectionOverlayWidget() {
    return Positioned(
        top: _adjustedTopOffset,
        left: 0,
        right: 0,
        height: _currentList.itemHeight(),
        child: Container(
            height: _currentList.itemHeight(),
            decoration: _currentList.focusedItemDecoration != null
                ? _currentList.focusedItemDecoration
                : BoxDecoration()));
  }

  void performListDrag(double dragDy) {
    try {
      if (_scrollController.hasClients) {
        final currentScrollOffset = _scrollController.offset;
        double allowedOffset = _allowedDragDistance(
            currentScrollOffset + _adjustedTopOffset,
            dragDy * widget.dragSpeedMultiplier);
        if (allowedOffset != 0.0) {
          _scrollController.jumpTo(currentScrollOffset + allowedOffset);

          final scrollPixels =
              _scrollController.offset - listPadding + _adjustedTopOffset;
          final selectedItemIndex = _getCurrentListElementIndex(scrollPixels);
          lastSelectedItem = selectedItemIndex;

          _performScaleTransformation(scrollPixels, selectedItemIndex);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  double _allowedDragDistance(double currentScrollOffset, double position) {
    double newPosition = currentScrollOffset + position;
    double endOfListPosition =
        (_currentList.items.length - 1) * _currentList.itemHeight() +
            listPadding;
    if (newPosition < listPadding) {
      return listPadding - currentScrollOffset;
    } else if (newPosition > endOfListPosition) {
      return endOfListPosition - currentScrollOffset;
    } else {
      return position;
    }
  }

  void _performScaleTransformation(double scrollPixels, int selectedItemIndex) {
    final neighbourDistance = _getNeighbourListElementDistance(scrollPixels);
    int neighbourIncrementDirection =
        neighbourScrollDirection(neighbourDistance);

    int neighbourIndex = lastSelectedItem + neighbourIncrementDirection;

    double neighbourDistanceToCurrentItem =
        _getNeighbourListElementDistanceToCurrentItem(neighbourDistance);

    if (neighbourIndex < 0 || neighbourIndex > _currentList.items.length - 1) {
      //incorrect neighbour index quit
      return;
    }
    _currentList.items[selectedItemIndex].updateOpacity(1.0);
    _currentList.items[neighbourIndex].updateOpacity(0.5);

    _currentList.items[selectedItemIndex]
        .updateScale(_calculateNewScale(neighbourDistanceToCurrentItem));
    _currentList.items[neighbourIndex]
        .updateScale(_calculateNewScale(neighbourDistance.abs()));
  }

  double _calculateNewScale(double distance) =>
      1.0 + distance / _currentList.items[lastSelectedItem].scaleFactor;

  int neighbourScrollDirection(double neighbourDistance) {
    int neighbourScrollDirection = 0;
    if (neighbourDistance > 0) {
      neighbourScrollDirection = 1;
    } else {
      neighbourScrollDirection = -1;
    }
    return neighbourScrollDirection;
  }

  double _getNeighbourListElementDistanceToCurrentItem(
      double neighbourDistance) {
    double neighbourDistanceToCurrentItem = (1 - neighbourDistance.abs());

    if (neighbourDistanceToCurrentItem > 1 ||
        neighbourDistanceToCurrentItem < 0) {
      neighbourDistanceToCurrentItem = 1.0;
    }
    return neighbourDistanceToCurrentItem;
  }

  int _getCurrentListElementIndex(double scrollPixels) {
    int selectedElement = (scrollPixels / _currentList.itemHeight()).round();
    final maxElementIndex = _currentList.items.length;

    if (selectedElement < 0) {
      selectedElement = 0;
    }
    if (selectedElement >= maxElementIndex) {
      selectedElement = maxElementIndex - 1;
    }
    return selectedElement;
  }

  double _getNeighbourListElementDistance(double scrollPixels) {
    double selectedElementDeviation =
        (scrollPixels / _currentList.itemHeight());
    int selectedElement = _getCurrentListElementIndex(scrollPixels);
    return selectedElementDeviation - selectedElement;
  }

  Future toggleListOverlayVisibility(
      DirectSelectList visibleList, double location) async {
    if (isOverlayVisible) {
      try {
        await _scrollController.animateTo(
          listPadding -
              _adjustedTopOffset +
              lastSelectedItem * _currentList.itemHeight(),
          duration: scrollToListElementAnimationDuration,
          curve: Curves.ease,
        );
      } catch (e) {} finally {
        _currentList.setSelectedItemIndex(lastSelectedItem);
        await Future.delayed(Duration(milliseconds: 200));
        await fadeAnimationController.reverse();
        setState(() {
          _hideListOverlay();
        });
      }
    } else {
      setState(() {
        _showListOverlay(visibleList, location);
      });
    }
  }

  _showListOverlay(DirectSelectList visibleList, double location) async {
    _currentList = visibleList;
    _currentScrollLocation = location;
    lastSelectedItem = _currentList.getSelectedItemIndex();
    _currentList.items[lastSelectedItem].updateOpacity(1.0);
    isOverlayVisible = true;
    await fadeAnimationController.forward(from: 0.0);
  }

  void _hideListOverlay() {
    _scrollController.dispose();
    _currentList.items[lastSelectedItem].updateScale(1.0);
    _currentScrollLocation = 0;
    _adjustedTopOffset = 0;
    isOverlayVisible = false;
  }
}

class DirectSelectGestureEventListeners {
  toggleListOverlayVisibility(DirectSelectList list, double location) =>
      throw 'Not implemented.';

  performListDrag(double dragDy) => throw 'Not implemented';
}

/// Allows Direct Select List implementations to
class _InheritedContainerListeners extends InheritedWidget {
  final DirectSelectGestureEventListeners listeners;

  _InheritedContainerListeners({
    Key? key,
    required this.listeners,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedContainerListeners old) =>
      old.listeners != listeners;
}
