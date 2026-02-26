/// Types de réactions disponibles pour les posts
enum ReactionType {
  /// J'aime (👍)
  like,
  
  /// J'adore (❤️)
  love,
  
  /// Drôle (😂)
  laugh,
  
  /// Impressionnant (😮)
  wow,
  
  /// Triste (😢)
  sad,
  
  /// En colère (😠)
  angry,
}

/// Extensions pour ReactionType
extension ReactionTypeExtension on ReactionType {
  /// Retourne l'emoji associé à la réaction
  String get emoji {
    switch (this) {
      case ReactionType.like:
        return '👍';
      case ReactionType.love:
        return '❤️';
      case ReactionType.laugh:
        return '😂';
      case ReactionType.wow:
        return '😮';
      case ReactionType.sad:
        return '😢';
      case ReactionType.angry:
        return '😠';
    }
  }
  
  /// Retourne le nom de la réaction
  String get name {
    switch (this) {
      case ReactionType.like:
        return 'J\'aime';
      case ReactionType.love:
        return 'J\'adore';
      case ReactionType.laugh:
        return 'Drôle';
      case ReactionType.wow:
        return 'Wow';
      case ReactionType.sad:
        return 'Triste';
      case ReactionType.angry:
        return 'Grrr';
    }
  }
  
  /// Retourne la couleur associée à la réaction
  String get colorHex {
    switch (this) {
      case ReactionType.like:
        return '#1877F2'; // Bleu Facebook
      case ReactionType.love:
        return '#E91E63'; // Rouge/Rose
      case ReactionType.laugh:
        return '#FFC107'; // Jaune
      case ReactionType.wow:
        return '#FF9800'; // Orange
      case ReactionType.sad:
        return '#2196F3'; // Bleu clair
      case ReactionType.angry:
        return '#F44336'; // Rouge
    }
  }
}