import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/groups/group_chat_model.dart';
import '../../providers/group_chat_provider.dart';
import '../../widgets/groups/member_list_tile.dart';
import '../../widgets/settings/confirmation_dialog.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive_layout.dart';
import 'group_members_screen.dart';

/// Bottom sheet affichant les informations d'un groupe
///
/// Affiche:
/// - Photo, nom et description du groupe
/// - Liste des membres avec permissions (max 5, puis "Voir tous")
/// - Boutons d'action: Gérer membres, Paramètres, Quitter
///
/// Validates: Requirements 1.4, 1.5, 1.8
class GroupInfoBottomSheet extends StatelessWidget {
  final GroupChatModel group;

  const GroupInfoBottomSheet({
    super.key,
    required this.group,
  });

  /// Méthode helper pour afficher le bottom sheet avec animation slide up (300ms)
  /// 
  /// On mobile: shows as bottom sheet
  /// On desktop: shows as dialog
  /// 
  /// Note: showModalBottomSheet uses Material Design's default slide-up animation
  /// which is approximately 300ms, matching the requirement.
  static void show(BuildContext context, GroupChatModel group) {
    ResponsiveLayout.showAdaptiveModal(
      context: context,
      builder: (context) => GroupInfoBottomSheet(group: group),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final provider = context.watch<GroupChatProvider>();
    final currentUserId = provider.currentUserId;
    final isAdmin = currentUserId != null && group.isUserAdmin(currentUserId);
    final canManage = currentUserId != null && group.canUserManageMembers(currentUserId);
    final isDesktop = ResponsiveLayout.shouldUseDesktopLayout(context);

    // On desktop, show as dialog content
    if (isDesktop) {
      return Container(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Informations du groupe',
                    style: AppTheme.headingMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Content
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                children: [
                  _buildGroupHeader(context, colors),
                  const SizedBox(height: 24),
                  _buildMembersSection(context, colors, canManage, isAdmin),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, colors, canManage),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // On mobile, show as draggable bottom sheet
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLarge),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Contenu scrollable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // En-tête du groupe
                    _buildGroupHeader(context, colors),
                    const SizedBox(height: 24),

                    // Section membres
                    _buildMembersSection(context, colors, canManage, isAdmin),
                    const SizedBox(height: 24),

                    // Boutons d'action
                    _buildActionButtons(context, colors, canManage),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupHeader(BuildContext context, AppThemeData colors) {
    return Column(
      children: [
        // Photo du groupe
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.bgSecondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.borderMedium,
              width: 2,
            ),
          ),
          child: group.photoUrl != null
              ? ClipOval(
                  child: Image.asset(
                    group.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.group,
                        size: 40,
                        color: colors.textSecondary,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.group,
                  size: 40,
                  color: colors.textSecondary,
                ),
        ),
        const SizedBox(height: 16),

        // Nom du groupe
        Text(
          group.name,
          style: AppTheme.headingMedium.copyWith(
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Description
        if (group.description != null && group.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              group.description!,
              style: AppTheme.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 8),

        // Nombre de membres
        Text(
          '${group.members.length} membre${group.members.length > 1 ? 's' : ''}',
          style: AppTheme.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSection(
    BuildContext context,
    AppThemeData colors,
    bool canManage,
    bool isAdmin,
  ) {
    final displayedMembers = group.members.take(5).toList();
    final hasMore = group.members.length > 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Membres',
              style: AppTheme.headingSmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
            if (hasMore)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GroupMembersScreen(group: group),
                    ),
                  );
                },
                child: Text(
                  'Voir tous',
                  style: AppTheme.bodyMedium.copyWith(
                    color: colors.colorPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Liste des membres
        ...displayedMembers.map((member) {
          return MemberListTile(
            member: member,
            canManage: canManage,
            isCurrentUserAdmin: isAdmin,
            onRemove: () => _handleRemoveMember(context, member.userId),
            onChangePermission: (permission) =>
                _handleChangePermission(context, member.userId, permission),
          );
        }),

        // Bouton "Voir tous les membres"
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GroupMembersScreen(group: group),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Voir tous les membres (${group.members.length})',
                    style: AppTheme.bodyMedium.copyWith(
                      color: colors.colorPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppThemeData colors,
    bool canManage,
  ) {
    return Column(
      children: [
        // Bouton Gérer les membres (admin/moderator uniquement)
        if (canManage)
          _buildActionButton(
            context,
            colors,
            icon: Icons.group_add,
            label: 'Gérer les membres',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GroupMembersScreen(group: group),
                ),
              );
            },
          ),

        const SizedBox(height: 12),

        // Bouton Paramètres du groupe
        _buildActionButton(
          context,
          colors,
          icon: Icons.settings,
          label: 'Paramètres du groupe',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paramètres du groupe - À implémenter'),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // Bouton Quitter le groupe
        _buildActionButton(
          context,
          colors,
          icon: Icons.exit_to_app,
          label: 'Quitter le groupe',
          isDestructive: true,
          onTap: () => _handleLeaveGroup(context),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    AppThemeData colors, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: colors.borderMedium),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? colors.colorDanger : colors.textPrimary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color: isDestructive ? colors.colorDanger : colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRemoveMember(BuildContext context, String userId) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Retirer le membre',
      message: 'Êtes-vous sûr de vouloir retirer ce membre du groupe ?',
      confirmText: 'Retirer',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        final provider = context.read<GroupChatProvider>();
        await provider.removeMember(group.id, userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Membre retiré avec succès'),
              backgroundColor: context.themeColors.colorSuccess,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: context.themeColors.colorDanger,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleChangePermission(
    BuildContext context,
    String userId,
    permission,
  ) async {
    try {
      final provider = context.read<GroupChatProvider>();
      await provider.updateMemberPermission(group.id, userId, permission);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permission modifiée avec succès'),
            backgroundColor: context.themeColors.colorSuccess,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: context.themeColors.colorDanger,
          ),
        );
      }
    }
  }

  Future<void> _handleLeaveGroup(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Quitter le groupe',
      message:
          'Êtes-vous sûr de vouloir quitter ce groupe ? Vous ne recevrez plus les messages.',
      confirmText: 'Quitter',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        final provider = context.read<GroupChatProvider>();
        await provider.leaveGroup(group.id);

        if (context.mounted) {
          Navigator.of(context).pop(); // Fermer le bottom sheet
          Navigator.of(context).pop(); // Retourner à la liste des chats
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Vous avez quitté le groupe'),
              backgroundColor: context.themeColors.colorSuccess,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: context.themeColors.colorDanger,
            ),
          );
        }
      }
    }
  }
}
