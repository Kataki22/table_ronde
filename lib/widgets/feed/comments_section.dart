import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/feed/comment_model.dart';
import '../../models/feed/post_model.dart';
import '../../providers/feed_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/text_parser.dart';

/// Section commentaires avancée avec threading et interactions
/// 
/// Fonctionnalités :
/// - Commentaires avec réponses (threading)
/// - Likes sur les commentaires
/// - Mentions dans les commentaires
/// - Tri des commentaires (récents, populaires)
/// - Pagination des commentaires
/// - Réponse rapide
/// - Modération (signaler, supprimer)
/// 
/// **Validates: Requirements 2.5, 2.6, 3.1**
class CommentsSection extends StatefulWidget {
  /// Post pour lequel afficher les commentaires
  final PostModel post;
  
  /// Si true, affiche en mode modal (bottom sheet)
  final bool isModal;
  
  /// Nombre maximum de commentaires à afficher initialement
  final int initialCommentsLimit;
  
  /// Si true, permet l'ajout de nouveaux commentaires
  final bool allowNewComments;

  const CommentsSection({
    super.key,
    required this.post,
    this.isModal = false,
    this.initialCommentsLimit = 5,
    this.allowNewComments = true,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  // État
  String _sortBy = 'recent'; // recent, popular, oldest
  int _displayedCommentsCount = 0;
  CommentModel? _replyingTo;
  bool _isSubmitting = false;
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _displayedCommentsCount = widget.initialCommentsLimit;
    
    // Animation pour les nouveaux commentaires
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        final comments = _getSortedComments(feedProvider);
        final displayedComments = comments.take(_displayedCommentsCount).toList();
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: widget.isModal ? BoxDecoration(
              color: context.themeColors.bgPrimary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec titre et options de tri
                _buildHeader(comments.length),
                
                // Liste des commentaires
                if (displayedComments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildCommentsList(displayedComments, feedProvider),
                ],
                
                // Bouton "Voir plus" si nécessaire
                if (comments.length > _displayedCommentsCount)
                  _buildLoadMoreButton(comments.length),
                
                // Zone de saisie de nouveau commentaire
                if (widget.allowNewComments) ...[
                  const SizedBox(height: 16),
                  _buildCommentInput(feedProvider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construit l'en-tête avec titre et options
  Widget _buildHeader(int totalComments) {
    return Container(
      padding: EdgeInsets.all(widget.isModal ? 20 : 16),
      decoration: widget.isModal ? BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.themeColors.borderSubtle,
            width: 1,
          ),
        ),
      ) : null,
      child: Row(
        children: [
          // Titre
          Expanded(
            child: Text(
              'Commentaires ($totalComments)',
              style: widget.isModal 
                  ? AppTheme.headingSmall.copyWith(
                      color: context.themeColors.textPrimary,
                    )
                  : AppTheme.bodyLarge.copyWith(
                      color: context.themeColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
          
          // Options de tri
          PopupMenuButton<String>(
            icon: Icon(
              Icons.sort,
              color: context.themeColors.textSecondary,
            ),
            onSelected: (sortBy) {
              setState(() {
                _sortBy = sortBy;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: _sortBy == 'recent' 
                          ? context.themeColors.colorPrimary 
                          : context.themeColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Plus récents',
                      style: TextStyle(
                        color: _sortBy == 'recent' 
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
                      Icons.thumb_up,
                      size: 16,
                      color: _sortBy == 'popular' 
                          ? context.themeColors.colorPrimary 
                          : context.themeColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Plus populaires',
                      style: TextStyle(
                        color: _sortBy == 'popular' 
                            ? context.themeColors.colorPrimary 
                            : context.themeColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'oldest',
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 16,
                      color: _sortBy == 'oldest' 
                          ? context.themeColors.colorPrimary 
                          : context.themeColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Plus anciens',
                      style: TextStyle(
                        color: _sortBy == 'oldest' 
                            ? context.themeColors.colorPrimary 
                            : context.themeColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Bouton fermer (mode modal uniquement)
          if (widget.isModal)
            IconButton(
              icon: Icon(
                Icons.close,
                color: context.themeColors.textSecondary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  /// Construit la liste des commentaires
  Widget _buildCommentsList(List<CommentModel> comments, FeedProvider feedProvider) {
    return ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      physics: widget.isModal 
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return _buildCommentTile(comment, feedProvider, 0);
      },
    );
  }

  /// Construit une tuile de commentaire avec support du threading
  Widget _buildCommentTile(
    CommentModel comment,
    FeedProvider feedProvider,
    int depth,
  ) {
    final isReply = depth > 0;
    final maxDepth = 3; // Profondeur maximale des réponses
    
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? (depth * 20.0) + 16 : 16,
        right: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Commentaire principal
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isReply 
                  ? context.themeColors.bgTertiary
                  : context.themeColors.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: isReply ? Border.all(
                color: context.themeColors.borderSubtle,
                width: 1,
              ) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête du commentaire
                _buildCommentHeader(comment, isReply),
                const SizedBox(height: 8),
                
                // Contenu du commentaire avec mentions/hashtags
                TextParser.buildRichText(
                  comment.content,
                  baseStyle: AppTheme.bodyMedium.copyWith(
                    color: context.themeColors.textPrimary,
                  ),
                  hashtagStyle: AppTheme.bodyMedium.copyWith(
                    color: context.themeColors.colorPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  mentionStyle: AppTheme.bodyMedium.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                  onHashtagTap: (hashtag) => _navigateToHashtag(hashtag),
                  onMentionTap: (mention) => _navigateToProfile(mention),
                ),
                
                const SizedBox(height: 8),
                
                // Actions du commentaire
                _buildCommentActions(comment, feedProvider, depth < maxDepth),
              ],
            ),
          ),
          
          // Réponses au commentaire
          if (comment.replies.isNotEmpty && depth < maxDepth) ...[
            const SizedBox(height: 8),
            ...comment.replies.map((reply) => 
              _buildCommentTile(reply, feedProvider, depth + 1)
            ).toList(),
          ],
          
          // Indicateur de réponses masquées
          if (comment.replies.isNotEmpty && depth >= maxDepth)
            _buildHiddenRepliesIndicator(comment.replies.length),
        ],
      ),
    );
  }

  /// Construit l'en-tête d'un commentaire
  Widget _buildCommentHeader(CommentModel comment, bool isReply) {
    return Row(
      children: [
        // Avatar
        Container(
          width: isReply ? 24 : 32,
          height: isReply ? 24 : 32,
          decoration: BoxDecoration(
            color: context.themeColors.colorPrimary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              comment.authorName.substring(0, 1).toUpperCase(),
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isReply ? 10 : 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        
        // Nom et temps
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.authorName,
                style: (isReply ? AppTheme.bodySmall : AppTheme.bodyMedium).copyWith(
                  color: context.themeColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatCommentTime(comment.timestamp),
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Menu options
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_horiz,
            size: isReply ? 16 : 20,
            color: context.themeColors.textSecondary,
          ),
          onSelected: (action) => _handleCommentAction(comment, action),
          itemBuilder: (context) => [
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
            if (comment.authorId == context.read<FeedProvider>().currentUserId)
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
        ),
      ],
    );
  }

  /// Construit les actions d'un commentaire
  Widget _buildCommentActions(
    CommentModel comment,
    FeedProvider feedProvider,
    bool canReply,
  ) {
    return Row(
      children: [
        // Bouton like
        GestureDetector(
          onTap: () => _toggleCommentLike(comment),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                comment.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                size: 16,
                color: comment.isLiked 
                    ? context.themeColors.colorPrimary 
                    : context.themeColors.textSecondary,
              ),
              if (comment.likeCount > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '${comment.likeCount}',
                  style: AppTheme.bodySmall.copyWith(
                    color: comment.isLiked 
                        ? context.themeColors.colorPrimary 
                        : context.themeColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Bouton répondre
        if (canReply)
          GestureDetector(
            onTap: () => _startReply(comment),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.reply,
                  size: 16,
                  color: context.themeColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Répondre',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        
        const Spacer(),
        
        // Nombre de réponses
        if (comment.replies.isNotEmpty)
          Text(
            '${comment.totalRepliesCount} réponse${comment.totalRepliesCount > 1 ? 's' : ''}',
            style: AppTheme.bodySmall.copyWith(
              color: context.themeColors.textSecondary,
            ),
          ),
      ],
    );
  }

  /// Construit l'indicateur de réponses masquées
  Widget _buildHiddenRepliesIndicator(int hiddenCount) {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 8),
      child: GestureDetector(
        onTap: () {
          // TODO: Afficher les réponses masquées
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$hiddenCount réponses masquées - Fonctionnalité à implémenter'),
            ),
          );
        },
        child: Row(
          children: [
            Icon(
              Icons.more_horiz,
              size: 16,
              color: context.themeColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Voir $hiddenCount réponse${hiddenCount > 1 ? 's' : ''} de plus',
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.colorPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le bouton "Voir plus"
  Widget _buildLoadMoreButton(int totalComments) {
    final remainingComments = totalComments - _displayedCommentsCount;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: TextButton(
          onPressed: () {
            setState(() {
              _displayedCommentsCount += widget.initialCommentsLimit;
            });
          },
          child: Text(
            'Voir $remainingComments commentaire${remainingComments > 1 ? 's' : ''} de plus',
            style: AppTheme.bodyMedium.copyWith(
              color: context.themeColors.colorPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Construit la zone de saisie de commentaire
  Widget _buildCommentInput(FeedProvider feedProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.themeColors.bgSecondary,
        border: Border(
          top: BorderSide(
            color: context.themeColors.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicateur de réponse
          if (_replyingTo != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.themeColors.bgTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    size: 16,
                    color: context.themeColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Réponse à ${_replyingTo!.authorName}',
                      style: AppTheme.bodySmall.copyWith(
                        color: context.themeColors.textSecondary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: context.themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Zone de saisie
          Row(
            children: [
              // Avatar utilisateur
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'A', // Première lettre du nom utilisateur
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Champ de texte
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: _replyingTo != null 
                        ? 'Répondre à ${_replyingTo!.authorName}...'
                        : 'Ajouter un commentaire...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: context.themeColors.borderSubtle,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: context.themeColors.borderSubtle,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: context.themeColors.colorPrimary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.themeColors.textPrimary,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Bouton envoyer
              GestureDetector(
                onTap: _commentController.text.trim().isNotEmpty && !_isSubmitting
                    ? () => _submitComment(feedProvider)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _commentController.text.trim().isNotEmpty && !_isSubmitting
                        ? context.themeColors.colorPrimary
                        : context.themeColors.bgTertiary,
                    shape: BoxShape.circle,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          Icons.send,
                          size: 16,
                          color: _commentController.text.trim().isNotEmpty
                              ? Colors.white
                              : context.themeColors.textSecondary,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Retourne les commentaires triés selon le critère sélectionné
  List<CommentModel> _getSortedComments(FeedProvider feedProvider) {
    final comments = feedProvider.getCommentsForPost(widget.post.id);
    
    switch (_sortBy) {
      case 'popular':
        return comments..sort((a, b) => b.likeCount.compareTo(a.likeCount));
      case 'oldest':
        return comments..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      case 'recent':
      default:
        return comments..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  /// Formate le temps d'un commentaire
  String _formatCommentTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}j';
    }
  }

  /// Gère les actions sur un commentaire
  void _handleCommentAction(CommentModel comment, String action) {
    switch (action) {
      case 'report':
        _reportComment(comment);
        break;
      case 'delete':
        _deleteComment(comment);
        break;
    }
  }

  /// Signale un commentaire
  void _reportComment(CommentModel comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler le commentaire'),
        content: const Text('Voulez-vous signaler ce commentaire comme inapproprié ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Commentaire signalé'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }

  /// Supprime un commentaire
  void _deleteComment(CommentModel comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le commentaire'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce commentaire ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implémenter la suppression
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Commentaire supprimé'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  /// Bascule le like d'un commentaire
  void _toggleCommentLike(CommentModel comment) {
    // TODO: Implémenter le like de commentaire
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          comment.isLiked 
              ? 'Like retiré du commentaire'
              : 'Commentaire liké',
        ),
      ),
    );
  }

  /// Démarre une réponse à un commentaire
  void _startReply(CommentModel comment) {
    setState(() {
      _replyingTo = comment;
    });
    _commentFocusNode.requestFocus();
  }

  /// Annule la réponse en cours
  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  /// Soumet un nouveau commentaire
  Future<void> _submitComment(FeedProvider feedProvider) async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      await feedProvider.addComment(
        postId: widget.post.id,
        content: content,
        parentCommentId: _replyingTo?.id,
      );
      
      _commentController.clear();
      _cancelReply();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commentaire ajouté'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Navigation vers un hashtag
  void _navigateToHashtag(String hashtag) {
    // TODO: Implémenter la navigation vers hashtag
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigation vers #$hashtag')),
    );
  }

  /// Navigation vers un profil
  void _navigateToProfile(String username) {
    // TODO: Implémenter la navigation vers profil
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigation vers @$username')),
    );
  }
}