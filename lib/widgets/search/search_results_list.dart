import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/search/search_result.dart';
import '../../providers/message_search_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/accessibility_helpers.dart';

/// Widget de liste des résultats de recherche
/// 
/// Affiche une liste des résultats de recherche avec le texte recherché
/// mis en surbrillance. Fournit des boutons de navigation précédent/suivant
/// avec un indicateur de position actuelle. Gère le tap sur un résultat
/// pour naviguer vers ce message dans le chat.
/// 
/// **Validates: Requirements 3.5, 3.6**
class SearchResultsList extends StatelessWidget {
  /// Callback appelé lorsqu'un résultat est tapé
  /// Reçoit le SearchResult sélectionné
  final Function(SearchResult) onResultTap;

  const SearchResultsList({
    super.key,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageSearchProvider>(
      builder: (context, provider, child) {
        final results = provider.results;
        final currentIndex = provider.currentResultIndex;

        // Si aucun résultat, afficher un message
        // (Normalement géré par SearchOverlay, mais gardé comme fallback)
        if (results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: context.themeColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun résultat trouvé',
                    style: TextStyle(
                      color: context.themeColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (provider.query.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'pour "${provider.query}"',
                        style: TextStyle(
                          color: context.themeColors.textMuted,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Essayez avec d\'autres mots-clés ou\nmodifiez les filtres de recherche',
                    style: TextStyle(
                      color: context.themeColors.textMuted,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Barre de navigation
            _NavigationBar(
              currentIndex: currentIndex,
              totalResults: results.length,
              onPrevious: provider.navigateToPrevious,
              onNext: provider.navigateToNext,
            ),
            
            // Liste des résultats
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  final isSelected = index == currentIndex;
                  
                  return _SearchResultTile(
                    result: result,
                    isSelected: isSelected,
                    query: provider.query,
                    onTap: () => onResultTap(result),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Barre de navigation avec boutons précédent/suivant
class _NavigationBar extends StatelessWidget {
  final int currentIndex;
  final int totalResults;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _NavigationBar({
    required this.currentIndex,
    required this.totalResults,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.themeColors.bgSecondary,
        border: Border(
          bottom: BorderSide(
            color: context.themeColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicateur de position
          Text(
            'Résultat ${currentIndex + 1} sur $totalResults',
            style: TextStyle(
              color: context.themeColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Boutons de navigation
          Row(
            children: [
              // Bouton précédent
              Semantics(
                label: 'Résultat précédent',
                hint: AccessibilityHelpers.tapToOpen,
                button: true,
                enabled: true,
                child: IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    color: context.themeColors.textPrimary,
                  ),
                  onPressed: onPrevious,
                  tooltip: 'Résultat précédent',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Bouton suivant
              Semantics(
                label: 'Résultat suivant',
                hint: AccessibilityHelpers.tapToOpen,
                button: true,
                enabled: true,
                child: IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: context.themeColors.textPrimary,
                  ),
                  onPressed: onNext,
                  tooltip: 'Résultat suivant',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tuile représentant un résultat de recherche
class _SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final bool isSelected;
  final String query;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.result,
    required this.isSelected,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final message = result.message;
    
    // Formater le timestamp
    final hour = message.timestamp.hour.toString().padLeft(2, '0');
    final minute = message.timestamp.minute.toString().padLeft(2, '0');
    final day = message.timestamp.day.toString().padLeft(2, '0');
    final month = message.timestamp.month.toString().padLeft(2, '0');
    final year = message.timestamp.year;
    
    // Déterminer si on affiche la date ou juste l'heure
    final now = DateTime.now();
    final isToday = message.timestamp.year == now.year &&
        message.timestamp.month == now.month &&
        message.timestamp.day == now.day;
    
    final timeString = isToday
        ? '$hour:$minute'
        : '$day/$month/$year';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.themeColors.colorPrimary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected
                  ? context.themeColors.colorPrimary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec expéditeur et timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Expéditeur
                Text(
                  message.isSentByMe ? 'Vous' : 'Contact',
                  style: TextStyle(
                    color: context.themeColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                // Timestamp
                Text(
                  timeString,
                  style: TextStyle(
                    color: context.themeColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 6),
            
            // Contenu du message avec highlighting
            _HighlightedText(
              text: message.text,
              highlightRanges: result.highlightRanges,
              textColor: context.themeColors.textSecondary,
              highlightColor: context.themeColors.colorBrand,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher du texte avec des portions mises en surbrillance
/// avec animation de pulse (300ms)
class _HighlightedText extends StatefulWidget {
  final String text;
  final List<dynamic> highlightRanges; // TextRange from search_result
  final Color textColor;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.highlightRanges,
    required this.textColor,
    required this.highlightColor,
  });

  @override
  State<_HighlightedText> createState() => _HighlightedTextState();
}

class _HighlightedTextState extends State<_HighlightedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configuration de l'animation de pulse (300ms)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Démarrer l'animation de pulse si des highlights existent
    if (widget.highlightRanges.isNotEmpty) {
      _pulseController.forward();
    }
  }

  @override
  void didUpdateWidget(_HighlightedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Redémarrer l'animation si les ranges changent
    if (widget.highlightRanges != oldWidget.highlightRanges &&
        widget.highlightRanges.isNotEmpty) {
      _pulseController.reset();
      _pulseController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si pas de ranges, afficher le texte normalement
    if (widget.highlightRanges.isEmpty) {
      return Text(
        widget.text,
        style: TextStyle(
          color: widget.textColor,
          fontSize: 14,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Construire les spans avec highlighting animé
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final spans = <TextSpan>[];
        int currentIndex = 0;

        // Trier les ranges par position de début
        final sortedRanges = List.from(widget.highlightRanges)
          ..sort((a, b) => a.start.compareTo(b.start));

        for (final range in sortedRanges) {
          // Ajouter le texte avant le highlight
          if (currentIndex < range.start) {
            spans.add(TextSpan(
              text: widget.text.substring(currentIndex, range.start),
              style: TextStyle(color: widget.textColor),
            ));
          }

          // Ajouter le texte highlighté avec animation de pulse
          spans.add(TextSpan(
            text: widget.text.substring(range.start, range.end),
            style: TextStyle(
              color: Colors.white,
              backgroundColor: widget.highlightColor.withValues(
                alpha: _pulseAnimation.value,
              ),
              fontWeight: FontWeight.w600,
            ),
          ));

          currentIndex = range.end;
        }

        // Ajouter le texte restant après le dernier highlight
        if (currentIndex < widget.text.length) {
          spans.add(TextSpan(
            text: widget.text.substring(currentIndex),
            style: TextStyle(color: widget.textColor),
          ));
        }

        return RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14),
            children: spans,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
