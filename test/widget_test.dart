import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:status_maker/main.dart';
import 'package:status_maker/screens/home_screen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StatusMakerApp());

    // Verify that HomeScreen is shown
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('StatusMaker'), findsOneWidget);
  });
}
