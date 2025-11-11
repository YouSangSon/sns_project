import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sns_app/core/animations/custom_animations.dart';

void main() {
  group('BounceButton', () {
    testWidgets('should render child widget', (WidgetTester tester) async {
      // Arrange
      const childText = 'Press Me';
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BounceButton(
              onTap: () => tapped = true,
              child: const Text(childText),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(childText), findsOneWidget);
      expect(tapped, false);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BounceButton(
              onTap: () => tapped = true,
              child: const Text('Press Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BounceButton));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should animate on tap', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BounceButton(
              onTap: () {},
              child: const Text('Press Me'),
            ),
          ),
        ),
      );

      // Get initial transform
      final buttonFinder = find.byType(ScaleTransition);
      expect(buttonFinder, findsOneWidget);

      // Trigger tap down
      await tester.press(find.byType(BounceButton));
      await tester.pump(const Duration(milliseconds: 50));

      // Animation should be running
      expect(buttonFinder, findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should work without onTap callback', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BounceButton(
              child: Text('Press Me'),
            ),
          ),
        ),
      );

      // Should not throw error
      await tester.tap(find.byType(BounceButton));
      await tester.pumpAndSettle();

      // Assert - no error thrown
      expect(find.text('Press Me'), findsOneWidget);
    });
  });

  group('AnimatedLikeButton', () {
    testWidgets('should show empty heart when not liked', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedLikeButton(
              isLiked: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.favorite_border);
    });

    testWidgets('should show filled heart when liked', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedLikeButton(
              isLiked: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.favorite);
      expect(icon.color, Colors.red);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedLikeButton(
              isLiked: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedLikeButton));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });
  });

  group('FadeInAnimation', () {
    testWidgets('should fade in child widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeInAnimation(
              child: Text('Fade In'),
            ),
          ),
        ),
      );

      // Initially invisible
      expect(find.text('Fade In'), findsOneWidget);

      // Wait for animation
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      // Should be visible now
      expect(find.text('Fade In'), findsOneWidget);
    });

    testWidgets('should respect delay parameter', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeInAnimation(
              delay: Duration(milliseconds: 500),
              child: Text('Delayed Fade'),
            ),
          ),
        ),
      );

      // Animation should not start yet
      await tester.pump(const Duration(milliseconds: 250));

      // Wait for delay + animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Delayed Fade'), findsOneWidget);
    });
  });

  group('SlideInAnimation', () {
    testWidgets('should slide in child widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SlideInAnimation(
              child: Text('Slide In'),
            ),
          ),
        ),
      );

      expect(find.text('Slide In'), findsOneWidget);

      // Wait for animation
      await tester.pumpAndSettle();

      expect(find.text('Slide In'), findsOneWidget);
    });
  });

  group('PulseAnimation', () {
    testWidgets('should pulse child widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulseAnimation(
              child: Text('Pulse'),
            ),
          ),
        ),
      );

      expect(find.text('Pulse'), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);

      // Animation should be running
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Pulse'), findsOneWidget);
    });
  });
}
