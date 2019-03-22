import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_control.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

List<String> _meals = [
  "Breakfast1",
  "Breakfast2",
  "Lunch1",
  "Lunch2",
  "Dinner1",
  "Dinner2",
];

class _MyHomePageState extends State<MyHomePage> {

  List<String> _food = ["Chicken", "Pork", "Vegetables", "Cheese", "Bread"];

  List<String> _foodVariants = [
    "Chicken grilled",
    "Pork grilled",
    "Vegetables as is",
    "Cheese as is",
    "Bread tasty"
  ];

  List<String> _portionSize = [
    "Small portion",
    "Medium portion",
    "Large portion",
    "Huge portion"
  ];

  List<String> _numbers = ["1.0", "2.0", "3.0", "4.0", "5.0", "6.0", "7.0"];

  int selectedFoodVariants = 0;
  int selectedPortionCounts = 0;
  int selectedPortionSize = 0;

  DirectSelectItem<String> getDropDownMenuItem(String value) {
    return DirectSelectItem<String>(
        itemHeight: 56,
        value: value,
        itemBuilder: (context, value) {
          return Text(value);
        });
  }

  _getDslDecoration() {
    return BoxDecoration(
      border: BorderDirectional(
        bottom: BorderSide(width: 1, color: Colors.black12),
        top: BorderSide(width: 1, color: Colors.black12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = PreferredSize(
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(246, 247, 249, 1),
              border: BorderDirectional(
                  bottom: BorderSide(width: 1, color: Colors.black12))),
          child: Padding(
              padding: EdgeInsets.only(left: 16, bottom: 24),
              child: Column(
                  verticalDirection: VerticalDirection.up,
                  children: <Widget>[
                    Container(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("Add Food",
                            style: TextStyle(
                                fontSize: 26,
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    Container(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("Journal",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                                fontWeight: FontWeight.bold)))
                  ])),
        ),
        preferredSize: Size.fromHeight(90));

    final dsl2 = DirectSelectList<String>(
      values: _food,
      itemBuilder: (String value) => getDropDownMenuItem(value),
      focusedItemDecoration: _getDslDecoration(),
    );

    final dsl3 = DirectSelectList<String>(
        values: _foodVariants,
        defaultItemIndex: selectedFoodVariants,
        itemBuilder: (String value) => getDropDownMenuItem(value),
        focusedItemDecoration: _getDslDecoration(),
        onItemSelectedListener: (item, index, context) {
          setState(() {
            selectedFoodVariants = index;
          });
        });

    final dsl4 = DirectSelectList<String>(
        values: _numbers,
        defaultItemIndex: selectedPortionCounts,
        itemBuilder: (String value) => getDropDownMenuItem(value),
        focusedItemDecoration: _getDslDecoration(),
        onItemSelectedListener: (item, index, context) {
          setState(() {
            selectedPortionCounts = index;
          });
        });

    final dsl5 = DirectSelectList<String>(
        values: _portionSize,
        defaultItemIndex: selectedPortionSize,
        itemBuilder: (String value) => getDropDownMenuItem(value),
        focusedItemDecoration: _getDslDecoration(),
        onItemSelectedListener: (item, index, context) {
          setState(() {
            selectedPortionSize = index;
          });
        });

    return Scaffold(
      appBar: appBar,
      body: DirectSelectControlsContainer(
        child: DirectSelectContainer(
        controls: [dsl2, dsl3, dsl4, dsl5],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                SizedBox(height: 20.0),
                Container(
                    padding: const EdgeInsets.only(left: 8.0),
                    alignment: AlignmentDirectional.centerStart,
                    margin: EdgeInsets.only(left: 4),
                    child: Column(
                      children: <Widget>[
                        Text(_foodVariants[selectedFoodVariants],
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold))
                      ],
                    )),
                Container(
                    padding: const EdgeInsets.only(left: 8.0),
                    alignment: AlignmentDirectional.centerStart,
                    margin: EdgeInsets.only(left: 4),
                    child: Column(
                      children: <Widget>[
                        Text(_numbers[selectedPortionCounts] + "   " +
                            _portionSize[selectedPortionSize])
                      ],
                    )),
                SizedBox(height: 5.0),
                _getFoodContainsRow(),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      MealSelector(),
                      SizedBox(height: 20.0),
                      Container(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          margin: EdgeInsets.only(left: 4),
                          alignment: AlignmentDirectional.centerStart,
                          child: Text("Search our database by name")),
                      Padding(
                        padding: buttonPadding,
                        child: Container(
                          decoration: _getShadowDecoration(),
                          child: Card(
                              child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                  child: Padding(
                                      child: dsl2,
                                      padding: EdgeInsets.only(left: 22))),
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                              )
                            ],
                              )),
                        ),
                      ),
                      Padding(
                        padding: buttonPadding,
                        child: Container(
                          decoration: _getShadowDecoration(),
                          child: Card(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                      child: Padding(
                                          child: dsl3,
                                          padding: EdgeInsets.only(left: 22))),
                                  Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: _getDropdownIcon(),
                              )
                            ],
                          )),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Container(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          margin: EdgeInsets.only(left: 4),
                          alignment: AlignmentDirectional.centerStart,
                          child: Text("How Much?")),
                      Row(children: <Widget>[
                        Expanded(
                            flex: 2,
                            child: Container(
                              decoration: _getShadowDecoration(),
                              child: Card(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                          child: Padding(
                                              child: dsl4,
                                              padding: EdgeInsets.only(
                                                  left: 22))),
                                    ],
                                  )),
                            )),
                        Expanded(
                            flex: 8,
                            child: Container(
                              decoration: _getShadowDecoration(),
                              child: Card(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                          child: Padding(
                                              child: dsl5,
                                              padding: EdgeInsets.only(
                                                  left: 22))),
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: _getDropdownIcon(),
                                      )
                                    ],
                                  )),
                            )),
                      ]),
                      Row(children: <Widget>[
                        Expanded(
                            child: RaisedButton(
                              child: const Text('ADD TO JOURNAL',
                                  style: TextStyle(color: Colors.blueAccent)),
                              onPressed: () {},
                            ))
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  final buttonPadding = const EdgeInsets.fromLTRB(0, 8, 0, 0);

  double cardSize = 80;

  Color cardColor = Colors.blueGrey[100];

  Icon _getDropdownIcon() {
    return Icon(
      Icons.unfold_more,
      color: Colors.blueAccent,
    );
  }

  BoxDecoration _getShadowDecoration() {
    return BoxDecoration(
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black.withOpacity(0.06),
          spreadRadius: 4,
          offset: new Offset(0.0, 0.0),
          blurRadius: 15.0,
        ),
      ],
    );
  }

  Widget _getFoodContainsRow() {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
                child: Center(child: Text("226")),
                height: cardSize,
                margin: EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        bottomLeft: const Radius.circular(10.0)))),
          ),
          Expanded(
            child: Container(
                child: Center(child: Text("41")),
                height: cardSize,
                margin: EdgeInsets.only(right: 3),
                decoration: BoxDecoration(color: cardColor)),
          ),
          Expanded(
            child: Container(
                child: Center(child: Text("0")),
                height: cardSize,
                margin: EdgeInsets.only(right: 3),
                decoration: BoxDecoration(color: cardColor)),
          ),
          Expanded(
            child: Container(
                child: Center(child: Text("4.5")),
                height: cardSize,
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(10.0),
                        bottomRight: const Radius.circular(10.0)))),
          ),
        ],
      ),
    );
  }
}

class MealSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MealSelectorState();
}

class _MealSelectorState extends State<MealSelector> {
  final buttonPadding = const EdgeInsets.fromLTRB(0, 8, 0, 0);
  DirectSelectList<String> dsl;

  @override
  Widget build(BuildContext context) {
    dsl = DirectSelectList<String>(
      values: _meals,
      defaultItemIndex: 0,
      itemBuilder: (String value) => getDropDownMenuItem(value),
      focusedItemDecoration: _getDslDecoration());
    final controlState = DirectSelectControlsContainer.of(context);
    controlState.addControls([dsl]);

    print('[_MealSelectorState]: Adding controller!');

    return Column(
      children: [
        Container(
          alignment: AlignmentDirectional.centerStart,
            margin: EdgeInsets.only(left: 4),
            child: Text("To which meal?")),
        Padding(
          padding: buttonPadding,
          child: Container(
            decoration: _getShadowDecoration(),
            child: Card(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: Padding(
                        child: dsl,
                        padding: EdgeInsets.only(left: 12))),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: _getDropdownIcon(),
                )
              ],
            )),
          ),
        ),
      ],
    );
  }

  DirectSelectItem<String> getDropDownMenuItem(String value) {
    return DirectSelectItem<String>(
        itemHeight: 56,
        value: value,
        itemBuilder: (context, value) {
          return Text(value);
        });
  }

  _getDslDecoration() {
    return BoxDecoration(
      border: BorderDirectional(
        bottom: BorderSide(width: 1, color: Colors.black12),
        top: BorderSide(width: 1, color: Colors.black12),
      ),
    );
  }

  BoxDecoration _getShadowDecoration() {
    return BoxDecoration(
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black.withOpacity(0.06),
          spreadRadius: 4,
          offset: new Offset(0.0, 0.0),
          blurRadius: 15.0,
        ),
      ],
    );
  }

  Icon _getDropdownIcon() {
    return Icon(
      Icons.unfold_more,
      color: Colors.blueAccent,
    );
  }

}
