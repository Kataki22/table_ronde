/// Types de posts supportés dans le feed
enum PostType {
  /// Post texte uniquement
  text,
  
  /// Post avec image(s)
  image,
  
  /// Post avec vidéo
  video,
  
  /// Post avec GIF
  gif,
  
  /// Sondage/Poll
  poll,
  
  /// Partage d'un autre post
  share,
}

/// Extensions pour PostType
extension PostTypeExtension on PostType {
  /// Retourne l'icône associée au type de post
  String get icon {
    switch (this) {
      case PostType.text:
        return '📝';
      case PostType.image:
        return '📷';
      case PostType.video:
        return '🎥';
      case PostType.gif:
        return '🎭';
      case PostType.poll:
        return '📊';
      case PostType.share:
        return '🔄';
    }
  }
  
  /// Retourne le nom lisible du type
  String get displayName {
    switch (this) {
      case PostType.text:
        return 'Texte';
      case PostType.image:
        return 'Image';
      case PostType.video:
        return 'Vidéo';
      case PostType.gif:
        return 'GIF';
      case PostType.poll:
        return 'Sondage';
      case PostType.share:
        return 'Partage';
    }
  }
}