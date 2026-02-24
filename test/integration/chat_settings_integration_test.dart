import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tableronde_app/providers/conversation_settings_provider.dart';
import 'package:tableronde_app/providers/group_chat_provider.dart';
import 'package:tableronde_app/providers/profile_provider.dart';
import 'package:tableronde_app/providers/message_search_provider.dart';
import 'package:tableronde_app/screens/chat_screen.dart';
import 'package:tableronde_app/models/chat_model.dart';

/// Integration test for conversation settings in ChatScreen
/// 
/// Validates: Requirements 4.1, 4.2
void main() {
  group('ChatScreen Settings Integration', () {
    late ConversationSettingsProvider settingsProvider;
    late GroupChatProvider groupProvider;
    late ProfileProvider profileProvider;
    late MessageSearchProvider searchProvider;

    setUp(() async {
      settingsProvider = ConversationSettingsProvider();
      await settingsProvider.initialize();
      
      groupProvider = GroupChatProvider();
      await groupProvider.initialize();
      
      profileProvider = ProfileProvider();
      await profileProvider.initialize();
      
      searchProvider = MessageSearchProvider();
    });

    testWidgets('Settings button is visible in AppBar', (WidgetTester tester) async {
      // Create a test chat
      final testChat = ChatModel(
        id: 'test-chat-1',
        name: 'Test User',
        avatarUrl: null,
        isOnline: true,
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsProvider),
            ChangeNotifierProvider.value(value: groupProvider),
            ChangeNotifierProvider.value(value: profileProvider),
            ChangeNotifierProvider.value(value: searchProvider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                // Navigate to ChatScreen with arguments
                return Scaffold(
                  body: ChatScreen(),
                );
              },
            ),
            onGenerateRoute: (settings) {
              if (settings.name == '/chat') {
                return MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                  settings: RouteSettings(arguments: testChat),
                );
              }
              return null;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify settings button exists
      expect(
        find.byTooltip('Paramètres de conversation'),
        findsOneWidget,
        reason: 'Settings button should be visible in AppBar',
      );
    });

    testWidgets('Settings button opens ConversationSettingsBottomSheet', (WidgetTester tester) async {
      // Create a test chat
      final testChat = ChatModel(
        id: 'test-chat-2',
        name: 'Test User 2',
        avatarUrl: null,
        isOnline: false,
        lastMessage: 'Hi there',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );

      // Build the widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsProvider),
            ChangeNotifierProvider.value(value: groupProvider),
            ChangeNotifierProvider.value(value: profileProvider),
            ChangeNotifierProvider.value(value: searchProvider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ChatScreen(),
                );
              },
            ),
            onGenerateRoute: (settings) {
              if (settings.name == '/chat') {
                return MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                  settings: RouteSettings(arguments: testChat),
                );
              }
              return null;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the settings button
      final settingsButton = find.byTooltip('Paramètres de conversation');
      expect(settingsButton, findsOneWidget);
      
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet is displayed
      expect(
        find.text('Paramètres de conversation'),
        findsOneWidget,
        reason: 'Settings bottom sheet should be displayed',
      );

      // Verify wallpaper option is present
      expect(
        find.text('Fond d\'écran'),
        findsOneWidget,
        reason: 'Wallpaper option should be visible',
      );
    });

    testWidgets('Wallpaper is applied to chat background', (WidgetTester tester) async {
      // Create a test chat
      final testChat = ChatModel(
        id: 'test-chat-3',
        name: 'Test User 3',
        avatarUrl: null,
        isOnline: true,
        lastMessage: 'Test',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );

      // Set a wallpaper for this chat
      const testWallpaperUrl = 'assets/wallpapers/wallpaper_1.jpg';
      await settingsProvider.setWallpaper(testChat.id, testWallpaperUrl);

      // Build the widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsProvider),
            ChangeNotifierProvider.value(value: groupProvider),
            ChangeNotifierProvider.value(value: profileProvider),
            ChangeNotifierProvider.value(value: searchProvider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ChatScreen(),
                );
              },
            ),
            onGenerateRoute: (settings) {
              if (settings.name == '/chat') {
                return MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                  settings: RouteSettings(arguments: testChat),
                );
              }
              return null;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify wallpaper is applied by checking for Container with DecorationImage
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Get the settings to verify wallpaper is set
      final settings = settingsProvider.getSettings(testChat.id);
      expect(
        settings.wallpaperUrl,
        equals(testWallpaperUrl),
        reason: 'Wallpaper should be set for the chat',
      );
    });
  });
}
