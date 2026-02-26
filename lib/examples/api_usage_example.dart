import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/feed/post_model.dart';
import '../models/feed/post_type.dart';

/// Exemple d'utilisation de l'API Service
/// 
/// Ce fichier montre comment utiliser ApiService pour interagir avec le serveur JSON
class ApiUsageExample extends StatefulWidget {
  const ApiUsageExample({super.key});

  @override
  State<ApiUsageExample> createState() => _ApiUsageExampleState();
}

class _ApiUsageExampleState extends State<ApiUsageExample> {
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  /// Charge tous les posts depuis le serveur
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Chargement des posts...';
    });

    try {
      final posts = await ApiService.getPosts();
      setState(() {
        _posts = posts;
        _statusMessage = '${posts.length} posts chargés avec succès';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  /// Crée un nouveau post
  Future<void> _createPost() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Création du post...';
    });

    final newPost = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: 'user_1',
      authorName: 'Test User',
      authorUsername: '@testuser',
      content: 'Nouveau post créé depuis l\'app ! 🚀\n\nTimestamp: ${DateTime.now()}',
      timestamp: DateTime.now(),
      type: PostType.text,
      hashtags: ['Test', 'API'],
    );

    try {
      final createdPost = await ApiService.createPost(newPost);
      setState(() {
        _statusMessage = 'Post créé avec succès: ${createdPost.id}';
        _isLoading = false;
      });
      
      // Recharge la liste des posts
      await _loadPosts();
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur lors de la création: $e';
        _isLoading = false;
      });
    }
  }

  /// Met à jour un post existant
  Future<void> _updatePost(PostModel post) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mise à jour du post...';
    });

    final updatedPost = post.copyWith(
      reactionCount: post.reactionCount + 1,
      hasReacted: true,
    );

    try {
      await ApiService.updatePost(post.id, updatedPost);
      setState(() {
        _statusMessage = 'Post mis à jour avec succès';
        _isLoading = false;
      });
      
      // Recharge la liste des posts
      await _loadPosts();
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur lors de la mise à jour: $e';
        _isLoading = false;
      });
    }
  }

  /// Supprime un post
  Future<void> _deletePost(String postId) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Suppression du post...';
    });

    try {
      await ApiService.deletePost(postId);
      setState(() {
        _statusMessage = 'Post supprimé avec succès';
        _isLoading = false;
      });
      
      // Recharge la liste des posts
      await _loadPosts();
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur lors de la suppression: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple API Usage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
            tooltip: 'Recharger',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de statut
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _isLoading ? Colors.blue.shade100 : Colors.green.shade100,
            child: Row(
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (_isLoading) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // Boutons d'action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createPost,
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un post'),
                  ),
                ),
              ],
            ),
          ),

          // Liste des posts
          Expanded(
            child: _posts.isEmpty
                ? const Center(
                    child: Text('Aucun post disponible'),
                  )
                : ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(post.authorName[0]),
                          ),
                          title: Text(post.authorName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                post.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 16,
                                    color: post.hasReacted
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${post.reactionCount}'),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.comment, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${post.commentCount}'),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.share, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${post.shareCount}'),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'like',
                                child: Row(
                                  children: [
                                    Icon(Icons.favorite),
                                    SizedBox(width: 8),
                                    Text('Liker'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Supprimer',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'like') {
                                _updatePost(post);
                              } else if (value == 'delete') {
                                _showDeleteConfirmation(post);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Affiche une confirmation avant de supprimer
  void _showDeleteConfirmation(PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce post ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(post.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
