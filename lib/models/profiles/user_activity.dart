/// Model representing a user's activity (post, comment, like, join_group, etc.)
class UserActivity {
  final String id;
  final String type; // 'post', 'comment', 'like', 'join_group'
  final String description;
  final DateTime timestamp;

  UserActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  /// Creates a UserActivity from JSON
  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts this UserActivity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
