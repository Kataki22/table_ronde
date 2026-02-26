import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_search_provider.dart';
import '../../providers/feed_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import 'feed_search_bar.dart';
import 'feed_search_results.dart';
import 'hashtag_mention_navigator.dart';

/// Widget principal de recherche avancée pour le feed social
/// 
/// Combine tous les éléments de recherche :
/// - Barre de recherche avec suggestions
/// - Résultats avec surlignage et filtres
/// - Navigation par hashtags et mentions
/// - Interface adaptative selon l'état
/// 
/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
class AdvancedFeedSearch extends StatefulWidget {
  /// Callback appelé lors du tap sur un profil
  final Function(String userId)? onProfileTap;
  
  /// Callback appelé lors du tap sur un hashtag
  final Function(String hashtag)? onHashtagTap;
  
  /// Callback appelé lors du tap sur une mention
  final Function(String mention)? onMentionTap;
  
  /// Si true, affiche le navigateur de découverte
  final bool showDiscoveryPanel;
  
  /// Si true, active la recherche vocale
  final bool enableVoiceSearch;

  const AdvancedFeedSearch({
    super.key,
    this.onProfileTap,
    this.onHashtagTap,
    this.onMentionTap,
    this.showDiscoveryPanel = true,
    this.enableVoiceSearch = false,
  });

  @override
  State<AdvancedFeedSearch> createState() => _AdvancedFeedSearchState();
}

class _AdvancedFeedSearchState extends State<AdvancedFeedSearch>
    with SingleTickerProviderStateMixin {
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // État
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    
    // Initialiser le provider de recherche avec le provider de feed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final feedProvider = context.read<FeedProvider>();
      final searchProvider = context.read<FeedSearchProvider>();
      searchProvider.setFeedProvider(feedProvider);
    });
    
    // Animation pour l'interface
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
      child: Consumer<FeedSearchProvider>(
        builder: (context, searchProvider, child) {
          return Scaffold(
            backgroundColor: context.themeColors.bgPrimary,
            body: _buildResponsiveLayout(searchProvider),
          );
        },
      ),
    );
  }

  /// Construit le layout adaptatif selon la taille d'écran
  Widget _buildResponsiveLayout(FeedSearchProvider searchProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;
        
        if (isWideScreen) {
          return _buildWideScreenLayout(searchProvider);
        } else {
          return _buildMobileLayout(searchProvider);
        }
      },
    );
  }

  /// Layout pour écrans larges (desktop/tablet)
  Widget _buildWideScreenLayout(FeedSearchProvider searchProvider) {
    return Row(
      children: [
        // Panneau de recherche principal
        Expanded(
          flex: 2,
          child: _buildMainSearchPanel(searchProvider),
        ),
        
        // Panneau de découverte (sidebar)
        if (widget.showDiscoveryPanel)
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: context.themeColors.borderSubtle,
                ),
              ),
            ),
            child: HashtagMentionNavigator(
              onHashtagSelected: (hashtag) {
                if (widget.onHashtagTap != null) {
                  widget.onHashtagTap!(hashtag);
                }
              },
              onMentionSelected: (mention) {
                if (widget.onMentionTap != null) {
                  widget.onMentionTap!(mention);
                }
              },
            ),
          ),
      ],
    );
  }

  /// Layout pour écrans mobiles
  Widget _buildMobileLayout(FeedSearchProvider searchProvider) {
    return Column(
      children: [
        // Barre de recherche fixe en haut
        _buildSearchHeader(searchProvider),
        
        // Contenu principal
        Expanded(
          child: _buildMainContent(searchProvider),
        ),
      ],
    );
  }

  /// Construit l'en-tête de recherche pour mobile
  Widget _buildSearchHeader(FeedSearchProvider searchProvider) {
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
            // Barre de navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Bouton retour
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: context.themeColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  
                  // Titre
                  Expanded(
                    child: Text(
                      'Recherche avancée',
                      style: AppTheme.headingMedium.copyWith(
                        color: context.themeColors.textPrimary,
                      ),
                    ),
                  ),
                  
                  // Bouton de découverte
                  if (widget.showDiscoveryPanel)
                    IconButton(
                      icon: Icon(
                        Icons.explore,
                        color: context.themeColors.textSecondary,
                      ),
                      onPressed: () => _showDiscoveryBottomSheet(),
                    ),
                ],
              ),
            ),
            
            // Barre de recherche
            FeedSearchBar(
              onHashtagSelected: widget.onHashtagTap,
              onMentionSelected: widget.onMentionTap,
              showQuickFilters: true,
              enableVoiceSearch: widget.enableVoiceSearch,
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le panneau principal de recherche
  Widget _buildMainSearchPanel(FeedSearchProvider searchProvider) {
    return Column(
      children: [
        // Barre de recherche
        FeedSearchBar(
          onHashtagSelected: widget.onHashtagTap,
          onMentionSelected: widget.onMentionTap,
          showQuickFilters: true,
          enableVoiceSearch: widget.enableVoiceSearch,
        ),
        
        // Résultats
        Expanded(
          child: FeedSearchResults(
            onProfileTap: widget.onProfileTap,
            onHashtagTap: widget.onHashtagTap,
            onMentionTap: widget.onMentionTap,
            showAdvancedFilters: true,
            showSearchStats: true,
          ),
        ),
      ],
    );
  }

  /// Construit le contenu principal pour mobile
  Widget _buildMainContent(FeedSearchProvider searchProvider) {
    if (!searchProvider.hasSearched) {
      return _buildWelcomeScreen(searchProvider);
    }
    
    return FeedSearchResults(
      onProfileTap: widget.onProfileTap,
      onHashtagTap: widget.onHashtagTap,
      onMentionTap: widget.onMentionTap,
      showAdvancedFilters: true,
      showSearchStats: false, // Masqué sur mobile pour économiser l'espace
    );
  }

  /// Construit l'écran d'accueil de la recherche
  Widget _buildWelcomeScreen(FeedSearchProvider searchProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message d'accueil
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.themeColors.colorPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search,
                    size: 40,
                    color: context.themeColors.colorPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Recherche avancée',
                  style: AppTheme.headingLarge.copyWith(
                    color: context.themeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trouvez exactement ce que vous cherchez dans le feed',
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.themeColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Guide de recherche
          _buildSearchGuide(),
          
          const SizedBox(height: 32),
          
          // Raccourcis rapides
          _buildQuickActions(searchProvider),
        ],
      ),
    );
  }

  /// Construit le guide de recherche
  Widget _buildSearchGuide() {
    final guides = [
      {
        'icon': Icons.tag,
        'color': const Color(0xFF1DA1F2),
        'title': 'Recherche par hashtag',
        'description': 'Utilisez # suivi du hashtag',
        'example': '#Flutter #Dev',
      },
      {
        'icon': Icons.alternate_email,
        'color': const Color(0xFF9C27B0),
        'title': 'Recherche par mention',
        'description': 'Utilisez @ suivi du nom d\'utilisateur',
        'example': '@alistairjr @sophie',
      },
      {
        'icon': Icons.person,
        'color': const Color(0xFF4CAF50),
        'title': 'Recherche par auteur',
        'description': 'Utilisez auteur: suivi du nom',
        'example': 'auteur:Sophie',
      },
      {
        'icon': Icons.format_quote,
        'color': const Color(0xFFFF9800),
        'title': 'Phrase exacte',
        'description': 'Entourez de guillemets',
        'example': '"phrase exacte"',
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comment rechercher',
          style: AppTheme.headingSmall.copyWith(
            color: context.themeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        ...guides.map((guide) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (guide['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    guide['icon'] as IconData,
                    color: guide['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide['title'] as String,
                        style: AppTheme.bodyMedium.copyWith(
                          color: context.themeColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        guide['description'] as String,
                        style: AppTheme.bodySmall.copyWith(
                          color: context.themeColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guide['example'] as String,
                        style: AppTheme.bodySmall.copyWith(
                          color: guide['color'] as Color,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Construit les actions rapides
  Widget _buildQuickActions(FeedSearchProvider searchProvider) {
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searchProvider.trendingHashtags.take(6).map((hashtag) {
            return GestureDetector(
              onTap: () => searchProvider.searchByHashtag(hashtag),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DA1F2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1DA1F2).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '#$hashtag',
                  style: AppTheme.bodySmall.copyWith(
                    color: const Color(0xFF1DA1F2),
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

  /// Affiche le panneau de découverte en bottom sheet
  void _showDiscoveryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: context.themeColors.bgPrimary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.themeColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Contenu
            Expanded(
              child: HashtagMentionNavigator(
                onHashtagSelected: (hashtag) {
                  Navigator.pop(context);
                  if (widget.onHashtagTap != null) {
                    widget.onHashtagTap!(hashtag);
                  }
                },
                onMentionSelected: (mention) {
                  Navigator.pop(context);
                  if (widget.onMentionTap != null) {
                    widget.onMentionTap!(mention);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}