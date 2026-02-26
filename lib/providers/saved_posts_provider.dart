import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/feed/post_model.dart';
import '../models/feed/post_type.dart';

/// Provider pour la gestion des posts sauvegardés
/// Gère la sauvegarde locale des posts favoris de l'utilisateur
class SavedPostsProvider extends ChangeNotifier {
  // État privé
  final Set<String> _savedPostIds = {};
  final Map<String, PostModel> _savedPosts = {};
  bool _isLoading = false;
  
  // Clé pour la persistance locale
  static const String _savedPostsKey = 'saved_posts';
  static const String _savedPostIdsKey = 'saved_post_ids';

  /// Constructeur - charge les posts sauvegardés depuis le stockage local
  SavedPostsProvider() {
    _loadSavedPosts();
  }

  // Getters publics

  /// IDs des posts sauvegardés
  Set<String> get savedPostIds => Set.unmodifiable(_savedPostIds);
  
  /// Posts sauvegardés complets
  List<PostModel> get savedPosts => _savedPosts.values.toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Plus récents en premier
  
  /// Nombre de posts sauvegardés
  int get savedPostsCount => _savedPostIds.length;
  
  /// État de chargement
  bool get isLoading => _isLoading;

  // Actions publiques

  /// Sauvegarde un post
  Future<void> savePost(PostModel post) async {
    if (_savedPostIds.contains(post.id)) return; // Déjà sauvegardé

    _savedPostIds.add(post.id);
    _savedPosts[post.id] = post.copyWith(isSaved: true);
    
    await _persistSavedPosts();
    notifyListeners();
  }

  /// Supprime un post des sauvegardés
  Future<void> unsavePost(String postId) async {
    if (!_savedPostIds.contains(postId)) return; // Pas sauvegardé

    _savedPostIds.remove(postId);
    _savedPosts.remove(postId);
    
    await _persistSavedPosts();
    notifyListeners();
  }

  /// Bascule l'état de sauvegarde d'un post
  Future<void> toggleSavePost(PostModel post) async {
    if (isPostSaved(post.id)) {
      await unsavePost(post.id);
    } else {
      await savePost(post);
    }
  }

  /// Vérifie si un post est sauvegardé
  bool isPostSaved(String postId) {
    return _savedPostIds.contains(postId);
  }

  /// Récupère un post sauvegardé par son ID
  PostModel? getSavedPost(String postId) {
    return _savedPosts[postId];
  }

  /// Supprime tous les posts sauvegardés
  Future<void> clearAllSavedPosts() async {
    _savedPostIds.clear();
    _savedPosts.clear();
    
    await _persistSavedPosts();
    notifyListeners();
  }

  /// Exporte les posts sauvegardés (pour sauvegarde/partage)
  Map<String, dynamic> exportSavedPosts() {
    return {
      'savedPostIds': _savedPostIds.toList(),
      'savedPosts': _savedPosts.map((key, value) => MapEntry(key, value.toJson())),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// Importe des posts sauvegardés (depuis une sauvegarde)
  Future<void> importSavedPosts(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Vérifier la version
      final version = data['version'] as String?;
      if (version != '1.0') {
        throw Exception('Version de sauvegarde non supportée: $version');
      }

      // Importer les IDs
      final savedPostIds = (data['savedPostIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet() ?? <String>{};

      // Importer les posts
      final savedPostsData = data['savedPosts'] as Map<String, dynamic>? ?? {};
      final Map<String, PostModel> savedPosts = {};
      
      for (final entry in savedPostsData.entries) {
        try {
          savedPosts[entry.key] = PostModel.fromJson(entry.value as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Erreur lors de l\'import du post ${entry.key}: $e');
        }
      }

      // Appliquer les données importées
      _savedPostIds.clear();
      _savedPostIds.addAll(savedPostIds);
      _savedPosts.clear();
      _savedPosts.addAll(savedPosts);

      await _persistSavedPosts();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Filtre les posts sauvegardés par hashtag
  List<PostModel> getSavedPostsByHashtag(String hashtag) {
    return savedPosts
        .where((post) => post.hashtags.contains(hashtag))
        .toList();
  }

  /// Filtre les posts sauvegardés par auteur
  List<PostModel> getSavedPostsByAuthor(String authorId) {
    return savedPosts
        .where((post) => post.authorId == authorId)
        .toList();
  }

  /// Filtre les posts sauvegardés par type
  List<PostModel> getSavedPostsByType(PostType type) {
    return savedPosts
        .where((post) => post.type == type)
        .toList();
  }

  /// Recherche dans les posts sauvegardés
  List<PostModel> searchSavedPosts(String query) {
    if (query.trim().isEmpty) return savedPosts;
    
    final lowerQuery = query.toLowerCase();
    return savedPosts.where((post) {
      return post.content.toLowerCase().contains(lowerQuery) ||
             post.authorName.toLowerCase().contains(lowerQuery) ||
             post.hashtags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Obtient les hashtags les plus utilisés dans les posts sauvegardés
  Map<String, int> getMostUsedHashtags({int limit = 10}) {
    final Map<String, int> hashtagCounts = {};
    
    for (final post in savedPosts) {
      for (final hashtag in post.hashtags) {
        hashtagCounts[hashtag] = (hashtagCounts[hashtag] ?? 0) + 1;
      }
    }
    
    // Trier par nombre d'occurrences et limiter
    final sortedEntries = hashtagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(limit));
  }

  /// Obtient les auteurs les plus sauvegardés
  Map<String, int> getMostSavedAuthors({int limit = 10}) {
    final Map<String, int> authorCounts = {};
    
    for (final post in savedPosts) {
      authorCounts[post.authorName] = (authorCounts[post.authorName] ?? 0) + 1;
    }
    
    // Trier par nombre d'occurrences et limiter
    final sortedEntries = authorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(limit));
  }

  // Méthodes privées

  /// Charge les posts sauvegardés depuis le stockage local
  Future<void> _loadSavedPosts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      
      // Charger les IDs des posts sauvegardés
      final savedPostIdsJson = prefs.getString(_savedPostIdsKey);
      if (savedPostIdsJson != null) {
        final List<dynamic> savedPostIdsList = json.decode(savedPostIdsJson);
        _savedPostIds.addAll(savedPostIdsList.map((e) => e as String));
      }
      
      // Charger les posts complets
      final savedPostsJson = prefs.getString(_savedPostsKey);
      if (savedPostsJson != null) {
        final Map<String, dynamic> savedPostsData = json.decode(savedPostsJson);
        for (final entry in savedPostsData.entries) {
          try {
            _savedPosts[entry.key] = PostModel.fromJson(entry.value as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Erreur lors du chargement du post sauvegardé ${entry.key}: $e');
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Erreur lors du chargement des posts sauvegardés: $e');
    }
  }

  /// Persiste les posts sauvegardés dans le stockage local
  Future<void> _persistSavedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Sauvegarder les IDs
      final savedPostIdsJson = json.encode(_savedPostIds.toList());
      await prefs.setString(_savedPostIdsKey, savedPostIdsJson);
      
      // Sauvegarder les posts complets
      final savedPostsData = _savedPosts.map((key, value) => MapEntry(key, value.toJson()));
      final savedPostsJson = json.encode(savedPostsData);
      await prefs.setString(_savedPostsKey, savedPostsJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des posts: $e');
    }
  }

  /// Nettoie les posts sauvegardés obsolètes (plus de 30 jours)
  Future<void> cleanupOldSavedPosts({int maxDays = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: maxDays));
    final postsToRemove = <String>[];
    
    for (final entry in _savedPosts.entries) {
      if (entry.value.timestamp.isBefore(cutoffDate)) {
        postsToRemove.add(entry.key);
      }
    }
    
    for (final postId in postsToRemove) {
      _savedPostIds.remove(postId);
      _savedPosts.remove(postId);
    }
    
    if (postsToRemove.isNotEmpty) {
      await _persistSavedPosts();
      notifyListeners();
    }
  }

  /// Réinitialise le provider
  void reset() {
    _savedPostIds.clear();
    _savedPosts.clear();
    _isLoading = false;
    notifyListeners();
  }
}