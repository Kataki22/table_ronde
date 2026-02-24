import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/models/settings/conversation_settings.dart';

void main() {
  group('ConversationSettings', () {
    test('should create instance with required chatId', () {
      final settings = ConversationSettings(chatId: 'chat123');
      
      expect(settings.chatId, 'chat123');
      expect(settings.wallpaperUrl, isNull);
      expect(settings.notificationsEnabled, true);
      expect(settings.notificationSoundId, isNull);
      expect(settings.isPinned, false);
      expect(settings.isArchived, false);
    });

    test('should create instance with all parameters', () {
      final settings = ConversationSettings(
        chatId: 'chat123',
        wallpaperUrl: 'https://example.com/wallpaper.jpg',
        notificationsEnabled: false,
        notificationSoundId: 'sound1',
        isPinned: true,
        isArchived: true,
      );
      
      expect(settings.chatId, 'chat123');
      expect(settings.wallpaperUrl, 'https://example.com/wallpaper.jpg');
      expect(settings.notificationsEnabled, false);
      expect(settings.notificationSoundId, 'sound1');
      expect(settings.isPinned, true);
      expect(settings.isArchived, true);
    });

    test('toJson should serialize all fields correctly', () {
      final settings = ConversationSettings(
        chatId: 'chat123',
        wallpaperUrl: 'https://example.com/wallpaper.jpg',
        notificationsEnabled: false,
        notificationSoundId: 'sound1',
        isPinned: true,
        isArchived: true,
      );
      
      final json = settings.toJson();
      
      expect(json['chatId'], 'chat123');
      expect(json['wallpaperUrl'], 'https://example.com/wallpaper.jpg');
      expect(json['notificationsEnabled'], false);
      expect(json['notificationSoundId'], 'sound1');
      expect(json['isPinned'], true);
      expect(json['isArchived'], true);
    });

    test('fromJson should deserialize all fields correctly', () {
      final json = {
        'chatId': 'chat123',
        'wallpaperUrl': 'https://example.com/wallpaper.jpg',
        'notificationsEnabled': false,
        'notificationSoundId': 'sound1',
        'isPinned': true,
        'isArchived': true,
      };
      
      final settings = ConversationSettings.fromJson(json);
      
      expect(settings.chatId, 'chat123');
      expect(settings.wallpaperUrl, 'https://example.com/wallpaper.jpg');
      expect(settings.notificationsEnabled, false);
      expect(settings.notificationSoundId, 'sound1');
      expect(settings.isPinned, true);
      expect(settings.isArchived, true);
    });

    test('fromJson should use default values for missing optional fields', () {
      final json = {
        'chatId': 'chat123',
      };
      
      final settings = ConversationSettings.fromJson(json);
      
      expect(settings.chatId, 'chat123');
      expect(settings.wallpaperUrl, isNull);
      expect(settings.notificationsEnabled, true);
      expect(settings.notificationSoundId, isNull);
      expect(settings.isPinned, false);
      expect(settings.isArchived, false);
    });

    test('toJson and fromJson should be reversible (round-trip)', () {
      final original = ConversationSettings(
        chatId: 'chat123',
        wallpaperUrl: 'https://example.com/wallpaper.jpg',
        notificationsEnabled: false,
        notificationSoundId: 'sound1',
        isPinned: true,
        isArchived: true,
      );
      
      final json = original.toJson();
      final restored = ConversationSettings.fromJson(json);
      
      expect(restored.chatId, original.chatId);
      expect(restored.wallpaperUrl, original.wallpaperUrl);
      expect(restored.notificationsEnabled, original.notificationsEnabled);
      expect(restored.notificationSoundId, original.notificationSoundId);
      expect(restored.isPinned, original.isPinned);
      expect(restored.isArchived, original.isArchived);
    });

    test('copyWith should create new instance with updated values', () {
      final original = ConversationSettings(
        chatId: 'chat123',
        wallpaperUrl: 'https://example.com/old.jpg',
        notificationsEnabled: true,
        isPinned: false,
      );
      
      final updated = original.copyWith(
        wallpaperUrl: 'https://example.com/new.jpg',
        isPinned: true,
      );
      
      expect(updated.chatId, 'chat123');
      expect(updated.wallpaperUrl, 'https://example.com/new.jpg');
      expect(updated.notificationsEnabled, true);
      expect(updated.isPinned, true);
      expect(updated.isArchived, false);
    });

    test('copyWith should preserve original values when not specified', () {
      final original = ConversationSettings(
        chatId: 'chat123',
        wallpaperUrl: 'https://example.com/wallpaper.jpg',
        notificationsEnabled: false,
        notificationSoundId: 'sound1',
        isPinned: true,
        isArchived: true,
      );
      
      final updated = original.copyWith(isPinned: false);
      
      expect(updated.chatId, 'chat123');
      expect(updated.wallpaperUrl, 'https://example.com/wallpaper.jpg');
      expect(updated.notificationsEnabled, false);
      expect(updated.notificationSoundId, 'sound1');
      expect(updated.isPinned, false);
      expect(updated.isArchived, true);
    });

    test('copyWith should not modify original instance (immutability)', () {
      final original = ConversationSettings(
        chatId: 'chat123',
        isPinned: false,
      );
      
      final updated = original.copyWith(isPinned: true);
      
      expect(original.isPinned, false);
      expect(updated.isPinned, true);
    });

    test('equality operator should return true for identical instances', () {
      final settings1 = ConversationSettings(
        chatId: 'chat123',
        wallpaperUrl: 'https://example.com/wallpaper.jpg',
        notificationsEnabled: false,
        isPinned: true,
      );
      
      final settings2 = ConversationSettings(
        chatId: 'chat123',
        wallpaperUrl: 'https://example.com/wallpaper.jpg',
        notificationsEnabled: false,
        isPinned: true,
      );
      
      expect(settings1, equals(settings2));
    });

    test('equality operator should return false for different instances', () {
      final settings1 = ConversationSettings(
        chatId: 'chat123',
        isPinned: true,
      );
      
      final settings2 = ConversationSettings(
        chatId: 'chat123',
        isPinned: false,
      );
      
      expect(settings1, isNot(equals(settings2)));
    });

    test('hashCode should be consistent for equal instances', () {
      final settings1 = ConversationSettings(
        chatId: 'chat123',
        wallpaperUrl: 'https://example.com/wallpaper.jpg',
        notificationsEnabled: false,
      );
      
      final settings2 = ConversationSettings(
        chatId: 'chat123',
        wallpaperUrl: 'https://example.com/wallpaper.jpg',
        notificationsEnabled: false,
      );
      
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('toString should include all fields', () {
      final settings = ConversationSettings(
        chatId: 'chat123',
        wallpaperUrl: 'https://example.com/wallpaper.jpg',
        notificationsEnabled: false,
        notificationSoundId: 'sound1',
        isPinned: true,
        isArchived: true,
      );
      
      final string = settings.toString();
      
      expect(string, contains('chat123'));
      expect(string, contains('https://example.com/wallpaper.jpg'));
      expect(string, contains('false'));
      expect(string, contains('sound1'));
      expect(string, contains('true'));
    });
  });
}
