import 'package:flutter/foundation.dart';
import '../models/feed/post_model.dart';
import '../services/api_service.dart';

/// Provider pour gérer les posts via l'API
/// 
/// Ce provider remplace les données mock par des données provenant du serveur JSON
class ApiPostsProvider with ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Charge tous les posts depuis l'API
  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await ApiService.getPosts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _posts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée un nouveau post
  Future<bool> createPost(PostModel post) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdPost = await ApiService.createPost(post);
      _posts.insert(0, createdPost);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Met à jour un post existant
  Future<bool> updatePost(String id, PostModel post) async {
    try {
      final updatedPost = await ApiService.updatePost(id, post);
      final index = _posts.indexWhere((p) => p.id == id);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Supprime un post
  Future<bool> deletePost(String id) async {
    try {
      await ApiService.deletePost(id);
      _posts.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Ajoute une réaction à un post
  Future<bool> toggleReaction(String postId) async {
    final post = _posts.firstWhere((p) => p.id == postId);
    final updatedPost = post.copyWith(
      hasReacted: !post.hasReacted,
      reactionCount: post.hasReacted 
          ? post.reactionCount - 1 
          : post.reactionCount + 1,
    );
    return await updatePost(postId, updatedPost);
  }

  /// Sauvegarde/désauvegarde un post
  Future<bool> toggleSave(String postId) async {
    final post = _posts.firstWhere((p) => p.id == postId);
    final updatedPost = post.copyWith(isSaved: !post.isSaved);
    return await updatePost(postId, updatedPost);
  }

  /// Incrémente le nombre de partages
  Future<bool> sharePost(String postId) async {
    final post = _posts.firstWhere((p) => p.id == postId);
    final updatedPost = post.copyWith(shareCount: post.shareCount + 1);
    return await updatePost(postId, updatedPost);
  }

  /// Incrémente le nombre de vues
  Future<bool> incrementViews(String postId) async {
    final post = _posts.firstWhere((p) => p.id == postId);
    final updatedPost = post.copyWith(
      viewCount: (post.viewCount ?? 0) + 1,
    );
    return await updatePost(postId, updatedPost);
  }

  /// Recherche des posts par contenu
  List<PostModel> searchPosts(String query) {
    if (query.isEmpty) return _posts;
    
    final lowerQuery = query.toLowerCase();
    return _posts.where((post) {
      return post.content.toLowerCase().contains(lowerQuery) ||
             post.authorName.toLowerCase().contains(lowerQuery) ||
             post.hashtags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Filtre les posts par auteur
  List<PostModel> getPostsByAuthor(String authorId) {
    return _posts.where((post) => post.authorId == authorId).toList();
  }

  /// Filtre les posts par hashtag
  List<PostModel> getPostsByHashtag(String hashtag) {
    return _posts.where((post) => 
      post.hashtags.any((tag) => tag.toLowerCase() == hashtag.toLowerCase())
    ).toList();
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Rafraîchit les posts
  Future<void> refresh() async {
    await loadPosts();
  }
}
