import 'package:flutter/material.dart';

/// Helper utilities for accessibility improvements
/// 
/// Provides common accessibility labels and helpers for the application.
/// All labels are in French to match the application language.
class AccessibilityHelpers {
  AccessibilityHelpers._();

  // Common action labels
  static const String tapToOpen = 'Appuyer pour ouvrir';
  static const String tapToSelect = 'Appuyer pour sélectionner';
  static const String tapToEdit = 'Appuyer pour modifier';
  static const String tapToDelete = 'Appuyer pour supprimer';
  static const String tapToClose = 'Appuyer pour fermer';
  static const String tapToSend = 'Appuyer pour envoyer';
  static const String tapToCall = 'Appuyer pour appeler';
  static const String tapToVideoCall = 'Appuyer pour appeler en vidéo';
  static const String tapToMessage = 'Appuyer pour envoyer un message';
  static const String tapToBlock = 'Appuyer pour bloquer';
  static const String tapToDownload = 'Appuyer pour télécharger';
  static const String tapToPlay = 'Appuyer pour lire';
  static const String tapToPause = 'Appuyer pour mettre en pause';
  
  // Navigation labels
  static const String navigateToProfile = 'Naviguer vers le profil';
  static const String navigateToChat = 'Naviguer vers la conversation';
  static const String navigateToSettings = 'Naviguer vers les paramètres';
  static const String navigateBack = 'Retour';
  
  // Toggle labels
  static const String toggleNotifications = 'Activer ou désactiver les notifications';
  static const String togglePin = 'Épingler ou désépingler';
  static const String toggleArchive = 'Archiver ou désarchiver';
  static const String toggleRead = 'Marquer comme lu ou non lu';
  
  // Status labels
  static const String online = 'En ligne';
  static const String offline = 'Hors ligne';
  static const String idle = 'Absent';
  static const String doNotDisturb = 'Ne pas déranger';
  static const String read = 'Lu';
  static const String unread = 'Non lu';
  
  // Permission labels
  static const String admin = 'Administrateur';
  static const String moderator = 'Modérateur';
  static const String member = 'Membre';
  
  // Media labels
  static const String image = 'Image';
  static const String video = 'Vidéo';
  static const String document = 'Document';
  static const String voiceMessage = 'Message vocal';
  static const String link = 'Lien';
  
  /// Creates a semantic label for a notification
  static String notificationLabel({
    required String title,
    required String body,
    required bool isRead,
    required String timestamp,
  }) {
    final readStatus = isRead ? 'Lu' : 'Non lu';
    return '$readStatus. $title. $body. $timestamp';
  }
  
  /// Creates a semantic label for a group member
  static String memberLabel({
    required String name,
    required String permission,
    required String joinDate,
  }) {
    return '$name, $permission, membre depuis $joinDate';
  }
  
  /// Creates a semantic label for a search filter chip
  static String filterChipLabel({
    required String filterName,
    required bool isActive,
  }) {
    final status = isActive ? 'activé' : 'désactivé';
    return 'Filtre $filterName, $status';
  }
  
  /// Creates a semantic label for a settings tile
  static String settingsTileLabel({
    required String title,
    String? subtitle,
    bool? toggleValue,
  }) {
    if (subtitle != null && toggleValue != null) {
      final status = toggleValue ? 'activé' : 'désactivé';
      return '$title, $subtitle, $status';
    } else if (subtitle != null) {
      return '$title, $subtitle';
    } else if (toggleValue != null) {
      final status = toggleValue ? 'activé' : 'désactivé';
      return '$title, $status';
    }
    return title;
  }
  
  /// Creates a semantic label for a media item
  static String mediaItemLabel({
    required String type,
    required String fileName,
    String? duration,
    String? size,
  }) {
    final parts = <String>[type, fileName];
    if (duration != null) parts.add('durée $duration');
    if (size != null) parts.add('taille $size');
    return parts.join(', ');
  }
  
  /// Creates a semantic label for an action button
  static String actionButtonLabel({
    required String action,
    required String targetName,
  }) {
    return '$action $targetName';
  }
}
