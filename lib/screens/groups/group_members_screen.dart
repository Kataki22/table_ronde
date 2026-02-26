import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/groups/group_chat_model.dart';
import '../../models/groups/group_permission.dart';
import '../../providers/group_chat_provider.dart';
import '../../widgets/groups/member_list_tile.dart';
import '../../widgets/settings/confirmation_dialog.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/avatar_helper.dart';

/// Screen affichant la liste complète des membres d'un groupe
///
/// Affiche:
/// - Liste complète des membres avec permissions
/// - Options de gestion pour les admins (ajouter/retirer membres, changer permissions)
/// - Sections séparées pour admins, modérateurs et membres
///
/// Validates: Requirements 1.4, 1.6, 9.3, 9.4
class GroupMembersScreen extends StatefulWidget {
  final GroupChatModel group;

  const GroupMembersScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_MemberSection> _getFilteredSections(GroupChatModel group) {
    final admins = group.admins;
    final moderators = group.moderators;
    final members = group.members
        .where((m) => m.permission == GroupPermission.member)
        .toList();

    // Filtrer par recherche
    List<_MemberSection> sections = [];

    if (_searchQuery.isEmpty) {
      if (admins.isNotEmpty) {
        sections.add(_MemberSection('Administrateurs', admins));
      }
      if (moderators.isNotEmpty) {
        sections.add(_MemberSection('Modérateurs', moderators));
      }
      if (members.isNotEmpty) {
        sections.add(_MemberSection('Membres', members));
      }
    } else {
      final query = _searchQuery.toLowerCase();
      final filteredMembers = group.members
          .where((m) => m.name.toLowerCase().contains(query))
          .toList();

      if (filteredMembers.isNotEmpty) {
        sections.add(_MemberSection('Résultats', filteredMembers));
      }
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final provider = context.watch<GroupChatProvider>();
    final currentGroup = provider.getGroupById(widget.group.id);

    // Si le groupe n'existe plus, retourner
    if (currentGroup == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentUserId = provider.currentUserId;
    final isAdmin = currentUserId != null && currentGroup.isUserAdmin(currentUserId);
    final canManage = currentUserId != null && currentGroup.canUserManageMembers(currentUserId);
    final sections = _getFilteredSections(currentGroup);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: colors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Membres',
              style: AppTheme.headingSmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
            Text(
              '${currentGroup.members.length} membre${currentGroup.members.length > 1 ? 's' : ''}',
              style: AppTheme.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          if (canManage)
            IconButton(
              icon: Icon(Icons.person_add, color: colors.textPrimary),
              onPressed: () => _showAddMemberDialog(context, currentGroup),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          _buildSearchBar(colors),

          // Liste des membres
          Expanded(
            child: sections.isEmpty
                ? _buildEmptyState(colors)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      return _buildSection(
                        context,
                        sections[index],
                        currentGroup,
                        canManage,
                        isAdmin,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppThemeData colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: colors.bgSurface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un membre',
          prefixIcon: Icon(Icons.search, color: colors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: colors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: colors.bgSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: colors.borderMedium),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: colors.colorPrimary, width: 2),
          ),
        ),
        style: AppTheme.bodyMedium.copyWith(color: colors.textPrimary),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    _MemberSection section,
    GroupChatModel group,
    bool canManage,
    bool isAdmin,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${section.title} (${section.members.length})',
            style: AppTheme.bodySmall.copyWith(
              color: context.themeColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Membres de la section
        ...section.members.map((member) {
          final provider = context.read<GroupChatProvider>();
          final isCurrentUser = member.userId == provider.currentUserId;

          return MemberListTile(
            member: member,
            canManage: canManage && !isCurrentUser,
            isCurrentUserAdmin: isAdmin,
            onRemove: () => _handleRemoveMember(context, group, member.userId),
            onChangePermission: (permission) =>
                _handleChangePermission(context, group, member.userId, permission),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(AppThemeData colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun membre trouvé',
            style: AppTheme.bodyLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, GroupChatModel group) {
    // Mock users disponibles (qui ne sont pas déjà membres)
    final existingMemberIds = group.members.map((m) => m.userId).toSet();
    final availableUsers = [
      _MockUser('user_2', 'T4zor', 'assets/images/Avatar2.png'),
      _MockUser('user_3', 'Tk-Porky', AvatarHelper.getRandomAvatar()),
      _MockUser('user_4', 'Sophie Martin', AvatarHelper.getRandomAvatar()),
      _MockUser('user_5', 'Lucas Dubois', AvatarHelper.getRandomAvatar()),
      _MockUser('user_6', 'ProGamer42', AvatarHelper.getRandomAvatar()),
      _MockUser('user_7', 'NinjaKiller', AvatarHelper.getRandomAvatar()),
      _MockUser('user_8', 'Emma Leroy', AvatarHelper.getRandomAvatar()),
      _MockUser('user_9', 'MaxPower', AvatarHelper.getRandomAvatar()),
      _MockUser('user_10', 'Julie Bernard', 'assets/images/Avatar1.png'),
    ].where((user) => !existingMemberIds.contains(user.id)).toList();

    if (availableUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tous les utilisateurs sont déjà membres du groupe'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _AddMemberDialog(
        group: group,
        availableUsers: availableUsers,
      ),
    );
  }

  Future<void> _handleRemoveMember(
    BuildContext context,
    GroupChatModel group,
    String userId,
  ) async {
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
    GroupChatModel group,
    String userId,
    GroupPermission permission,
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
}

/// Section de membres groupés par permission
class _MemberSection {
  final String title;
  final List members;

  _MemberSection(this.title, this.members);
}

/// Mock user pour l'ajout de membres
class _MockUser {
  final String id;
  final String name;
  final String avatarUrl;

  _MockUser(this.id, this.name, this.avatarUrl);
}

/// Dialog pour ajouter un membre au groupe
class _AddMemberDialog extends StatefulWidget {
  final GroupChatModel group;
  final List<_MockUser> availableUsers;

  const _AddMemberDialog({
    required this.group,
    required this.availableUsers,
  });

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  String? _selectedUserId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return AlertDialog(
      backgroundColor: colors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      title: Text(
        'Ajouter un membre',
        style: AppTheme.headingSmall.copyWith(
          color: colors.textPrimary,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.availableUsers.length,
          itemBuilder: (context, index) {
            final user = widget.availableUsers[index];
            final isSelected = _selectedUserId == user.id;

            return InkWell(
              onTap: () {
                setState(() => _selectedUserId = user.id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.colorPrimary.withValues(alpha: 0.1)
                      : colors.bgSecondary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: isSelected ? colors.colorPrimary : colors.borderMedium,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(user.avatarUrl),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user.name,
                        style: AppTheme.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: colors.colorPrimary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Annuler',
            style: AppTheme.bodyLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedUserId == null
              ? null
              : () => _handleAddMember(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.colorPrimary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: colors.textSecondary.withValues(alpha: 0.3),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Ajouter'),
        ),
      ],
    );
  }

  Future<void> _handleAddMember(BuildContext context) async {
    if (_selectedUserId == null) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<GroupChatProvider>();
      await provider.addMember(widget.group.id, _selectedUserId!);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Membre ajouté avec succès'),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
