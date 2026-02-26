import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_search_provider.dart';
import '../../providers/feed_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';

/// Widget de navigation pour hashtags et mentions
/// 
/// Fonctionnalités :
/// - Affichage des hashtags tendances
/// - Liste des utilisateurs suggérés
/// - Navigation rapide vers les recherches
/// - Statistiques d'utilisation
/// - Découverte de contenu
/// 
/// **Validates: Requirements 3.2, 3.4**
class HashtagMentionNavigator extends StatefulWidget {
  /// Callback appelé lors de la sélection d'un hashtag
  final Function(String hashtag)? onHashtagSelected;
  
  /// Callback appelé lors de la sélection d'une mention
  final Function(String mention)? onMentionSelected;
  
  /// Si true, affiche les hashtags tendances
  final bool showTrendingHashtags;
  
  /// Si true, affiche les utilisateurs suggérés
  final bool showSuggestedUsers;
  
  /// Nombre maximum d'éléments à afficher
  final int maxItems;

  const HashtagMentionNavigator({
    super.key,
    this.onHashtagSelected,
    this.onMentionSelected,
    this.showTrendingHashtags = true,
    this.showSuggestedUsers = true,
    this.maxItems = 10,
  });

  @override
  State<HashtagMentionNavigator> createState() => _HashtagMentionNavigatorState();
}

class _HashtagMentionNavigatorState extends State<HashtagMentionNavigator>
    with SingleTickerProviderStateMixin {
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // État
  String _selectedTab = 'hashtags'; // 'hashtags' ou 'mentions'

  @override
  void initState() {
    super.initState();
    
    // Animation pour l'apparition
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
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer2<FeedSearchProvider, FeedProvider>(
        builder: (context, searchProvider, feedProvider, child) {
          return Container(
            decoration: BoxDecoration(
              color: context.themeColors.bgPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.themeColors.borderSubtle,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec onglets
                _buildHeader(),
                
                // Contenu selon l'onglet sélectionné
                Expanded(
                  child: _selectedTab == 'hashtags'
                      ? _buildHashtagsContent(searchProvider, feedProvider)
                      : _buildMentionsContent(searchProvider, feedProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construit l'en-tête avec les onglets
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.themeColors.borderSubtle,
          ),
        ),
      ),
      child: Row(
        children: [
          // Titre
          Text(
            'Découvrir',
            style: AppTheme.headingSmall.copyWith(
              color: context.themeColors.textPrimary,
            ),
          ),
          const Spacer(),
          
          // Onglets
          Container(
            decoration: BoxDecoration(
              color: context.themeColors.bgSecondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabButton(
                  'hashtags',
                  'Hashtags',
                  Icons.tag,
                ),
                _buildTabButton(
                  'mentions',
                  'Utilisateurs',
                  Icons.people,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un bouton d'onglet
  Widget _buildTabButton(String tabId, String label, IconData icon) {
    final isSelected = _selectedTab == tabId;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? context.themeColors.colorPrimary 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? Colors.white 
                  : context.themeColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: isSelected 
                    ? Colors.white 
                    : context.themeColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le contenu des hashtags
  Widget _buildHashtagsContent(
    FeedSearchProvider searchProvider,
    FeedProvider feedProvider,
  ) {
    if (!widget.showTrendingHashtags) {
      return _buildEmptyState('Hashtags désactivés');
    }
    
    final trendingHashtags = searchProvider.trendingHashtags;
    
    if (trendingHashtags.isEmpty) {
      return _buildEmptyState('Aucun hashtag tendance');
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section hashtags tendances
        _buildSectionHeader(
          'Hashtags tendances',
          Icons.trending_up,
          const Color(0xFF1DA1F2),
        ),
        const SizedBox(height: 12),
        
        ...trendingHashtags.take(widget.maxItems).map((hashtag) {
          return _buildHashtagItem(hashtag, searchProvider, feedProvider);
        }).toList(),
        
        const SizedBox(height: 24),
        
        // Section hashtags récents dans les résultats
        if (searchProvider.hasSearched && searchProvider.resultCount > 0) ...[
          _buildSectionHeader(
            'Dans vos résultats',
            Icons.search,
            context.themeColors.colorPrimary,
          ),
          const SizedBox(height: 12),
          
          ...searchProvider.getPopularHashtagsInResults().entries
              .take(5)
              .map((entry) {
            return _buildHashtagResultItem(
              entry.key,
              entry.value,
              searchProvider,
            );
          }).toList(),
        ],
      ],
    );
  }

  /// Construit le contenu des mentions
  Widget _buildMentionsContent(
    FeedSearchProvider searchProvider,
    FeedProvider feedProvider,
  ) {
    if (!widget.showSuggestedUsers) {
      return _buildEmptyState('Utilisateurs désactivés');
    }
    
    final suggestedUsers = searchProvider.suggestedUsers;
    
    if (suggestedUsers.isEmpty) {
      return _buildEmptyState('Aucun utilisateur suggéré');
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section utilisateurs suggérés
        _buildSectionHeader(
          'Utilisateurs suggérés',
          Icons.people_outline,
          const Color(0xFF9C27B0),
        ),
        const SizedBox(height: 12),
        
        ...suggestedUsers.take(widget.maxItems).map((user) {
          return _buildUserItem(user, searchProvider, feedProvider);
        }).toList(),
        
        const SizedBox(height: 24),
        
        // Section utilisateurs actifs dans les résultats
        if (searchProvider.hasSearched && searchProvider.resultCount > 0) ...[
          _buildSectionHeader(
            'Auteurs actifs',
            Icons.edit,
            context.themeColors.colorPrimary,
          ),
          const SizedBox(height: 12),
          
          ...searchProvider.getActiveAuthorsInResults().entries
              .take(5)
              .map((entry) {
            return _buildAuthorResultItem(
              entry.key,
              entry.value,
              searchProvider,
            );
          }).toList(),
        ],
      ],
    );
  }

  /// Construit un en-tête de section
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.bodyMedium.copyWith(
            color: context.themeColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Construit un élément de hashtag
  Widget _buildHashtagItem(
    String hashtag,
    FeedSearchProvider searchProvider,
    FeedProvider feedProvider,
  ) {
    // Calculer le nombre de posts avec ce hashtag (simulation)
    final postCount = _getHashtagPostCount(hashtag, feedProvider);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          searchProvider.searchByHashtag(hashtag);
          if (widget.onHashtagSelected != null) {
            widget.onHashtagSelected!(hashtag);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icône hashtag
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DA1F2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '#',
                    style: TextStyle(
                      color: Color(0xFF1DA1F2),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#$hashtag',
                      style: AppTheme.bodyMedium.copyWith(
                        color: const Color(0xFF1DA1F2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$postCount post${postCount > 1 ? 's' : ''}',
                      style: AppTheme.bodySmall.copyWith(
                        color: context.themeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Flèche
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: context.themeColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un élément d'utilisateur
  Widget _buildUserItem(
    String username,
    FeedSearchProvider searchProvider,
    FeedProvider feedProvider,
  ) {
    // Calculer le nombre de posts de cet utilisateur (simulation)
    final postCount = _getUserPostCount(username, feedProvider);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          searchProvider.searchByMention(username);
          if (widget.onMentionSelected != null) {
            widget.onMentionSelected!(username);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF9C27B0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$username',
                      style: AppTheme.bodyMedium.copyWith(
                        color: const Color(0xFF9C27B0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$postCount post${postCount > 1 ? 's' : ''}',
                      style: AppTheme.bodySmall.copyWith(
                        color: context.themeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Flèche
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: context.themeColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un élément de hashtag dans les résultats
  Widget _buildHashtagResultItem(
    String hashtag,
    int count,
    FeedSearchProvider searchProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () {
          searchProvider.searchByHashtag(hashtag);
          if (widget.onHashtagSelected != null) {
            widget.onHashtagSelected!(hashtag);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Text(
                '#$hashtag',
                style: AppTheme.bodySmall.copyWith(
                  color: const Color(0xFF1DA1F2),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.colorPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un élément d'auteur dans les résultats
  Widget _buildAuthorResultItem(
    String author,
    int count,
    FeedSearchProvider searchProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () {
          searchProvider.searchByAuthor(author);
          if (widget.onMentionSelected != null) {
            widget.onMentionSelected!(author);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Text(
                author,
                style: AppTheme.bodySmall.copyWith(
                  color: const Color(0xFF9C27B0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.colorPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'état vide
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off,
              size: 48,
              color: context.themeColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Calcule le nombre de posts avec un hashtag (simulation)
  int _getHashtagPostCount(String hashtag, FeedProvider feedProvider) {
    return feedProvider.allPosts
        .where((post) => post.hashtags.any((h) => 
            h.toLowerCase() == hashtag.toLowerCase()))
        .length;
  }

  /// Calcule le nombre de posts d'un utilisateur (simulation)
  int _getUserPostCount(String username, FeedProvider feedProvider) {
    return feedProvider.allPosts
        .where((post) => post.authorName.toLowerCase() == username.toLowerCase())
        .length;
  }
}