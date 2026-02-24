import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/message_search_provider.dart';
import '../../utils/theme_extensions.dart';

/// Widget de barre de recherche personnalisée pour les messages
/// 
/// Intégrable dans un AppBar avec animation d'ouverture/fermeture.
/// Gère la saisie en temps réel et affiche un compteur de résultats.
/// 
/// **Validates: Requirements 3.1, 3.2, 3.4**
class ChatSearchBar extends StatefulWidget {
  /// Callback appelé lorsque la recherche change
  final Function(String query)? onSearchChanged;
  
  /// Callback appelé lorsque la recherche est fermée
  final VoidCallback? onClose;
  
  /// Si true, la barre de recherche est ouverte et animée
  final bool isOpen;
  
  /// Durée de l'animation d'ouverture/fermeture
  final Duration animationDuration;

  const ChatSearchBar({
    super.key,
    this.onSearchChanged,
    this.onClose,
    this.isOpen = false,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    
    // Configuration de l'animation
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    
    _widthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Si déjà ouvert au démarrage, animer immédiatement
    if (widget.isOpen) {
      _animationController.forward();
      // Focus automatique après l'animation
      Future.delayed(widget.animationDuration, () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(ChatSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Gérer l'animation lors du changement d'état
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _animationController.forward();
        // Focus automatique après l'animation
        Future.delayed(widget.animationDuration, () {
          if (mounted) {
            _focusNode.requestFocus();
          }
        });
      } else {
        _animationController.reverse();
        _focusNode.unfocus();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String query) {
    // Notifier le parent
    widget.onSearchChanged?.call(query);
  }

  void _handleClear() {
    _textController.clear();
    _handleSearchChanged('');
    _focusNode.requestFocus();
  }

  void _handleClose() {
    _textController.clear();
    _handleSearchChanged('');
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return SizedBox(
          width: _widthAnimation.value * MediaQuery.of(context).size.width * 0.7,
          child: _widthAnimation.value > 0.1 ? child : const SizedBox.shrink(),
        );
      },
      child: Consumer<MessageSearchProvider>(
        builder: (context, searchProvider, _) {
          final resultCount = searchProvider.resultCount;
          final currentIndex = searchProvider.currentResultIndex;
          final hasResults = resultCount > 0;

          return Container(
            height: 40,
            decoration: BoxDecoration(
              color: context.themeColors.bgInput,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Icône de recherche
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    Icons.search,
                    size: 20,
                    color: context.themeColors.textSecondary,
                  ),
                ),
                
                // Champ de texte
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    style: TextStyle(
                      color: context.themeColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle: TextStyle(
                        color: context.themeColors.textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 10,
                      ),
                    ),
                    onChanged: _handleSearchChanged,
                  ),
                ),
                
                // Compteur de résultats
                if (hasResults && _textController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${currentIndex + 1}/$resultCount',
                      style: TextStyle(
                        color: context.themeColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                // Bouton clear (si du texte est saisi)
                if (_textController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 18,
                      color: context.themeColors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: _handleClear,
                  ),
                
                // Bouton close
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: context.themeColors.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: _handleClose,
                ),
                
                const SizedBox(width: 4),
              ],
            ),
          );
        },
      ),
    );
  }
}
