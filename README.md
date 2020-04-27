# direct-select-flutter
DirectSelect is a selection widget with an ethereal, full-screen modal popup displaying the available choices when the widget is interact with. 
Inspired by [dribble shot](https://dribbble.com/shots/3876250-DirectSelect-Dropdown-ux).

Made in [lanars.com](https://lanars.com).

[![pub package](https://img.shields.io/pub/v/direct_select_flutter.svg)](https://pub.dev/packages/direct_select_flutter)
<a href="https://github.com/Solido/awesome-flutter">
   <img alt="Awesome Flutter" src="https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square" />
</a>

# iOS

<img src="https://raw.githubusercontent.com/LanarsInc/direct-select-flutter/master/example/direct-select-ios.gif" width="300">

# Android 

<img src="https://raw.githubusercontent.com/LanarsInc/direct-select-flutter/master/example/direct-select-android.gif" width="300">

# Usage

 Create DirectSelectList and fill it with items using itemBuilder
```dart
    final dsl = DirectSelectList<String>(
        values: _cities,
        defaultItemIndex: 3,
        itemBuilder: (String value) => getDropDownMenuItem(value),
        focusedItemDecoration: _getDslDecoration(),
        onItemSelectedListener: (item, index, context) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(item)));
        });
```
 Create items like this
```dart
  DirectSelectItem<String> getDropDownMenuItem(String value) {
    return DirectSelectItem<String>(
        itemHeight: 56,
        value: value,
        itemBuilder: (context, value) {
          return Text(value);
        });
  }
  ```
 Create decorations for focused items
 ```dart
   _getDslDecoration() {
    return BoxDecoration(
      border: BorderDirectional(
        bottom: BorderSide(width: 1, color: Colors.black12),
        top: BorderSide(width: 1, color: Colors.black12),
      ),
    );
  }
```
 Create DirectSelectContainer and fill it with your data
```dart
Scaffold(
      appBar: appBar,
      body: DirectSelectContainer(
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
                      child: Text("City"),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Card(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                                    child: DirectSelectList<String>(
                                                     values: _cities,
                                                     defaultItemIndex: 3,
                                                     itemBuilder: (String value) => getDropDownMenuItem(value),
                                                     focusedItemDecoration: _getDslDecoration(),
                                                     onItemSelectedListener: (item, index, context) {
                                                       Scaffold.of(context).showSnackBar(SnackBar(content: Text(item)));
                                                     }),
                                    padding: EdgeInsets.only(left: 12))),
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.unfold_more,
                                color: Colors.black38,
                              ),
                            )
                          ],
                        ),
                         ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
```
