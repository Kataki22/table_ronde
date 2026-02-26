import '../models/feed/reaction_model.dart';
import '../models/feed/reaction_type.dart';
import '../utils/avatar_helper.dart';

/// Données mockées pour les réactions sur les posts
/// Contient des réactions réalistes pour chaque post avec distribution variée
class MockReactionsData {
  static final DateTime _now = DateTime.now();

  /// Réactions organisées par post ID
  static final Map<String, List<ReactionModel>> reactionsByPost = _generateReactionsByPost();

  /// Génère des réactions pour chaque post
  static Map<String, List<ReactionModel>> _generateReactionsByPost() {
    final Map<String, List<ReactionModel>> reactions = {};

    // Post 1: AlistairJr - Post technique populaire
    reactions['post_1'] = [
      ReactionModel(
        id: 'reaction_1_1',
        postId: 'post_1',
        userId: 'user_2',
        userName: 'T4zor',
        userAvatar: 'assets/images/Avatar2.png',
        type: ReactionType.like,
        timestamp: _now.subtract(const Duration(minutes: 10)),
      ),
      ReactionModel(
        id: 'reaction_1_2',
        postId: 'post_1',
        userId: 'user_3',
        userName: 'Tk-Porky',
        userAvatar: AvatarHelper.getRandomAvatar(),
        type: ReactionType.wow,
        timestamp: _now.subtract(const Duration(minutes: 8)),
      ),
      ReactionModel(
        id: 'reaction_1_3',
        postId: 'post_1',
        userId: 'user_4',
        userName: 'Sophie Martin',
        userAvatar: AvatarHelper.getRandomAvatar(),
        type: ReactionType.love,
        timestamp: _now.subtract(const Duration(minutes: 5)),
      ),
      // Ajouter plus de réactions pour atteindre 42 au total
      ...List.generate(39, (index) {
        return ReactionModel(
          id: 'reaction_1_${index + 4}',
          postId: 'post_1',
          userId: 'user_${(index % 20) + 1}',
          userName: 'User ${(index % 20) + 1}',
          userAvatar: AvatarHelper.getRandomAvatar(),
          type: _getRandomReactionType(index),
          timestamp: _now.subtract(Duration(minutes: index + 1)),
        );
      }),
    ];

    // Post 2: T4zor - Post gaming drôle
    reactions['post_2'] = [
      ReactionModel(
        id: 'reaction_2_1',
        postId: 'post_2',
        userId: 'user_1',
        userName: 'AlistairJr',
        userAvatar: 'assets/images/Avatar1.png',
        type: ReactionType.laugh,
        timestamp: _now.subtract(const Duration(hours: 1, minutes: 30)),
      ),
      ReactionModel(
        id: 'reaction_2_2',
        postId: 'post_2',
        userId: 'user_6',
        userName: 'ProGamer42',
        userAvatar: AvatarHelper.getRandomAvatar(),
        type: ReactionType.laugh,
        timestamp: _now.subtract(const Duration(hours: 1, minutes: 25)),
      ),
      ReactionModel(
        id: 'reaction_2_3',
        postId: 'post_2',
        userId: 'user_7',
        userName: 'NinjaKiller',
        userAvatar: AvatarHelper.getRandomAvatar(),
        type: ReactionType.like,
        timestamp: _now.subtract(const Duration(hours: 1, minutes: 20)),
      ),
      // Ajouter plus de réactions pour atteindre 89 au total
      ...List.generate(86, (index) {
        return ReactionModel(
          id: 'reaction_2_${index + 4}',
          postId: 'post_2',
          userId: 'user_${(index % 25) + 1}',
          userName: 'User ${(index % 25) + 1}',
          userAvatar: AvatarHelper.getRandomAvatar(),
          type: _getRandomReactionType(index, favorLaugh: true),
          timestamp: _now.subtract(Duration(hours: 1, minutes: index + 1)),
        );
      }),
    ];

    // Post 3: Tk-Porky - Post inspirant
    reactions['post_3'] = [
      ReactionModel(
        id: 'reaction_3_1',
        postId: 'post_3',
        userId: 'user_1',
        userName: 'AlistairJr',
        userAvatar: 'assets/images/Avatar1.png',
        type: ReactionType.love,
        timestamp: _now.subtract(const Duration(hours: 3, minutes: 30)),
      ),
      ReactionModel(
        id: 'reaction_3_2',
        postId: 'post_3',
        userId: 'user_8',
        userName: 'Emma Leroy',
        userAvatar: AvatarHelper.getRandomAvatar(),
        type: ReactionType.wow,
        timestamp: _now.subtract(const Duration(hours: 3, minutes: 25)),
      ),
      // Ajouter plus de réactions pour atteindre 67 au total
      ...List.generate(65, (index) {
        return ReactionModel(
          id: 'reaction_3_${index + 3}',
          postId: 'post_3',
          userId: 'user_${(index % 20) + 1}',
          userName: 'User ${(index % 20) + 1}',
          userAvatar: AvatarHelper.getRandomAvatar(),
          type: _getRandomReactionType(index, favorLove: true),
          timestamp: _now.subtract(Duration(hours: 3, minutes: index + 1)),
        );
      }),
    ];

    // Post 4: Sophie Martin - Post professionnel
    reactions['post_4'] = [
      ReactionModel(
        id: 'reaction_4_1',
        postId: 'post_4',
        userId: 'user_1',
        userName: 'AlistairJr',
        userAvatar: 'assets/images/Avatar1.png',
        type: ReactionType.like,
        timestamp: _now.subtract(const Duration(hours: 5, minutes: 30)),
      ),
      ReactionModel(
        id: 'reaction_4_2',
        postId: 'post_4',
        userId: 'user_2',
        userName: 'T4zor',
        userAvatar: 'assets/images/Avatar2.png',
        type: ReactionType.like,
        timestamp: _now.subtract(const Duration(hours: 5, minutes: 25)),
      ),
      // Ajouter plus de réactions pour atteindre 34 au total
      ...List.generate(32, (index) {
        return ReactionModel(
          id: 'reaction_4_${index + 3}',
          postId: 'post_4',
          userId: 'user_${(index % 15) + 1}',
          userName: 'User ${(index % 15) + 1}',
          userAvatar: AvatarHelper.getRandomAvatar(),
          type: _getRandomReactionType(index, favorLike: true),
          timestamp: _now.subtract(Duration(hours: 5, minutes: index + 1)),
        );
      }),
    ];

    // Post 5: Lucas Dubois - Tutoriel vidéo populaire
    reactions['post_5'] = [
      ReactionModel(
        id: 'reaction_5_1',
        postId: 'post_5',
        userId: 'user_1',
        userName: 'AlistairJr',
        userAvatar: 'assets/images/Avatar1.png',
        type: ReactionType.love,
        timestamp: _now.subtract(const Duration(hours: 7, minutes: 30)),
      ),
      ReactionModel(
        id: 'reaction_5_2',
        postId: 'post_5',
        userId: 'user_4',
        userName: 'Sophie Martin',
        userAvatar: AvatarHelper.getRandomAvatar(),
        type: ReactionType.wow,
        timestamp: _now.subtract(const Duration(hours: 7, minutes: 25)),
      ),
      // Ajouter plus de réactions pour atteindre 156 au total
      ...List.generate(154, (index) {
        return ReactionModel(
          id: 'reaction_5_${index + 3}',
          postId: 'post_5',
          userId: 'user_${(index % 30) + 1}',
          userName: 'User ${(index % 30) + 1}',
          userAvatar: AvatarHelper.getRandomAvatar(),
          type: _getRandomReactionType(index, favorWow: true),
          timestamp: _now.subtract(Duration(hours: 7, minutes: index + 1)),
        );
      }),
    ];

    // Générer des réactions pour les autres posts (6-50)
    for (int postIndex = 6; postIndex <= 50; postIndex++) {
      final postId = 'post_$postIndex';
      final reactionCount = 10 + (postIndex % 50); // Nombre variable de réactions
      
      reactions[postId] = List.generate(reactionCount, (index) {
        return ReactionModel(
          id: 'reaction_${postIndex}_${index + 1}',
          postId: postId,
          userId: 'user_${(index % 25) + 1}',
          userName: 'User ${(index % 25) + 1}',
          userAvatar: AvatarHelper.getRandomAvatar(),
          type: _getRandomReactionType(index + postIndex),
          timestamp: _now.subtract(Duration(hours: postIndex, minutes: index + 1)),
        );
      });
    }

    return reactions;
  }

  /// Génère un type de réaction aléatoire avec des préférences optionnelles
  static ReactionType _getRandomReactionType(
    int seed, {
    bool favorLike = false,
    bool favorLove = false,
    bool favorLaugh = false,
    bool favorWow = false,
  }) {
    // Distribution normale : like (40%), love (20%), laugh (15%), wow (10%), sad (8%), angry (7%)
    final random = (seed * 17 + 42) % 100;
    
    if (favorLike) {
      if (random < 60) return ReactionType.like;
      if (random < 75) return ReactionType.love;
      if (random < 85) return ReactionType.wow;
      if (random < 92) return ReactionType.laugh;
      if (random < 97) return ReactionType.sad;
      return ReactionType.angry;
    }
    
    if (favorLove) {
      if (random < 45) return ReactionType.love;
      if (random < 70) return ReactionType.like;
      if (random < 80) return ReactionType.wow;
      if (random < 88) return ReactionType.laugh;
      if (random < 94) return ReactionType.sad;
      return ReactionType.angry;
    }
    
    if (favorLaugh) {
      if (random < 50) return ReactionType.laugh;
      if (random < 70) return ReactionType.like;
      if (random < 80) return ReactionType.love;
      if (random < 88) return ReactionType.wow;
      if (random < 94) return ReactionType.sad;
      return ReactionType.angry;
    }
    
    if (favorWow) {
      if (random < 40) return ReactionType.wow;
      if (random < 65) return ReactionType.like;
      if (random < 80) return ReactionType.love;
      if (random < 88) return ReactionType.laugh;
      if (random < 94) return ReactionType.sad;
      return ReactionType.angry;
    }
    
    // Distribution normale
    if (random < 40) return ReactionType.like;
    if (random < 60) return ReactionType.love;
    if (random < 75) return ReactionType.laugh;
    if (random < 85) return ReactionType.wow;
    if (random < 93) return ReactionType.sad;
    return ReactionType.angry;
  }

  /// Retourne les réactions pour un post spécifique
  static List<ReactionModel> getReactionsForPost(String postId) {
    return reactionsByPost[postId] ?? [];
  }

  /// Retourne le nombre de réactions par type pour un post
  static Map<ReactionType, int> getReactionCountsByType(String postId) {
    final reactions = getReactionsForPost(postId);
    final Map<ReactionType, int> counts = {};
    
    for (final reaction in reactions) {
      counts[reaction.type] = (counts[reaction.type] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Retourne la réaction de l'utilisateur actuel pour un post (si elle existe)
  static ReactionModel? getUserReactionForPost(String postId, String userId) {
    final reactions = getReactionsForPost(postId);
    try {
      return reactions.firstWhere((reaction) => reaction.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si l'utilisateur actuel a réagi à un post
  static bool hasUserReacted(String postId, String userId) {
    return getUserReactionForPost(postId, userId) != null;
  }

  /// Retourne le type de réaction de l'utilisateur actuel pour un post
  static ReactionType? getUserReactionType(String postId, String userId) {
    final reaction = getUserReactionForPost(postId, userId);
    return reaction?.type;
  }

  /// Retourne les utilisateurs qui ont réagi avec un type spécifique
  static List<ReactionModel> getReactionsByType(String postId, ReactionType type) {
    final reactions = getReactionsForPost(postId);
    return reactions.where((reaction) => reaction.type == type).toList();
  }

  /// Retourne le nombre total de réactions pour un post
  static int getTotalReactionCount(String postId) {
    return getReactionsForPost(postId).length;
  }
}