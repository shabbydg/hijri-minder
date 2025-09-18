// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hijri_minder/main.dart';

void main() {
  testWidgets('HijriMinder app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HijriMinderApp());

    // Verify that our app displays the welcome message.
    expect(find.text('Welcome to HijriMinder'), findsOneWidget);
    expect(find.text('Your comprehensive Hijri calendar companion'), findsOneWidget);
    
    // Verify the calendar icon is displayed.
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
  });
}
