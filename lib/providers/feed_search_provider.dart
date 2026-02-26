import 'package:flutter/foundation.dart';
import '../models/feed/post_model.dart';
import '../models/feed/post_type.dart';
import '../models/search/feed_search_result.dart';
import '../models/search/text_range.dart';
import '../providers/feed_provider.dart';
import '../utils/text_parser.dart';

/// Provider pour la recherche avancée dans le feed
/// 
/// Fonctionnalités :
/// - Recherche en temps réel dans les posts
/// - Filtrage par hashtags, mentions, auteurs
/// - Recherche par type de contenu
/// - Historique des recherches
/// - Suggestions de recherche
/// - Recherche vocale (hooks prêts)
/// 
/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
class FeedSearchProvider extends ChangeNotifier {
  // État privé
  String _query = '';
  List<FeedSearchResult> _searchResults = [];
  List<PostModel> _filteredPosts = [];
  final List<String> _searchHistory = [];
  final List<String> _trendingHashtags = [];
  final List<String> _suggestedUsers = [];
  
  // Filtres de recherche
  Set<PostType> _selectedPostTypes = {};
  Set<String> _selectedAuthors = {};
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _includeComments = true;
  
  // État de chargement
  bool _isSearching = false;
  bool _hasSearched = false;
  
  // Référence au FeedProvider
  FeedProvider? _feedProvider;

  /// Constructeur
  FeedSearchProvider() {
    _loadTrendingHashtags();
    _loadSuggestedUsers();
  }

  // Getters publics

  /// Query de recherche actuelle
  String get query => _query;
  
  /// Résultats de recherche
  List<FeedSearchResult> get searchResults => List.unmodifiable(_searchResults);
  
  /// Posts filtrés
  List<PostModel> get filteredPosts => List.unmodifiable(_filteredPosts);
  
  /// Historique des recherches
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  
  /// Hashtags tendances
  List<String> get trendingHashtags => List.unmodifiable(_trendingHashtags);
  
  /// Utilisateurs suggérés
  List<String> get suggestedUsers => List.unmodifiable(_suggestedUsers);
  
  /// Types de posts sélectionnés pour le filtre
  Set<PostType> get selectedPostTypes => Set.unmodifiable(_selectedPostTypes);
  
  /// Auteurs sélectionnés pour le filtre
  Set<String> get selectedAuthors => Set.unmodifiable(_selectedAuthors);
  
  /// Date de début du filtre
  DateTime? get dateFrom => _dateFrom;
  
  /// Date de fin du filtre
  DateTime? get dateTo => _dateTo;
  
  /// Si les commentaires sont inclus dans la recherche
  bool get includeComments => _includeComments;
  
  /// État de recherche en cours
  bool get isSearching => _isSearching;
  
  /// Si une recherche a été effectuée
  bool get hasSearched => _hasSearched;
  
  /// Nombre de résultats trouvés
  int get resultCount => _searchResults.length;

  // Actions publiques

  /// Définit la référence au FeedProvider
  void setFeedProvider(FeedProvider feedProvider) {
    _feedProvider = feedProvider;
  }

  /// Effectue une recherche avec la query donnée
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }
    
    _query = query.trim();
    _isSearching = true;
    _hasSearched = true;
    notifyListeners();
    
    // Simuler une latence de recherche
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      // Ajouter à l'historique si ce n'est pas déjà présent
      if (!_searchHistory.contains(_query)) {
        _searchHistory.insert(0, _query);
        // Limiter l'historique à 20 éléments
        if (_searchHistory.length > 20) {
          _searchHistory.removeLast();
        }
      }
      
      // Effectuer la recherche
      await _performSearch();
      
    } catch (e) {
      debugPrint('Erreur lors de la recherche: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Recherche par hashtag
  Future<void> searchByHashtag(String hashtag) async {
    await search('#$hashtag');
  }

  /// Recherche par mention
  Future<void> searchByMention(String username) async {
    await search('@$username');
  }

  /// Recherche par auteur
  Future<void> searchByAuthor(String authorName) async {
    await search('auteur:$authorName');
  }

  /// Efface la recherche actuelle
  void clearSearch() {
    _query = '';
    _searchResults.clear();
    _filteredPosts.clear();
    _hasSearched = false;
    _isSearching = false;
    notifyListeners();
  }

  /// Ajoute un filtre par type de post
  void togglePostTypeFilter(PostType postType) {
    if (_selectedPostTypes.contains(postType)) {
      _selectedPostTypes.remove(postType);
    } else {
      _selectedPostTypes.add(postType);
    }
    
    if (_hasSearched) {
      _applyFilters();
    }
    notifyListeners();
  }

  /// Ajoute un filtre par auteur
  void toggleAuthorFilter(String authorId) {
    if (_selectedAuthors.contains(authorId)) {
      _selectedAuthors.remove(authorId);
    } else {
      _selectedAuthors.add(authorId);
    }
    
    if (_hasSearched) {
      _applyFilters();
    }
    notifyListeners();
  }

  /// Définit le filtre de date
  void setDateFilter(DateTime? from, DateTime? to) {
    _dateFrom = from;
    _dateTo = to;
    
    if (_hasSearched) {
      _applyFilters();
    }
    notifyListeners();
  }

  /// Bascule l'inclusion des commentaires
  void toggleIncludeComments() {
    _includeComments = !_includeComments;
    
    if (_hasSearched) {
      _performSearch();
    }
    notifyListeners();
  }

  /// Efface tous les filtres
  void clearFilters() {
    _selectedPostTypes.clear();
    _selectedAuthors.clear();
    _dateFrom = null;
    _dateTo = null;
    _includeComments = true;
    
    if (_hasSearched) {
      _applyFilters();
    }
    notifyListeners();
  }

  /// Supprime un élément de l'historique
  void removeFromHistory(String query) {
    _searchHistory.remove(query);
    notifyListeners();
  }

  /// Efface tout l'historique
  void clearHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  /// Retourne les suggestions de recherche basées sur la query partielle
  List<String> getSuggestions(String partialQuery) {
    if (partialQuery.isEmpty) return [];
    
    final suggestions = <String>[];
    final lowerQuery = partialQuery.toLowerCase();
    
    // Suggestions depuis l'historique
    for (final historyItem in _searchHistory) {
      if (historyItem.toLowerCase().contains(lowerQuery)) {
        suggestions.add(historyItem);
      }
    }
    
    // Suggestions de hashtags
    if (partialQuery.startsWith('#')) {
      final hashtagQuery = partialQuery.substring(1).toLowerCase();
      for (final hashtag in _trendingHashtags) {
        if (hashtag.toLowerCase().contains(hashtagQuery)) {
          suggestions.add('#$hashtag');
        }
      }
    }
    
    // Suggestions d'utilisateurs
    if (partialQuery.startsWith('@')) {
      final userQuery = partialQuery.substring(1).toLowerCase();
      for (final user in _suggestedUsers) {
        if (user.toLowerCase().contains(userQuery)) {
          suggestions.add('@$user');
        }
      }
    }
    
    // Limiter à 10 suggestions
    return suggestions.take(10).toList();
  }

  /// Retourne les hashtags populaires dans les résultats
  Map<String, int> getPopularHashtagsInResults() {
    final hashtagCounts = <String, int>{};
    
    for (final result in _searchResults) {
      if (result.post.hashtags.isNotEmpty) {
        for (final hashtag in result.post.hashtags) {
          hashtagCounts[hashtag] = (hashtagCounts[hashtag] ?? 0) + 1;
        }
      }
    }
    
    // Trier par popularité
    final sortedEntries = hashtagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(10));
  }

  /// Retourne les auteurs les plus actifs dans les résultats
  Map<String, int> getActiveAuthorsInResults() {
    final authorCounts = <String, int>{};
    
    for (final result in _searchResults) {
      final authorName = result.post.authorName;
      authorCounts[authorName] = (authorCounts[authorName] ?? 0) + 1;
    }
    
    // Trier par activité
    final sortedEntries = authorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(10));
  }

  // Méthodes privées

  /// Effectue la recherche principale
  Future<void> _performSearch() async {
    if (_feedProvider == null) return;
    
    final allPosts = _feedProvider!.allPosts;
    final results = <FeedSearchResult>[];
    
    // Analyser la query pour détecter les types de recherche
    final searchTerms = _parseSearchQuery(_query);
    
    for (final post in allPosts) {
      final matchResult = _matchPost(post, searchTerms);
      if (matchResult != null) {
        results.add(matchResult);
      }
    }
    
    // Trier les résultats par pertinence puis par date
    results.sort((a, b) {
      final relevanceComparison = b.relevanceScore.compareTo(a.relevanceScore);
      if (relevanceComparison != 0) return relevanceComparison;
      return b.post.timestamp.compareTo(a.post.timestamp);
    });
    
    _searchResults = results;
    _applyFilters();
  }

  /// Parse la query de recherche pour extraire les termes spéciaux
  Map<String, dynamic> _parseSearchQuery(String query) {
    final terms = <String, dynamic>{
      'text': <String>[],
      'hashtags': <String>[],
      'mentions': <String>[],
      'authors': <String>[],
      'exact': <String>[],
    };
    
    // Extraire les hashtags
    final hashtags = TextParser.extractHashtags(query);
    terms['hashtags'] = hashtags;
    
    // Extraire les mentions
    final mentions = TextParser.extractMentions(query);
    terms['mentions'] = mentions;
    
    // Extraire les recherches d'auteur (auteur:nom)
    final authorMatches = RegExp(r'auteur:(\w+)').allMatches(query);
    for (final match in authorMatches) {
      terms['authors'].add(match.group(1)!);
    }
    
    // Extraire les phrases exactes (entre guillemets)
    final exactMatches = RegExp(r'"([^"]+)"').allMatches(query);
    for (final match in exactMatches) {
      terms['exact'].add(match.group(1)!);
    }
    
    // Extraire les termes de texte restants
    String remainingQuery = query;
    
    // Supprimer les éléments déjà extraits
    for (final hashtag in hashtags) {
      remainingQuery = remainingQuery.replaceAll('#$hashtag', '');
    }
    for (final mention in mentions) {
      remainingQuery = remainingQuery.replaceAll('@$mention', '');
    }
    for (final match in authorMatches) {
      remainingQuery = remainingQuery.replaceAll(match.group(0)!, '');
    }
    for (final match in exactMatches) {
      remainingQuery = remainingQuery.replaceAll(match.group(0)!, '');
    }
    
    // Diviser le texte restant en mots
    final textTerms = remainingQuery
        .split(RegExp(r'\s+'))
        .where((term) => term.trim().isNotEmpty)
        .map((term) => term.toLowerCase())
        .toList();
    
    terms['text'] = textTerms;
    
    return terms;
  }

  /// Vérifie si un post correspond aux termes de recherche
  FeedSearchResult? _matchPost(PostModel post, Map<String, dynamic> searchTerms) {
    double relevanceScore = 0.0;
    final matchedRanges = <TextRange>[];
    
    final textTerms = searchTerms['text'] as List<String>;
    final hashtags = searchTerms['hashtags'] as List<String>;
    final mentions = searchTerms['mentions'] as List<String>;
    final authors = searchTerms['authors'] as List<String>;
    final exactTerms = searchTerms['exact'] as List<String>;
    
    // Vérifier les hashtags
    if (hashtags.isNotEmpty) {
      for (final hashtag in hashtags) {
        if (post.hashtags.any((h) => h.toLowerCase().contains(hashtag.toLowerCase()))) {
          relevanceScore += 10.0; // Score élevé pour les hashtags
        }
      }
    }
    
    // Vérifier les mentions
    if (mentions.isNotEmpty) {
      for (final mention in mentions) {
        if (post.mentions.any((m) => m.toLowerCase().contains(mention.toLowerCase()))) {
          relevanceScore += 8.0;
        }
      }
    }
    
    // Vérifier les auteurs
    if (authors.isNotEmpty) {
      for (final author in authors) {
        if (post.authorName.toLowerCase().contains(author.toLowerCase())) {
          relevanceScore += 15.0; // Score très élevé pour l'auteur
        }
      }
    }
    
    // Vérifier les phrases exactes
    if (exactTerms.isNotEmpty) {
      for (final exactTerm in exactTerms) {
        if (post.content.toLowerCase().contains(exactTerm.toLowerCase())) {
          relevanceScore += 12.0;
          // Ajouter les ranges pour le surlignage
          _addMatchRanges(post.content, exactTerm, matchedRanges);
        }
      }
    }
    
    // Vérifier les termes de texte
    if (textTerms.isNotEmpty) {
      for (final term in textTerms) {
        // Recherche dans le contenu
        if (post.content.toLowerCase().contains(term)) {
          relevanceScore += 5.0;
          _addMatchRanges(post.content, term, matchedRanges);
        }
        
        // Recherche dans le nom de l'auteur
        if (post.authorName.toLowerCase().contains(term)) {
          relevanceScore += 3.0;
        }
        
        // Recherche dans les hashtags
        for (final hashtag in post.hashtags) {
          if (hashtag.toLowerCase().contains(term)) {
            relevanceScore += 4.0;
          }
        }
      }
    }
    
    // Si aucun terme spécifique, rechercher dans tout le contenu
    if (textTerms.isEmpty && hashtags.isEmpty && mentions.isEmpty && 
        authors.isEmpty && exactTerms.isEmpty) {
      final queryLower = _query.toLowerCase();
      if (post.content.toLowerCase().contains(queryLower)) {
        relevanceScore += 5.0;
        _addMatchRanges(post.content, _query, matchedRanges);
      }
      if (post.authorName.toLowerCase().contains(queryLower)) {
        relevanceScore += 3.0;
      }
    }
    
    // Bonus pour les posts récents
    final daysSincePost = DateTime.now().difference(post.timestamp).inDays;
    if (daysSincePost < 7) {
      relevanceScore += 2.0;
    } else if (daysSincePost < 30) {
      relevanceScore += 1.0;
    }
    
    // Bonus pour l'engagement
    relevanceScore += (post.totalEngagement * 0.1);
    
    // Retourner le résultat si pertinent
    if (relevanceScore > 0) {
      return FeedSearchResult(
        post: post,
        relevanceScore: relevanceScore,
        matchedRanges: matchedRanges,
        matchType: _determineMatchType(searchTerms),
      );
    }
    
    return null;
  }

  /// Ajoute les ranges de correspondance pour le surlignage
  void _addMatchRanges(String content, String term, List<TextRange> ranges) {
    final contentLower = content.toLowerCase();
    final termLower = term.toLowerCase();
    
    int startIndex = 0;
    while (true) {
      final index = contentLower.indexOf(termLower, startIndex);
      if (index == -1) break;
      
      ranges.add(TextRange(
        start: index,
        end: index + term.length,
      ));
      
      startIndex = index + 1;
    }
  }

  /// Détermine le type de correspondance
  String _determineMatchType(Map<String, dynamic> searchTerms) {
    if ((searchTerms['hashtags'] as List).isNotEmpty) return 'hashtag';
    if ((searchTerms['mentions'] as List).isNotEmpty) return 'mention';
    if ((searchTerms['authors'] as List).isNotEmpty) return 'author';
    if ((searchTerms['exact'] as List).isNotEmpty) return 'exact';
    return 'text';
  }

  /// Applique les filtres aux résultats de recherche
  void _applyFilters() {
    List<FeedSearchResult> filtered = List.from(_searchResults);
    
    // Filtre par type de post
    if (_selectedPostTypes.isNotEmpty) {
      filtered = filtered.where((result) => 
        _selectedPostTypes.contains(result.post.type)
      ).toList();
    }
    
    // Filtre par auteur
    if (_selectedAuthors.isNotEmpty) {
      filtered = filtered.where((result) => 
        _selectedAuthors.contains(result.post.authorId)
      ).toList();
    }
    
    // Filtre par date
    if (_dateFrom != null) {
      filtered = filtered.where((result) => 
        result.post.timestamp.isAfter(_dateFrom!)
      ).toList();
    }
    
    if (_dateTo != null) {
      filtered = filtered.where((result) => 
        result.post.timestamp.isBefore(_dateTo!.add(const Duration(days: 1)))
      ).toList();
    }
    
    // Convertir en posts filtrés
    _filteredPosts = filtered.map((result) => result.post).toList();
    
    notifyListeners();
  }

  /// Charge les hashtags tendances (simulé)
  void _loadTrendingHashtags() {
    _trendingHashtags.addAll([
      'Flutter',
      'Dev',
      'Programming',
      'Mobile',
      'UI',
      'UX',
      'Design',
      'Code',
      'Tech',
      'Innovation',
      'Gaming',
      'AI',
      'MachineLearning',
      'WebDev',
      'OpenSource',
    ]);
  }

  /// Charge les utilisateurs suggérés (simulé)
  void _loadSuggestedUsers() {
    _suggestedUsers.addAll([
      'alistairjr',
      't4zor',
      'tkporky',
      'sophiemartin',
      'lucasdubois',
      'progamer42',
      'ninjakiller',
      'emmaleroy',
      'maxpower',
      'juliebernard',
    ]);
  }

  /// Réinitialise le provider
  void reset() {
    _query = '';
    _searchResults.clear();
    _filteredPosts.clear();
    _searchHistory.clear();
    _selectedPostTypes.clear();
    _selectedAuthors.clear();
    _dateFrom = null;
    _dateTo = null;
    _includeComments = true;
    _isSearching = false;
    _hasSearched = false;
    notifyListeners();
  }
}