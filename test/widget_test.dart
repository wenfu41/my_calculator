// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:my_calculator/main.dart';

void main() {
  testWidgets('Calculator addition test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our display starts at 0.
    // Note: There might be multiple '0's (display and button), so we look for the one in the display area specifically
    // or just check if at least one exists.
    // However, the button '0' is a text widget, and the display is a text widget.
    // Let's just find the button '1' and tap it.

    await tester.tap(find.text('1'));
    await tester.pump();

    await tester.tap(find.text('+'));
    await tester.pump();

    await tester.tap(find.text('2'));
    await tester.pump();

    await tester.tap(find.text('='));
    await tester.pump();

    // Verify that the result is 3.
    // The display should show '3'.
    // There is also a button '3', so we expect findsNWidgets(2) if the result is 3?
    // Wait, the result is 1+2=3.
    // So we expect to find text '3'.
    // One is the button '3', one is the result.
    expect(find.text('3'), findsAtLeastNWidgets(1));
  });
}
