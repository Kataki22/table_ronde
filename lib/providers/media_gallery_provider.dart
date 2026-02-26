import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/media/media_item.dart';
import '../models/media/media_type.dart';
import '../services/api_service.dart';

/// Provider pour la galerie de médias
/// Gère l'affichage et le téléchargement des médias partagés
/// 
/// Validates: Requirements 5.2, 5.3, 5.6, 5.7, 7.1, 7.2
class MediaGalleryProvider extends ChangeNotifier {
  /// Map of media items organized by chat ID
  final Map<String, List<MediaItem>> _mediaByChat = {};
  
  /// Currently selected tab in the media gallery
  MediaType _selectedTab = MediaType.photo;
  
  /// Currently opened media item for full-screen viewing
  MediaItem? _currentMediaItem;
  
  /// Gallery of media items for the current viewer session
  List<MediaItem> _currentGallery = [];
  
  /// Set of media IDs currently being downloaded
  final Set<String> _downloadingMedia = {};
  
  /// Random number generator for simulating download failures
  final Random _random = Random();
  
  /// Loading and error states
  bool _isLoading = false;
  String? _error;

  /// Get loading status
  bool get isLoading => _isLoading;
  
  /// Get error message
  String? get error => _error;
  
  /// Get the currently selected tab
  MediaType get selectedTab => _selectedTab;
  
  /// Get the currently opened media item
  MediaItem? get currentMediaItem => _currentMediaItem;
  
  /// Get the current gallery for viewer
  List<MediaItem> get currentGallery => List.unmodifiable(_currentGallery);
  
  /// Check if a media item is currently being downloaded
  bool isDownloading(String mediaId) => _downloadingMedia.contains(mediaId);

  /// Charge les médias pour un chat spécifique depuis l'API
  Future<void> loadMediaForChat(String chatId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final mediaItems = await ApiService.getMediaByChat(chatId);
      _mediaByChat[chatId] = mediaItems;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get all media items for a specific chat filtered by type
  /// Validates: Requirements 5.2
  List<MediaItem> getMediaForChat(String chatId, MediaType type) {
    final allMedia = _mediaByChat[chatId] ?? [];
    return allMedia.where((item) => item.type == type).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first (descending)
  }

  /// Get all photos for a specific chat
  /// Validates: Requirements 5.2, 5.3
  List<MediaItem> getPhotos(String chatId) {
    return getMediaForChat(chatId, MediaType.photo);
  }

  /// Get all videos for a specific chat
  /// Validates: Requirements 5.2, 5.3
  List<MediaItem> getVideos(String chatId) {
    return getMediaForChat(chatId, MediaType.video);
  }

  /// Get all documents for a specific chat
  /// Validates: Requirements 5.2, 5.4
  List<MediaItem> getDocuments(String chatId) {
    return getMediaForChat(chatId, MediaType.document);
  }

  /// Get all links for a specific chat
  /// Validates: Requirements 5.2, 5.4
  List<MediaItem> getLinks(String chatId) {
    return getMediaForChat(chatId, MediaType.link);
  }

  /// Get all voice messages for a specific chat
  /// Validates: Requirements 5.2, 5.4
  List<MediaItem> getVoiceMessages(String chatId) {
    return getMediaForChat(chatId, MediaType.voice);
  }

  /// Select a tab in the media gallery
  /// Validates: Requirements 5.2
  void selectTab(MediaType type) {
    if (_selectedTab != type) {
      _selectedTab = type;
      notifyListeners();
    }
  }

  /// Upload un nouveau média via l'API
  Future<MediaItem> uploadMedia(String chatId, MediaItem media) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uploadedMedia = await ApiService.uploadMedia(media);
      
      // Ajouter le média au cache local
      if (!_mediaByChat.containsKey(chatId)) {
        _mediaByChat[chatId] = [];
      }
      _mediaByChat[chatId]!.add(uploadedMedia);
      
      // Trier par timestamp décroissant
      _mediaByChat[chatId]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _isLoading = false;
      notifyListeners();
      
      return uploadedMedia;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Supprime un média via l'API
  Future<void> deleteMedia(String mediaId, String chatId) async {
    // Sauvegarder pour rollback
    final mediaList = _mediaByChat[chatId];
    final index = mediaList?.indexWhere((m) => m.id == mediaId) ?? -1;
    final deletedMedia = index != -1 ? mediaList![index] : null;
    
    if (deletedMedia == null) return;

    // Suppression optimiste
    mediaList!.removeAt(index);
    notifyListeners();

    try {
      await ApiService.deleteMedia(mediaId);
    } catch (e) {
      // Rollback en cas d'erreur
      mediaList.insert(index, deletedMedia);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Download a media item with simulated download process
  /// Simulates a 10% failure rate as per design requirements
  /// Validates: Requirements 5.6, 5.7
  Future<bool> downloadMedia(MediaItem item) async {
    // Check if already downloading
    if (_downloadingMedia.contains(item.id)) {
      debugPrint('Media ${item.id} is already being downloaded');
      return false;
    }

    // Add to downloading set
    _downloadingMedia.add(item.id);
    notifyListeners();

    try {
      // Simulate download time based on file size
      final downloadDuration = _calculateDownloadDuration(item.fileSize);
      await Future.delayed(downloadDuration);

      // Simulate 10% failure rate
      final shouldFail = _random.nextInt(100) < 10;
      
      if (shouldFail) {
        debugPrint('Simulated download failure for media ${item.id}');
        return false;
      }

      debugPrint('Successfully downloaded media ${item.id}');
      return true;
    } finally {
      // Remove from downloading set
      _downloadingMedia.remove(item.id);
      notifyListeners();
    }
  }

  /// Calculate simulated download duration based on file size
  Duration _calculateDownloadDuration(int? fileSize) {
    if (fileSize == null) {
      return const Duration(milliseconds: 500);
    }

    // Simulate download speed of ~2MB/s
    // Minimum 300ms, maximum 5s
    final seconds = (fileSize / (2 * 1024 * 1024)).clamp(0.3, 5.0);
    return Duration(milliseconds: (seconds * 1000).toInt());
  }

  /// Open media viewer for full-screen preview
  /// Validates: Requirements 5.5
  void openMediaViewer(MediaItem item, List<MediaItem> gallery) {
    _currentMediaItem = item;
    _currentGallery = List.from(gallery);
    notifyListeners();
  }

  /// Close the media viewer
  void closeMediaViewer() {
    _currentMediaItem = null;
    _currentGallery = [];
    notifyListeners();
  }

  /// Navigate to the next media item in the viewer
  /// Validates: Requirements 5.5
  void navigateToNextMedia() {
    if (_currentMediaItem == null || _currentGallery.isEmpty) return;

    final currentIndex = _currentGallery.indexWhere(
      (item) => item.id == _currentMediaItem!.id,
    );

    if (currentIndex == -1) return;

    // Wrap around to the beginning if at the end
    final nextIndex = (currentIndex + 1) % _currentGallery.length;
    _currentMediaItem = _currentGallery[nextIndex];
    notifyListeners();
  }

  /// Navigate to the previous media item in the viewer
  /// Validates: Requirements 5.5
  void navigateToPreviousMedia() {
    if (_currentMediaItem == null || _currentGallery.isEmpty) return;

    final currentIndex = _currentGallery.indexWhere(
      (item) => item.id == _currentMediaItem!.id,
    );

    if (currentIndex == -1) return;

    // Wrap around to the end if at the beginning
    final previousIndex = 
        (currentIndex - 1 + _currentGallery.length) % _currentGallery.length;
    _currentMediaItem = _currentGallery[previousIndex];
    notifyListeners();
  }

  /// Get the current index in the gallery (1-based for display)
  int get currentMediaIndex {
    if (_currentMediaItem == null || _currentGallery.isEmpty) return 0;
    
    final index = _currentGallery.indexWhere(
      (item) => item.id == _currentMediaItem!.id,
    );
    
    return index == -1 ? 0 : index + 1;
  }

  /// Get the total count of items in the current gallery
  int get galleryItemCount => _currentGallery.length;

  /// Get count of media items by type for a specific chat
  int getMediaCount(String chatId, MediaType type) {
    return getMediaForChat(chatId, type).length;
  }

  /// Get total count of all media items for a specific chat
  int getTotalMediaCount(String chatId) {
    final allMedia = _mediaByChat[chatId] ?? [];
    return allMedia.length;
  }

  /// Check if a chat has any media
  bool hasMedia(String chatId) {
    return (_mediaByChat[chatId]?.isNotEmpty ?? false);
  }

  /// Clear all data (useful for testing or logout)
  void clear() {
    _mediaByChat.clear();
    _selectedTab = MediaType.photo;
    _currentMediaItem = null;
    _currentGallery = [];
    _downloadingMedia.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
