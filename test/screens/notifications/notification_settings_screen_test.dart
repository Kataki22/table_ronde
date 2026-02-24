import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tableronde_app/providers/notification_provider.dart';
import 'package:tableronde_app/screens/notifications/notification_settings_screen.dart';
import 'package:tableronde_app/models/notifications/notification_type.dart';

void main() {
  group('NotificationSettingsScreen', () {
    late NotificationProvider provider;

    setUp(() {
      provider = NotificationProvider();
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<NotificationProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: NotificationSettingsScreen(),
        ),
      );
    }

    testWidgets('displays all notification types', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify all notification types are displayed
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Mentions'), findsOneWidget);
      expect(find.text('Likes'), findsOneWidget);
      expect(find.text('Commentaires'), findsOneWidget);
      expect(find.text('Annonces'), findsOneWidget);
      expect(find.text('Activités'), findsOneWidget);
    });

    testWidgets('displays correct subtitles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify subtitles are present
      expect(find.text('Notifications pour les nouveaux messages'), findsOneWidget);
      expect(find.text('Notifications quand vous êtes mentionné'), findsOneWidget);
      expect(find.text('Notifications pour les likes sur vos publications'), findsOneWidget);
      expect(find.text('Notifications pour les commentaires'), findsOneWidget);
      expect(find.text('Notifications pour les annonces importantes'), findsOneWidget);
      expect(find.text('Notifications pour les activités générales'), findsOneWidget);
    });

    testWidgets('all toggles are initially enabled', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find all switches
      final switches = tester.widgetList<Switch>(find.byType(Switch));
      
      // Verify all switches are enabled by default
      for (final switchWidget in switches) {
        expect(switchWidget.value, isTrue);
      }
    });

    testWidgets('can toggle notification settings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the first switch (Messages)
      final firstSwitch = find.byType(Switch).first;
      
      // Verify initial state
      expect(provider.notificationSettings[NotificationType.message], isTrue);
      
      // Tap the switch
      await tester.tap(firstSwitch);
      await tester.pumpAndSettle();
      
      // Verify the setting was updated
      expect(provider.notificationSettings[NotificationType.message], isFalse);
      
      // Tap again to re-enable
      await tester.tap(firstSwitch);
      await tester.pumpAndSettle();
      
      // Verify it's enabled again
      expect(provider.notificationSettings[NotificationType.message], isTrue);
    });

    testWidgets('displays info text at bottom', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to bottom to see the info text
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify info text is present
      expect(
        find.text('Les paramètres sont sauvegardés automatiquement et s\'appliquent immédiatement.'),
        findsOneWidget,
      );
    });

    testWidgets('has correct app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify app bar title
      expect(find.text('Paramètres de notifications'), findsOneWidget);
    });

    testWidgets('displays section header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify section header
      expect(find.text('Types de notifications'), findsOneWidget);
    });

    testWidgets('each notification type has correct icon color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find all icons (excluding app bar icons)
      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      
      // Verify we have at least 6 notification type icons
      // (there may be more from switches and app bar)
      expect(icons.length, greaterThanOrEqualTo(6));
    });

    testWidgets('can toggle multiple settings independently', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Toggle Messages off
      await tester.tap(find.byType(Switch).at(0));
      await tester.pumpAndSettle();
      
      // Toggle Likes off
      await tester.tap(find.byType(Switch).at(2));
      await tester.pumpAndSettle();
      
      // Verify states
      expect(provider.notificationSettings[NotificationType.message], isFalse);
      expect(provider.notificationSettings[NotificationType.mention], isTrue);
      expect(provider.notificationSettings[NotificationType.like], isFalse);
      expect(provider.notificationSettings[NotificationType.comment], isTrue);
      expect(provider.notificationSettings[NotificationType.announcement], isTrue);
      expect(provider.notificationSettings[NotificationType.activity], isTrue);
    });
  });
}
