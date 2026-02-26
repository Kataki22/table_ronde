import '../feed/post_model.dart';
import 'text_range.dart';

/// Modèle représentant un résultat de recherche dans le feed
/// 
/// Contient le post trouvé, son score de pertinence,
/// les ranges de texte correspondant à la recherche,
/// et le type de correspondance trouvé.
class FeedSearchResult {
  /// Post correspondant à la recherche
  final PostModel post;
  
  /// Score de pertinence (0.0 à 100.0+)
  final double relevanceScore;
  
  /// Ranges de texte qui correspondent à la recherche
  /// Utilisés pour le surlignage dans l'UI
  final List<TextRange> matchedRanges;
  
  /// Type de correspondance trouvé
  /// Valeurs possibles: 'text', 'hashtag', 'mention', 'author', 'exact'
  final String matchType;
  
  /// Timestamp de quand ce résultat a été trouvé
  final DateTime searchTimestamp;

  FeedSearchResult({
    required this.post,
    required this.relevanceScore,
    required this.matchedRanges,
    required this.matchType,
    DateTime? searchTimestamp,
  }) : searchTimestamp = searchTimestamp ?? DateTime.now();

  /// Crée une copie avec les champs modifiés
  FeedSearchResult copyWith({
    PostModel? post,
    double? relevanceScore,
    List<TextRange>? matchedRanges,
    String? matchType,
    DateTime? searchTimestamp,
  }) {
    return FeedSearchResult(
      post: post ?? this.post,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      matchedRanges: matchedRanges ?? this.matchedRanges,
      matchType: matchType ?? this.matchType,
      searchTimestamp: searchTimestamp ?? this.searchTimestamp,
    );
  }

  /// Vérifie si ce résultat a des ranges de surlignage
  bool get hasHighlights => matchedRanges.isNotEmpty;
  
  /// Retourne le nombre de correspondances trouvées
  int get matchCount => matchedRanges.length;
  
  /// Vérifie si c'est une correspondance exacte
  bool get isExactMatch => matchType == 'exact';
  
  /// Vérifie si c'est une correspondance par hashtag
  bool get isHashtagMatch => matchType == 'hashtag';
  
  /// Vérifie si c'est une correspondance par mention
  bool get isMentionMatch => matchType == 'mention';
  
  /// Vérifie si c'est une correspondance par auteur
  bool get isAuthorMatch => matchType == 'author';
  
  /// Retourne une description du type de correspondance
  String get matchTypeDescription {
    switch (matchType) {
      case 'hashtag':
        return 'Correspondance par hashtag';
      case 'mention':
        return 'Correspondance par mention';
      case 'author':
        return 'Correspondance par auteur';
      case 'exact':
        return 'Correspondance exacte';
      case 'text':
      default:
        return 'Correspondance textuelle';
    }
  }
  
  /// Retourne l'icône appropriée pour le type de correspondance
  String get matchTypeIcon {
    switch (matchType) {
      case 'hashtag':
        return '#️⃣';
      case 'mention':
        return '@';
      case 'author':
        return '👤';
      case 'exact':
        return '🎯';
      case 'text':
      default:
        return '📝';
    }
  }

  /// Crée un FeedSearchResult depuis JSON
  factory FeedSearchResult.fromJson(Map<String, dynamic> json) {
    return FeedSearchResult(
      post: PostModel.fromJson(json['post'] as Map<String, dynamic>),
      relevanceScore: (json['relevanceScore'] as num).toDouble(),
      matchedRanges: (json['matchedRanges'] as List<dynamic>)
          .map((e) => TextRange.fromJson(e as Map<String, dynamic>))
          .toList(),
      matchType: json['matchType'] as String,
      searchTimestamp: DateTime.parse(json['searchTimestamp'] as String),
    );
  }

  /// Convertit ce FeedSearchResult en JSON
  Map<String, dynamic> toJson() {
    return {
      'post': post.toJson(),
      'relevanceScore': relevanceScore,
      'matchedRanges': matchedRanges.map((e) => e.toJson()).toList(),
      'matchType': matchType,
      'searchTimestamp': searchTimestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedSearchResult &&
        other.post.id == post.id &&
        other.relevanceScore == relevanceScore &&
        other.matchType == matchType;
  }

  @override
  int get hashCode {
    return post.id.hashCode ^
        relevanceScore.hashCode ^
        matchType.hashCode;
  }

  @override
  String toString() {
    return 'FeedSearchResult(postId: ${post.id}, relevanceScore: $relevanceScore, matchType: $matchType, matchCount: $matchCount)';
  }
}