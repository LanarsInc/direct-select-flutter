import 'package:example/main.dart';
import 'package:example/widgets/compact_selector_examples.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the add food form with default selections', (tester) async {
    await tester.pumpWidget(const DirectSelectExampleApp());

    expect(find.text('Add Food'), findsOneWidget);
    expect(find.text('Breakfast1'), findsOneWidget);
    expect(find.text('Chicken'), findsOneWidget);
    expect(find.text('1.0   Small portion'), findsOneWidget);
    expect(find.text('Chicken grilled'), findsNWidgets(2));
  });

  testWidgets('a plain tap on a field hints to hold and drag', (tester) async {
    await tester.pumpWidget(const DirectSelectExampleApp());

    await tester.tap(find.text('Breakfast1'));
    await tester.pumpAndSettle();

    expect(find.text('Hold and drag instead of tap'), findsOneWidget);
  });

  testWidgets('compact selectors fit inside a row and a horizontal scroll view', (tester) async {
    await tester.pumpWidget(const DirectSelectExampleApp());

    expect(tester.takeException(), isNull);
    expect(find.byType(ReminderSentence), findsOneWidget);
    expect(find.byType(FoodFilterBar), findsOneWidget);
    expect(find.text('Any cuisine'), findsOneWidget);
  });
}
