import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_note/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app widget is pumped successfully.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
