import 'reaction_type.dart';

/// Modèle représentant une réaction sur un post
class ReactionModel {
  /// ID unique de la réaction
  final String id;
  
  /// ID du post sur lequel la réaction est faite
  final String postId;
  
  /// ID de l'utilisateur qui a réagi
  final String userId;
  
  /// Nom de l'utilisateur qui a réagi
  final String userName;
  
  /// Avatar de l'utilisateur qui a réagi
  final String? userAvatar;
  
  /// Type de réaction
  final ReactionType type;
  
  /// Date et heure de la réaction
  final DateTime timestamp;

  ReactionModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.type,
    required this.timestamp,
  });

  /// Crée une copie de cette réaction avec les champs modifiés
  ReactionModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userAvatar,
    ReactionType? type,
    DateTime? timestamp,
  }) {
    return ReactionModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Crée une ReactionModel depuis JSON
  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      type: ReactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReactionType.like,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convertit cette ReactionModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReactionModel &&
        other.id == id &&
        other.postId == postId &&
        other.userId == userId &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        postId.hashCode ^
        userId.hashCode ^
        type.hashCode;
  }

  @override
  String toString() {
    return 'ReactionModel(id: $id, postId: $postId, userId: $userId, userName: $userName, type: $type, timestamp: $timestamp)';
  }
}