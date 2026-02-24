import 'package:flutter/material.dart';
import 'notification_type.dart';

/// Model representing a notification with all its properties
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? avatarUrl;
  final String? targetId; // ID of the related content (message, post, etc.)
  final String? targetType; // Type of content ('chat', 'post', 'comment')

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.avatarUrl,
    this.targetId,
    this.targetType,
  });

  /// Creates a copy of this notification with the given fields replaced with new values
  NotificationModel copyWith({
    bool? isRead,
    String? title,
    String? body,
    String? avatarUrl,
    String? targetId,
    String? targetType,
  }) {
    return NotificationModel(
      id: id,
      type: type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
    );
  }

  /// Returns the appropriate icon for this notification type
  IconData get icon {
    switch (type) {
      case NotificationType.message:
        return Icons.message;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.activity:
        return Icons.notifications_active;
    }
  }

  /// Returns the appropriate color for this notification type
  Color get color {
    switch (type) {
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.mention:
        return Colors.purple;
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.green;
      case NotificationType.announcement:
        return Colors.orange;
      case NotificationType.activity:
        return Colors.teal;
    }
  }

  /// Creates a NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.activity,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      targetId: json['targetId'] as String?,
      targetType: json['targetType'] as String?,
    );
  }

  /// Converts this NotificationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'avatarUrl': avatarUrl,
      'targetId': targetId,
      'targetType': targetType,
    };
  }
}
