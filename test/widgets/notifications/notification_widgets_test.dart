import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/models/notifications/notification_model.dart';
import 'package:tableronde_app/models/notifications/notification_type.dart';
import 'package:tableronde_app/widgets/notifications/badge_counter.dart';
import 'package:tableronde_app/widgets/notifications/filter_tabs.dart';
import 'package:tableronde_app/widgets/notifications/notification_tile.dart';

void main() {
  group('BadgeCounter Widget Tests', () {
    testWidgets('displays count correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BadgeCounter(count: 5),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('displays 99+ for counts over 99', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BadgeCounter(count: 150),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('hides when count is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BadgeCounter(count: 0),
          ),
        ),
      );

      expect(find.byType(BadgeCounter), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });

  group('FilterTabs Widget Tests', () {
    testWidgets('displays all notification types', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterTabs(
              selectedType: null,
              onTypeSelected: (_) {},
              countsByType: const {
                NotificationType.message: 5,
                NotificationType.mention: 2,
                NotificationType.like: 10,
              },
              totalCount: 17,
            ),
          ),
        ),
      );

      expect(find.text('Tous'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Mentions'), findsOneWidget);
      expect(find.text('Likes'), findsOneWidget);
    });

    testWidgets('shows counts per type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterTabs(
              selectedType: null,
              onTypeSelected: (_) {},
              countsByType: const {
                NotificationType.message: 5,
                NotificationType.mention: 2,
              },
              totalCount: 7,
            ),
          ),
        ),
      );

      expect(find.text('7'), findsOneWidget); // Total count
      expect(find.text('5'), findsOneWidget); // Message count
      expect(find.text('2'), findsOneWidget); // Mention count
    });
  });

  group('NotificationTile Widget Tests', () {
    final testNotification = NotificationModel(
      id: '1',
      type: NotificationType.message,
      title: 'Test Notification',
      body: 'This is a test notification body',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    );

    testWidgets('displays notification content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationTile(
              notification: testNotification,
              onTap: () {},
              onMarkRead: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('This is a test notification body'), findsOneWidget);
    });

    testWidgets('shows unread indicator for unread notifications',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationTile(
              notification: testNotification,
              onTap: () {},
              onMarkRead: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find the unread indicator (blue dot)
      final unreadIndicator = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      expect(unreadIndicator, findsWidgets);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationTile(
              notification: testNotification,
              onTap: () => tapped = true,
              onMarkRead: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Wait for slide-in animation to complete
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NotificationTile));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
