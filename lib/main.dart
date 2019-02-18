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

  List<String> _numbers = ["1", "2", "3", "4", "5"];

  DirectSelectItem<String> getDropDownMenuItem(String value) {
    return DirectSelectItem<String>(
        value: value,
        listItemBuilder: (context, value) {
          return Container(
              child: Text(value), margin: EdgeInsets.only(left: 5));
        },
        buttonItemBuilder: (context, value) {
          return Card(
              margin: EdgeInsets.all(0),
              elevation: 2,
              child: Container(
                margin: EdgeInsets.only(left: 4),
                child: Text(value),
                alignment: AlignmentDirectional.centerStart,
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(widget.title),
    );
    final bottomNavigationBar = BottomNavigationBar(
      currentIndex: 0, // this will be set when a tab is tapped
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mail),
          title: Text('Messages'),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), title: Text('Profile'))
      ],
    );

    final dsl = DirectSelectList<String>(
        values: _cities,
        itemBuilder: (String value) => getDropDownMenuItem(value),
        focusedItemDecoration:
        BoxDecoration(color: Colors.greenAccent.withOpacity(0.3)),
        itemSelected: (item, context) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(item)));
        });

    final dsl2 = DirectSelectList<String>(
        values: _numbers,
        itemBuilder: (String value) => getDropDownMenuItem(value),
        focusedItemDecoration: BoxDecoration(border: Border.all(width: 1)));

    return Scaffold(
      appBar: appBar,
      body: DirectSelectContainer(
        listPadding: EdgeInsets.only(left: 24, right: 24),
        controls: [dsl, dsl2],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
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
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(child: dsl),
                        ],
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        margin: EdgeInsets.only(left: 4),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("Number")),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(child: dsl2),
                        ],
                      ),
                    )
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
