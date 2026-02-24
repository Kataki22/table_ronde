import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tableronde_app/models/settings/conversation_settings.dart';
import 'package:tableronde_app/providers/conversation_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConversationSettingsProvider', () {
    late ConversationSettingsProvider provider;

    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
      provider = ConversationSettingsProvider();
      await provider.initialize();
    });

    test('should initialize with empty settings', () {
      expect(provider.isInitialized, true);
      final settings = provider.getSettings('test-chat-1');
      expect(settings.chatId, 'test-chat-1');
      expect(settings.notificationsEnabled, true);
      expect(settings.isPinned, false);
      expect(settings.isArchived, false);
    });

    test('should set wallpaper for a conversation', () async {
      const chatId = 'test-chat-1';
      const wallpaperUrl = 'https://example.com/wallpaper.jpg';

      await provider.setWallpaper(chatId, wallpaperUrl);

      final settings = provider.getSettings(chatId);
      expect(settings.wallpaperUrl, wallpaperUrl);
    });

    test('should toggle notifications', () async {
      const chatId = 'test-chat-1';

      // Initially enabled
      expect(provider.areNotificationsEnabled(chatId), true);

      // Toggle off
      await provider.toggleNotifications(chatId);
      expect(provider.areNotificationsEnabled(chatId), false);

      // Toggle back on
      await provider.toggleNotifications(chatId);
      expect(provider.areNotificationsEnabled(chatId), true);
    });

    test('should set notification sound', () async {
      const chatId = 'test-chat-1';
      const soundId = 'sound-123';

      await provider.setNotificationSound(chatId, soundId);

      final settings = provider.getSettings(chatId);
      expect(settings.notificationSoundId, soundId);
    });

    test('should pin and unpin conversation', () async {
      const chatId = 'test-chat-1';

      expect(provider.isPinned(chatId), false);

      await provider.pinConversation(chatId);
      expect(provider.isPinned(chatId), true);
      expect(provider.pinnedConversationIds, contains(chatId));

      await provider.unpinConversation(chatId);
      expect(provider.isPinned(chatId), false);
      expect(provider.pinnedConversationIds, isNot(contains(chatId)));
    });

    test('should archive and unarchive conversation', () async {
      const chatId = 'test-chat-1';

      expect(provider.isArchived(chatId), false);

      await provider.archiveConversation(chatId);
      expect(provider.isArchived(chatId), true);
      expect(provider.archivedConversationIds, contains(chatId));

      await provider.unarchiveConversation(chatId);
      expect(provider.isArchived(chatId), false);
      expect(provider.archivedConversationIds, isNot(contains(chatId)));
    });

    test('should delete conversation settings', () async {
      const chatId = 'test-chat-1';

      // Set some settings
      await provider.setWallpaper(chatId, 'https://example.com/wallpaper.jpg');
      await provider.pinConversation(chatId);

      // Verify settings exist
      var settings = provider.getSettings(chatId);
      expect(settings.wallpaperUrl, isNotNull);
      expect(settings.isPinned, true);

      // Delete conversation
      await provider.deleteConversation(chatId);

      // Verify settings are back to default
      settings = provider.getSettings(chatId);
      expect(settings.wallpaperUrl, isNull);
      expect(settings.isPinned, false);
    });

    test('should block user and archive conversation', () async {
      const chatId = 'test-chat-1';

      expect(provider.isArchived(chatId), false);

      await provider.blockUser(chatId);

      expect(provider.isArchived(chatId), true);
    });

    test('should report user and archive conversation', () async {
      const chatId = 'test-chat-1';
      const reason = 'Spam';

      expect(provider.isArchived(chatId), false);

      await provider.reportUser(chatId, reason);

      expect(provider.isArchived(chatId), true);
    });

    test('should persist settings across provider instances', () async {
      const chatId = 'test-chat-1';
      const wallpaperUrl = 'https://example.com/wallpaper.jpg';

      // Set settings in first provider
      await provider.setWallpaper(chatId, wallpaperUrl);
      await provider.pinConversation(chatId);
      await provider.toggleNotifications(chatId);

      // Create new provider instance
      final newProvider = ConversationSettingsProvider();
      await newProvider.initialize();

      // Verify settings persisted
      final settings = newProvider.getSettings(chatId);
      expect(settings.wallpaperUrl, wallpaperUrl);
      expect(settings.isPinned, true);
      expect(settings.notificationsEnabled, false);
    });

    test('should handle multiple conversations', () async {
      const chatId1 = 'chat-1';
      const chatId2 = 'chat-2';
      const chatId3 = 'chat-3';

      await provider.pinConversation(chatId1);
      await provider.archiveConversation(chatId2);
      await provider.setWallpaper(chatId3, 'https://example.com/wallpaper.jpg');

      expect(provider.isPinned(chatId1), true);
      expect(provider.isArchived(chatId2), true);
      expect(provider.getSettings(chatId3).wallpaperUrl, isNotNull);

      expect(provider.pinnedConversationIds, [chatId1]);
      expect(provider.archivedConversationIds, [chatId2]);
    });

    test('should clear all settings', () async {
      const chatId1 = 'chat-1';
      const chatId2 = 'chat-2';

      await provider.pinConversation(chatId1);
      await provider.archiveConversation(chatId2);

      expect(provider.pinnedConversationIds, isNotEmpty);
      expect(provider.archivedConversationIds, isNotEmpty);

      await provider.clearAllSettings();

      expect(provider.pinnedConversationIds, isEmpty);
      expect(provider.archivedConversationIds, isEmpty);
    });

    test('should notify listeners on changes', () async {
      const chatId = 'test-chat-1';
      int notificationCount = 0;

      provider.addListener(() {
        notificationCount++;
      });

      await provider.setWallpaper(chatId, 'https://example.com/wallpaper.jpg');
      expect(notificationCount, 1);

      await provider.toggleNotifications(chatId);
      expect(notificationCount, 2);

      await provider.pinConversation(chatId);
      expect(notificationCount, 3);
    });
  });
}
