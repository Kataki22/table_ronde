import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_search_provider.dart';
import '../../providers/feed_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/safe_context_mixin.dart';
import 'advanced_feed_search.dart';
import 'complete_feed_widget.dart';

/// Widget d'exemple d'intégration de la recherche avancée dans le feed
/// 
/// Démontre comment intégrer toutes les fonctionnalités de recherche
/// dans l'interface existante du feed social.
/// 
/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
class FeedSearchIntegrationExample extends StatefulWidget {
  const FeedSearchIntegrationExample({super.key});

  @override
  State<FeedSearchIntegrationExample> createState() => _FeedSearchIntegrationExampleState();
}

class _FeedSearchIntegrationExampleState extends State<FeedSearchIntegrationExample>
    with SingleTickerProviderStateMixin, SafeContextMixin {
  // Controllers
  late TabController _tabController;
  
  // État
  int _currentIndex = 0;
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FeedSearchProvider()),
      ],
      child: Scaffold(
        backgroundColor: context.themeColors.bgPrimary,
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  /// Construit le corps principal
  Widget _buildBody() {
    if (_isSearchMode) {
      return AdvancedFeedSearch(
        onProfileTap: _navigateToProfile,
        onHashtagTap: _navigateToHashtag,
        onMentionTap: _navigateToMention,
        showDiscoveryPanel: true,
        enableVoiceSearch: true,
      );
    }
    
    return Column(
      children: [
        // App bar personnalisé
        _buildAppBar(),
        
        // Contenu principal avec onglets
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Onglet Feed
              CompleteFeedWidget(
                showCreatePost: true,
                showFilters: true,
                enableRefresh: true,
                enableInfiniteScroll: true,
                onProfileTap: _navigateToProfile,
                onHashtagTap: _navigateToHashtag,
              ),
              
              // Onglet Recherche (version intégrée)
              _buildIntegratedSearch(),
            ],
          ),
        ),
      ],
    );
  }

  /// Construit l'app bar personnalisé
  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.themeColors.bgPrimary,
        border: Border(
          bottom: BorderSide(
            color: context.themeColors.borderSubtle,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Barre de titre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Logo/Titre
                  Text(
                    'Feed Social',
                    style: AppTheme.headingLarge.copyWith(
                      color: context.themeColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  
                  // Bouton de recherche
                  IconButton(
                    icon: Icon(
                      _isSearchMode ? Icons.close : Icons.search,
                      color: context.themeColors.textPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchMode = !_isSearchMode;
                      });
                    },
                    tooltip: _isSearchMode ? 'Fermer la recherche' : 'Rechercher',
                  ),
                  
                  // Bouton de notifications
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: context.themeColors.textPrimary,
                        ),
                        // Badge de notification
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.themeColors.colorPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications - Bientôt disponible'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Onglets
            if (!_isSearchMode)
              TabBar(
                controller: _tabController,
                indicatorColor: context.themeColors.colorPrimary,
                labelColor: context.themeColors.colorPrimary,
                unselectedLabelColor: context.themeColors.textSecondary,
                labelStyle: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTheme.bodyMedium,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.home),
                    text: 'Feed',
                  ),
                  Tab(
                    icon: Icon(Icons.explore),
                    text: 'Découvrir',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Construit la recherche intégrée
  Widget _buildIntegratedSearch() {
    return Consumer<FeedSearchProvider>(
      builder: (context, searchProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message d'introduction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.themeColors.colorPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: context.themeColors.colorPrimary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recherche avancée',
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.themeColors.colorPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Appuyez sur l\'icône de recherche pour accéder à toutes les fonctionnalités',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.themeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Raccourcis de recherche populaire
              _buildQuickSearches(searchProvider),
              
              const SizedBox(height: 24),
              
              // Statistiques de recherche
              _buildSearchStats(searchProvider),
            ],
          ),
        );
      },
    );
  }

  /// Construit les recherches rapides
  Widget _buildQuickSearches(FeedSearchProvider searchProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recherches populaires',
          style: AppTheme.headingSmall.copyWith(
            color: context.themeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Hashtags populaires
        _buildQuickSearchSection(
          'Hashtags tendances',
          Icons.tag,
          const Color(0xFF1DA1F2),
          searchProvider.trendingHashtags.take(6).map((h) => '#$h').toList(),
          (item) => searchProvider.searchByHashtag(item.substring(1)),
        ),
        
        const SizedBox(height: 16),
        
        // Utilisateurs suggérés
        _buildQuickSearchSection(
          'Utilisateurs actifs',
          Icons.people,
          const Color(0xFF9C27B0),
          searchProvider.suggestedUsers.take(4).map((u) => '@$u').toList(),
          (item) => searchProvider.searchByMention(item.substring(1)),
        ),
      ],
    );
  }

  /// Construit une section de recherche rapide
  Widget _buildQuickSearchSection(
    String title,
    IconData icon,
    Color color,
    List<String> items,
    Function(String) onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return GestureDetector(
              onTap: () {
                onTap(item);
                setState(() {
                  _isSearchMode = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  item,
                  style: AppTheme.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Construit les statistiques de recherche
  Widget _buildSearchStats(FeedSearchProvider searchProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique de recherche',
          style: AppTheme.headingSmall.copyWith(
            color: context.themeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        if (searchProvider.searchHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.themeColors.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.themeColors.borderSubtle,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 32,
                    color: context.themeColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucune recherche récente',
                    style: AppTheme.bodyMedium.copyWith(
                      color: context.themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...searchProvider.searchHistory.take(5).map((query) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  Icons.history,
                  color: context.themeColors.textSecondary,
                ),
                title: Text(
                  query,
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.themeColors.textPrimary,
                  ),
                ),
                trailing: Icon(
                  Icons.north_west,
                  size: 16,
                  color: context.themeColors.textSecondary,
                ),
                onTap: () {
                  searchProvider.search(query);
                  setState(() {
                    _isSearchMode = true;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  /// Construit le bouton d'action flottant
  Widget _buildFloatingActionButton() {
    if (_isSearchMode) return const SizedBox.shrink();
    
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _isSearchMode = true;
        });
      },
      backgroundColor: context.themeColors.colorPrimary,
      child: const Icon(
        Icons.search,
        color: Colors.white,
      ),
      tooltip: 'Recherche avancée',
    );
  }

  /// Navigation vers un profil
  void _navigateToProfile(String userId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation vers le profil: $userId'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  /// Navigation vers un hashtag
  void _navigateToHashtag(String hashtag) {
    safeContext((context) {
      final searchProvider = context.read<FeedSearchProvider>();
      searchProvider.searchByHashtag(hashtag);
      
      setState(() {
        _isSearchMode = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recherche pour #$hashtag'),
          action: SnackBarAction(
            label: 'Voir',
            onPressed: () {},
          ),
        ),
      );
    });
  }

  /// Navigation vers une mention
  void _navigateToMention(String mention) {
    safeContext((context) {
      final searchProvider = context.read<FeedSearchProvider>();
      searchProvider.searchByMention(mention);
      
      setState(() {
        _isSearchMode = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recherche pour @$mention'),
          action: SnackBarAction(
            label: 'Voir',
            onPressed: () {},
          ),
        ),
      );
    });
  }
}