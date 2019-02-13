import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const double _kMenuItemHeight = 48.0;
const double _kItemsOffset = 2;

class DirectSelectList<T> extends StatefulWidget {
  final List<DirectSelectItem> items;

  const DirectSelectList({Key key, @required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DirectSelectState();
  }
}

class DirectSelectState<T> extends State<DirectSelectList<T>> {
  var expanded = false;

  var selectedItemIndex = 0;

  var _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      final RenderBox itemBox = this.context.findRenderObject();

      //offset from button to parent's top
      double topOffset = 0;
      //parent's padding from top
      double topPadding = 0;
      //padding for all elements could fit
      double scrollPadding = 0;

      double height = MediaQuery
          .of(context)
          .size
          .height;
      final RenderPadding paddingRender =
      context.ancestorRenderObjectOfType(TypeMatcher<RenderPadding>());
      if (paddingRender != null) {
        topPadding = paddingRender.padding.vertical / 2;
        // scrollPadding = padding;
      }

      if (itemBox.parentData is BoxParentData) {
        final BoxParentData parentData = itemBox.parentData as BoxParentData;
        topOffset = (parentData.offset.dy);
        if (itemBox.parent is RenderPadding) {
          topOffset = topOffset - topPadding;
        }
      }


      //very efemerical calculations
      final idealScale = 48.0 / 100;
      final y = idealScale * 100;
      final z = 0; //((topPadding - 10.0) * 10.0 / 100);
      double padding = y * 5 - ((_kMenuItemHeight - 48.0) * idealScale);

      final initialPadding = padding - topOffset;
      _scrollController = ScrollController(
          initialScrollOffset:
          initialPadding + selectedItemIndex * _kMenuItemHeight);

      double paddingBottom = padding;
      print(padding.toString());
      if (topOffset < padding) {
        paddingBottom = padding * 2;
      }

      final itemCount = widget.items.length + 2;
      final listView = ListView.builder(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        itemCount: itemCount,
        itemBuilder: (context, position) {
          if (position == 0) {
            return Container(height: padding);
          }
          if (position == itemCount - 1) {
            return Container(height: paddingBottom);
          }
          return GestureDetector(
              onTap: () {
                selectedItemIndex = position - 1;
                _toggleExpand();
              },
              child: widget.items[position - 1]);
        },
      );

      return Stack(
        children: <Widget>[
          NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  int selectedElement =
                  getCurrentElementIndex(
                      scrollNotification, padding, topOffset);

//                  (widget.items[selectedElement] as DirectSelectItem)
//                      .state
//                      .animation
//                      .reset();
//                  (widget.items[selectedElement] as DirectSelectItem)
//                      .state
//                      .animation
//                      .forward();
                }
                if (scrollNotification is ScrollEndNotification) {
                  final scrollPixels = scrollNotification.metrics.pixels;
                  final maxElementIndex = widget.items.length;

                  int selectedElement =
                  getCurrentElementIndex(
                      scrollNotification, padding, topOffset);

                  if (selectedElement < maxElementIndex) {
                    selectedItemIndex = selectedElement;
                    final selectedElementPosition =
                        initialPadding + selectedItemIndex * _kMenuItemHeight;

                    widget.items[selectedItemIndex].state.setSelected();

                    if (selectedElementPosition != scrollPixels) {
                      Future.delayed(Duration.zero, () {
                        if (_scrollController != null) {
                          _scrollController
                              .animateTo(selectedElementPosition,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease)
                              .then((onValue) {
                            _scrollController = null;
                            _toggleExpand();
                          });
                        }
                      });
                    }
                  }
                }
              },
              child: listView),
          Container(
              margin: EdgeInsets.fromLTRB(0, topOffset, 0, 0),
              height: _kMenuItemHeight,
              decoration:
              BoxDecoration(color: Colors.greenAccent.withOpacity(0.3))),
        ],
      );
    } else {
      return Container(
        child: GestureDetector(
            child: widget.items[selectedItemIndex],
            onTapDown: (tapDetail) => _toggleExpand()),
      );
    }
  }

  int getCurrentElementIndex(ScrollNotification scrollNotification,
      double padding, double topOffset) {
    double scrollPixels = scrollNotification.metrics.pixels;

//    if (topOffset - scrollPixels < 0) {
//      scrollPixels = scrollNotification.metrics.pixels - topOffset;
//    }

    int selectedElement = (scrollPixels / _kMenuItemHeight).round();
    final maxElementIndex = widget.items.length;

    if (selectedElement < 0) {
      selectedElement = 0;
    }
    print(selectedElement.toString());
    if (selectedElement >= maxElementIndex) {
      selectedElement = maxElementIndex - 1;
    }
    return selectedElement;
  }

  _toggleExpand() {
    setState(() {
      expanded = !expanded;
    });
  }
}

class DirectSelectItem<T> extends StatefulWidget {
  final T value;
  final Widget child;
  DirectSelectItemState state;

  DirectSelectItem({Key key, this.value, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = DirectSelectItemState(value, child);
    return state;
  }
}

class DirectSelectItemState<T> extends State<DirectSelectItem<T>>
    with SingleTickerProviderStateMixin {
  final T value;
  final Widget child;

  AnimationController animation;

  DirectSelectItemState(this.value, this.child);

  bool isSelected = false;

  int opacity = 0;

  @override
  void initState() {
    super.initState();
    animation = new AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
        animationBehavior: AnimationBehavior.normal);

    animation.addListener(() {
      setState(() {});
    });
  }

  void setSelected() {
    setState(() {
      isSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: child,
        decoration: isSelected ? BoxDecoration(
            color: Colors.redAccent.withOpacity(0.3)) : BoxDecoration(
            color: Colors.black38),
        alignment: AlignmentDirectional.centerStart,
        height: _kMenuItemHeight);

//    return AnimatedBuilder(
//      animation: animation,
//      child: child,
//      builder: (BuildContext context, Widget child) {
//
//        double opacity = animation.value;
//        if (opacity != 0) {
//          return Container(
//              child: child,
//              decoration: BoxDecoration(color: Colors.green.withOpacity(opacity)),
//              alignment: AlignmentDirectional.centerStart,
//              height: _kMenuItemHeight);
//        } else {
//          return Container(
//              child: child,
//              decoration: BoxDecoration(color: Colors.black38),
//              alignment: AlignmentDirectional.centerStart,
//              height: _kMenuItemHeight);
//        }
//      },
//    );
  }

  @override
  void dispose() {
    animation.dispose();
  }
}
