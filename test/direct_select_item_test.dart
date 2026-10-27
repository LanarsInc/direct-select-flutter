import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _itemHeight = 48.0;
const _itemKey = Key('item');
const _legacyKey = Key('legacy');
const _contentKey = Key('content');
const _legacyContentKey = Key('legacy-content');

Widget _content(Key key) => SizedBox(key: key, width: 80, height: 20);

Widget _selectedItem() => DirectSelectItem<String>(
      key: _itemKey,
      value: 'value',
      itemHeight: _itemHeight,
      isSelected: true,
      itemBuilder: (context, value) => _content(_contentKey),
    );

Widget _legacySelectedItem() => Row(
      key: _legacyKey,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.transparent,
            height: _itemHeight,
            alignment: AlignmentDirectional.centerStart,
            child: Transform.scale(
                scale: 1.0,
                alignment: Alignment.topLeft,
                child: _content(_legacyContentKey)),
          ),
        ),
      ],
    );

Widget _unselectedItem() => DirectSelectItem<String>(
      key: _itemKey,
      value: 'value',
      itemHeight: _itemHeight,
      itemBuilder: (context, value) => _content(_contentKey),
    );

Widget _legacyUnselectedItem() => Material(
      key: _legacyKey,
      color: Colors.transparent,
      child: Container(
        child: Opacity(
          opacity: 0.5,
          child: Container(
            height: _itemHeight,
            alignment: AlignmentDirectional.centerStart,
            child: Transform.scale(
              scale: 1.0,
              alignment: Alignment.topLeft,
              child: _content(_legacyContentKey),
            ),
          ),
        ),
      ),
    );

Widget _app(Widget child) => MaterialApp(
    home: Scaffold(
        body: Directionality(textDirection: TextDirection.ltr, child: child)));

final _parents = <String, Widget Function(Widget child)>{
  'loose bounded box': (child) => Align(
      alignment: Alignment.topLeft, child: SizedBox(width: 300, child: child)),
  'tight box taller than item': (child) =>
      Align(child: SizedBox(width: 300, height: 80, child: child)),
  'column': (child) => Column(children: [child]),
  'card with row and expanded': (child) => Card(
        child: Row(children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 12), child: child)),
          const Icon(Icons.unfold_more),
        ]),
      ),
  'list view': (child) => ListView(children: [child]),
  'min height constraint': (child) => Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60, maxWidth: 300),
            child: child),
      ),
};

void main() {
  for (final entry in _parents.entries) {
    testWidgets('selected item lays out like before in ${entry.key}',
        (tester) async {
      await tester.pumpWidget(_app(entry.value(_legacySelectedItem())));
      final legacySize = tester.getSize(find.byKey(_legacyKey));
      final legacyContent = tester.getRect(find.byKey(_legacyContentKey));
      final legacyOrigin = tester.getTopLeft(find.byKey(_legacyKey));

      await tester.pumpWidget(_app(entry.value(_selectedItem())));
      expect(tester.getSize(find.byKey(_itemKey)), legacySize);
      expect(tester.getTopLeft(find.byKey(_itemKey)), legacyOrigin);
      expect(tester.getRect(find.byKey(_contentKey)), legacyContent);
    });
  }

  testWidgets(
      'selected item shrinks to its content when the width is unbounded',
      (tester) async {
    await tester.pumpWidget(
        _app(Row(children: [_selectedItem(), const Icon(Icons.unfold_more)])));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(_itemKey)), const Size(80, _itemHeight));
  });

  for (final entry in _parents.entries) {
    testWidgets('list item lays out like before in ${entry.key}',
        (tester) async {
      await tester.pumpWidget(_app(entry.value(_legacyUnselectedItem())));
      final legacySize = tester.getSize(find.byKey(_legacyKey));
      final legacyContent = tester.getRect(find.byKey(_legacyContentKey));

      await tester.pumpWidget(_app(entry.value(_unselectedItem())));
      expect(tester.getSize(find.byKey(_itemKey)), legacySize);
      expect(tester.getRect(find.byKey(_contentKey)), legacyContent);
    });
  }

  testWidgets('empty space of the selected item receives taps', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_app(Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 300,
        child: GestureDetector(
          onTap: () => tapped = true,
          child: _selectedItem(),
        ),
      ),
    )));

    final itemRect = tester.getRect(find.byKey(_itemKey));
    await tester.tapAt(Offset(itemRect.right - 10, itemRect.center.dy));

    expect(tapped, isTrue);
  });
}
