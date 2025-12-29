// Basic smoke test for the app
import 'package:flutter_test/flutter_test.dart';
import 'package:finer_history/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Just verify the app builds successfully
    expect(find.byType(MyApp), findsOneWidget);
  });
}
