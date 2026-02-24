import 'group_permission.dart';

/// Model representing a member of a group chat
class GroupMemberModel {
  /// Unique identifier of the user
  final String userId;
  
  /// Display name of the member
  final String name;
  
  /// Optional avatar URL
  final String? avatarUrl;
  
  /// Permission level of the member in the group
  final GroupPermission permission;
  
  /// Date and time when the member joined the group
  final DateTime joinedAt;

  GroupMemberModel({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.permission,
    required this.joinedAt,
  });

  /// Creates a copy of this member with updated fields
  GroupMemberModel copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    GroupPermission? permission,
    DateTime? joinedAt,
  }) {
    return GroupMemberModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      permission: permission ?? this.permission,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  /// Converts the member to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'avatarUrl': avatarUrl,
      'permission': permission.name,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  /// Creates a member from a JSON map
  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      permission: GroupPermission.values.firstWhere(
        (e) => e.name == json['permission'],
      ),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}
