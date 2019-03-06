import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_direct_select/direct_select_container.dart';
import 'package:flutter_direct_select/direct_select_item.dart';
import 'package:flutter_direct_select/direct_select_list.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  List<String> _cities = [
    "Cluj-Napoca",
    "Bucuresti",
    "Timisoara",
    "Brasov",
    "Constanta"
  ];

  List<String> _numbers = ["1", "2", "3", "4", "5", "6", "7"];

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

    final bottomNavigationBar = FancyBottomNavigation(
      initialSelection: 1,
      activeIconColor: Colors.white,
      inactiveIconColor: Colors.blueAccent,
      circleColor: Colors.blueAccent,
      tabs: [
        TabData(iconData: Icons.home, title: "Home"),
        TabData(iconData: Icons.add, title: "Add"),
        TabData(iconData: Icons.all_inclusive, title: "Infinity")
      ],
      onTabChangedListener: (position) {
        setState(() {});
      },
    );

    final dsl = DirectSelectList<String>(
        values: _cities,
        defaultItemIndex: 3,
        itemBuilder: (String value) => getDropDownMenuItem(value),
        focusedItemDecoration: _getDslDecoration(),
        onItemSelectedListener: (item, context) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(item)));
        });

    final dsl2 = DirectSelectList<String>(
        values: _numbers,
        itemBuilder: (String value) => getDropDownMenuItem(value),
        focusedItemDecoration: _getDslDecoration());

    return Scaffold(
      appBar: appBar,
      body: DirectSelectContainer(
        controls: [dsl, dsl2],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              SizedBox(height: 150.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Container(
                        alignment: AlignmentDirectional.centerStart,
                        margin: EdgeInsets.only(left: 4),
                        child: Text("City")),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
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
                            child: Icon(
                              Icons.unfold_more,
                              color: Colors.black38,
                            ),
                          )
                        ],
                          )),
                    ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        margin: EdgeInsets.only(left: 4),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("Number")),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
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
                            child: Icon(
                              Icons.unfold_more,
                              color: Colors.black38,
                            ),
                          )
                        ],
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
