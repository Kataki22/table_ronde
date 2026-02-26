import 'package:flutter/foundation.dart';
import '../models/feed/post_model.dart';
import '../models/feed/post_type.dart';
import '../models/feed/reaction_model.dart';
import '../models/feed/reaction_type.dart';
import '../models/feed/comment_model.dart';
import '../models/auth/user_model.dart';
import '../services/api_service.dart';
import '../utils/text_parser.dart';

/// Provider pour la gestion du feed social
/// Gère l'affichage, la création, et les interactions avec les posts
class FeedProvider extends ChangeNotifier {
  // État privé
  List<PostModel> _posts = [];
  List<PostModel> _filteredPosts = [];
  final Map<String, List<ReactionModel>> _reactionsByPost = {};
  final Map<String, List<CommentModel>> _commentsByPost = {};
  final Set<String> _savedPostIds = {};
  
  // Paramètres de filtrage et tri
  String _selectedFilter = 'all'; // all, following, trending, saved
  String _selectedSort = 'recent'; // recent, popular, trending
  PostType? _selectedPostType; // null = tous les types
  
  // État de chargement et erreur
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  String? _error;
  
  // Utilisateur actuel
  UserModel? _currentUser;
  
  // Pagination
  int _currentPage = 0;

  /// Constructeur
  FeedProvider();

  /// Synchronise avec l'utilisateur authentifié
  void syncWithAuthUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Getters publics

  /// Liste des posts filtrés et triés
  List<PostModel> get posts => List.unmodifiable(_filteredPosts);
  
  /// Liste complète des posts (non filtrés)
  List<PostModel> get allPosts => List.unmodifiable(_posts);
  
  /// Filtre actuellement sélectionné
  String get selectedFilter => _selectedFilter;
  
  /// Tri actuellement sélectionné
  String get selectedSort => _selectedSort;
  
  /// Type de post filtré (null = tous)
  PostType? get selectedPostType => _selectedPostType;
  
  /// État de chargement
  bool get isLoading => _isLoading;
  
  /// État de chargement de plus de posts
  bool get isLoadingMore => _isLoadingMore;
  
  /// Si il y a plus de posts à charger
  bool get hasMorePosts => _hasMorePosts;
  
  /// Message d'erreur s'il y en a un
  String? get error => _error;
  
  /// ID de l'utilisateur actuel
  String get currentUserId => _currentUser?.id ?? 'user_1';
  
  /// Posts sauvegardés
  Set<String> get savedPostIds => Set.unmodifiable(_savedPostIds);

  // Actions publiques

  /// Charge les posts depuis l'API
  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final posts = await ApiService.getPosts();
      _posts = posts;
      
      // Charger les réactions pour chaque post
      for (final post in _posts) {
        try {
          final reactions = await ApiService.getReactions(post.id);
          _reactionsByPost[post.id] = reactions;
        } catch (e) {
          // Continuer même si le chargement des réactions échoue
          _reactionsByPost[post.id] = [];
        }
      }
      
      _applyFiltersAndSort();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraîchit le feed (pull-to-refresh)
  Future<void> refreshPosts() async {
    _currentPage = 0;
    _hasMorePosts = true;
    await loadPosts();
  }
  
  /// Alias pour compatibilité
  Future<void> refreshFeed() => refreshPosts();

  /// Charge plus de posts (pagination infinie)
  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts) return;

    _isLoadingMore = true;
    notifyListeners();

    // Simuler une latence réseau
    await Future.delayed(const Duration(milliseconds: 500));

    _currentPage++;
    
    // Simuler qu'il n'y a plus de posts après la page 5
    if (_currentPage >= 5) {
      _hasMorePosts = false;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Crée un nouveau post
  Future<PostModel> createPost({
    required String content,
    List<String>? imageUrls,
    String? videoUrl,
    String? gifUrl,
    String? location,
  }) async {
    // Extraire hashtags et mentions
    final hashtags = TextParser.extractHashtags(content);
    final mentions = TextParser.extractMentions(content);

    // Déterminer le type de post
    PostType type = PostType.text;
    if (imageUrls?.isNotEmpty ?? false) {
      type = PostType.image;
    } else if (videoUrl != null) {
      type = PostType.video;
    } else if (gifUrl != null) {
      type = PostType.gif;
    }

    // Créer le nouveau post
    final newPost = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: _currentUser?.id ?? 'user_1',
      authorName: _currentUser?.name ?? 'Utilisateur',
      authorUsername: _currentUser?.username ?? '@utilisateur',
      authorAvatar: _currentUser?.avatarUrl ?? 'assets/images/Avatar1.png',
      isAuthorVerified: true,
      content: content,
      imageUrls: imageUrls,
      videoUrl: videoUrl,
      gifUrl: gifUrl,
      timestamp: DateTime.now(),
      type: type,
      hashtags: hashtags,
      mentions: mentions,
      location: location,
    );

    // Optimistic update: ajouter le post localement d'abord
    _posts.insert(0, newPost);
    _applyFiltersAndSort();
    notifyListeners();

    try {
      // Envoyer à l'API
      final createdPost = await ApiService.createPost(newPost);
      
      // Remplacer le post temporaire par celui de l'API
      final index = _posts.indexWhere((p) => p.id == newPost.id);
      if (index != -1) {
        _posts[index] = createdPost;
        _applyFiltersAndSort();
        notifyListeners();
      }
      
      return createdPost;
    } catch (e) {
      // Rollback en cas d'erreur
      _posts.removeWhere((p) => p.id == newPost.id);
      _applyFiltersAndSort();
      notifyListeners();
      rethrow;
    }
  }

  /// Ajoute ou modifie une réaction sur un post
  Future<void> reactToPost(String postId, ReactionType reactionType) async {
    // Simuler une latence réseau
    await Future.delayed(const Duration(milliseconds: 200));

    // Trouver le post
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    final reactions = _reactionsByPost[postId] ?? [];

    // Vérifier si l'utilisateur a déjà réagi
    final existingReactionIndex = reactions.indexWhere(
      (reaction) => reaction.userId == (_currentUser?.id ?? 'user_1'),
    );

    if (existingReactionIndex != -1) {
      // Modifier la réaction existante ou la supprimer si c'est la même
      final existingReaction = reactions[existingReactionIndex];
      if (existingReaction.type == reactionType) {
        // Supprimer la réaction
        reactions.removeAt(existingReactionIndex);
        _posts[postIndex] = post.copyWith(
          reactionCount: post.reactionCount - 1,
          hasReacted: false,
          userReactionType: null,
        );
      } else {
        // Modifier la réaction
        reactions[existingReactionIndex] = existingReaction.copyWith(
          type: reactionType,
          timestamp: DateTime.now(),
        );
        _posts[postIndex] = post.copyWith(
          userReactionType: reactionType.name,
        );
      }
    } else {
      // Ajouter une nouvelle réaction
      final newReaction = ReactionModel(
        id: 'reaction_${postId}_${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        userId: _currentUser?.id ?? 'user_1',
        userName: _currentUser?.name ?? 'Utilisateur',
        userAvatar: _currentUser?.avatarUrl ?? 'assets/images/Avatar1.png',
        type: reactionType,
        timestamp: DateTime.now(),
      );
      
      reactions.add(newReaction);
      _posts[postIndex] = post.copyWith(
        reactionCount: post.reactionCount + 1,
        hasReacted: true,
        userReactionType: reactionType.name,
      );
    }

    _reactionsByPost[postId] = reactions;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Ajoute un commentaire à un post
  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    // Simuler une latence réseau
    await Future.delayed(const Duration(milliseconds: 300));

    // Extraire hashtags et mentions
    final hashtags = TextParser.extractHashtags(content);
    final mentions = TextParser.extractMentions(content);

    // Créer le nouveau commentaire
    final newComment = CommentModel(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      parentCommentId: parentCommentId,
      authorId: _currentUser?.id ?? 'user_1',
      authorName: _currentUser?.name ?? 'Utilisateur',
      authorAvatar: _currentUser?.avatarUrl ?? 'assets/images/Avatar1.png',
      content: content,
      timestamp: DateTime.now(),
      hashtags: hashtags,
      mentions: mentions,
    );

    // Ajouter le commentaire à la liste
    if (!_commentsByPost.containsKey(postId)) {
      _commentsByPost[postId] = [];
    }
    _commentsByPost[postId]!.add(newComment);

    // Mettre à jour le compteur de commentaires du post
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = post.copyWith(
        commentCount: post.commentCount + 1,
      );
    }

    _applyFiltersAndSort();
    notifyListeners();

    return newComment;
  }

  /// Partage un post
  Future<PostModel> sharePost(String originalPostId, {String? comment}) async {
    // Simuler une latence réseau
    await Future.delayed(const Duration(milliseconds: 400));

    // Trouver le post original
    final originalPost = _posts.firstWhere((post) => post.id == originalPostId);

    // Créer le post de partage
    final sharePost = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: _currentUser?.id ?? 'user_1',
      authorName: _currentUser?.name ?? 'Utilisateur',
      authorUsername: _currentUser?.username ?? '@utilisateur',
      authorAvatar: 'assets/images/Avatar1.png',
      isAuthorVerified: true,
      content: comment ?? 'Post partagé',
      timestamp: DateTime.now(),
      type: PostType.share,
      originalPostId: originalPostId,
      originalPost: originalPost,
    );

    // Ajouter le post en début de liste
    _posts.insert(0, sharePost);

    // Mettre à jour le compteur de partages du post original
    final originalPostIndex = _posts.indexWhere((post) => post.id == originalPostId);
    if (originalPostIndex != -1) {
      final post = _posts[originalPostIndex];
      _posts[originalPostIndex] = post.copyWith(
        shareCount: post.shareCount + 1,
      );
    }

    _applyFiltersAndSort();
    notifyListeners();

    return sharePost;
  }

  /// Sauvegarde ou désauvegarde un post
  void toggleSavePost(String postId) {
    if (_savedPostIds.contains(postId)) {
      _savedPostIds.remove(postId);
    } else {
      _savedPostIds.add(postId);
    }

    // Mettre à jour le post
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = post.copyWith(
        isSaved: _savedPostIds.contains(postId),
      );
    }

    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Supprime un post (si l'utilisateur en est l'auteur)
  Future<void> deletePost(String postId) async {
    // Vérifier que l'utilisateur est l'auteur
    final post = _posts.firstWhere((post) => post.id == postId);
    if (post.authorId != (_currentUser?.id ?? 'user_1')) {
      throw Exception('Vous ne pouvez supprimer que vos propres posts');
    }

    // Sauvegarder pour rollback potentiel
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    final deletedPost = _posts[postIndex];
    final deletedReactions = _reactionsByPost[postId];
    final deletedComments = _commentsByPost[postId];
    final wasSaved = _savedPostIds.contains(postId);

    // Optimistic update: supprimer localement d'abord
    _posts.removeAt(postIndex);
    _reactionsByPost.remove(postId);
    _commentsByPost.remove(postId);
    _savedPostIds.remove(postId);
    _applyFiltersAndSort();
    notifyListeners();

    try {
      // Supprimer via l'API
      await ApiService.deletePost(postId);
    } catch (e) {
      // Rollback en cas d'erreur
      _posts.insert(postIndex, deletedPost);
      if (deletedReactions != null) {
        _reactionsByPost[postId] = deletedReactions;
      }
      if (deletedComments != null) {
        _commentsByPost[postId] = deletedComments;
      }
      if (wasSaved) {
        _savedPostIds.add(postId);
      }
      _applyFiltersAndSort();
      notifyListeners();
      rethrow;
    }
  }

  /// Change le filtre du feed
  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      _applyFiltersAndSort();
      notifyListeners();
    }
  }

  /// Change le tri du feed
  void setSort(String sort) {
    if (_selectedSort != sort) {
      _selectedSort = sort;
      _applyFiltersAndSort();
      notifyListeners();
    }
  }

  /// Filtre par type de post
  void setPostTypeFilter(PostType? postType) {
    if (_selectedPostType != postType) {
      _selectedPostType = postType;
      _applyFiltersAndSort();
      notifyListeners();
    }
  }

  /// Applique les filtres et le tri aux posts
  void _applyFiltersAndSort() {
    List<PostModel> filtered = List.from(_posts);

    // Appliquer le filtre principal
    switch (_selectedFilter) {
      case 'following':
        // Simuler un filtre "abonnements" (posts des utilisateurs suivis)
        filtered = filtered.where((post) => 
          ['user_1', 'user_2', 'user_3', 'user_4'].contains(post.authorId)
        ).toList();
        break;
      case 'trending':
        // Filtrer les posts populaires (plus de 50 réactions)
        filtered = filtered.where((post) => post.reactionCount > 50).toList();
        break;
      case 'saved':
        // Filtrer les posts sauvegardés
        filtered = filtered.where((post) => _savedPostIds.contains(post.id)).toList();
        break;
      case 'all':
      default:
        // Pas de filtre
        break;
    }

    // Appliquer le filtre par type de post
    if (_selectedPostType != null) {
      filtered = filtered.where((post) => post.type == _selectedPostType).toList();
    }

    // Appliquer le tri
    switch (_selectedSort) {
      case 'popular':
        filtered.sort((a, b) => b.totalEngagement.compareTo(a.totalEngagement));
        break;
      case 'trending':
        // Tri par engagement récent (posts récents avec beaucoup d'interactions)
        filtered.sort((a, b) {
          final aScore = a.totalEngagement / (DateTime.now().difference(a.timestamp).inHours + 1);
          final bScore = b.totalEngagement / (DateTime.now().difference(b.timestamp).inHours + 1);
          return bScore.compareTo(aScore);
        });
        break;
      case 'recent':
      default:
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
    }

    _filteredPosts = filtered;
  }

  /// Retourne les réactions pour un post
  List<ReactionModel> getReactionsForPost(String postId) {
    return _reactionsByPost[postId] ?? [];
  }

  /// Retourne les commentaires pour un post
  List<CommentModel> getCommentsForPost(String postId) {
    return _commentsByPost[postId] ?? [];
  }

  /// Vérifie si l'utilisateur a réagi à un post
  bool hasUserReacted(String postId) {
    final reactions = getReactionsForPost(postId);
    return reactions.any((reaction) => reaction.userId == (_currentUser?.id ?? 'user_1'));
  }

  /// Retourne le type de réaction de l'utilisateur pour un post
  ReactionType? getUserReactionType(String postId) {
    final reactions = getReactionsForPost(postId);
    try {
      final userReaction = reactions.firstWhere(
        (reaction) => reaction.userId == (_currentUser?.id ?? 'user_1'),
      );
      return userReaction.type;
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si un post est sauvegardé
  bool isPostSaved(String postId) {
    return _savedPostIds.contains(postId);
  }

  /// Réinitialise le provider et recharge depuis l'API
  Future<void> reset() async {
    _posts.clear();
    _filteredPosts.clear();
    _reactionsByPost.clear();
    _commentsByPost.clear();
    _savedPostIds.clear();
    _selectedFilter = 'all';
    _selectedSort = 'recent';
    _selectedPostType = null;
    _isLoading = false;
    _isLoadingMore = false;
    _hasMorePosts = true;
    _currentPage = 0;
    _error = null;
    
    await loadPosts();
  }
}