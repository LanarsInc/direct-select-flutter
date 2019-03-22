import 'dart:async';

import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/widgets.dart';

class DirectSelectControlsContainer extends StatefulWidget {
  final Widget child;

  DirectSelectControlsContainer({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ControlsState();

  static _ControlsState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedControlState)
          as _InheritedControlState)
      .data;
  }

}

class _ControlsState extends State<DirectSelectControlsContainer> {
  
  StreamController<DirectSelectList> _controlStreamController;
  Stream<DirectSelectList> get outController => _controlStreamController.stream; 
  Sink<DirectSelectList> get _inController => _controlStreamController.sink; 

  @override
  void initState() {
    super.initState();
    _controlStreamController = StreamController<DirectSelectList>();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedControlState(
      data: this,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controlStreamController.close();
    super.dispose();
  }

  addControl(DirectSelectList control) => addControls([control]);

  addControls(List<DirectSelectList> controlsToAdd) {
    for(final control in controlsToAdd)
      _inController.add(control);
  }
}

/// Provides a list of DirectSelectLists
class _InheritedControlState extends InheritedWidget {
  final _ControlsState data;

  _InheritedControlState({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(
    key: key,
    child: child
  );

  @override
  bool updateShouldNotify(_InheritedControlState old) => old.data != data;
}