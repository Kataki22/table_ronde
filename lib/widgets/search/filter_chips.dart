import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_model.dart';
import '../../providers/message_search_provider.dart';
import '../../utils/accessibility_helpers.dart';

/// Widget de chips de filtrage pour la recherche de messages
/// 
/// Affiche des chips pour chaque type de message (texte, image, vidéo, etc.)
/// permettant de filtrer les résultats de recherche. Supporte la sélection
/// multiple et affiche visuellement l'état actif/inactif de chaque filtre.
/// 
/// **Validates: Requirements 3.3**
class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageSearchProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: MessageType.values.map((type) {
              final isActive = provider.activeFilters.contains(type);
              final filterLabel = _getLabelForType(type);
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  label: AccessibilityHelpers.filterChipLabel(
                    filterName: filterLabel,
                    isActive: isActive,
                  ),
                  hint: AccessibilityHelpers.tapToSelect,
                  button: true,
                  selected: isActive,
                  child: FilterChip(
                  avatar: Icon(
                    _getIconForType(type),
                    size: 18,
                    color: isActive 
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  label: Text(_getLabelForType(type)),
                  selected: isActive,
                  onSelected: (selected) {
                    if (selected) {
                      provider.applyFilter(type);
                    } else {
                      provider.removeFilter(type);
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                  labelStyle: TextStyle(
                    color: isActive
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  elevation: isActive ? 2 : 0,
                  pressElevation: 4,
                ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Retourne l'icône appropriée pour chaque type de message
  IconData _getIconForType(MessageType type) {
    switch (type) {
      case MessageType.text:
        return Icons.text_fields;
      case MessageType.image:
        return Icons.image;
      case MessageType.video:
        return Icons.videocam;
      case MessageType.document:
        return Icons.description;
      case MessageType.voice:
        return Icons.mic;
      case MessageType.sticker:
        return Icons.emoji_emotions;
      case MessageType.gif:
        return Icons.gif;
    }
  }

  /// Retourne le label approprié pour chaque type de message
  String _getLabelForType(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'Texte';
      case MessageType.image:
        return 'Images';
      case MessageType.video:
        return 'Vidéos';
      case MessageType.document:
        return 'Documents';
      case MessageType.voice:
        return 'Vocaux';
      case MessageType.sticker:
        return 'Stickers';
      case MessageType.gif:
        return 'GIFs';
    }
  }
}
