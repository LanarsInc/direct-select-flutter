import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _itemHeight = 56.0;
const _values = ['a', 'b', 'c', 'd', 'e', 'f'];
const _fieldKey = Key('field');

class _Page extends StatelessWidget {
  const _Page({
    required this.openOnLongPress,
    this.defaultItemIndex = 0,
    this.onTapped,
    this.scrollController,
  });

  final bool openOnLongPress;
  final int defaultItemIndex;
  final VoidCallback? onTapped;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: DirectSelectContainer(
          child: ListView(
            controller: scrollController,
            children: [
              const SizedBox(height: 200),
              SizedBox(
                key: _fieldKey,
                child: DirectSelectList<String>(
                  values: _values,
                  defaultItemIndex: defaultItemIndex,
                  openOnLongPress: openOnLongPress,
                  onUserTappedListener: onTapped,
                  itemBuilder: (value) => DirectSelectItem<String>(
                    value: value,
                    itemHeight: _itemHeight,
                    itemBuilder: (context, value) => Text(value),
                  ),
                ),
              ),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      ),
    );
  }
}

DirectSelectContainerState _container(WidgetTester tester) =>
    tester.state(find.byType(DirectSelectContainer));

DirectSelectList<String> _list(WidgetTester tester) =>
    tester.widget(find.byType(DirectSelectList<String>));

Future<void> _settleHide(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<TestGesture> _longPress(WidgetTester tester) async {
  final gesture =
      await tester.startGesture(tester.getCenter(find.byKey(_fieldKey)));
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
  return gesture;
}

Future<void> _moveInSteps(TestGesture gesture, WidgetTester tester, double dy,
    {int steps = 4}) async {
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(Offset(0, dy / steps));
    await tester.pump();
  }
}

void main() {
  testWidgets('a drag that starts on the field scrolls the page',
      (tester) async {
    final scrollController = ScrollController();
    await tester.pumpWidget(
        _Page(openOnLongPress: true, scrollController: scrollController));

    await tester.drag(find.byKey(_fieldKey), const Offset(0, -150));
    await tester.pumpAndSettle();

    expect(scrollController.offset, greaterThan(0));
    expect(_container(tester).isOverlayVisible, isFalse);
  });

  testWidgets('without the flag a drag on the field opens the list',
      (tester) async {
    final scrollController = ScrollController();
    await tester.pumpWidget(
        _Page(openOnLongPress: false, scrollController: scrollController));

    final gesture =
        await tester.startGesture(tester.getCenter(find.byKey(_fieldKey)));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    await _moveInSteps(gesture, tester, 40);

    expect(scrollController.offset, 0);
    expect(_container(tester).isOverlayVisible, isTrue);

    await gesture.up();
    await _settleHide(tester);
    expect(_container(tester).isOverlayVisible, isFalse);
  });

  testWidgets('a long press opens the list and release closes it',
      (tester) async {
    await tester.pumpWidget(const _Page(openOnLongPress: true));

    final gesture = await _longPress(tester);
    expect(_container(tester).isOverlayVisible, isTrue);

    await gesture.up();
    await _settleHide(tester);
    expect(_container(tester).isOverlayVisible, isFalse);
    expect(_list(tester).getSelectedItemIndex(), 0);
  });

  testWidgets('moving down after a long press selects a following item',
      (tester) async {
    await tester.pumpWidget(const _Page(openOnLongPress: true));

    final gesture = await _longPress(tester);
    await _moveInSteps(gesture, tester, _itemHeight);
    await gesture.up();
    await _settleHide(tester);

    expect(_list(tester).getSelectedItemIndex(), 2);
  });

  testWidgets('moving up after a long press selects a preceding item',
      (tester) async {
    await tester
        .pumpWidget(const _Page(openOnLongPress: true, defaultItemIndex: 4));

    final gesture = await _longPress(tester);
    await _moveInSteps(gesture, tester, -_itemHeight);
    await gesture.up();
    await _settleHide(tester);

    expect(_list(tester).getSelectedItemIndex(), 2);
  });

  testWidgets('a cancelled long press closes the list', (tester) async {
    await tester.pumpWidget(const _Page(openOnLongPress: true));

    final gesture = await _longPress(tester);
    await _moveInSteps(gesture, tester, _itemHeight);
    await gesture.cancel();
    await _settleHide(tester);

    expect(_container(tester).isOverlayVisible, isFalse);
  });

  testWidgets('a short tap reports the tap and keeps the list closed',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
        _Page(openOnLongPress: true, onTapped: () => tapped = true));

    await tester.tap(find.byKey(_fieldKey));
    await _settleHide(tester);

    expect(tapped, isTrue);
    expect(_container(tester).isOverlayVisible, isFalse);
  });
}
