import 'package:flutter/material.dart';
import '../../models/profiles/user_profile_model.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/accessibility_helpers.dart';

/// Widget displaying a user profile header
/// 
/// Displays user information including:
/// - Profile photo with fallback to initials (with Hero animation support)
/// - Name and username
/// - Bio
/// - Registration date
/// - Online status indicator
/// 
/// **Validates: Requirements 2.2, 8.3**
class ProfileHeader extends StatelessWidget {
  /// The user profile to display
  final UserProfileModel profile;
  
  /// Whether this is the current user's profile
  final bool isCurrentUser;
  
  /// Hero tag for avatar animation (optional)
  final String? heroTag;
  
  /// Callback when edit button is pressed (only shown for current user)
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.isCurrentUser = false,
    this.heroTag,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          // Profile photo and online status
          _buildProfilePhoto(context),
          const SizedBox(height: 16),
          
          // Name
          Text(
            profile.name,
            style: AppTheme.headingMedium.copyWith(
              color: context.themeColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Username
          if (profile.username != null && profile.username!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.username!,
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              profile.bio!,
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Registration date
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: context.themeColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Membre depuis ${_formatRegistrationDate(profile.createdAt)}',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                ),
              ),
            ],
          ),
          
          // Edit button (only for current user)
          if (isCurrentUser && onEditPressed != null) ...[
            const SizedBox(height: 20),
            Semantics(
              label: 'Modifier le profil',
              hint: AccessibilityHelpers.tapToEdit,
              button: true,
              enabled: true,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onEditPressed,
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('Modifier le profil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.themeColors.colorPrimary,
                    foregroundColor: context.themeColors.textInverse,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  /// Builds the profile photo with online status indicator
  Widget _buildProfilePhoto(BuildContext context) {
    final avatarWidget = Stack(
      children: [
        // Profile photo
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.themeColors.borderMedium,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                ? NetworkImage(profile.avatarUrl!)
                : null,
            backgroundColor: context.themeColors.bgSurfaceDark,
            child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                ? Text(
                    _getInitials(profile.name),
                    style: AppTheme.headingLarge.copyWith(
                      color: context.themeColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  )
                : null,
          ),
        ),
        
        // Online status indicator
        Positioned(
          right: 4,
          bottom: 4,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(context),
              border: Border.all(
                color: context.themeColors.bgSecondary,
                width: 3,
              ),
            ),
          ),
        ),
      ],
    );

    // Wrap with Hero animation if heroTag is provided
    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  /// Gets the initials from the user's name
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
  }

  /// Gets the color for the online status indicator
  Color _getStatusColor(BuildContext context) {
    return profile.isOnline
        ? context.themeColors.colorOnline
        : context.themeColors.colorOffline;
  }

  /// Formats the registration date to a readable format
  String _formatRegistrationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      if (weeks == 0) {
        return 'moins d\'une semaine';
      }
      return '$weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months mois';
    } else {
      // Format as "mois année" (e.g., "janvier 2023")
      final monthNames = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      return '${monthNames[date.month - 1]} ${date.year}';
    }
  }
}
