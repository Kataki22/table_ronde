import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/saved_posts_provider.dart';
import '../../models/feed/post_type.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import 'create_post_widget.dart';
import 'advanced_post_card.dart';

/// Widget de feed complet avec toutes les fonctionnalités avancées
/// 
/// Fonctionnalités :
/// - Création de posts intégrée
/// - Filtres et tri avancés
/// - Pull-to-refresh et pagination infinie
/// - Posts avec toutes les interactions sociales
/// - Animations fluides
/// - Gestion d'état optimisée
/// 
/// **Validates: Requirements 1.1, 1.2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6**
class CompleteFeedWidget extends StatefulWidget {
  /// Si true, affiche le widget de création de post
  final bool showCreatePost;
  
  /// Si true, affiche les filtres rapides
  final bool showFilters;
  
  /// Si true, permet le pull-to-refresh
  final bool enableRefresh;
  
  /// Si true, active la pagination infinie
  final bool enableInfiniteScroll;
  
  /// Callback appelé lors de la navigation vers un profil
  final Function(String userId)? onProfileTap;
  
  /// Callback appelé lors de la navigation vers un hashtag
  final Function(String hashtag)? onHashtagTap;

  const CompleteFeedWidget({
    super.key,
    this.showCreatePost = true,
    this.showFilters = true,
    this.enableRefresh = true,
    this.enableInfiniteScroll = true,
    this.onProfileTap,
    this.onHashtagTap,
  });

  @override
  State<CompleteFeedWidget> createState() => _CompleteFeedWidgetState();
}

class _CompleteFeedWidgetState extends State<CompleteFeedWidget>
    with SingleTickerProviderStateMixin {
  // Controllers
  final ScrollController _scrollController = ScrollController();
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // État
  bool _showCreatePostExpanded = false;

  @override
  void initState() {
    super.initState();
    
    // Animation pour l'apparition du feed
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Écouter le scroll pour la pagination infinie
    if (widget.enableInfiniteScroll) {
      _scrollController.addListener(_onScroll);
    }
    
    // Démarrer l'animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.enableInfiniteScroll) {
      _scrollController.removeListener(_onScroll);
    }
    _scrollController.dispose();
    super.dispose();
  }

  /// Gère le scroll pour la pagination infinie
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedProvider>().loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          return Column(
            children: [
              // Widget de création de post
              if (widget.showCreatePost) _buildCreatePostSection(),
              
              // Filtres rapides
              if (widget.showFilters) _buildFiltersSection(feedProvider),
              
              // Feed principal
              Expanded(
                child: _buildFeedContent(feedProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Construit la section de création de post
  Widget _buildCreatePostSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Version compacte par défaut
          if (!_showCreatePostExpanded)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCreatePostExpanded = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.themeColors.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.themeColors.borderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar utilisateur
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.themeColors.colorPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Texte d'invitation
                    Expanded(
                      child: Text(
                        'Quoi de neuf, AlistairJr ?',
                        style: AppTheme.bodyMedium.copyWith(
                          color: context.themeColors.textSecondary,
                        ),
                      ),
                    ),
                    
                    // Icônes d'actions rapides
                    Row(
                      children: [
                        Icon(
                          Icons.photo_camera,
                          color: context.themeColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.gif_box,
                          color: context.themeColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on,
                          color: context.themeColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          // Version étendue
          if (_showCreatePostExpanded)
            CreatePostWidget(
              onPostCreated: () {
                setState(() {
                  _showCreatePostExpanded = false;
                });
              },
            ),
        ],
      ),
    );
  }

  /// Construit la section des filtres
  Widget _buildFiltersSection(FeedProvider feedProvider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Filtres principaux
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(
                  'Tous',
                  feedProvider.selectedFilter == 'all',
                  () => feedProvider.setFilter('all'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Abonnements',
                  feedProvider.selectedFilter == 'following',
                  () => feedProvider.setFilter('following'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Tendances',
                  feedProvider.selectedFilter == 'trending',
                  () => feedProvider.setFilter('trending'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Sauvegardés',
                  feedProvider.selectedFilter == 'saved',
                  () => feedProvider.setFilter('saved'),
                ),
                const SizedBox(width: 16),
                
                // Séparateur
                Container(
                  width: 1,
                  height: 30,
                  color: context.themeColors.borderSubtle,
                ),
                const SizedBox(width: 16),
                
                // Filtres par type de contenu
                _buildFilterChip(
                  '📝 Texte',
                  feedProvider.selectedPostType == PostType.text,
                  () => feedProvider.setPostTypeFilter(
                    feedProvider.selectedPostType == PostType.text 
                        ? null 
                        : PostType.text,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  '📷 Images',
                  feedProvider.selectedPostType == PostType.image,
                  () => feedProvider.setPostTypeFilter(
                    feedProvider.selectedPostType == PostType.image 
                        ? null 
                        : PostType.image,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  '🎥 Vidéos',
                  feedProvider.selectedPostType == PostType.video,
                  () => feedProvider.setPostTypeFilter(
                    feedProvider.selectedPostType == PostType.video 
                        ? null 
                        : PostType.video,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Bouton tri
                _buildSortButton(feedProvider),
              ],
            ),
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
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? context.themeColors.colorPrimary 
              : context.themeColors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? context.themeColors.colorPrimary 
                : context.themeColors.borderSubtle,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: context.themeColors.colorPrimary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected 
                ? Colors.white 
                : context.themeColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Construit le bouton de tri
  Widget _buildSortButton(FeedProvider feedProvider) {
    return PopupMenuButton<String>(
      onSelected: feedProvider.setSort,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.themeColors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.themeColors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 16,
              color: context.themeColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              _getSortLabel(feedProvider.selectedSort),
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: context.themeColors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'recent',
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: feedProvider.selectedSort == 'recent' 
                    ? context.themeColors.colorPrimary 
                    : context.themeColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Plus récents',
                style: TextStyle(
                  color: feedProvider.selectedSort == 'recent' 
                      ? context.themeColors.colorPrimary 
                      : context.themeColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'popular',
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 16,
                color: feedProvider.selectedSort == 'popular' 
                    ? context.themeColors.colorPrimary 
                    : context.themeColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Plus populaires',
                style: TextStyle(
                  color: feedProvider.selectedSort == 'popular' 
                      ? context.themeColors.colorPrimary 
                      : context.themeColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'trending',
          child: Row(
            children: [
              Icon(
                Icons.whatshot,
                size: 16,
                color: feedProvider.selectedSort == 'trending' 
                    ? context.themeColors.colorPrimary 
                    : context.themeColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Tendances',
                style: TextStyle(
                  color: feedProvider.selectedSort == 'trending' 
                      ? context.themeColors.colorPrimary 
                      : context.themeColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construit le contenu principal du feed
  Widget _buildFeedContent(FeedProvider feedProvider) {
    if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
      return _buildLoadingState();
    }
    
    if (feedProvider.posts.isEmpty) {
      return _buildEmptyState(feedProvider);
    }
    
    return widget.enableRefresh
        ? RefreshIndicator(
            onRefresh: feedProvider.refreshFeed,
            child: _buildPostsList(feedProvider),
          )
        : _buildPostsList(feedProvider);
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
            'Chargement du feed...',
            style: AppTheme.bodyMedium.copyWith(
              color: context.themeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit l'état vide
  Widget _buildEmptyState(FeedProvider feedProvider) {
    String title;
    String subtitle;
    IconData icon;
    
    switch (feedProvider.selectedFilter) {
      case 'following':
        title = 'Aucun post d\'abonnement';
        subtitle = 'Suivez des utilisateurs pour voir leurs posts ici';
        icon = Icons.people_outline;
        break;
      case 'trending':
        title = 'Aucun post tendance';
        subtitle = 'Les posts populaires apparaîtront ici';
        icon = Icons.trending_up;
        break;
      case 'saved':
        title = 'Aucun post sauvegardé';
        subtitle = 'Sauvegardez des posts pour les retrouver ici';
        icon = Icons.bookmark_border;
        break;
      default:
        title = 'Aucun post à afficher';
        subtitle = 'Soyez le premier à publier quelque chose !';
        icon = Icons.post_add;
        break;
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: context.themeColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.headingMedium.copyWith(
                color: context.themeColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Bouton d'action selon le contexte
            if (feedProvider.selectedFilter == 'all' && widget.showCreatePost)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showCreatePostExpanded = true;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Créer un post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.themeColors.colorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construit la liste des posts
  Widget _buildPostsList(FeedProvider feedProvider) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: feedProvider.posts.length + 
          (feedProvider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Indicateur de chargement en bas
        if (index >= feedProvider.posts.length) {
          return _buildLoadMoreIndicator();
        }
        
        final post = feedProvider.posts[index];
        
        return AdvancedPostCard(
          post: post,
          onProfileTap: widget.onProfileTap,
          onHashtagTap: widget.onHashtagTap,
        );
      },
    );
  }

  /// Construit l'indicateur de chargement pour plus de posts
  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                context.themeColors.colorPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chargement de plus de posts...',
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retourne le label du tri sélectionné
  String _getSortLabel(String sort) {
    switch (sort) {
      case 'popular':
        return 'Populaires';
      case 'trending':
        return 'Tendances';
      case 'recent':
      default:
        return 'Récents';
    }
  }
}