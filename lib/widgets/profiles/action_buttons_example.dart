import 'package:flutter/material.dart';
import 'action_buttons.dart';
import '../../models/profiles/user_profile_model.dart';
import '../../utils/app_theme.dart';

/// Example demonstrating the ActionButtons widget
/// 
/// Shows how to use ActionButtons for different user profiles
class ActionButtonsExample extends StatelessWidget {
  const ActionButtonsExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Example profile for another user
    final otherUserProfile = UserProfileModel(
      id: 'user_2',
      name: 'Marie Dubois',
      username: '@marie_dubois',
      bio: 'Designer passionnée par l\'UX/UI',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      isOnline: true,
    );

    // Example profile for current user
    final currentUserProfile = UserProfileModel(
      id: 'user_1',
      name: 'Jean Dupont',
      username: '@jean_dupont',
      bio: 'Développeur Flutter',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      isOnline: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ActionButtons Examples'),
      ),
      body: ListView(
        children: [
          // Example 1: Action buttons for another user
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Action Buttons for Another User',
              style: AppTheme.headingMedium,
            ),
          ),
          ActionButtons(
            profile: otherUserProfile,
            isCurrentUser: false,
            onMessageTap: () => _showSnackBar(context, 'Message tapped'),
            onVoiceCallTap: () => _showSnackBar(context, 'Voice call tapped'),
            onVideoCallTap: () => _showSnackBar(context, 'Video call tapped'),
            onBlockTap: () => _showSnackBar(context, 'Block tapped'),
          ),
          
          const SizedBox(height: 32),
          
          // Example 2: No buttons for current user (should be hidden)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Action Buttons for Current User (Hidden)',
              style: AppTheme.headingMedium,
            ),
          ),
          ActionButtons(
            profile: currentUserProfile,
            isCurrentUser: true,
            onMessageTap: () => _showSnackBar(context, 'Message tapped'),
            onVoiceCallTap: () => _showSnackBar(context, 'Voice call tapped'),
            onVideoCallTap: () => _showSnackBar(context, 'Video call tapped'),
            onBlockTap: () => _showSnackBar(context, 'Block tapped'),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '(No buttons shown - edit button is in ProfileHeader)',
              style: AppTheme.bodySmall,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Example 3: Buttons without callbacks (disabled state)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Action Buttons Without Callbacks',
              style: AppTheme.headingMedium,
            ),
          ),
          ActionButtons(
            profile: otherUserProfile,
            isCurrentUser: false,
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
