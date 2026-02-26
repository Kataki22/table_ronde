import 'package:flutter/material.dart';
import '../../models/feed/post_model.dart';
import 'post_card.dart';

class HomeFeed extends StatelessWidget {
  final List<PostModel> posts;

  const HomeFeed({super.key, required this.posts});

  /// Convertit un PostModel en Map pour le PostCard
  Map<String, dynamic> _postModelToMap(PostModel post) {
    // Extraire les initiales pour l'avatar
    String getInitials(String name) {
      final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) return '?';
      if (parts.length == 1) {
        // Vérifier que la première partie a au moins un caractère
        return parts[0].isNotEmpty ? parts[0].substring(0, 1).toUpperCase() : '?';
      }
      // Vérifier que les deux parties ont au moins un caractère
      final first = parts[0].isNotEmpty ? parts[0].substring(0, 1).toUpperCase() : '';
      final second = parts[1].isNotEmpty ? parts[1].substring(0, 1).toUpperCase() : '';
      return first + second;
    }

    return {
      'author': post.authorName,
      'username': post.authorUsername ?? '@${post.authorName.toLowerCase()}',
      'avatar': getInitials(post.authorName),
      'time': post.timeAgo,
      'content': post.content,
      'imageUrl': post.imageUrls?.isNotEmpty == true ? post.imageUrls!.first : null,
      'likes': post.reactionCount,
      'comments': post.commentCount,
      'type': post.type.name,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feed_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun post à afficher',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final postMap = _postModelToMap(posts[index]);
        return PostCard(post: postMap);
      },
    );
  }
}
