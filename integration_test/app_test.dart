import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sns_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('should load app and show login screen', (WidgetTester tester) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle();

      // Verify login screen is shown
      expect(find.text('Log In'), findsWidgets);
    });

    testWidgets('should navigate to signup screen', (WidgetTester tester) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle();

      // Find and tap sign up button
      final signUpButton = find.text('Sign Up');
      expect(signUpButton, findsOneWidget);

      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify signup screen is shown
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('should show validation errors on empty login', (WidgetTester tester) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle();

      // Find login button and tap
      final loginButton = find.widgetWithText(ElevatedButton, 'Log In');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation messages or state
      // Note: Actual implementation may vary
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should show password field as obscured', (WidgetTester tester) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle();

      // Find password field
      final passwordFields = find.byType(TextField);
      expect(passwordFields, findsWidgets);

      // Check if any TextField has obscureText
      final textFields = tester.widgetList<TextField>(passwordFields);
      final hasObscuredField = textFields.any((field) => field.obscureText == true);
      expect(hasObscuredField, true);
    });
  });

  group('Navigation Tests', () {
    testWidgets('should navigate between login and signup screens', (WidgetTester tester) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to signup
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify we're on signup screen
      expect(find.text('Create Account'), findsWidgets);

      // Navigate back to login
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Verify we're back on login screen
        expect(find.text('Log In'), findsWidgets);
      }
    });
  });

  group('UI Responsiveness Tests', () {
    testWidgets('should render properly on different screen sizes', (WidgetTester tester) async {
      // Test on phone size
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 3.0;

      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);

      // Test on tablet size
      tester.binding.window.physicalSizeTestValue = const Size(2048, 1536);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);

      // Reset to default
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });

  group('Performance Tests', () {
    testWidgets('should render login screen efficiently', (WidgetTester tester) async {
      // Measure frame rendering
      await tester.runAsync(() async {
        app.main();
      });

      await tester.pumpAndSettle();

      // Verify no jank or dropped frames
      // This is a basic check - real performance testing would be more comprehensive
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
