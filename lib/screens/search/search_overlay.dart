import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/message_search_provider.dart';
import '../../widgets/search/filter_chips.dart';
import '../../widgets/search/search_results_list.dart';
import '../../utils/theme_extensions.dart';

/// Overlay widget for displaying search results over the chat
/// 
/// Displays:
/// - Filter chips for content type filtering
/// - Search results list with navigation
/// - Empty state when no results
/// 
/// **Validates: Requirements 3.4, 3.5, 3.7**
class SearchOverlay extends StatelessWidget {
  /// Callback when a search result is tapped
  /// Should scroll to the message in the chat
  final Function(int messageIndex) onResultTap;

  const SearchOverlay({
    super.key,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageSearchProvider>(
      builder: (context, provider, child) {
        // Only show overlay if there's a query
        if (provider.query.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: context.themeColors.bgPrimary,
          child: Column(
            children: [
              // Filter chips
              FilterChips(),
              
              // Results list or appropriate state
              Expanded(
                child: _buildContent(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construit le contenu approprié selon l'état de la recherche
  Widget _buildContent(BuildContext context, MessageSearchProvider provider) {
    // Query trop courte
    if (!provider.isQueryValid) {
      return _buildMinQueryState(context);
    }
    
    // Aucun résultat trouvé
    if (provider.hasNoResults) {
      return _buildEmptyState(context, provider.query);
    }
    
    // Afficher les résultats
    return SearchResultsList(
      onResultTap: (result) {
        onResultTap(result.matchIndex);
      },
    );
  }

  /// Builds empty state when no results are found
  Widget _buildEmptyState(BuildContext context, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: context.themeColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(
                color: context.themeColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'pour "$query"',
              style: TextStyle(
                color: context.themeColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Essayez avec d\'autres mots-clés ou\nmodifiez les filtres de recherche',
              style: TextStyle(
                color: context.themeColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds state when query is too short
  Widget _buildMinQueryState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: context.themeColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Rechercher dans la conversation',
              style: TextStyle(
                color: context.themeColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saisissez au moins 2 caractères\npour lancer la recherche',
              style: TextStyle(
                color: context.themeColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
