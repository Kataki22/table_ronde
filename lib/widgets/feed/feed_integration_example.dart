import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/saved_posts_provider.dart';
import '../../models/feed/post_model.dart';
import '../../models/feed/reaction_type.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';

/// Exemple d'intégration du feed dans l'application existante
/// 
/// Ce widget montre comment utiliser le FeedProvider pour afficher
/// et interagir avec les posts du feed social.
/// 
/// À intégrer dans home_screen.dart ou créer un nouvel onglet feed
class FeedIntegrationExample extends StatefulWidget {
  const FeedIntegrationExample({super.key});

  @override
  State<FeedIntegrationExample> createState() => _FeedIntegrationExampleState();
}

class _FeedIntegrationExampleState extends State<FeedIntegrationExample> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Écouter le scroll pour la pagination infinie
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Charger plus de posts quand on approche de la fin
      context.read<FeedProvider>().loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Feed Social'),
        backgroundColor: context.themeColors.bgSecondary,
        elevation: 0,
        actions: [
          // Bouton pour créer un post
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => _showCreatePostDialog(context),
            tooltip: 'Créer un post',
          ),
          // Bouton filtres
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              context.read<FeedProvider>().setFilter(filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tous les posts')),
              const PopupMenuItem(value: 'following', child: Text('Abonnements')),
              const PopupMenuItem(value: 'trending', child: Text('Tendances')),
              const PopupMenuItem(value: 'saved', child: Text('Sauvegardés')),
            ],
          ),
        ],
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: feedProvider.refreshFeed,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Filtres rapides
                SliverToBoxAdapter(
                  child: _buildQuickFilters(context, feedProvider),
                ),
                
                // Liste des posts
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= feedProvider.posts.length) {
                        // Indicateur de chargement en bas
                        return feedProvider.isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }
                      
                      final post = feedProvider.posts[index];
                      return _buildPostCard(context, post, feedProvider);
                    },
                    childCount: feedProvider.posts.length + 
                        (feedProvider.isLoadingMore ? 1 : 0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construit les filtres rapides en haut du feed
  Widget _buildQuickFilters(BuildContext context, FeedProvider feedProvider) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            context,
            'Tous',
            feedProvider.selectedFilter == 'all',
            () => feedProvider.setFilter('all'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'Abonnements',
            feedProvider.selectedFilter == 'following',
            () => feedProvider.setFilter('following'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'Tendances',
            feedProvider.selectedFilter == 'trending',
            () => feedProvider.setFilter('trending'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'Sauvegardés',
            feedProvider.selectedFilter == 'saved',
            () => feedProvider.setFilter('saved'),
          ),
        ],
      ),
    );
  }

  /// Construit un chip de filtre
  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? context.themeColors.colorPrimary 
              : context.themeColors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? context.themeColors.colorPrimary 
                : context.themeColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected 
                ? Colors.white 
                : context.themeColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Construit une carte de post
  Widget _buildPostCard(
    BuildContext context,
    PostModel post,
    FeedProvider feedProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.themeColors.bgSecondary,
        border: Border(
          bottom: BorderSide(
            color: context.themeColors.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du post
          _buildPostHeader(context, post),
          const SizedBox(height: 12),
          
          // Contenu du post
          _buildPostContent(context, post),
          
          // Images si présentes
          if (post.imageUrls?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            _buildPostImages(context, post.imageUrls!),
          ],
          
          const SizedBox(height: 12),
          
          // Actions du post
          _buildPostActions(context, post, feedProvider),
        ],
      ),
    );
  }

  /// Construit l'en-tête du post (avatar, nom, temps)
  Widget _buildPostHeader(BuildContext context, PostModel post) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.themeColors.colorPrimary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              post.authorName.substring(0, 1).toUpperCase(),
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Nom et temps
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    post.authorName,
                    style: AppTheme.bodyMedium.copyWith(
                      color: context.themeColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (post.isAuthorVerified) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: context.themeColors.colorPrimary,
                    ),
                  ],
                ],
              ),
              Text(
                post.timeAgo,
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
            color: context.themeColors.textSecondary,
          ),
          onSelected: (action) => _handlePostAction(context, post, action),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'save', child: Text('Sauvegarder')),
            const PopupMenuItem(value: 'share', child: Text('Partager')),
            if (post.authorId == context.read<FeedProvider>().currentUserId)
              const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ],
    );
  }

  /// Construit le contenu textuel du post
  Widget _buildPostContent(BuildContext context, PostModel post) {
    return Text(
      post.content,
      style: AppTheme.bodyMedium.copyWith(
        color: context.themeColors.textPrimary,
      ),
    );
  }

  /// Construit les images du post
  Widget _buildPostImages(BuildContext context, List<String> imageUrls) {
    if (imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imageUrls.first,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 200,
              color: context.themeColors.bgTertiary,
              child: Icon(
                Icons.image_not_supported,
                color: context.themeColors.textSecondary,
              ),
            );
          },
        ),
      );
    }
    
    // Grille pour plusieurs images
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imageUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: context.themeColors.bgTertiary,
                child: Icon(
                  Icons.image_not_supported,
                  color: context.themeColors.textSecondary,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Construit les actions du post (like, comment, share)
  Widget _buildPostActions(
    BuildContext context,
    PostModel post,
    FeedProvider feedProvider,
  ) {
    return Row(
      children: [
        // Bouton like
        GestureDetector(
          onTap: () => feedProvider.reactToPost(post.id, ReactionType.like),
          child: Row(
            children: [
              Icon(
                post.hasReacted ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: post.hasReacted 
                    ? Colors.red 
                    : context.themeColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.reactionCount}',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Bouton commentaire
        GestureDetector(
          onTap: () => _showCommentsDialog(context, post, feedProvider),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: context.themeColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.commentCount}',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Bouton partage
        GestureDetector(
          onTap: () => feedProvider.sharePost(post.id),
          child: Row(
            children: [
              Icon(
                Icons.share_outlined,
                size: 20,
                color: context.themeColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.shareCount}',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Bouton sauvegarder
        Consumer<SavedPostsProvider>(
          builder: (context, savedProvider, child) {
            final isSaved = savedProvider.isPostSaved(post.id);
            return GestureDetector(
              onTap: () => savedProvider.toggleSavePost(post),
              child: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
                color: isSaved 
                    ? context.themeColors.colorPrimary 
                    : context.themeColors.textSecondary,
              ),
            );
          },
        ),
      ],
    );
  }

  /// Gère les actions du menu post
  void _handlePostAction(BuildContext context, PostModel post, String action) {
    final feedProvider = context.read<FeedProvider>();
    final savedProvider = context.read<SavedPostsProvider>();
    
    switch (action) {
      case 'save':
        savedProvider.toggleSavePost(post);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              savedProvider.isPostSaved(post.id) 
                  ? 'Post sauvegardé' 
                  : 'Post retiré des sauvegardés',
            ),
          ),
        );
        break;
      case 'share':
        feedProvider.sharePost(post.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post partagé')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, post, feedProvider);
        break;
    }
  }

  /// Affiche la boîte de dialogue de création de post
  void _showCreatePostDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un post'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Quoi de neuf ?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<FeedProvider>().createPost(
                  content: controller.text.trim(),
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post créé avec succès')),
                );
              }
            },
            child: const Text('Publier'),
          ),
        ],
      ),
    );
  }

  /// Affiche la boîte de dialogue des commentaires
  void _showCommentsDialog(
    BuildContext context,
    PostModel post,
    FeedProvider feedProvider,
  ) {
    final TextEditingController controller = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Commentaires (${post.commentCount})',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ajouter un commentaire...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        feedProvider.addComment(
                          postId: post.id,
                          content: controller.text.trim(),
                        );
                        controller.clear();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Commentaire ajouté')),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Affiche la confirmation de suppression
  void _showDeleteConfirmation(
    BuildContext context,
    PostModel post,
    FeedProvider feedProvider,
  ) {
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
              feedProvider.deletePost(post.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post supprimé')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}