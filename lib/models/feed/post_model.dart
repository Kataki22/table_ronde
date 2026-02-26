import 'post_type.dart';

/// Modèle représentant un post dans le feed social
class PostModel {
  /// ID unique du post
  final String id;
  
  /// ID de l'auteur du post
  final String authorId;
  
  /// Nom de l'auteur du post
  final String authorName;
  
  /// Username de l'auteur (optionnel)
  final String? authorUsername;
  
  /// Avatar de l'auteur du post
  final String? authorAvatar;
  
  /// Si l'auteur est vérifié (badge)
  final bool isAuthorVerified;
  
  /// Contenu textuel du post
  final String content;
  
  /// URLs des images attachées (optionnel)
  final List<String>? imageUrls;
  
  /// URL de la vidéo attachée (optionnel)
  final String? videoUrl;
  
  /// URL du GIF attaché (optionnel)
  final String? gifUrl;
  
  /// Date et heure de publication
  final DateTime timestamp;
  
  /// Type de post
  final PostType type;
  
  /// Nombre total de réactions
  final int reactionCount;
  
  /// Nombre de commentaires
  final int commentCount;
  
  /// Nombre de partages
  final int shareCount;
  
  /// Nombre de vues (optionnel)
  final int? viewCount;
  
  /// Si l'utilisateur actuel a réagi à ce post
  final bool hasReacted;
  
  /// Type de réaction de l'utilisateur actuel (si applicable)
  final String? userReactionType;
  
  /// Si l'utilisateur actuel a sauvegardé ce post
  final bool isSaved;
  
  /// Hashtags extraits du contenu
  final List<String> hashtags;
  
  /// Mentions extraites du contenu
  final List<String> mentions;
  
  /// ID du post original (si c'est un partage)
  final String? originalPostId;
  
  /// Données du post original (si c'est un partage)
  final PostModel? originalPost;
  
  /// Localisation (optionnel)
  final String? location;
  
  /// Si les commentaires sont activés
  final bool commentsEnabled;
  
  /// Si le post est épinglé
  final bool isPinned;
  
  /// Si le post est archivé
  final bool isArchived;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorUsername,
    this.authorAvatar,
    this.isAuthorVerified = false,
    required this.content,
    this.imageUrls,
    this.videoUrl,
    this.gifUrl,
    required this.timestamp,
    required this.type,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.viewCount,
    this.hasReacted = false,
    this.userReactionType,
    this.isSaved = false,
    this.hashtags = const [],
    this.mentions = const [],
    this.originalPostId,
    this.originalPost,
    this.location,
    this.commentsEnabled = true,
    this.isPinned = false,
    this.isArchived = false,
  });

  /// Crée une copie de ce post avec les champs modifiés
  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorUsername,
    String? authorAvatar,
    bool? isAuthorVerified,
    String? content,
    List<String>? imageUrls,
    String? videoUrl,
    String? gifUrl,
    DateTime? timestamp,
    PostType? type,
    int? reactionCount,
    int? commentCount,
    int? shareCount,
    int? viewCount,
    bool? hasReacted,
    String? userReactionType,
    bool? isSaved,
    List<String>? hashtags,
    List<String>? mentions,
    String? originalPostId,
    PostModel? originalPost,
    String? location,
    bool? commentsEnabled,
    bool? isPinned,
    bool? isArchived,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      isAuthorVerified: isAuthorVerified ?? this.isAuthorVerified,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      gifUrl: gifUrl ?? this.gifUrl,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      viewCount: viewCount ?? this.viewCount,
      hasReacted: hasReacted ?? this.hasReacted,
      userReactionType: userReactionType ?? this.userReactionType,
      isSaved: isSaved ?? this.isSaved,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      originalPostId: originalPostId ?? this.originalPostId,
      originalPost: originalPost ?? this.originalPost,
      location: location ?? this.location,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  /// Vérifie si le post a des médias attachés
  bool get hasMedia {
    return (imageUrls?.isNotEmpty ?? false) || 
           videoUrl != null || 
           gifUrl != null;
  }
  
  /// Vérifie si c'est un post partagé
  bool get isSharedPost => originalPostId != null;
  
  /// Retourne le nombre total d'engagements
  int get totalEngagement => reactionCount + commentCount + shareCount;
  
  /// Retourne le temps écoulé depuis la publication (format lisible)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}sem';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}an${years > 1 ? 's' : ''}';
    }
  }

  /// Crée un PostModel depuis JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorUsername: json['authorUsername'] as String?,
      authorAvatar: json['authorAvatar'] as String?,
      isAuthorVerified: json['isAuthorVerified'] as bool? ?? false,
      content: json['content'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      videoUrl: json['videoUrl'] as String?,
      gifUrl: json['gifUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: PostType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PostType.text,
      ),
      reactionCount: json['reactionCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int?,
      hasReacted: json['hasReacted'] as bool? ?? false,
      userReactionType: json['userReactionType'] as String?,
      isSaved: json['isSaved'] as bool? ?? false,
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      mentions: (json['mentions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      originalPostId: json['originalPostId'] as String?,
      originalPost: json['originalPost'] != null
          ? PostModel.fromJson(json['originalPost'] as Map<String, dynamic>)
          : null,
      location: json['location'] as String?,
      commentsEnabled: json['commentsEnabled'] as bool? ?? true,
      isPinned: json['isPinned'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  /// Convertit ce PostModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatar': authorAvatar,
      'isAuthorVerified': isAuthorVerified,
      'content': content,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'gifUrl': gifUrl,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'reactionCount': reactionCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'viewCount': viewCount,
      'hasReacted': hasReacted,
      'userReactionType': userReactionType,
      'isSaved': isSaved,
      'hashtags': hashtags,
      'mentions': mentions,
      'originalPostId': originalPostId,
      'originalPost': originalPost?.toJson(),
      'location': location,
      'commentsEnabled': commentsEnabled,
      'isPinned': isPinned,
      'isArchived': isArchived,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel &&
        other.id == id &&
        other.authorId == authorId &&
        other.content == content &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        authorId.hashCode ^
        content.hashCode ^
        timestamp.hashCode;
  }

  @override
  String toString() {
    return 'PostModel(id: $id, authorId: $authorId, authorName: $authorName, content: $content, type: $type, timestamp: $timestamp, reactionCount: $reactionCount, commentCount: $commentCount)';
  }
}