import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_direct_select/direct_select_list.dart';

class DirectSelectContainer extends StatefulWidget {
  final Widget child;
  final List<DirectSelectList> controls;

  const DirectSelectContainer({Key key, this.controls, this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectContainerState();
  }
}

//todo better padding calculation
const listPadding = 500.0;

class DirectSelectContainerState extends State<DirectSelectContainer>
    with SingleTickerProviderStateMixin {
  double scaleFactor = 3.0;

  bool isOverlayVisible = false;

  ScrollController _scrollController;
  DirectSelectList _currentList = DirectSelectList(items: []);
  double _currentScrollLocation = 0;

  double _adjustedTopOffset = 0.0;

  AnimationController animationController;

  int lastSelectedItem = 0;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);

    for (DirectSelectList dsl in widget.controls) {
      dsl.setOnTapEventListener((owner, location) {
        setVisible(owner, location);
      });

      dsl.setOnDragEvent((dragDy) {
        try {
          if (_scrollController != null && _scrollController.position != null) {
            final offset = _scrollController.offset;
            _scrollController.jumpTo(offset + dragDy);

            final scrollPixels =
                _scrollController.offset - listPadding + _adjustedTopOffset;
            final selectedItemIndex = getCurrentElementIndex(scrollPixels);
            _currentList.setSelectedItemIndex(selectedItemIndex);

            _currentList.items[lastSelectedItem].updateScale(1.0);
            lastSelectedItem = selectedItemIndex;

            final neighbourDistance = getNeighbourDistance(scrollPixels);
            int neighbourIncrementDirection = 0;
            if (neighbourDistance > 0) {
              neighbourIncrementDirection = 1;
            } else {
              neighbourIncrementDirection = -1;
            }
            int neighbourIndex = lastSelectedItem + neighbourIncrementDirection;
            double neighbourDistanceToCurrentItem =
            (1 - neighbourDistance.abs());

            if (neighbourDistanceToCurrentItem > 1 ||
                neighbourDistanceToCurrentItem < 0) {
              neighbourDistanceToCurrentItem = 1.0;
            }

            bool updateScale = true;
            if (neighbourIndex < 0) {
              updateScale = false;
            }

            if (neighbourIndex > _currentList.items.length - 1) {
              updateScale = false;
            }

            if (updateScale) {
              _currentList.items[selectedItemIndex].updateScale(
                  1.0 + neighbourDistanceToCurrentItem / scaleFactor);
              _currentList.items[neighbourIndex]
                  .updateScale(1.0 + neighbourDistance.abs() / scaleFactor);
            } else {
              _currentList.items[selectedItemIndex]
                  .updateScale(1.0 + 1.0 / scaleFactor);
            }
          }
        } catch (e) {}
      });
    }
  }

  int getCurrentElementIndex(double scrollPixels) {
    int selectedElement = (scrollPixels / _currentList.itemHeight).round();
    final maxElementIndex = _currentList.items.length;

    if (selectedElement < 0) {
      selectedElement = 0;
    }
    if (selectedElement >= maxElementIndex) {
      selectedElement = maxElementIndex - 1;
    }
    return selectedElement;
  }

  double getNeighbourDistance(double scrollPixels) {
    double selectedElementDeviation = (scrollPixels / _currentList.itemHeight);
    int selectedElement = getCurrentElementIndex(scrollPixels);
    return selectedElementDeviation - selectedElement;
  }

  Future setVisible(DirectSelectList visibleList, double location) async {
    if (isOverlayVisible == true) {
      try {
        await _scrollController.animateTo(
            listPadding -
                _adjustedTopOffset +
                _currentList.getSelectedItemIndex() * _currentList.itemHeight,
            duration: Duration(milliseconds: 300),
            curve: Curves.ease);
      } catch (e) {} finally {
        _currentList.commitSelection();
        animationController.duration = Duration(milliseconds: 300);
        animationController.reverse().then((f) {
          setState(() {
            _scrollController.dispose();
            _scrollController = null;
            _currentList.items[lastSelectedItem].scale = 1.0;
            _currentScrollLocation = 0;
            _adjustedTopOffset = 0;

            isOverlayVisible = false;
          });
        });
      }
    } else {
      setState(() {
        _currentList = visibleList;
        _currentScrollLocation = location;
        lastSelectedItem = _currentList.getSelectedItemIndex();
        isOverlayVisible = true;
        animationController.duration = Duration(milliseconds: 300);
        animationController.forward(from: 0.0);
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

    _adjustedTopOffset = _currentScrollLocation - topOffset;
    _scrollController = ScrollController(
        initialScrollOffset: listPadding -
            _currentScrollLocation +
            topOffset +
            _currentList.getSelectedItemIndex() * _currentList.itemHeight);

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
                        Container(
                            color: Colors.white,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _currentList.items.length + 2,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0 ||
                                    index == _currentList.items.length + 1) {
                                  return Container(height: listPadding);
                                }
                                final item = _currentList.items[index - 1];
                                if (lastSelectedItem == index - 1) {
                                  item.scale = 1.0 + 1.0 / scaleFactor;
                                } else {
                                  item.scale = 1.0;
                                }
                                return item;
                              },
                            )),
                        Positioned(
                          top: _adjustedTopOffset,
                          left: 0,
                          right: 0,
                          height: _currentList.itemHeight,
                          child: Container(
                            height: _currentList.itemHeight,
                            decoration:
                            _currentList.focusedItemDecoration != null
                                ? _currentList.focusedItemDecoration
                                : BoxDecoration(),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ))
      ],
    );
  }
}