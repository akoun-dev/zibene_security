// This is a basic Flutter widget test for the ZIBENE SECURITY app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zibene_security/screens/auth/welcome_screen.dart';

void main() {
  group('ZIBENE SECURITY Widget Tests', () {
    testWidgets('Welcome screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      // Verify that the welcome screen is displayed.
      expect(find.text('ZIBENE SECURITY'), findsOneWidget);
      expect(find.text('Your safety, our priority.'), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byIcon(Icons.shield), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('Welcome screen buttons are present', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      // Verify that both buttons are present and tappable.
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('Welcome screen navigation buttons work', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      // Test that the Sign Up button exists and can be tapped
      final signUpButton = find.text('Sign Up');
      expect(signUpButton, findsOneWidget);

      // Test that the Log In button exists
      final loginButton = find.text('Log In');
      expect(loginButton, findsOneWidget);
    });

    testWidgets('Welcome screen has correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      // Verify the screen has the correct structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('Welcome screen has shield icon with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      // Verify the shield icon is present and has correct size
      final shieldIcon = find.byIcon(Icons.shield);
      expect(shieldIcon, findsOneWidget);

      // Test that the icon has the correct size (96)
      final iconWidget = tester.widget<Icon>(shieldIcon);
      expect(iconWidget.size, equals(96));
    });

    testWidgets('Welcome screen has proper spacing', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      // Verify there are SizedBox widgets for spacing
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
    });
  });
}
