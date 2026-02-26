/// Énumération des niveaux de visibilité d'un post
enum PostVisibility {
  /// Post visible par tous (public)
  public,
  
  /// Post visible uniquement par les amis
  friends,
  
  /// Post visible uniquement par l'auteur (privé)
  private,
  
  /// Post visible par les abonnés uniquement
  followers,
  
  /// Post visible par un groupe spécifique
  group,
  
  /// Post visible par des utilisateurs mentionnés uniquement
  mentioned;

  /// Retourne le libellé français de la visibilité
  String get label {
    switch (this) {
      case PostVisibility.public:
        return 'Public';
      case PostVisibility.friends:
        return 'Amis';
      case PostVisibility.private:
        return 'Privé';
      case PostVisibility.followers:
        return 'Abonnés';
      case PostVisibility.group:
        return 'Groupe';
      case PostVisibility.mentioned:
        return 'Mentionnés';
    }
  }

  /// Retourne la description de la visibilité
  String get description {
    switch (this) {
      case PostVisibility.public:
        return 'Visible par tous les utilisateurs';
      case PostVisibility.friends:
        return 'Visible uniquement par vos amis';
      case PostVisibility.private:
        return 'Visible uniquement par vous';
      case PostVisibility.followers:
        return 'Visible par vos abonnés';
      case PostVisibility.group:
        return 'Visible par les membres du groupe';
      case PostVisibility.mentioned:
        return 'Visible par les utilisateurs mentionnés';
    }
  }

  /// Retourne l'icône associée à la visibilité
  String get iconName {
    switch (this) {
      case PostVisibility.public:
        return 'public';
      case PostVisibility.friends:
        return 'group';
      case PostVisibility.private:
        return 'lock';
      case PostVisibility.followers:
        return 'people';
      case PostVisibility.group:
        return 'groups';
      case PostVisibility.mentioned:
        return 'alternate_email';
    }
  }
}