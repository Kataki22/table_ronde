import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings/conversation_settings.dart';

/// Provider pour les paramètres de conversation
/// Gère les préférences et la persistance locale
/// 
/// Validates: Requirements 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 10.1, 10.5, 7.1, 7.2
class ConversationSettingsProvider extends ChangeNotifier {
  /// Map of conversation settings by chatId
  final Map<String, ConversationSettings> _settings = {};
  
  /// SharedPreferences key for storing settings
  static const String _storageKey = 'conversation_settings';
  
  /// Whether the provider has been initialized
  bool _isInitialized = false;
  
  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Initialize the provider and load saved settings
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  /// Get settings for a specific conversation
  /// Returns default settings if none exist for this chatId
  ConversationSettings getSettings(String chatId) {
    return _settings[chatId] ?? ConversationSettings(chatId: chatId);
  }

  /// Set wallpaper for a conversation
  /// Validates: Requirements 4.2, 10.2
  Future<void> setWallpaper(String chatId, String wallpaperUrl) async {
    final currentSettings = getSettings(chatId);
    final updatedSettings = currentSettings.copyWith(wallpaperUrl: wallpaperUrl);
    _settings[chatId] = updatedSettings;
    await _saveSettings(chatId);
    notifyListeners();
  }

  /// Toggle notifications for a conversation
  /// Validates: Requirements 4.3, 10.3
  Future<void> toggleNotifications(String chatId) async {
    final currentSettings = getSettings(chatId);
    final updatedSettings = currentSettings.copyWith(
      notificationsEnabled: !currentSettings.notificationsEnabled,
    );
    _settings[chatId] = updatedSettings;
    await _saveSettings(chatId);
    notifyListeners();
  }

  /// Set notification sound for a conversation
  /// Validates: Requirements 4.4, 10.3
  Future<void> setNotificationSound(String chatId, String soundId) async {
    final currentSettings = getSettings(chatId);
    final updatedSettings = currentSettings.copyWith(notificationSoundId: soundId);
    _settings[chatId] = updatedSettings;
    await _saveSettings(chatId);
    notifyListeners();
  }

  /// Pin a conversation to the top of the chat list
  /// Validates: Requirements 4.5, 10.4
  Future<void> pinConversation(String chatId) async {
    final currentSettings = getSettings(chatId);
    final updatedSettings = currentSettings.copyWith(isPinned: true);
    _settings[chatId] = updatedSettings;
    await _saveSettings(chatId);
    notifyListeners();
  }

  /// Unpin a conversation
  /// Validates: Requirements 4.5, 10.4
  Future<void> unpinConversation(String chatId) async {
    final currentSettings = getSettings(chatId);
    final updatedSettings = currentSettings.copyWith(isPinned: false);
    _settings[chatId] = updatedSettings;
    await _saveSettings(chatId);
    notifyListeners();
  }

  /// Archive a conversation
  /// Validates: Requirements 4.6, 10.4
  Future<void> archiveConversation(String chatId) async {
    final currentSettings = getSettings(chatId);
    final updatedSettings = currentSettings.copyWith(isArchived: true);
    _settings[chatId] = updatedSettings;
    await _saveSettings(chatId);
    notifyListeners();
  }

  /// Unarchive a conversation
  /// Validates: Requirements 4.6, 10.4
  Future<void> unarchiveConversation(String chatId) async {
    final currentSettings = getSettings(chatId);
    final updatedSettings = currentSettings.copyWith(isArchived: false);
    _settings[chatId] = updatedSettings;
    await _saveSettings(chatId);
    notifyListeners();
  }

  /// Delete a conversation
  /// This removes all settings for the conversation
  /// Validates: Requirements 4.9
  Future<void> deleteConversation(String chatId) async {
    _settings.remove(chatId);
    await _saveSettings(chatId);
    notifyListeners();
  }

  /// Block a user (conversation-level action)
  /// This is a placeholder for blocking functionality
  /// In a real app, this would interact with a user management service
  /// Validates: Requirements 4.7
  Future<void> blockUser(String chatId) async {
    // In a real implementation, this would:
    // 1. Call a backend API to block the user
    // 2. Update local state to reflect the block
    // 3. Possibly archive or hide the conversation
    
    // For now, we'll archive the conversation as a visual indicator
    await archiveConversation(chatId);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Report a user for inappropriate behavior
  /// This is a placeholder for reporting functionality
  /// In a real app, this would send a report to moderation
  /// Validates: Requirements 4.8
  Future<void> reportUser(String chatId, String reason) async {
    // In a real implementation, this would:
    // 1. Call a backend API to submit the report
    // 2. Include the reason and any relevant context
    // 3. Possibly archive or hide the conversation
    
    // For now, we'll just simulate the action
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Optionally archive the conversation after reporting
    await archiveConversation(chatId);
  }

  /// Save settings for a specific conversation to local storage
  /// Validates: Requirements 10.1, 10.5
  Future<void> _saveSettings(String chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert all settings to JSON
      final settingsMap = <String, dynamic>{};
      for (final entry in _settings.entries) {
        settingsMap[entry.key] = entry.value.toJson();
      }
      
      // Save as JSON string
      final jsonString = jsonEncode(settingsMap);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      // Log error but don't throw - graceful degradation
      debugPrint('Error saving conversation settings: $e');
    }
  }

  /// Load all settings from local storage
  /// Validates: Requirements 10.1, 10.5
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        // No saved settings, start with empty map
        return;
      }
      
      // Parse JSON string
      final settingsMap = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Convert each entry back to ConversationSettings
      _settings.clear();
      for (final entry in settingsMap.entries) {
        final settings = ConversationSettings.fromJson(
          entry.value as Map<String, dynamic>,
        );
        _settings[entry.key] = settings;
      }
    } catch (e) {
      // Log error but don't throw - graceful degradation
      debugPrint('Error loading conversation settings: $e');
      _settings.clear();
    }
  }

  /// Clear all settings (useful for testing or logout)
  Future<void> clearAllSettings() async {
    _settings.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  /// Get all pinned conversation IDs
  List<String> get pinnedConversationIds {
    return _settings.entries
        .where((entry) => entry.value.isPinned)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get all archived conversation IDs
  List<String> get archivedConversationIds {
    return _settings.entries
        .where((entry) => entry.value.isArchived)
        .map((entry) => entry.key)
        .toList();
  }

  /// Check if a conversation is pinned
  bool isPinned(String chatId) {
    return getSettings(chatId).isPinned;
  }

  /// Check if a conversation is archived
  bool isArchived(String chatId) {
    return getSettings(chatId).isArchived;
  }

  /// Check if notifications are enabled for a conversation
  bool areNotificationsEnabled(String chatId) {
    return getSettings(chatId).notificationsEnabled;
  }
}
