import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/profiles/user_profile_model.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/profiles/profile_header.dart';
import '../../widgets/profiles/action_buttons.dart';
import '../../widgets/profiles/activity_card.dart';
import '../../widgets/profiles/post_card.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_layout.dart';
import 'profile_edit_screen.dart';

/// Screen displaying a user's complete profile
/// 
/// Displays:
/// - Profile header with photo, name, bio, registration date
/// - Action buttons (Message, Call, Video, Block) for other users
/// - Edit button for current user's profile
/// - Recent activities section
/// - Posts section
/// 
/// Animations:
/// - Hero animation on avatar (when navigating from another screen)
/// - Staggered fade-in for sections (200ms delay between each)
/// 
/// **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 8.3**
class ProfileScreen extends StatefulWidget {
  /// The ID of the user whose profile to display
  final String userId;

  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _sectionAnimations;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for staggered fade-in
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create staggered animations for each section (200ms delay between each)
    _sectionAnimations = List.generate(4, (index) {
      final start = index * 0.2; // 200ms delay between sections
      final end = start + 0.3; // Each animation takes 300ms
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    // Start animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.getProfile(widget.userId);
        final currentUser = profileProvider.currentUserProfile;
        
        // Handle case where profile doesn't exist
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profil'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: context.themeColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ce profil n\'est plus disponible',
                    style: AppTheme.bodyLarge.copyWith(
                      color: context.themeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),
          );
        }

        final isCurrentUser = currentUser?.id == widget.userId;

        return Scaffold(
          backgroundColor: context.themeColors.bgPrimary,
          appBar: AppBar(
            title: Text(isCurrentUser ? 'Mon profil' : 'Profil'),
            backgroundColor: context.themeColors.bgSecondary,
            elevation: 0,
          ),
          body: ResponsiveLayout.shouldUseDesktopLayout(context)
              ? _buildDesktopLayout(context, profile, isCurrentUser)
              : _buildMobileLayout(context, profile, isCurrentUser),
        );
      },
    );
  }

  /// Builds an animated section with fade-in effect
  Widget _buildAnimatedSection({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  /// Mobile layout: single column scrollable
  Widget _buildMobileLayout(
    BuildContext context,
    UserProfileModel profile,
    bool isCurrentUser,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with fade-in animation (section 0)
          _buildAnimatedSection(
            animation: _sectionAnimations[0],
            child: ProfileHeader(
              profile: profile,
              isCurrentUser: isCurrentUser,
              heroTag: 'profile_avatar_${widget.userId}',
              onEditPressed: isCurrentUser
                  ? () => _navigateToEditProfile(context)
                  : null,
            ),
          ),

          // Action buttons with fade-in animation (section 1)
          if (!isCurrentUser)
            _buildAnimatedSection(
              animation: _sectionAnimations[1],
              child: ActionButtons(
                profile: profile,
                isCurrentUser: isCurrentUser,
                onMessageTap: () => _handleMessageTap(context, profile),
                onVoiceCallTap: () => _handleVoiceCallTap(context, profile),
                onVideoCallTap: () => _handleVideoCallTap(context, profile),
                onBlockTap: () => _handleBlockTap(context, profile),
              ),
            ),

          // Recent activities section with fade-in animation (section 2)
          if (profile.recentActivities.isNotEmpty)
            _buildAnimatedSection(
              animation: _sectionAnimations[2],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    'Activités récentes',
                    Icons.history,
                  ),
                  _buildActivitiesSection(context, profile),
                ],
              ),
            ),

          // Posts section with fade-in animation (section 3)
          if (profile.posts.isNotEmpty)
            _buildAnimatedSection(
              animation: _sectionAnimations[3],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    'Publications',
                    Icons.article_outlined,
                  ),
                  _buildPostsSection(context, profile),
                ],
              ),
            ),

          // Empty state if no activities and no posts
          if (profile.recentActivities.isEmpty && profile.posts.isEmpty)
            _buildAnimatedSection(
              animation: _sectionAnimations[2],
              child: _buildEmptyState(context, isCurrentUser),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Desktop layout: two-column with profile info on left, content on right
  Widget _buildDesktopLayout(
    BuildContext context,
    UserProfileModel profile,
    bool isCurrentUser,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Profile info (fixed width)
        Container(
          width: ResponsiveLayout.getSidePanelWidth(context),
          decoration: BoxDecoration(
            color: context.themeColors.bgSecondary,
            border: Border(
              right: BorderSide(color: context.themeColors.borderMedium),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                _buildAnimatedSection(
                  animation: _sectionAnimations[0],
                  child: ProfileHeader(
                    profile: profile,
                    isCurrentUser: isCurrentUser,
                    heroTag: 'profile_avatar_${widget.userId}',
                    onEditPressed: isCurrentUser
                        ? () => _navigateToEditProfile(context)
                        : null,
                  ),
                ),

                // Action buttons
                if (!isCurrentUser)
                  _buildAnimatedSection(
                    animation: _sectionAnimations[1],
                    child: ActionButtons(
                      profile: profile,
                      isCurrentUser: isCurrentUser,
                      onMessageTap: () => _handleMessageTap(context, profile),
                      onVoiceCallTap: () => _handleVoiceCallTap(context, profile),
                      onVideoCallTap: () => _handleVideoCallTap(context, profile),
                      onBlockTap: () => _handleBlockTap(context, profile),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Right column: Activities and posts
        Expanded(
          child: SingleChildScrollView(
            padding: ResponsiveLayout.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent activities section
                if (profile.recentActivities.isNotEmpty)
                  _buildAnimatedSection(
                    animation: _sectionAnimations[2],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          context,
                          'Activités récentes',
                          Icons.history,
                        ),
                        _buildActivitiesSection(context, profile),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Posts section
                if (profile.posts.isNotEmpty)
                  _buildAnimatedSection(
                    animation: _sectionAnimations[3],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          context,
                          'Publications',
                          Icons.article_outlined,
                        ),
                        _buildPostsSection(context, profile),
                      ],
                    ),
                  ),

                // Empty state if no activities and no posts
                if (profile.recentActivities.isEmpty && profile.posts.isEmpty)
                  _buildAnimatedSection(
                    animation: _sectionAnimations[2],
                    child: _buildEmptyState(context, isCurrentUser),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a section header
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: context.themeColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTheme.bodyLarge.copyWith(
              color: context.themeColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the activities section
  Widget _buildActivitiesSection(
    BuildContext context,
    UserProfileModel profile,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: profile.recentActivities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final activity = profile.recentActivities[index];
        return ActivityCard(
          activity: activity,
          onTap: () => _handleActivityTap(context, activity),
        );
      },
    );
  }

  /// Builds the posts section
  Widget _buildPostsSection(
    BuildContext context,
    UserProfileModel profile,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: profile.posts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = profile.posts[index];
        return PostCard(
          post: post,
          onLikeTap: () => _handleLikeTap(context, post),
          onCommentTap: () => _handleCommentTap(context, post),
        );
      },
    );
  }

  /// Builds empty state when user has no activities or posts
  Widget _buildEmptyState(BuildContext context, bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: context.themeColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isCurrentUser
                  ? 'Aucune activité pour le moment'
                  : 'Cet utilisateur n\'a pas encore d\'activité',
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Action handlers

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(userId: widget.userId),
      ),
    );
  }

  void _handleMessageTap(BuildContext context, UserProfileModel profile) {
    // TODO: Navigate to chat screen with this user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouvrir conversation avec ${profile.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleVoiceCallTap(BuildContext context, UserProfileModel profile) {
    // TODO: Initiate voice call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appel vocal avec ${profile.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleVideoCallTap(BuildContext context, UserProfileModel profile) {
    // TODO: Initiate video call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appel vidéo avec ${profile.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleBlockTap(BuildContext context, UserProfileModel profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquer cet utilisateur'),
        content: Text(
          'Êtes-vous sûr de vouloir bloquer ${profile.name} ? '
          'Vous ne recevrez plus de messages de cette personne.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<ProfileProvider>().blockUser(profile.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${profile.name} a été bloqué'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: context.themeColors.colorDanger,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: context.themeColors.colorDanger,
            ),
            child: const Text('Bloquer'),
          ),
        ],
      ),
    );
  }

  void _handleActivityTap(BuildContext context, activity) {
    // TODO: Navigate to activity content
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ouvrir activité'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleLikeTap(BuildContext context, post) {
    // TODO: Toggle like on post
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post aimé'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleCommentTap(BuildContext context, post) {
    // TODO: Open comments
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ouvrir commentaires'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
