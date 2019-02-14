import 'package:flutter/material.dart';
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

class DirectSelectContainerState extends State<DirectSelectContainer> {
  bool isOverlayVisible = false;

  ScrollController _scrollController;
  DirectSelectList _currentList = DirectSelectList(items: []);

  @override
  void initState() {
    super.initState();
    for (DirectSelectList dsl in widget.controls) {
      dsl.addOnTapEvent((owner) {
        setVisible(owner);
      });
      dsl.addOnDragEvent((dragDy) {
        try {
          if (_scrollController != null && _scrollController.position != null) {
            print(dragDy);
            _scrollController.jumpTo(dragDy);
          }
        } catch (Exception) {}
      });
    }
  }

  void setVisible(DirectSelectList visibleList) {
    setState(() {
      _currentList = visibleList;
      if (isOverlayVisible == true) {
        if (_scrollController != null) {
          _scrollController.dispose();
          _scrollController = null;
        }
      }
      isOverlayVisible = !isOverlayVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    _scrollController = ScrollController();

    return Stack(
      children: <Widget>[
        widget.child,
        Visibility(
            visible: isOverlayVisible,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                          color: Colors.white,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _currentList.items.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                  child: _currentList.items[index]);
                            },
                          )),
                      Container(
                        height: 48,
                        padding: EdgeInsets.fromLTRB(0, 120, 0, 0),
                        color: Colors.greenAccent.withOpacity(0.3),
                      )
                    ],
                  ),
                ),
              ],
            ))
      ],
    );
  }
}
