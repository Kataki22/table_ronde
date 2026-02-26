import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_search_provider.dart';
import '../../models/search/feed_search_result.dart';
import '../../models/feed/post_type.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import 'advanced_post_card.dart';

/// Widget d'affichage des résultats de recherche dans le feed
/// 
/// Fonctionnalités :
/// - Affichage des posts avec surlignage des correspondances
/// - Statistiques de recherche (nombre de résultats, temps)
/// - Filtres avancés intégrés
/// - Tri par pertinence ou date
/// - Navigation vers hashtags et mentions
/// - Gestion des états vides et d'erreur
/// 
/// **Validates: Requirements 3.1, 3.3, 3.4**
class FeedSearchResults extends StatefulWidget {
  /// Callback appelé lors du tap sur un profil
  final Function(String userId)? onProfileTap;
  
  /// Callback appelé lors du tap sur un hashtag
  final Function(String hashtag)? onHashtagTap;
  
  /// Callback appelé lors du tap sur une mention
  final Function(String mention)? onMentionTap;
  
  /// Si true, affiche les filtres avancés
  final bool showAdvancedFilters;
  
  /// Si true, affiche les statistiques de recherche
  final bool showSearchStats;

  const FeedSearchResults({
    super.key,
    this.onProfileTap,
    this.onHashtagTap,
    this.onMentionTap,
    this.showAdvancedFilters = true,
    this.showSearchStats = true,
  });

  @override
  State<FeedSearchResults> createState() => _FeedSearchResultsState();
}

class _FeedSearchResultsState extends State<FeedSearchResults>
    with SingleTickerProviderStateMixin {
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation pour l'apparition des résultats
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedSearchProvider>(
      builder: (context, searchProvider, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Statistiques et filtres
                if (searchProvider.hasSearched) ...[
                  if (widget.showSearchStats)
                    _buildSearchStats(searchProvider),
                  
                  if (widget.showAdvancedFilters)
                    _buildAdvancedFilters(searchProvider),
                ],
                
                // Contenu principal
                Expanded(
                  child: _buildContent(searchProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construit les statistiques de recherche
  Widget _buildSearchStats(FeedSearchProvider searchProvider) {
    if (!searchProvider.hasSearched) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.themeColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.themeColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Résultats principaux
          Row(
            children: [
              Icon(
                Icons.search,
                size: 16,
                color: context.themeColors.colorPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.bodyMedium.copyWith(
                      color: context.themeColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: '${searchProvider.resultCount} résultat${searchProvider.resultCount > 1 ? 's' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (searchProvider.query.isNotEmpty) ...[
                        const TextSpan(text: ' pour '),
                        TextSpan(
                          text: '"${searchProvider.query}"',
                          style: TextStyle(
                            color: context.themeColors.colorPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Bouton d'effacement
              IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 18,
                  color: context.themeColors.textSecondary,
                ),
                onPressed: () {
                  searchProvider.clearSearch();
                },
                tooltip: 'Effacer la recherche',
              ),
            ],
          ),
          
          // Statistiques détaillées
          if (searchProvider.resultCount > 0) ...[
            const SizedBox(height: 12),
            _buildDetailedStats(searchProvider),
          ],
        ],
      ),
    );
  }

  /// Construit les statistiques détaillées
  Widget _buildDetailedStats(FeedSearchProvider searchProvider) {
    final popularHashtags = searchProvider.getPopularHashtagsInResults();
    final activeAuthors = searchProvider.getActiveAuthorsInResults();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hashtags populaires dans les résultats
        if (popularHashtags.isNotEmpty) ...[
          Text(
            'Hashtags populaires :',
            style: AppTheme.bodySmall.copyWith(
              color: context.themeColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: popularHashtags.entries.take(5).map((entry) {
              return GestureDetector(
                onTap: () {
                  searchProvider.searchByHashtag(entry.key);
                  if (widget.onHashtagTap != null) {
                    widget.onHashtagTap!(entry.key);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DA1F2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1DA1F2).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#${entry.key}',
                        style: AppTheme.bodySmall.copyWith(
                          color: const Color(0xFF1DA1F2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.value}',
                        style: AppTheme.bodySmall.copyWith(
                          color: context.themeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        
        // Auteurs actifs dans les résultats
        if (activeAuthors.isNotEmpty) ...[
          Text(
            'Auteurs les plus actifs :',
            style: AppTheme.bodySmall.copyWith(
              color: context.themeColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: activeAuthors.entries.take(3).map((entry) {
              return GestureDetector(
                onTap: () {
                  searchProvider.searchByAuthor(entry.key);
                  if (widget.onProfileTap != null) {
                    // Trouver l'ID utilisateur depuis le nom (simulation)
                    widget.onProfileTap!('user_${entry.key.toLowerCase()}');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.key,
                        style: AppTheme.bodySmall.copyWith(
                          color: const Color(0xFF9C27B0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.value}',
                        style: AppTheme.bodySmall.copyWith(
                          color: context.themeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// Construit les filtres avancés
  Widget _buildAdvancedFilters(FeedSearchProvider searchProvider) {
    if (!searchProvider.hasSearched || searchProvider.resultCount == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête des filtres
          Row(
            children: [
              Icon(
                Icons.tune,
                size: 16,
                color: context.themeColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtres avancés',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              
              // Bouton d'effacement des filtres
              if (_hasActiveFilters(searchProvider))
                TextButton(
                  onPressed: searchProvider.clearFilters,
                  child: Text(
                    'Effacer',
                    style: AppTheme.bodySmall.copyWith(
                      color: context.themeColors.colorPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Filtres par type de post
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildFilterChip(
                'Texte',
                searchProvider.selectedPostTypes.contains(PostType.text),
                () => searchProvider.togglePostTypeFilter(PostType.text),
                Icons.text_fields,
              ),
              _buildFilterChip(
                'Images',
                searchProvider.selectedPostTypes.contains(PostType.image),
                () => searchProvider.togglePostTypeFilter(PostType.image),
                Icons.image,
              ),
              _buildFilterChip(
                'Vidéos',
                searchProvider.selectedPostTypes.contains(PostType.video),
                () => searchProvider.togglePostTypeFilter(PostType.video),
                Icons.videocam,
              ),
              _buildFilterChip(
                'GIFs',
                searchProvider.selectedPostTypes.contains(PostType.gif),
                () => searchProvider.togglePostTypeFilter(PostType.gif),
                Icons.gif,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construit un chip de filtre
  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? context.themeColors.colorPrimary 
              : context.themeColors.bgTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? context.themeColors.colorPrimary 
                : context.themeColors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected 
                  ? Colors.white 
                  : context.themeColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: isSelected 
                    ? Colors.white 
                    : context.themeColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le contenu principal
  Widget _buildContent(FeedSearchProvider searchProvider) {
    if (searchProvider.isSearching) {
      return _buildLoadingState();
    }
    
    if (!searchProvider.hasSearched) {
      return _buildInitialState();
    }
    
    if (searchProvider.resultCount == 0) {
      return _buildEmptyState(searchProvider);
    }
    
    return _buildResultsList(searchProvider);
  }

  /// Construit l'état de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              context.themeColors.colorPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recherche en cours...',
            style: AppTheme.bodyMedium.copyWith(
              color: context.themeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit l'état initial (pas de recherche)
  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: context.themeColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Rechercher dans le feed',
              style: AppTheme.headingMedium.copyWith(
                color: context.themeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Utilisez la barre de recherche pour trouver des posts, hashtags ou mentions',
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Exemples de recherche
            _buildSearchExamples(),
          ],
        ),
      ),
    );
  }

  /// Construit les exemples de recherche
  Widget _buildSearchExamples() {
    final examples = [
      {'text': '#Flutter', 'icon': Icons.tag, 'color': const Color(0xFF1DA1F2)},
      {'text': '@alistairjr', 'icon': Icons.alternate_email, 'color': const Color(0xFF9C27B0)},
      {'text': 'auteur:Sophie', 'icon': Icons.person, 'color': const Color(0xFF4CAF50)},
      {'text': '"phrase exacte"', 'icon': Icons.format_quote, 'color': const Color(0xFFFF9800)},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exemples de recherche :',
          style: AppTheme.bodySmall.copyWith(
            color: context.themeColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...examples.map((example) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  example['icon'] as IconData,
                  size: 14,
                  color: example['color'] as Color,
                ),
                const SizedBox(width: 8),
                Text(
                  example['text'] as String,
                  style: AppTheme.bodySmall.copyWith(
                    color: example['color'] as Color,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Construit l'état vide (aucun résultat)
  Widget _buildEmptyState(FeedSearchProvider searchProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: context.themeColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: AppTheme.headingMedium.copyWith(
                color: context.themeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez avec d\'autres mots-clés ou vérifiez l\'orthographe',
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Suggestions d'amélioration
            _buildSearchSuggestions(searchProvider),
          ],
        ),
      ),
    );
  }

  /// Construit les suggestions d'amélioration de recherche
  Widget _buildSearchSuggestions(FeedSearchProvider searchProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions :',
          style: AppTheme.bodySmall.copyWith(
            color: context.themeColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...const [
          '• Utilisez des mots-clés plus généraux',
          '• Vérifiez l\'orthographe',
          '• Essayez des hashtags populaires',
          '• Recherchez par nom d\'utilisateur',
        ].map((suggestion) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              suggestion,
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Construit la liste des résultats
  Widget _buildResultsList(FeedSearchProvider searchProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: searchProvider.filteredPosts.length,
      itemBuilder: (context, index) {
        final post = searchProvider.filteredPosts[index];
        final searchResult = searchProvider.searchResults
            .firstWhere((result) => result.post.id == post.id);
        
        return _buildSearchResultCard(searchResult);
      },
    );
  }

  /// Construit une carte de résultat de recherche
  Widget _buildSearchResultCard(FeedSearchResult searchResult) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicateur de pertinence et type de correspondance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.themeColors.colorPrimary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(
                color: context.themeColors.colorPrimary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  searchResult.matchTypeIcon,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  searchResult.matchTypeDescription,
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.colorPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Pertinence: ${searchResult.relevanceScore.toInt()}%',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Post avec surlignage
          AdvancedPostCard(
            post: searchResult.post,
            highlightRanges: searchResult.matchedRanges,
            onProfileTap: widget.onProfileTap,
            onHashtagTap: widget.onHashtagTap,
          ),
        ],
      ),
    );
  }

  /// Vérifie si des filtres sont actifs
  bool _hasActiveFilters(FeedSearchProvider searchProvider) {
    return searchProvider.selectedPostTypes.isNotEmpty ||
           searchProvider.selectedAuthors.isNotEmpty ||
           searchProvider.dateFrom != null ||
           searchProvider.dateTo != null;
  }
}

