import 'user_activity.dart';
import 'user_post.dart';

/// Model representing a user's profile with all their information
class UserProfileModel {
  final String id;
  final String name;
  final String? username;
  final String? bio;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isOnline;
  final String? currentActivity;
  final List<UserActivity> recentActivities;
  final List<UserPost> posts;

  UserProfileModel({
    required this.id,
    required this.name,
    this.username,
    this.bio,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    this.isOnline = false,
    this.currentActivity,
    this.recentActivities = const [],
    this.posts = const [],
  });

  /// Creates a copy of this profile with the given fields replaced with new values
  UserProfileModel copyWith({
    String? name,
    String? username,
    String? bio,
    String? phone,
    String? avatarUrl,
    bool? isOnline,
    String? currentActivity,
    List<UserActivity>? recentActivities,
    List<UserPost>? posts,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      isOnline: isOnline ?? this.isOnline,
      currentActivity: currentActivity ?? this.currentActivity,
      recentActivities: recentActivities ?? this.recentActivities,
      posts: posts ?? this.posts,
    );
  }

  /// Creates a UserProfileModel from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
      currentActivity: json['currentActivity'] as String?,
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.map((e) => UserActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      posts: (json['posts'] as List<dynamic>?)
              ?.map((e) => UserPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converts this UserProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'bio': bio,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'isOnline': isOnline,
      'currentActivity': currentActivity,
      'recentActivities': recentActivities.map((e) => e.toJson()).toList(),
      'posts': posts.map((e) => e.toJson()).toList(),
    };
  }
}
