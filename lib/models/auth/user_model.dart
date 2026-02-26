import 'user_role.dart';

/// Modèle représentant un utilisateur authentifié
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? username;
  final String? bio;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isOnline;
  final String? currentActivity;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    this.bio,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    this.isOnline = false,
    this.currentActivity,
    this.role = UserRole.member,
  });

  /// Crée un UserModel depuis JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
      currentActivity: json['currentActivity'] as String?,
      role: json['role'] != null 
          ? UserRole.fromString(json['role'] as String)
          : UserRole.member,
    );
  }

  /// Convertit ce UserModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'bio': bio,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'isOnline': isOnline,
      'currentActivity': currentActivity,
      'role': role.name,
    };
  }

  /// Crée une copie avec les champs modifiés
  UserModel copyWith({
    String? name,
    String? username,
    String? bio,
    String? phone,
    String? avatarUrl,
    bool? isOnline,
    String? currentActivity,
    UserRole? role,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      isOnline: isOnline ?? this.isOnline,
      currentActivity: currentActivity ?? this.currentActivity,
      role: role ?? this.role,
    );
  }

  /// Retourne les permissions de cet utilisateur
  RolePermissions get permissions => RolePermissions(role);

  /// Vérifie si l'utilisateur a une permission spécifique
  bool hasPermission(String permission) {
    return permissions.hasPermission(permission);
  }

  /// Vérifie si l'utilisateur est administrateur
  bool get isAdmin => role == UserRole.admin;

  /// Vérifie si l'utilisateur est modérateur ou administrateur
  bool get isModerator => role == UserRole.moderator || role == UserRole.admin;
}
