import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/feed/post_model.dart';
import '../../models/feed/post_type.dart';
import '../../models/feed/reaction_type.dart';
import '../../models/search/text_range.dart';
import '../../providers/feed_provider.dart';
import '../../providers/saved_posts_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/text_parser.dart';
import 'reaction_picker.dart';
import 'comments_section.dart';

/// Carte de post avancée avec toutes les fonctionnalités sociales
/// 
/// Fonctionnalités :
/// - Affichage complet du post avec médias
/// - Réactions avancées avec sélecteur
/// - Commentaires avec threading
/// - Partage et sauvegarde
/// - Animations et interactions fluides
/// - Support des hashtags/mentions cliquables
/// - Menu d'actions contextuelles
/// 
/// **Validates: Requirements 1.1, 2.1, 2.2, 2.3, 2.4, 2.5**
class AdvancedPostCard extends StatefulWidget {
  /// Post à afficher
  final PostModel post;
  
  /// Ranges de texte à surligner (pour la recherche)
  final List<TextRange>? highlightRanges;
  
  /// Si true, affiche en mode compact
  final bool isCompact;
  
  /// Si true, affiche les commentaires directement
  final bool showComments;
  
  /// Callback appelé lors du tap sur le post
  final VoidCallback? onTap;
  
  /// Callback appelé lors de la navigation vers un profil
  final Function(String userId)? onProfileTap;
  
  /// Callback appelé lors de la navigation vers un hashtag
  final Function(String hashtag)? onHashtagTap;

  const AdvancedPostCard({
    super.key,
    required this.post,
    this.highlightRanges,
    this.isCompact = false,
    this.showComments = false,
    this.onTap,
    this.onProfileTap,
    this.onHashtagTap,
  });

  @override
  State<AdvancedPostCard> createState() => _AdvancedPostCardState();
}

class _AdvancedPostCardState extends State<AdvancedPostCard>
    with SingleTickerProviderStateMixin {
  // Animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // État
  bool _showReactionPicker = false;
  bool _showComments = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _showComments = widget.showComments;
    
    // Animation pour les interactions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: widget.onTap,
            child: Container(
              margin: EdgeInsets.only(
                bottom: widget.isCompact ? 8 : 12,
                left: widget.isCompact ? 8 : 16,
                right: widget.isCompact ? 8 : 16,
              ),
              decoration: BoxDecoration(
                color: context.themeColors.bgSecondary,
                borderRadius: BorderRadius.circular(widget.isCompact ? 8 : 12),
                border: Border.all(
                  color: context.themeColors.borderSubtle,
                  width: 1,
                ),
                boxShadow: widget.isCompact ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête du post
                  _buildPostHeader(),
                  
                  // Contenu du post
                  _buildPostContent(),
                  
                  // Médias attachés
                  if (widget.post.hasMedia) _buildPostMedia(),
                  
                  // Post partagé (si applicable)
                  if (widget.post.isSharedPost && widget.post.originalPost != null)
                    _buildSharedPost(),
                  
                  // Localisation
                  if (widget.post.location != null) _buildLocation(),
                  
                  // Statistiques d'engagement
                  _buildEngagementStats(),
                  
                  // Actions du post
                  _buildPostActions(),
                  
                  // Sélecteur de réactions (si visible)
                  if (_showReactionPicker) _buildReactionPickerSection(),
                  
                  // Section commentaires (si visible)
                  if (_showComments) _buildCommentsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construit l'en-tête du post
  Widget _buildPostHeader() {
    return Padding(
      padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
      child: Row(
        children: [
          // Avatar avec indicateur en ligne (si applicable)
          GestureDetector(
            onTap: () => widget.onProfileTap?.call(widget.post.authorId),
            child: Stack(
              children: [
                Container(
                  width: widget.isCompact ? 36 : 44,
                  height: widget.isCompact ? 36 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.themeColors.borderSubtle,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: widget.post.authorAvatar != null
                        ? Image.asset(
                            widget.post.authorAvatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildAvatarFallback();
                            },
                          )
                        : _buildAvatarFallback(),
                  ),
                ),
                
                // Badge épinglé
                if (widget.post.isPinned)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: context.themeColors.colorPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.push_pin,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Informations de l'auteur
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onProfileTap?.call(widget.post.authorId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Nom de l'auteur
                      Flexible(
                        child: Text(
                          widget.post.authorName,
                          style: (widget.isCompact 
                              ? AppTheme.bodyMedium 
                              : AppTheme.bodyLarge).copyWith(
                            color: context.themeColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Badge vérifié
                      if (widget.post.isAuthorVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: widget.isCompact ? 14 : 16,
                          color: context.themeColors.colorPrimary,
                        ),
                      ],
                      
                      // Type de post
                      if (widget.post.type != PostType.text) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.themeColors.bgTertiary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.post.type.icon,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Username et temps
                  Row(
                    children: [
                      if (widget.post.authorUsername != null) ...[
                        Text(
                          widget.post.authorUsername!,
                          style: AppTheme.bodySmall.copyWith(
                            color: context.themeColors.textSecondary,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: AppTheme.bodySmall.copyWith(
                            color: context.themeColors.textSecondary,
                          ),
                        ),
                      ],
                      Text(
                        widget.post.timeAgo,
                        style: AppTheme.bodySmall.copyWith(
                          color: context.themeColors.textSecondary,
                        ),
                      ),
                      
                      // Indicateur d'édition
                      if (widget.post.timestamp != widget.post.timestamp) ...[
                        Text(
                          ' • modifié',
                          style: AppTheme.bodySmall.copyWith(
                            color: context.themeColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Menu d'actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              color: context.themeColors.textSecondary,
            ),
            onSelected: _handlePostAction,
            itemBuilder: (context) => [
              // Actions communes
              const PopupMenuItem(
                value: 'share_external',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 16),
                    SizedBox(width: 8),
                    Text('Partager'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_link',
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16),
                    SizedBox(width: 8),
                    Text('Copier le lien'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag, size: 16),
                    SizedBox(width: 8),
                    Text('Signaler'),
                  ],
                ),
              ),
              
              // Actions pour l'auteur
              if (widget.post.authorId == context.read<FeedProvider>().currentUserId) ...[
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: widget.post.isPinned ? 'unpin' : 'pin',
                  child: Row(
                    children: [
                      Icon(
                        widget.post.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(widget.post.isPinned ? 'Désépingler' : 'Épingler'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Construit l'avatar de fallback
  Widget _buildAvatarFallback() {
    return Container(
      decoration: BoxDecoration(
        color: context.themeColors.colorPrimary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.post.authorName.substring(0, 1).toUpperCase(),
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Construit le contenu du post
  Widget _buildPostContent() {
    if (widget.post.content.isEmpty) return const SizedBox.shrink();
    
    final shouldTruncate = !_isExpanded && widget.post.content.length > 200;
    final displayContent = shouldTruncate 
        ? '${widget.post.content.substring(0, 200)}...'
        : widget.post.content;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 12 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contenu avec hashtags/mentions cliquables
          TextParser.buildRichText(
            displayContent,
            baseStyle: (widget.isCompact 
                ? AppTheme.bodyMedium 
                : AppTheme.bodyLarge).copyWith(
              color: context.themeColors.textPrimary,
              height: 1.4,
            ),
            hashtagStyle: AppTheme.bodyMedium.copyWith(
              color: context.themeColors.colorPrimary,
              fontWeight: FontWeight.w600,
            ),
            mentionStyle: AppTheme.bodyMedium.copyWith(
              color: Colors.purple,
              fontWeight: FontWeight.w600,
            ),
            onHashtagTap: widget.onHashtagTap,
            onMentionTap: (mention) => widget.onProfileTap?.call(mention),
          ),
          
          // Bouton "Voir plus/moins"
          if (widget.post.content.length > 200)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _isExpanded ? 'Voir moins' : 'Voir plus',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.colorPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construit les médias du post
  Widget _buildPostMedia() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 8 : 12,
        vertical: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildMediaContent(),
      ),
    );
  }

  /// Construit le contenu média selon le type
  Widget _buildMediaContent() {
    if (widget.post.imageUrls?.isNotEmpty ?? false) {
      return _buildImageGrid();
    } else if (widget.post.videoUrl != null) {
      return _buildVideoPlayer();
    } else if (widget.post.gifUrl != null) {
      return _buildGifPlayer();
    }
    return const SizedBox.shrink();
  }

  /// Construit la grille d'images
  Widget _buildImageGrid() {
    final images = widget.post.imageUrls!;
    
    if (images.length == 1) {
      return _buildSingleImage(images.first);
    } else if (images.length == 2) {
      return _buildTwoImages(images);
    } else {
      return _buildMultipleImages(images);
    }
  }

  /// Construit l'affichage d'une seule image
  Widget _buildSingleImage(String imageUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: context.themeColors.bgTertiary,
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                color: context.themeColors.textSecondary,
                size: 48,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Construit l'affichage de deux images
  Widget _buildTwoImages(List<String> images) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: Image.asset(
              images[0],
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Image.asset(
              images[1],
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit l'affichage de plusieurs images
  Widget _buildMultipleImages(List<String> images) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // Première image (plus grande)
          Expanded(
            flex: 2,
            child: Image.asset(
              images[0],
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          const SizedBox(width: 2),
          
          // Colonne avec les autres images
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    images[1],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                if (images.length > 2) ...[
                  const SizedBox(height: 2),
                  Expanded(
                    child: Stack(
                      children: [
                        Image.asset(
                          images[2],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        
                        // Overlay pour les images supplémentaires
                        if (images.length > 3)
                          Container(
                            color: Colors.black.withOpacity(0.6),
                            child: Center(
                              child: Text(
                                '+${images.length - 3}',
                                style: AppTheme.headingMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le lecteur vidéo (simulé)
  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Thumbnail de la vidéo
            if (widget.post.imageUrls?.isNotEmpty ?? false)
              Image.asset(
                widget.post.imageUrls!.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            
            // Bouton play
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            
            // Durée de la vidéo
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '2:34', // Durée simulée
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le lecteur GIF (simulé)
  Widget _buildGifPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: context.themeColors.bgTertiary,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gif,
                    size: 48,
                    color: context.themeColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GIF',
                    style: AppTheme.bodyLarge.copyWith(
                      color: context.themeColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Badge GIF
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'GIF',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit l'affichage du post partagé
  Widget _buildSharedPost() {
    final originalPost = widget.post.originalPost!;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 12 : 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.themeColors.borderSubtle,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du post original
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    originalPost.authorName.substring(0, 1).toUpperCase(),
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${originalPost.authorName} • ${originalPost.timeAgo}',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Contenu du post original (tronqué)
          Text(
            originalPost.content.length > 100
                ? '${originalPost.content.substring(0, 100)}...'
                : originalPost.content,
            style: AppTheme.bodyMedium.copyWith(
              color: context.themeColors.textPrimary,
            ),
          ),
          
          // Média du post original (si présent)
          if (originalPost.hasMedia) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: originalPost.imageUrls?.isNotEmpty ?? false
                    ? Image.asset(
                        originalPost.imageUrls!.first,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: context.themeColors.bgTertiary,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: context.themeColors.textSecondary,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construit l'affichage de la localisation
  Widget _buildLocation() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 12 : 16,
        vertical: 4,
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 16,
            color: context.themeColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            widget.post.location!,
            style: AppTheme.bodySmall.copyWith(
              color: context.themeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit les statistiques d'engagement
  Widget _buildEngagementStats() {
    final hasEngagement = widget.post.reactionCount > 0 || 
                         widget.post.commentCount > 0 || 
                         widget.post.shareCount > 0;
    
    if (!hasEngagement) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 12 : 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          // Réactions
          if (widget.post.reactionCount > 0) ...[
            _buildReactionSummary(),
            const Spacer(),
          ],
          
          // Commentaires et partages
          Row(
            children: [
              if (widget.post.commentCount > 0) ...[
                Text(
                  '${widget.post.commentCount} commentaire${widget.post.commentCount > 1 ? 's' : ''}',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.textSecondary,
                  ),
                ),
                if (widget.post.shareCount > 0) ...[
                  Text(
                    ' • ',
                    style: AppTheme.bodySmall.copyWith(
                      color: context.themeColors.textSecondary,
                    ),
                  ),
                ],
              ],
              if (widget.post.shareCount > 0)
                Text(
                  '${widget.post.shareCount} partage${widget.post.shareCount > 1 ? 's' : ''}',
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

  /// Construit le résumé des réactions
  Widget _buildReactionSummary() {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        final reactions = feedProvider.getReactionsForPost(widget.post.id);
        if (reactions.isEmpty) return const SizedBox.shrink();
        
        // Grouper les réactions par type
        final reactionCounts = <ReactionType, int>{};
        for (final reaction in reactions) {
          reactionCounts[reaction.type] = (reactionCounts[reaction.type] ?? 0) + 1;
        }
        
        // Prendre les 3 réactions les plus populaires
        final topReactions = reactionCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final displayReactions = topReactions.take(3).toList();
        
        return Row(
          children: [
            // Emojis des réactions
            ...displayReactions.map((entry) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Text(
                entry.key.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            )).toList(),
            
            const SizedBox(width: 4),
            
            // Nombre total
            Text(
              '${widget.post.reactionCount}',
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construit les actions du post
  Widget _buildPostActions() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 8 : 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.themeColors.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Bouton réaction
          Expanded(
            child: ReactionButton(
              postId: widget.post.id,
              showCount: false,
              isCompact: widget.isCompact,
            ),
          ),
          
          // Bouton commentaire
          Expanded(
            child: GestureDetector(
              onTap: _toggleComments,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: widget.isCompact ? 18 : 20,
                    color: _showComments 
                        ? context.themeColors.colorPrimary
                        : context.themeColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Commenter',
                    style: AppTheme.bodySmall.copyWith(
                      color: _showComments 
                          ? context.themeColors.colorPrimary
                          : context.themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bouton partage
          Expanded(
            child: GestureDetector(
              onTap: _sharePost,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share_outlined,
                    size: widget.isCompact ? 18 : 20,
                    color: context.themeColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Partager',
                    style: AppTheme.bodySmall.copyWith(
                      color: context.themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bouton sauvegarder
          Consumer<SavedPostsProvider>(
            builder: (context, savedProvider, child) {
              final isSaved = savedProvider.isPostSaved(widget.post.id);
              return GestureDetector(
                onTap: () => savedProvider.toggleSavePost(widget.post),
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: widget.isCompact ? 18 : 20,
                  color: isSaved 
                      ? context.themeColors.colorPrimary 
                      : context.themeColors.textSecondary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Construit la section du sélecteur de réactions
  Widget _buildReactionPickerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ReactionPicker(
        postId: widget.post.id,
        isCompact: true,
        onReactionSelected: (reaction) {
          setState(() {
            _showReactionPicker = false;
          });
        },
      ),
    );
  }

  /// Construit la section des commentaires
  Widget _buildCommentsSection() {
    return CommentsSection(
      post: widget.post,
      isModal: false,
      initialCommentsLimit: 3,
    );
  }

  /// Gère les actions du menu post
  void _handlePostAction(String action) {
    final feedProvider = context.read<FeedProvider>();
    
    switch (action) {
      case 'share_external':
        _sharePostExternal();
        break;
      case 'copy_link':
        _copyPostLink();
        break;
      case 'report':
        _reportPost();
        break;
      case 'edit':
        _editPost();
        break;
      case 'pin':
      case 'unpin':
        _togglePinPost();
        break;
      case 'delete':
        _deletePost(feedProvider);
        break;
    }
  }

  /// Bascule l'affichage des commentaires
  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  /// Partage le post
  void _sharePost() {
    context.read<FeedProvider>().sharePost(widget.post.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post partagé')),
    );
  }

  /// Partage le post vers l'extérieur
  void _sharePostExternal() {
    // TODO: Implémenter le partage externe
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partage externe - À implémenter')),
    );
  }

  /// Copie le lien du post
  void _copyPostLink() {
    // TODO: Implémenter la copie de lien
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lien copié dans le presse-papiers')),
    );
  }

  /// Signale le post
  void _reportPost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler le post'),
        content: const Text('Voulez-vous signaler ce post comme inapproprié ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post signalé')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }

  /// Édite le post
  void _editPost() {
    // TODO: Implémenter l'édition de post
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Édition de post - À implémenter')),
    );
  }

  /// Bascule l'épinglage du post
  void _togglePinPost() {
    // TODO: Implémenter l'épinglage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.post.isPinned ? 'Post désépinglé' : 'Post épinglé',
        ),
      ),
    );
  }

  /// Supprime le post
  void _deletePost(FeedProvider feedProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le post'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce post ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              feedProvider.deletePost(widget.post.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post supprimé')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}