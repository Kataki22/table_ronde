/// Modèle représentant un commentaire sur un post
class CommentModel {
  /// ID unique du commentaire
  final String id;
  
  /// ID du post commenté
  final String postId;
  
  /// ID du commentaire parent (null si commentaire principal)
  final String? parentCommentId;
  
  /// ID de l'auteur du commentaire
  final String authorId;
  
  /// Nom de l'auteur du commentaire
  final String authorName;
  
  /// Avatar de l'auteur du commentaire
  final String? authorAvatar;
  
  /// Contenu du commentaire
  final String content;
  
  /// Date et heure du commentaire
  final DateTime timestamp;
  
  /// Nombre de likes sur ce commentaire
  final int likeCount;
  
  /// Si l'utilisateur actuel a liké ce commentaire
  final bool isLiked;
  
  /// Liste des réponses à ce commentaire
  final List<CommentModel> replies;
  
  /// Hashtags extraits du contenu
  final List<String> hashtags;
  
  /// Mentions extraites du contenu
  final List<String> mentions;

  CommentModel({
    required this.id,
    required this.postId,
    this.parentCommentId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.timestamp,
    this.likeCount = 0,
    this.isLiked = false,
    this.replies = const [],
    this.hashtags = const [],
    this.mentions = const [],
  });

  /// Crée une copie de ce commentaire avec les champs modifiés
  CommentModel copyWith({
    String? id,
    String? postId,
    String? parentCommentId,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? content,
    DateTime? timestamp,
    int? likeCount,
    bool? isLiked,
    List<CommentModel>? replies,
    List<String>? hashtags,
    List<String>? mentions,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
    );
  }

  /// Vérifie si c'est un commentaire principal (pas une réponse)
  bool get isMainComment => parentCommentId == null;
  
  /// Vérifie si c'est une réponse à un autre commentaire
  bool get isReply => parentCommentId != null;
  
  /// Retourne le nombre total de réponses (récursif)
  int get totalRepliesCount {
    int count = replies.length;
    for (final reply in replies) {
      count += reply.totalRepliesCount;
    }
    return count;
  }

  /// Crée un CommentModel depuis JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      parentCommentId: json['parentCommentId'] as String?,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String?,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      mentions: (json['mentions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Convertit ce CommentModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'parentCommentId': parentCommentId,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likeCount': likeCount,
      'isLiked': isLiked,
      'replies': replies.map((e) => e.toJson()).toList(),
      'hashtags': hashtags,
      'mentions': mentions,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel &&
        other.id == id &&
        other.postId == postId &&
        other.authorId == authorId &&
        other.content == content;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        postId.hashCode ^
        authorId.hashCode ^
        content.hashCode;
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, postId: $postId, authorId: $authorId, authorName: $authorName, content: $content, timestamp: $timestamp, likeCount: $likeCount, repliesCount: ${replies.length})';
  }
}