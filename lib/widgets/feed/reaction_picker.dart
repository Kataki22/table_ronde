import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/feed/reaction_type.dart';
import '../../providers/feed_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';

/// Sélecteur de réactions avancé avec animations
/// 
/// Fonctionnalités :
/// - 6 types de réactions avec emojis
/// - Animation d'apparition fluide
/// - Feedback haptique
/// - Compteurs par type de réaction
/// - Animation de sélection
/// - Support du long press et tap
/// 
/// **Validates: Requirements 2.3, 2.4**
class ReactionPicker extends StatefulWidget {
  /// ID du post pour lequel afficher les réactions
  final String postId;
  
  /// Callback appelé lors de la sélection d'une réaction
  final Function(ReactionType)? onReactionSelected;
  
  /// Si true, affiche les compteurs de réactions
  final bool showCounts;
  
  /// Si true, affiche en mode compact (horizontal)
  final bool isCompact;
  
  /// Animation controller parent (optionnel)
  final AnimationController? parentController;

  const ReactionPicker({
    super.key,
    required this.postId,
    this.onReactionSelected,
    this.showCounts = true,
    this.isCompact = false,
    this.parentController,
  });

  @override
  State<ReactionPicker> createState() => _ReactionPickerState();
}

class _ReactionPickerState extends State<ReactionPicker>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _appearanceController;
  late AnimationController _selectionController;
  late List<AnimationController> _reactionControllers;
  
  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late List<Animation<double>> _reactionAnimations;
  
  // État
  ReactionType? _hoveredReaction;
  ReactionType? _selectedReaction;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    
    // Controller principal pour l'apparition
    _appearanceController = widget.parentController ?? AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Controller pour la sélection
    _selectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Controllers individuels pour chaque réaction
    _reactionControllers = List.generate(
      ReactionType.values.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200 + (index * 50)),
      ),
    );
    
    // Animations principales
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appearanceController,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    // Animations individuelles des réactions
    _reactionAnimations = _reactionControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();
    
    // Démarrer l'animation d'apparition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _show();
    });
  }

  @override
  void dispose() {
    if (widget.parentController == null) {
      _appearanceController.dispose();
    }
    _selectionController.dispose();
    for (final controller in _reactionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Affiche le sélecteur avec animation
  void _show() {
    setState(() {
      _isVisible = true;
    });
    
    _appearanceController.forward();
    
    // Animer les réactions une par une
    for (int i = 0; i < _reactionControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          _reactionControllers[i].forward();
        }
      });
    }
  }

  /// Masque le sélecteur avec animation
  void _hide() {
    _appearanceController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        return AnimatedBuilder(
          animation: _appearanceController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(widget.isCompact ? 8 : 12),
                  decoration: BoxDecoration(
                    color: context.themeColors.bgSecondary,
                    borderRadius: BorderRadius.circular(widget.isCompact ? 25 : 30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: context.themeColors.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: widget.isCompact
                      ? _buildCompactLayout(feedProvider)
                      : _buildExpandedLayout(feedProvider),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Construit la disposition compacte (horizontale)
  Widget _buildCompactLayout(FeedProvider feedProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ReactionType.values.asMap().entries.map((entry) {
        final index = entry.key;
        final reactionType = entry.value;
        return _buildReactionButton(feedProvider, reactionType, index, true);
      }).toList(),
    );
  }

  /// Construit la disposition étendue (grille)
  Widget _buildExpandedLayout(FeedProvider feedProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Titre
        if (widget.showCounts) ...[
          Text(
            'Réactions',
            style: AppTheme.bodySmall.copyWith(
              color: context.themeColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Grille de réactions
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ReactionType.values.asMap().entries.map((entry) {
            final index = entry.key;
            final reactionType = entry.value;
            return _buildReactionButton(feedProvider, reactionType, index, false);
          }).toList(),
        ),
        
        // Statistiques détaillées
        if (widget.showCounts && _hoveredReaction != null) ...[
          const SizedBox(height: 12),
          _buildReactionStats(feedProvider, _hoveredReaction!),
        ],
      ],
    );
  }

  /// Construit un bouton de réaction individuel
  Widget _buildReactionButton(
    FeedProvider feedProvider,
    ReactionType reactionType,
    int index,
    bool isCompact,
  ) {
    final reactionCount = _getReactionCount(feedProvider, reactionType);
    final isSelected = feedProvider.getUserReactionType(widget.postId) == reactionType;
    final isHovered = _hoveredReaction == reactionType;
    
    return AnimatedBuilder(
      animation: _reactionAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _reactionAnimations[index].value,
          child: GestureDetector(
            onTap: () => _selectReaction(reactionType),
            onTapDown: (_) => _onReactionHover(reactionType),
            onTapCancel: () => _onReactionHover(null),
            child: MouseRegion(
              onEnter: (_) => _onReactionHover(reactionType),
              onExit: (_) => _onReactionHover(null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isCompact ? 8 : 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getReactionColor(reactionType).withOpacity(0.2)
                      : isHovered
                          ? context.themeColors.bgTertiary
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(isCompact ? 20 : 25),
                  border: Border.all(
                    color: isSelected
                        ? _getReactionColor(reactionType)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emoji avec animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()
                        ..scale(isHovered ? 1.3 : 1.0),
                      child: Text(
                        reactionType.emoji,
                        style: TextStyle(
                          fontSize: isCompact ? 20 : 24,
                        ),
                      ),
                    ),
                    
                    // Nom et compteur (mode étendu uniquement)
                    if (!isCompact) ...[
                      const SizedBox(height: 4),
                      Text(
                        reactionType.name,
                        style: AppTheme.bodySmall.copyWith(
                          color: isSelected
                              ? _getReactionColor(reactionType)
                              : context.themeColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (widget.showCounts && reactionCount > 0) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getReactionColor(reactionType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$reactionCount',
                            style: AppTheme.bodySmall.copyWith(
                              color: _getReactionColor(reactionType),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construit les statistiques détaillées d'une réaction
  Widget _buildReactionStats(FeedProvider feedProvider, ReactionType reactionType) {
    final reactionCount = _getReactionCount(feedProvider, reactionType);
    final totalReactions = _getTotalReactionCount(feedProvider);
    final percentage = totalReactions > 0 ? (reactionCount / totalReactions * 100) : 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getReactionColor(reactionType).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getReactionColor(reactionType).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                reactionType.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reactionType.name,
                  style: AppTheme.bodyMedium.copyWith(
                    color: _getReactionColor(reactionType),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$reactionCount',
                style: AppTheme.bodyMedium.copyWith(
                  color: _getReactionColor(reactionType),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Barre de progression
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: context.themeColors.bgTertiary,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getReactionColor(reactionType),
            ),
          ),
          const SizedBox(height: 4),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}% des réactions',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                ),
              ),
              Text(
                '$totalReactions total',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Gère le survol d'une réaction
  void _onReactionHover(ReactionType? reactionType) {
    if (_hoveredReaction != reactionType) {
      setState(() {
        _hoveredReaction = reactionType;
      });
      
      // Feedback haptique léger
      if (reactionType != null) {
        HapticFeedback.selectionClick();
      }
    }
  }

  /// Sélectionne une réaction
  void _selectReaction(ReactionType reactionType) {
    // Feedback haptique
    HapticFeedback.lightImpact();
    
    // Animation de sélection
    _selectionController.forward().then((_) {
      _selectionController.reverse();
    });
    
    setState(() {
      _selectedReaction = reactionType;
    });
    
    // Callback
    widget.onReactionSelected?.call(reactionType);
    
    // Appliquer la réaction via le provider
    context.read<FeedProvider>().reactToPost(widget.postId, reactionType);
    
    // Masquer le sélecteur après un délai
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _hide();
      }
    });
  }

  /// Retourne le nombre de réactions d'un type spécifique
  int _getReactionCount(FeedProvider feedProvider, ReactionType reactionType) {
    final reactions = feedProvider.getReactionsForPost(widget.postId);
    return reactions.where((r) => r.type == reactionType).length;
  }

  /// Retourne le nombre total de réactions
  int _getTotalReactionCount(FeedProvider feedProvider) {
    return feedProvider.getReactionsForPost(widget.postId).length;
  }

  /// Retourne la couleur associée à un type de réaction
  Color _getReactionColor(ReactionType reactionType) {
    final colorHex = reactionType.colorHex;
    return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
  }
}

/// Widget pour afficher un bouton de réaction simple avec long press
class ReactionButton extends StatefulWidget {
  /// ID du post
  final String postId;
  
  /// Si true, affiche le compteur de réactions
  final bool showCount;
  
  /// Style du bouton (compact ou normal)
  final bool isCompact;

  const ReactionButton({
    super.key,
    required this.postId,
    this.showCount = true,
    this.isCompact = false,
  });

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showPicker = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        final userReactionType = feedProvider.getUserReactionType(widget.postId);
        final totalReactions = feedProvider.getReactionsForPost(widget.postId).length;
        final hasReacted = userReactionType != null;
        
        return GestureDetector(
          onTap: () {
            if (hasReacted) {
              // Si déjà réagi, retirer la réaction
              feedProvider.reactToPost(widget.postId, userReactionType);
            } else {
              // Sinon, réaction rapide (like)
              feedProvider.reactToPost(widget.postId, ReactionType.like);
            }
            _animateButton();
          },
          onLongPress: _showReactionPicker,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasReacted ? Icons.favorite : Icons.favorite_border,
                      size: widget.isCompact ? 18 : 20,
                      color: hasReacted
                          ? _getReactionColor(userReactionType!)
                          : context.themeColors.textSecondary,
                    ),
                    if (widget.showCount && totalReactions > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '$totalReactions',
                        style: AppTheme.bodySmall.copyWith(
                          color: hasReacted
                              ? _getReactionColor(userReactionType!)
                              : context.themeColors.textSecondary,
                          fontWeight: hasReacted ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Anime le bouton lors d'un tap
  void _animateButton() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    HapticFeedback.lightImpact();
  }

  /// Affiche le sélecteur de réactions en overlay
  void _showReactionPicker() {
    if (_showPicker) return;
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      _showPicker = true;
    });
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: _removeOverlay,
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: ReactionPicker(
                postId: widget.postId,
                onReactionSelected: (reaction) {
                  _removeOverlay();
                },
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Supprime l'overlay du sélecteur
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() {
        _showPicker = false;
      });
    }
  }

  /// Retourne la couleur d'une réaction
  Color _getReactionColor(ReactionType reactionType) {
    final colorHex = reactionType.colorHex;
    return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
  }
}