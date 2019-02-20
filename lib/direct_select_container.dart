import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_direct_select/direct_select_list.dart';

class DirectSelectContainer extends StatefulWidget {
  final Widget child;
  final List<DirectSelectList> controls;
  final scaleFactor;
  final EdgeInsetsGeometry listPadding;
  final int dragSpeedMultiplier;

  const DirectSelectContainer({Key key,
    this.controls,
    this.child,
    this.scaleFactor = 4.0,
    this.dragSpeedMultiplier = 2,
    this.listPadding = const EdgeInsets.all(0)})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectContainerState();
  }
}

class DirectSelectContainerState extends State<DirectSelectContainer>
    with SingleTickerProviderStateMixin {
  bool isOverlayVisible = false;

  ScrollController _scrollController;
  DirectSelectList _currentList =
  DirectSelectList(itemBuilder: (val) => null, values: []);
  double _currentScrollLocation = 0;

  double _adjustedTopOffset = 0.0;

  AnimationController animationController;

  int lastSelectedItem = 0;

  double listPadding = 0;

  final scrollToListElementAnimationDuration = Duration(milliseconds: 300);
  final fadeAnimationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(duration: fadeAnimationDuration, vsync: this);

    for (DirectSelectList dsl in widget.controls) {
      dsl.refreshDefaultValue();

      dsl.setOnTapEventListener((owner, location) {
        _toggleListOverlayVisibility(owner, location);
      });

      dsl.setOnDragEvent((dragDy) {
        _performListDrag(dragDy);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double topOffset = 0.0;
    RenderObject object = context.findRenderObject();
    if (object != null) {
      if (object.parentData is ContainerBoxParentData) {
        topOffset = (object.parentData as ContainerBoxParentData).offset.dy;
      }
    }

    listPadding = MediaQuery
        .of(context)
        .size
        .height;

    _adjustedTopOffset = _currentScrollLocation - topOffset;
    _scrollController = ScrollController(
        initialScrollOffset: listPadding -
            _currentScrollLocation +
            topOffset +
            _currentList.getSelectedItemIndex() * _currentList.itemHeight());

    return Stack(
      children: <Widget>[
        widget.child,
        Visibility(
            visible: isOverlayVisible,
            child: FadeTransition(
              opacity:
              animationController.drive(CurveTween(curve: Curves.easeOut)),
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
            ))
      ],
    );
  }

  Widget _getListWidget() {
    return Container(
        color: Colors.white,
        child: ListView.builder(
          padding: widget.listPadding,
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

  void _performListDrag(double dragDy) {
    try {
      if (_scrollController != null && _scrollController.position != null) {
        final currentScrollOffset = _scrollController.offset;

        final scrollPosition =
            currentScrollOffset + dragDy * widget.dragSpeedMultiplier;
        if (_dragActionAllowed(scrollPosition + _adjustedTopOffset)) {
          _scrollController.jumpTo(scrollPosition);

          final scrollPixels =
              _scrollController.offset - listPadding + _adjustedTopOffset;
          final selectedItemIndex = _getCurrentListElementIndex(scrollPixels);
          lastSelectedItem = selectedItemIndex;

          _performScaleTransformation(scrollPixels, selectedItemIndex);
        }
      }
    } catch (e) {}
  }

  bool _dragActionAllowed(double scrollPosition) {
    if (scrollPosition < listPadding ||
        scrollPosition >
            (_currentList.items.length - 1) * _currentList.itemHeight() +
                listPadding) {
      return false;
    }
    return true;
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
      1.0 + distance / widget.scaleFactor;

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

  Future _toggleListOverlayVisibility(DirectSelectList visibleList,
      double location) async {
    if (isOverlayVisible == true) {
      try {
        await _scrollController.animateTo(
            listPadding -
                _adjustedTopOffset +
                lastSelectedItem * _currentList.itemHeight(),
            duration: scrollToListElementAnimationDuration,
            curve: Curves.ease);
      } catch (e) {} finally {
        _currentList.setSelectedItemIndex(lastSelectedItem);
        animationController.reverse().then((f) {
          setState(() {
            _hideListOverlay();
          });
        });
      }
    } else {
      setState(() {
        _showListOverlay(visibleList, location);
      });
    }
  }

  void _showListOverlay(DirectSelectList visibleList, double location) {
    _currentList = visibleList;
    _currentScrollLocation = location;
    lastSelectedItem = _currentList.getSelectedItemIndex();
    _currentList.items[lastSelectedItem].updateOpacity(1.0);
    isOverlayVisible = true;
    animationController.forward(from: 0.0);
  }

  void _hideListOverlay() {
    _scrollController.dispose();
    _scrollController = null;
    _currentList.items[lastSelectedItem].updateScale(1.0);
    _currentScrollLocation = 0;
    _adjustedTopOffset = 0;

    isOverlayVisible = false;
  }
}
