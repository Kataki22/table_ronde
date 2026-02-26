/// Énumération des rôles utilisateur
enum UserRole {
  admin,
  moderator,
  member;

  /// Retourne le nom d'affichage du rôle
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.moderator:
        return 'Modérateur';
      case UserRole.member:
        return 'Membre';
    }
  }

  /// Retourne la description du rôle
  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Accès complet, gestion des membres, messages, annonces';
      case UserRole.moderator:
        return 'Modération des messages, gestion des annonces, expulsion de membres';
      case UserRole.member:
        return 'Accès basique au chat et aux fonctionnalités standard';
    }
  }

  /// Retourne l'icône associée au rôle
  String get icon {
    switch (this) {
      case UserRole.admin:
        return '👑';
      case UserRole.moderator:
        return '🛡️';
      case UserRole.member:
        return '👤';
    }
  }

  /// Convertit une chaîne en UserRole
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      case 'moderator':
      case 'mod':
        return UserRole.moderator;
      case 'member':
      default:
        return UserRole.member;
    }
  }
}

/// Classe pour gérer les permissions des rôles
class RolePermissions {
  final UserRole role;

  const RolePermissions(this.role);

  // ==================== Permissions de messagerie ====================

  /// Peut envoyer des messages
  bool get canSendMessages => true;

  /// Peut supprimer ses propres messages
  bool get canDeleteOwnMessages => true;

  /// Peut supprimer les messages des autres
  bool get canDeleteOthersMessages => role == UserRole.admin || role == UserRole.moderator;

  /// Peut éditer ses propres messages
  bool get canEditOwnMessages => true;

  /// Peut éditer les messages des autres
  bool get canEditOthersMessages => role == UserRole.admin;

  /// Peut épingler des messages
  bool get canPinMessages => role == UserRole.admin || role == UserRole.moderator;

  // ==================== Permissions de groupe ====================

  /// Peut créer des groupes
  bool get canCreateGroups => true;

  /// Peut supprimer des groupes
  bool get canDeleteGroups => role == UserRole.admin;

  /// Peut modifier les paramètres du groupe
  bool get canEditGroupSettings => role == UserRole.admin || role == UserRole.moderator;

  /// Peut ajouter des membres
  bool get canAddMembers => role == UserRole.admin || role == UserRole.moderator;

  /// Peut expulser des membres
  bool get canKickMembers => role == UserRole.admin || role == UserRole.moderator;

  /// Peut bannir des membres
  bool get canBanMembers => role == UserRole.admin;

  /// Peut promouvoir/rétrograder des membres
  bool get canManageRoles => role == UserRole.admin;

  // ==================== Permissions d'annonces ====================

  /// Peut créer des annonces
  bool get canCreateAnnouncements => role == UserRole.admin || role == UserRole.moderator;

  /// Peut modifier des annonces
  bool get canEditAnnouncements => role == UserRole.admin || role == UserRole.moderator;

  /// Peut supprimer des annonces
  bool get canDeleteAnnouncements => role == UserRole.admin || role == UserRole.moderator;

  // ==================== Permissions de modération ====================

  /// Peut voir les logs de modération
  bool get canViewModerationLogs => role == UserRole.admin || role == UserRole.moderator;

  /// Peut bloquer des utilisateurs
  bool get canBlockUsers => role == UserRole.admin || role == UserRole.moderator;

  /// Peut signaler du contenu
  bool get canReportContent => true;

  /// Peut gérer les signalements
  bool get canManageReports => role == UserRole.admin || role == UserRole.moderator;

  // ==================== Permissions système ====================

  /// Peut accéder aux paramètres du serveur
  bool get canAccessServerSettings => role == UserRole.admin;

  /// Peut voir les statistiques
  bool get canViewStatistics => role == UserRole.admin || role == UserRole.moderator;

  /// Peut gérer les permissions
  bool get canManagePermissions => role == UserRole.admin;

  // ==================== Méthodes utilitaires ====================

  /// Vérifie si l'utilisateur a une permission spécifique
  bool hasPermission(String permission) {
    switch (permission) {
      case 'send_messages':
        return canSendMessages;
      case 'delete_own_messages':
        return canDeleteOwnMessages;
      case 'delete_others_messages':
        return canDeleteOthersMessages;
      case 'edit_own_messages':
        return canEditOwnMessages;
      case 'edit_others_messages':
        return canEditOthersMessages;
      case 'pin_messages':
        return canPinMessages;
      case 'create_groups':
        return canCreateGroups;
      case 'delete_groups':
        return canDeleteGroups;
      case 'edit_group_settings':
        return canEditGroupSettings;
      case 'add_members':
        return canAddMembers;
      case 'kick_members':
        return canKickMembers;
      case 'ban_members':
        return canBanMembers;
      case 'manage_roles':
        return canManageRoles;
      case 'create_announcements':
        return canCreateAnnouncements;
      case 'edit_announcements':
        return canEditAnnouncements;
      case 'delete_announcements':
        return canDeleteAnnouncements;
      case 'view_moderation_logs':
        return canViewModerationLogs;
      case 'block_users':
        return canBlockUsers;
      case 'report_content':
        return canReportContent;
      case 'manage_reports':
        return canManageReports;
      case 'access_server_settings':
        return canAccessServerSettings;
      case 'view_statistics':
        return canViewStatistics;
      case 'manage_permissions':
        return canManagePermissions;
      default:
        return false;
    }
  }

  /// Retourne toutes les permissions de ce rôle
  Map<String, bool> getAllPermissions() {
    return {
      'send_messages': canSendMessages,
      'delete_own_messages': canDeleteOwnMessages,
      'delete_others_messages': canDeleteOthersMessages,
      'edit_own_messages': canEditOwnMessages,
      'edit_others_messages': canEditOthersMessages,
      'pin_messages': canPinMessages,
      'create_groups': canCreateGroups,
      'delete_groups': canDeleteGroups,
      'edit_group_settings': canEditGroupSettings,
      'add_members': canAddMembers,
      'kick_members': canKickMembers,
      'ban_members': canBanMembers,
      'manage_roles': canManageRoles,
      'create_announcements': canCreateAnnouncements,
      'edit_announcements': canEditAnnouncements,
      'delete_announcements': canDeleteAnnouncements,
      'view_moderation_logs': canViewModerationLogs,
      'block_users': canBlockUsers,
      'report_content': canReportContent,
      'manage_reports': canManageReports,
      'access_server_settings': canAccessServerSettings,
      'view_statistics': canViewStatistics,
      'manage_permissions': canManagePermissions,
    };
  }
}
