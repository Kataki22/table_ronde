/// Helper pour gérer les avatars disponibles
class AvatarHelper {
  /// Images d'avatars disponibles dans assets/images/
  static const List<String> _availableAvatars = [
    'assets/images/Avatar1.png',
    'assets/images/Avatar2.png',
  ];

  /// Retourne un avatar basé sur un index ou un ID utilisateur
  static String getAvatarUrl(dynamic identifier) {
    if (identifier == null) return _availableAvatars[0];
    
    // Si c'est un string, on utilise le hashCode
    int index;
    if (identifier is String) {
      index = identifier.hashCode.abs();
    } else if (identifier is int) {
      index = identifier;
    } else {
      index = identifier.toString().hashCode.abs();
    }
    
    return _availableAvatars[index % _availableAvatars.length];
  }

  /// Retourne tous les avatars disponibles
  static List<String> get availableAvatars => List.unmodifiable(_availableAvatars);

  /// Retourne un avatar aléatoire
  static String getRandomAvatar() {
    return _availableAvatars[DateTime.now().millisecond % _availableAvatars.length];
  }
}