import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/theme_extensions.dart';
import 'profile_header.dart';

/// Example screen demonstrating the ProfileHeader widget
/// 
/// This example shows how to use ProfileHeader in a real screen:
/// - Fetching profile data from ProfileProvider
/// - Displaying the header for current user vs other users
/// - Handling the edit button callback
class ProfileHeaderExample extends StatelessWidget {
  /// The ID of the user whose profile to display
  final String userId;
  
  /// Whether this is the current user's profile
  final bool isCurrentUser;

  const ProfileHeaderExample({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: context.themeColors.bgSecondary,
        foregroundColor: context.themeColors.textPrimary,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final profile = profileProvider.getProfile(userId);
          
          if (profile == null) {
            return Center(
              child: Text(
                'Profil non trouvé',
                style: TextStyle(color: context.themeColors.textSecondary),
              ),
            );
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                ProfileHeader(
                  profile: profile,
                  isCurrentUser: isCurrentUser,
                  onEditPressed: isCurrentUser
                      ? () => _handleEditProfile(context)
                      : null,
                ),
                
                // Additional profile content would go here
                // (activities, posts, etc.)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activités récentes',
                        style: TextStyle(
                          color: context.themeColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${profile.recentActivities.length} activités',
                        style: TextStyle(
                          color: context.themeColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Posts',
                        style: TextStyle(
                          color: context.themeColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${profile.posts.length} posts',
                        style: TextStyle(
                          color: context.themeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Handles the edit profile button press
  void _handleEditProfile(BuildContext context) {
    // Navigate to profile edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers l\'édition du profil'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Example demonstrating different ProfileHeader states
class ProfileHeaderStatesExample extends StatelessWidget {
  const ProfileHeaderStatesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      appBar: AppBar(
        title: const Text('ProfileHeader - États'),
        backgroundColor: context.themeColors.bgSecondary,
        foregroundColor: context.themeColors.textPrimary,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final currentProfile = profileProvider.currentUserProfile;
          
          if (currentProfile == null) {
            return Center(
              child: Text(
                'Aucun profil disponible',
                style: TextStyle(color: context.themeColors.textSecondary),
              ),
            );
          }
          
          return ListView(
            children: [
              // Current user profile (with edit button)
              ProfileHeader(
                profile: currentProfile,
                isCurrentUser: true,
                onEditPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Éditer le profil')),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              Container(
                height: 8,
                color: context.themeColors.bgTertiary,
              ),
              
              const SizedBox(height: 16),
              
              // Other user profile (without edit button)
              ProfileHeader(
                profile: currentProfile.copyWith(
                  name: 'Autre Utilisateur',
                  username: '@autre_user',
                  isOnline: false,
                ),
                isCurrentUser: false,
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              Container(
                height: 8,
                color: context.themeColors.bgTertiary,
              ),
              
              const SizedBox(height: 16),
              
              // Profile without bio
              ProfileHeader(
                profile: currentProfile.copyWith(
                  name: 'Utilisateur Sans Bio',
                  bio: null,
                  isOnline: true,
                ),
                isCurrentUser: false,
              ),
            ],
          );
        },
      ),
    );
  }
}
