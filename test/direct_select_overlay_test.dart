import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _itemHeight = 56.0;
const _values = ['a', 'b', 'c', 'd', 'e', 'f'];
const _fieldKey = Key('field');
const _containerKey = Key('container');
const _focusedDecoration = BoxDecoration(color: Color(0x2200FF00));

class _Field extends StatelessWidget {
  const _Field();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: SizedBox(
        key: _fieldKey,
        child: DirectSelectList<String>(
          values: _values,
          focusedItemDecoration: _focusedDecoration,
          itemBuilder: (value) => DirectSelectItem<String>(
            value: value,
            itemHeight: _itemHeight,
            itemBuilder: (context, value) => Text(value),
          ),
        ),
      ),
    );
  }
}

class _FullScreenPage extends StatelessWidget {
  const _FullScreenPage({this.padding = EdgeInsets.zero, this.safeAreaTop = 0});

  final EdgeInsets padding;
  final double safeAreaTop;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(top: safeAreaTop)),
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: padding,
              child: const DirectSelectContainer(
                key: _containerKey,
                child: Column(
                  children: [SizedBox(height: 200), _Field()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomPanelPage extends StatelessWidget {
  const _BottomPanelPage();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: DirectSelectContainer(
            key: _containerKey,
            child: SizedBox(
              height: 320,
              child: Column(
                children: [SizedBox(height: 120), _Field()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShrinkWrappedPage extends StatelessWidget {
  const _ShrinkWrappedPage();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DirectSelectContainer(
              key: _containerKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [SizedBox(height: 120), _Field()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _focusedOverlay = find.byWidgetPredicate(
    (widget) => widget is Container && widget.decoration == _focusedDecoration);

final _fieldText = find.descendant(
    of: find.byKey(_fieldKey), matching: find.text(_values.first));

final _overlayText = find.descendant(
    of: find.byType(ListView), matching: find.text(_values.first));

Future<TestGesture> _openList(WidgetTester tester) async {
  final gesture =
      await tester.startGesture(tester.getCenter(find.byKey(_fieldKey)));
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pumpAndSettle();
  expect(
      tester
          .state<DirectSelectContainerState>(find.byKey(_containerKey))
          .isOverlayVisible,
      isTrue);
  return gesture;
}

Future<void> _closeList(WidgetTester tester, TestGesture gesture) async {
  await gesture.up();
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _expectOverlayLinesUpWithField(WidgetTester tester) async {
  final fieldRect = tester.getRect(find.byKey(_fieldKey));
  final fieldTextLeft = tester.getTopLeft(_fieldText).dx;

  final gesture = await _openList(tester);

  expect(tester.getRect(_focusedOverlay).top, fieldRect.top);
  expect(tester.getTopLeft(_overlayText).dx, fieldTextLeft);

  await _closeList(tester, gesture);
}

void main() {
  testWidgets('overlay lines up with the field in a Scaffold body',
      (tester) async {
    await tester.pumpWidget(const _FullScreenPage());
    await _expectOverlayLinesUpWithField(tester);
  });

  testWidgets('overlay lines up with the field when the container is padded',
      (tester) async {
    await tester.pumpWidget(
        const _FullScreenPage(padding: EdgeInsets.fromLTRB(30, 40, 30, 0)));
    await _expectOverlayLinesUpWithField(tester);
  });

  testWidgets('overlay lines up with the field inside a SafeArea',
      (tester) async {
    await tester.pumpWidget(const _FullScreenPage(safeAreaTop: 30));
    await _expectOverlayLinesUpWithField(tester);
  });

  testWidgets('a container smaller than the screen keeps its size',
      (tester) async {
    await tester.pumpWidget(const _BottomPanelPage());
    final containerRect = tester.getRect(find.byKey(_containerKey));

    final gesture = await _openList(tester);
    expect(tester.getRect(find.byKey(_containerKey)), containerRect);
    expect(tester.getRect(_focusedOverlay).top,
        tester.getRect(find.byKey(_fieldKey)).top);

    await _closeList(tester, gesture);
  });

  testWidgets('a container with unbounded height opens the list',
      (tester) async {
    await tester.pumpWidget(const _ShrinkWrappedPage());

    final gesture = await _openList(tester);
    expect(tester.takeException(), isNull);

    await _closeList(tester, gesture);
  });
}
