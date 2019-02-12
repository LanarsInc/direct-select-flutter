import 'package:flutter/material.dart';
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
  List _cities = [
    "Cluj-Napoca",
    "Bucuresti",
    "Timisoara",
    "Brasov",
    "Constanta"
  ];

  List<DirectSelectItem<String>> _dropDownMenuItems;
  String _currentCity;

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _currentCity = _dropDownMenuItems[0].value;
    super.initState();
  }

  List<DirectSelectItem<String>> getDropDownMenuItems() {
    List<DirectSelectItem<String>> items = List();
    for (String city in _cities) {
      items.add(DirectSelectItem(value: city, child: Text(city)));
    }
    return items;
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
    return Scaffold(
      appBar: appBar,
      body: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black12),
        child: Center(child: DirectSelectList(items: getDropDownMenuItems(),)),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _currentCity = selectedCity;
    });
  }
}
