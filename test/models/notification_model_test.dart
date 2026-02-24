import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/models/notifications/notification_model.dart';
import 'package:tableronde_app/models/notifications/notification_type.dart';

void main() {
  group('NotificationModel', () {
    test('should create a notification with all required fields', () {
      final notification = NotificationModel(
        id: '1',
        type: NotificationType.message,
        title: 'New Message',
        body: 'You have a new message',
        timestamp: DateTime(2024, 1, 1),
      );

      expect(notification.id, '1');
      expect(notification.type, NotificationType.message);
      expect(notification.title, 'New Message');
      expect(notification.body, 'You have a new message');
      expect(notification.timestamp, DateTime(2024, 1, 1));
      expect(notification.isRead, false);
      expect(notification.avatarUrl, null);
      expect(notification.targetId, null);
      expect(notification.targetType, null);
    });

    test('should create a notification with optional fields', () {
      final notification = NotificationModel(
        id: '2',
        type: NotificationType.mention,
        title: 'Mention',
        body: 'Someone mentioned you',
        timestamp: DateTime(2024, 1, 1),
        isRead: true,
        avatarUrl: 'https://example.com/avatar.jpg',
        targetId: 'chat123',
        targetType: 'chat',
      );

      expect(notification.isRead, true);
      expect(notification.avatarUrl, 'https://example.com/avatar.jpg');
      expect(notification.targetId, 'chat123');
      expect(notification.targetType, 'chat');
    });

    test('copyWith should update isRead field', () {
      final notification = NotificationModel(
        id: '3',
        type: NotificationType.like,
        title: 'Like',
        body: 'Someone liked your post',
        timestamp: DateTime(2024, 1, 1),
        isRead: false,
      );

      final updated = notification.copyWith(isRead: true);

      expect(updated.id, '3');
      expect(updated.isRead, true);
      expect(updated.title, 'Like');
    });

    test('should return correct icon for each notification type', () {
      expect(
        NotificationModel(
          id: '1',
          type: NotificationType.message,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).icon,
        Icons.message,
      );

      expect(
        NotificationModel(
          id: '2',
          type: NotificationType.mention,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).icon,
        Icons.alternate_email,
      );

      expect(
        NotificationModel(
          id: '3',
          type: NotificationType.like,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).icon,
        Icons.favorite,
      );

      expect(
        NotificationModel(
          id: '4',
          type: NotificationType.comment,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).icon,
        Icons.comment,
      );

      expect(
        NotificationModel(
          id: '5',
          type: NotificationType.announcement,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).icon,
        Icons.campaign,
      );

      expect(
        NotificationModel(
          id: '6',
          type: NotificationType.activity,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).icon,
        Icons.notifications_active,
      );
    });

    test('should return correct color for each notification type', () {
      expect(
        NotificationModel(
          id: '1',
          type: NotificationType.message,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).color,
        Colors.blue,
      );

      expect(
        NotificationModel(
          id: '2',
          type: NotificationType.mention,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).color,
        Colors.purple,
      );

      expect(
        NotificationModel(
          id: '3',
          type: NotificationType.like,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).color,
        Colors.red,
      );

      expect(
        NotificationModel(
          id: '4',
          type: NotificationType.comment,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).color,
        Colors.green,
      );

      expect(
        NotificationModel(
          id: '5',
          type: NotificationType.announcement,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).color,
        Colors.orange,
      );

      expect(
        NotificationModel(
          id: '6',
          type: NotificationType.activity,
          title: 'Test',
          body: 'Test',
          timestamp: DateTime.now(),
        ).color,
        Colors.teal,
      );
    });

    test('should serialize to JSON correctly', () {
      final notification = NotificationModel(
        id: '1',
        type: NotificationType.message,
        title: 'Test',
        body: 'Test body',
        timestamp: DateTime(2024, 1, 1, 12, 0),
        isRead: true,
        avatarUrl: 'https://example.com/avatar.jpg',
        targetId: 'chat123',
        targetType: 'chat',
      );

      final json = notification.toJson();

      expect(json['id'], '1');
      expect(json['type'], 'message');
      expect(json['title'], 'Test');
      expect(json['body'], 'Test body');
      expect(json['timestamp'], '2024-01-01T12:00:00.000');
      expect(json['isRead'], true);
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
      expect(json['targetId'], 'chat123');
      expect(json['targetType'], 'chat');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': '1',
        'type': 'mention',
        'title': 'Test',
        'body': 'Test body',
        'timestamp': '2024-01-01T12:00:00.000',
        'isRead': true,
        'avatarUrl': 'https://example.com/avatar.jpg',
        'targetId': 'post456',
        'targetType': 'post',
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.id, '1');
      expect(notification.type, NotificationType.mention);
      expect(notification.title, 'Test');
      expect(notification.body, 'Test body');
      expect(notification.timestamp, DateTime(2024, 1, 1, 12, 0));
      expect(notification.isRead, true);
      expect(notification.avatarUrl, 'https://example.com/avatar.jpg');
      expect(notification.targetId, 'post456');
      expect(notification.targetType, 'post');
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': '1',
        'type': 'activity',
        'title': 'Test',
        'body': 'Test body',
        'timestamp': '2024-01-01T12:00:00.000',
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.id, '1');
      expect(notification.type, NotificationType.activity);
      expect(notification.isRead, false);
      expect(notification.avatarUrl, null);
      expect(notification.targetId, null);
      expect(notification.targetType, null);
    });
  });

  group('NotificationType', () {
    test('should have all expected notification types', () {
      expect(NotificationType.values.length, 6);
      expect(NotificationType.values, contains(NotificationType.message));
      expect(NotificationType.values, contains(NotificationType.mention));
      expect(NotificationType.values, contains(NotificationType.like));
      expect(NotificationType.values, contains(NotificationType.comment));
      expect(NotificationType.values, contains(NotificationType.announcement));
      expect(NotificationType.values, contains(NotificationType.activity));
    });
  });
}
