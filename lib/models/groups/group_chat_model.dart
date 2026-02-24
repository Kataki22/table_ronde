import 'group_member_model.dart';
import 'group_permission.dart';

/// Model representing a group chat
class GroupChatModel {
  /// Unique identifier of the group
  final String id;
  
  /// Name of the group
  final String name;
  
  /// Optional description of the group
  final String? description;
  
  /// Optional photo URL for the group
  final String? photoUrl;
  
  /// List of members in the group
  final List<GroupMemberModel> members;
  
  /// Date and time when the group was created
  final DateTime createdAt;
  
  /// Text of the last message sent in the group
  final String? lastMessage;
  
  /// Timestamp of the last message
  final DateTime? lastMessageTime;
  
  /// Number of unread messages
  final int unreadCount;

  GroupChatModel({
    required this.id,
    required this.name,
    this.description,
    this.photoUrl,
    required this.members,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  /// Checks if a user is an admin in the group
  bool isUserAdmin(String userId) {
    return members.any(
      (member) => member.userId == userId && member.permission == GroupPermission.admin,
    );
  }

  /// Checks if a user is a moderator in the group
  bool isUserModerator(String userId) {
    return members.any(
      (member) => member.userId == userId && member.permission == GroupPermission.moderator,
    );
  }

  /// Checks if a user can manage members (admin or moderator)
  bool canUserManageMembers(String userId) {
    return members.any(
      (member) => 
        member.userId == userId && 
        (member.permission == GroupPermission.admin || 
         member.permission == GroupPermission.moderator),
    );
  }

  /// Returns a list of all admin members
  List<GroupMemberModel> get admins {
    return members
        .where((member) => member.permission == GroupPermission.admin)
        .toList();
  }

  /// Returns a list of all moderator members
  List<GroupMemberModel> get moderators {
    return members
        .where((member) => member.permission == GroupPermission.moderator)
        .toList();
  }

  /// Creates a copy of this group with updated fields
  GroupChatModel copyWith({
    String? id,
    String? name,
    String? description,
    String? photoUrl,
    List<GroupMemberModel>? members,
    DateTime? createdAt,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return GroupChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  /// Converts the group to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'members': members.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  /// Creates a group from a JSON map
  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    return GroupChatModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      photoUrl: json['photoUrl'] as String?,
      members: (json['members'] as List)
          .map((m) => GroupMemberModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
