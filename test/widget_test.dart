// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flutter_mate/main.dart';
import 'package:flutter_mate/core/theme/theme_manager.dart';

void main() {
  testWidgets('FlutterMate app loads correctly', (WidgetTester tester) async {
    // Initialize GetX dependencies for testing
    Get.put(ThemeManager());

    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlutterMateApp());

    // Verify that the splash screen appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('FlutterMate'), findsOneWidget);

    // Advance time to allow splash timer and animations to complete
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify onboarding screen is visible after splash
    expect(find.text('Structured Roadmap'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
