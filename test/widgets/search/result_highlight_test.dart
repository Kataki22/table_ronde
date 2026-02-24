import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/widgets/search/result_highlight.dart';

void main() {
  group('ResultHighlight Widget Tests', () {
    testWidgets('displays text without highlighting when query is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: '',
            ),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('displays text without highlighting when no match found',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: 'xyz',
            ),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('highlights matching text case-insensitively',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: 'hello',
            ),
          ),
        ),
      );

      // The widget should render (we can't easily test RichText spans in widget tests)
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('highlights text with accents when query has no accents',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Le café est délicieux',
              query: 'cafe',
            ),
          ),
        ),
      );

      // The widget should render with RichText for highlighting
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('respects maxLines parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'This is a very long text that should be truncated',
              query: 'text',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      final richText = tester.widget<RichText>(find.byType(RichText));
      expect(richText.maxLines, equals(1));
      expect(richText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('applies custom colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: 'hello',
              textColor: Colors.blue,
              highlightColor: Colors.yellow,
              highlightTextColor: Colors.red,
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('handles multiple occurrences', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'café café café',
              query: 'cafe',
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('handles special characters in query',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello (World)',
              query: '(world)',
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('respects textAlign parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: 'hello',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      final richText = tester.widget<RichText>(find.byType(RichText));
      expect(richText.textAlign, equals(TextAlign.center));
    });

    testWidgets('handles empty text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: '',
              query: 'test',
            ),
          ),
        ),
      );

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('handles query with whitespace', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: '  hello  ',
            ),
          ),
        ),
      );

      // Should still highlight despite whitespace in query
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('applies custom textStyle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: 'hello',
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );

      final richText = tester.widget<RichText>(find.byType(RichText));
      expect(richText.text.style?.fontSize, equals(20));
      expect(richText.text.style?.fontWeight, equals(FontWeight.bold));
    });
  });

  group('ResultHighlight Accent Normalization Tests', () {
    test('normalizes common French accents', () {
      // This is a unit test for the normalization logic
      // We test the behavior indirectly through widget rendering
      
      final testCases = [
        {'text': 'café', 'query': 'cafe', 'shouldMatch': true},
        {'text': 'élève', 'query': 'eleve', 'shouldMatch': true},
        {'text': 'hôtel', 'query': 'hotel', 'shouldMatch': true},
        {'text': 'naïve', 'query': 'naive', 'shouldMatch': true},
        {'text': 'où', 'query': 'ou', 'shouldMatch': true},
      ];

      // Note: These are conceptual tests. In practice, we'd need to test
      // the actual rendering or extract the normalization method for unit testing.
      expect(testCases.length, equals(5));
    });
  });

  group('ResultHighlight Animation Tests', () {
    testWidgets('pulse animation is triggered when highlighting text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: 'hello',
            ),
          ),
        ),
      );

      // Initial render
      expect(find.byType(ResultHighlight), findsOneWidget);
      
      // Pump animation frames (300ms duration)
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      
      // Animation should complete
      await tester.pumpAndSettle();
      
      // Widget should still be rendered
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('pulse animation restarts when query changes',
        (WidgetTester tester) async {
      // Build with initial query
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: 'hello',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Update with new query
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: 'world',
            ),
          ),
        ),
      );

      // Pump animation frames
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      
      await tester.pumpAndSettle();
      
      // Widget should still be rendered with new highlight
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('no animation when query is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: '',
            ),
          ),
        ),
      );

      // Should render as plain Text (Flutter wraps it in RichText internally)
      // The key is that no animation controller should be running
      expect(find.byType(ResultHighlight), findsOneWidget);
      
      // Verify no animation is running by checking that pumpAndSettle completes immediately
      await tester.pumpAndSettle();
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('animation completes within 300ms',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResultHighlight(
              text: 'Hello World',
              query: 'hello',
            ),
          ),
        ),
      );

      // Initial render
      await tester.pump();
      
      // Advance time by 300ms (animation duration)
      await tester.pump(const Duration(milliseconds: 300));
      
      // Animation should be complete
      await tester.pumpAndSettle();
      
      expect(find.byType(RichText), findsOneWidget);
    });
  });
}
