import 'package:flutter/material.dart';
import '../../models/profiles/user_post.dart';
import 'post_card.dart';

/// Example usage of the PostCard widget
/// 
/// This file demonstrates how to use the PostCard widget with various
/// configurations including posts with different numbers of images.
class PostCardExample extends StatelessWidget {
  const PostCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PostCard Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Post with text only
          PostCard(
            post: UserPost(
              id: '1',
              content: 'Ceci est un exemple de post avec seulement du texte. '
                  'Le contenu peut être assez long et s\'étendra sur plusieurs lignes.',
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
              likesCount: 42,
              commentsCount: 8,
            ),
            onTap: () => _showSnackBar(context, 'Post tapped'),
            onLikeTap: () => _showSnackBar(context, 'Like tapped'),
            onCommentTap: () => _showSnackBar(context, 'Comment tapped'),
          ),
          const SizedBox(height: 16),
          
          // Example 2: Post with single image
          PostCard(
            post: UserPost(
              id: '2',
              content: 'Post avec une seule image',
              imageUrls: const [
                'https://picsum.photos/800/600?random=1',
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
              likesCount: 156,
              commentsCount: 23,
            ),
            onTap: () => _showSnackBar(context, 'Post tapped'),
            onLikeTap: () => _showSnackBar(context, 'Like tapped'),
            onCommentTap: () => _showSnackBar(context, 'Comment tapped'),
          ),
          const SizedBox(height: 16),
          
          // Example 3: Post with two images
          PostCard(
            post: UserPost(
              id: '3',
              content: 'Post avec deux images côte à côte',
              imageUrls: const [
                'https://picsum.photos/800/600?random=2',
                'https://picsum.photos/800/600?random=3',
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
              likesCount: 1234,
              commentsCount: 89,
            ),
            onTap: () => _showSnackBar(context, 'Post tapped'),
            onLikeTap: () => _showSnackBar(context, 'Like tapped'),
            onCommentTap: () => _showSnackBar(context, 'Comment tapped'),
          ),
          const SizedBox(height: 16),
          
          // Example 4: Post with three images
          PostCard(
            post: UserPost(
              id: '4',
              content: 'Post avec trois images (layout spécial)',
              imageUrls: const [
                'https://picsum.photos/800/600?random=4',
                'https://picsum.photos/800/600?random=5',
                'https://picsum.photos/800/600?random=6',
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 7)),
              likesCount: 5678,
              commentsCount: 234,
            ),
            onTap: () => _showSnackBar(context, 'Post tapped'),
            onLikeTap: () => _showSnackBar(context, 'Like tapped'),
            onCommentTap: () => _showSnackBar(context, 'Comment tapped'),
          ),
          const SizedBox(height: 16),
          
          // Example 5: Post with multiple images (4+)
          PostCard(
            post: UserPost(
              id: '5',
              content: 'Post avec plusieurs images (grille 2x2 avec indicateur)',
              imageUrls: const [
                'https://picsum.photos/800/600?random=7',
                'https://picsum.photos/800/600?random=8',
                'https://picsum.photos/800/600?random=9',
                'https://picsum.photos/800/600?random=10',
                'https://picsum.photos/800/600?random=11',
                'https://picsum.photos/800/600?random=12',
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 30)),
              likesCount: 12345,
              commentsCount: 567,
            ),
            onTap: () => _showSnackBar(context, 'Post tapped'),
            onLikeTap: () => _showSnackBar(context, 'Like tapped'),
            onCommentTap: () => _showSnackBar(context, 'Comment tapped'),
          ),
          const SizedBox(height: 16),
          
          // Example 6: Post with large numbers
          PostCard(
            post: UserPost(
              id: '6',
              content: 'Post viral avec beaucoup d\'engagement!',
              imageUrls: const [
                'https://picsum.photos/800/600?random=13',
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 365)),
              likesCount: 1234567,
              commentsCount: 89012,
            ),
            onTap: () => _showSnackBar(context, 'Post tapped'),
            onLikeTap: () => _showSnackBar(context, 'Like tapped'),
            onCommentTap: () => _showSnackBar(context, 'Comment tapped'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
