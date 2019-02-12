import 'package:flutter/material.dart';

const double _kMenuItemHeight = 48.0;
const double _kItemsOffset = 2;

class DirectSelectList<T> extends StatefulWidget {
  final List<Widget> items;

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
  void initState() {
    super.initState();
    _scrollController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      //padding from bottom and top to make sure all elements are reachable
      final padding = _kMenuItemHeight * widget.items.length * 2;

      final RenderBox itemBox = context.findRenderObject();
      final Rect itemRect = itemBox.localToGlobal(Offset(0, 0)) & itemBox.size;
      final topOffset = (itemRect.top) - 88;

      print("OFFFFFSET is" + topOffset.toString());

      _scrollController = ScrollController(
          initialScrollOffset: padding +
              selectedItemIndex * _kMenuItemHeight +
              selectedItemIndex * _kItemsOffset);

      final listview = ListView.builder(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(0, padding, 0, padding),
        itemCount: widget.items.length,
        itemBuilder: (context, position) {
          return GestureDetector(
              onTap: () {
                selectedItemIndex = position;
                _toggleExpand();
              },
              child: widget.items[position]);
        },
      );

      return Stack(
        children: <Widget>[
          listview,
          Container(
              margin: EdgeInsets.fromLTRB(0, topOffset, 0, 0),
              height: _kMenuItemHeight,
              decoration: BoxDecoration(color: Colors.black38)),
        ],
      );
    } else {
      return GestureDetector(
          child: widget.items[selectedItemIndex], onTap: () => _toggleExpand());
    }
  }

  _toggleExpand() {
    print("tapped");
    setState(() {
      expanded = !expanded;
    });
  }
}

class DirectSelectItem<T> extends StatelessWidget {
  final T value;
  final Widget child;

  const DirectSelectItem({
    Key key,
    this.value,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.fromLTRB(0, _kItemsOffset, 0, 0),
        child: Container(
            child: child,
            alignment: AlignmentDirectional.centerStart,
            height: _kMenuItemHeight));
  }
}
