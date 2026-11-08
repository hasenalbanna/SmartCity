// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_city/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartCityApp());

    // Verify that the app loads
    expect(find.byType(SmartCityApp), findsOneWidget);
  });
}
