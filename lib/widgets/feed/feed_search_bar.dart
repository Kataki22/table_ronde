import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_search_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/safe_context_mixin.dart';
import 'dart:async';

/// Barre de recherche avancée pour le feed social
/// 
/// Fonctionnalités :
/// - Recherche en temps réel avec debounce
/// - Suggestions automatiques (hashtags, mentions, historique)
/// - Filtres rapides intégrés
/// - Indicateurs visuels du type de recherche
/// - Raccourcis clavier et navigation
/// 
/// **Validates: Requirements 3.1, 3.2**
class FeedSearchBar extends StatefulWidget {
  /// Callback appelé lors de la sélection d'un hashtag
  final Function(String hashtag)? onHashtagSelected;
  
  /// Callback appelé lors de la sélection d'une mention
  final Function(String mention)? onMentionSelected;
  
  /// Si true, affiche les filtres rapides sous la barre
  final bool showQuickFilters;
  
  /// Si true, active la recherche vocale (placeholder)
  final bool enableVoiceSearch;

  const FeedSearchBar({
    super.key,
    this.onHashtagSelected,
    this.onMentionSelected,
    this.showQuickFilters = true,
    this.enableVoiceSearch = false,
  });

  @override
  State<FeedSearchBar> createState() => _FeedSearchBarState();
}

class _FeedSearchBarState extends State<FeedSearchBar>
    with SingleTickerProviderStateMixin, SafeContextMixin {
  // Controllers
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // État
  bool _isExpanded = false;
  bool _showSuggestions = false;
  List<String> _currentSuggestions = [];
  
  // Debounce timer
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    
    // Animation pour l'expansion
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Écouter les changements de focus
    _focusNode.addListener(_onFocusChanged);
    
    // Écouter les changements de texte
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Gère les changements de focus
  void _onFocusChanged() {
    setState(() {
      _isExpanded = _focusNode.hasFocus;
      _showSuggestions = _focusNode.hasFocus && _controller.text.isNotEmpty;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  /// Gère les changements de texte avec debounce
  void _onTextChanged() {
    final query = _controller.text;
    
    // Annuler le timer précédent
    _debounceTimer?.cancel();
    
    // Mettre à jour les suggestions immédiatement
    _updateSuggestions(query);
    
    // Débouncer la recherche avec sécurité
    _debounceTimer = safeTimer(const Duration(milliseconds: 300), (context) {
      if (query.isNotEmpty) {
        context.read<FeedSearchProvider>().search(query);
      } else {
        context.read<FeedSearchProvider>().clearSearch();
      }
    });
  }

  /// Met à jour les suggestions
  void _updateSuggestions(String query) {
    safeContext((context) {
      final searchProvider = context.read<FeedSearchProvider>();
      final suggestions = searchProvider.getSuggestions(query);
      
      setState(() {
        _currentSuggestions = suggestions;
        _showSuggestions = _focusNode.hasFocus && query.isNotEmpty;
      });
    });
  }

  /// Sélectionne une suggestion
  void _selectSuggestion(String suggestion) {
    safeContext((context) {
      _controller.text = suggestion;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: suggestion.length),
      );
      
      // Déclencher la recherche immédiatement
      context.read<FeedSearchProvider>().search(suggestion);
      
      // Gérer les callbacks spéciaux
      if (suggestion.startsWith('#') && widget.onHashtagSelected != null) {
        widget.onHashtagSelected!(suggestion.substring(1));
      } else if (suggestion.startsWith('@') && widget.onMentionSelected != null) {
        widget.onMentionSelected!(suggestion.substring(1));
      }
      
      // Masquer les suggestions
      setState(() {
        _showSuggestions = false;
      });
      
      // Retirer le focus
      _focusNode.unfocus();
    });
  }

  /// Efface la recherche
  void _clearSearch() {
    safeContext((context) {
      _controller.clear();
      context.read<FeedSearchProvider>().clearSearch();
      setState(() {
        _currentSuggestions.clear();
        _showSuggestions = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedSearchProvider>(
      builder: (context, searchProvider, child) {
        return Column(
          children: [
            // Barre de recherche principale
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildSearchField(searchProvider),
            ),
            
            // Suggestions
            if (_showSuggestions && _currentSuggestions.isNotEmpty)
              _buildSuggestions(),
            
            // Filtres rapides
            if (widget.showQuickFilters && _isExpanded)
              _buildQuickFilters(searchProvider),
          ],
        );
      },
    );
  }

  /// Construit le champ de recherche principal
  Widget _buildSearchField(FeedSearchProvider searchProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.themeColors.bgSecondary,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _isExpanded 
              ? context.themeColors.colorPrimary 
              : context.themeColors.borderSubtle,
          width: _isExpanded ? 2 : 1,
        ),
        boxShadow: _isExpanded ? [
          BoxShadow(
            color: context.themeColors.colorPrimary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Rechercher posts, #hashtags, @mentions...',
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: context.themeColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _isExpanded 
                ? context.themeColors.colorPrimary 
                : context.themeColors.textSecondary,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicateur de recherche active
              if (searchProvider.isSearching)
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.themeColors.colorPrimary,
                    ),
                  ),
                ),
              
              // Bouton de recherche vocale
              if (widget.enableVoiceSearch)
                IconButton(
                  icon: Icon(
                    Icons.mic,
                    color: context.themeColors.textSecondary,
                  ),
                  onPressed: () {
                    // TODO: Implémenter la recherche vocale
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recherche vocale bientôt disponible'),
                      ),
                    );
                  },
                ),
              
              // Bouton d'effacement
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: context.themeColors.textSecondary,
                  ),
                  onPressed: _clearSearch,
                ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: AppTheme.bodyMedium.copyWith(
          color: context.themeColors.textPrimary,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            context.read<FeedSearchProvider>().search(query);
            _focusNode.unfocus();
          }
        },
      ),
    );
  }

  /// Construit la liste des suggestions
  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.themeColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.themeColors.borderSubtle,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête des suggestions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Suggestions',
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Liste des suggestions
          ...List.generate(_currentSuggestions.length, (index) {
            final suggestion = _currentSuggestions[index];
            return _buildSuggestionItem(suggestion);
          }),
        ],
      ),
    );
  }

  /// Construit un élément de suggestion
  Widget _buildSuggestionItem(String suggestion) {
    IconData icon;
    Color iconColor;
    
    if (suggestion.startsWith('#')) {
      icon = Icons.tag;
      iconColor = const Color(0xFF1DA1F2);
    } else if (suggestion.startsWith('@')) {
      icon = Icons.alternate_email;
      iconColor = const Color(0xFF9C27B0);
    } else {
      icon = Icons.history;
      iconColor = context.themeColors.textSecondary;
    }
    
    return InkWell(
      onTap: () => _selectSuggestion(suggestion),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: AppTheme.bodyMedium.copyWith(
                  color: context.themeColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.north_west,
              size: 14,
              color: context.themeColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Construit les filtres rapides
  Widget _buildQuickFilters(FeedSearchProvider searchProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hashtags tendances
          if (searchProvider.trendingHashtags.isNotEmpty) ...[
            Text(
              'Hashtags tendances',
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: searchProvider.trendingHashtags.take(6).map((hashtag) {
                return GestureDetector(
                  onTap: () => _selectSuggestion('#$hashtag'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.themeColors.bgTertiary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.themeColors.borderSubtle,
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
            const SizedBox(height: 12),
          ],
          
          // Utilisateurs suggérés
          if (searchProvider.suggestedUsers.isNotEmpty) ...[
            Text(
              'Utilisateurs suggérés',
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: searchProvider.suggestedUsers.take(4).map((user) {
                return GestureDetector(
                  onTap: () => _selectSuggestion('@$user'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.themeColors.bgTertiary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.themeColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      '@$user',
                      style: AppTheme.bodySmall.copyWith(
                        color: const Color(0xFF9C27B0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

