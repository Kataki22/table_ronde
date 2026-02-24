import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_chat_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive_layout.dart';

/// Screen pour créer un nouveau groupe de discussion
///
/// Affiche un formulaire avec:
/// - Champ nom du groupe (requis, max 50 caractères)
/// - Champ description (optionnel)
/// - Sélecteur de photo (optionnel)
/// - Sélecteur de membres avec recherche (min 1 membre)
///
/// Validates: Requirements 1.1, 1.2
class GroupCreationScreen extends StatefulWidget {
  const GroupCreationScreen({super.key});

  @override
  State<GroupCreationScreen> createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  String? _photoUrl;
  final Set<String> _selectedMemberIds = {};
  bool _isLoading = false;
  String _searchQuery = '';

  // Mock users disponibles pour sélection
  final List<_MockUser> _availableUsers = [
    _MockUser('user_2', 'T4zor', 'assets/images/Avatar2.png'),
    _MockUser('user_3', 'Tk-Porky', 'assets/images/Avatar3.png'),
    _MockUser('user_4', 'Sophie Martin', 'assets/images/Avatar4.png'),
    _MockUser('user_5', 'Lucas Dubois', 'assets/images/Avatar5.png'),
    _MockUser('user_6', 'ProGamer42', 'assets/images/Avatar6.png'),
    _MockUser('user_7', 'NinjaKiller', 'assets/images/Avatar7.png'),
    _MockUser('user_8', 'Emma Leroy', 'assets/images/Avatar8.png'),
    _MockUser('user_9', 'MaxPower', 'assets/images/Avatar9.png'),
    _MockUser('user_10', 'Julie Bernard', 'assets/images/Avatar1.png'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_MockUser> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _availableUsers;
    }
    return _availableUsers
        .where((user) =>
            user.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sélectionnez au moins un membre'),
          backgroundColor: context.themeColors.colorDanger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<GroupChatProvider>();
      await provider.createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        photoUrl: _photoUrl,
        memberIds: _selectedMemberIds.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Groupe créé avec succès'),
            backgroundColor: context.themeColors.colorSuccess,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDesktop = ResponsiveLayout.shouldUseDesktopLayout(context);
    final maxWidth = ResponsiveLayout.getMaxContentWidth(context);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: colors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Nouveau groupe',
          style: AppTheme.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _createGroup,
              child: Text(
                'Créer',
                style: AppTheme.bodyLarge.copyWith(
                  color: colors.colorPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? double.infinity,
          ),
          child: Form(
            key: _formKey,
            child: isDesktop
                ? _buildDesktopLayout(colors)
                : _buildMobileLayout(colors),
          ),
        ),
      ),
    );
  }

  /// Mobile layout: single column with scrollable list
  Widget _buildMobileLayout(AppThemeData colors) {
    return ListView(
      padding: ResponsiveLayout.getScreenPadding(context),
      children: [
        // Photo du groupe
        _buildPhotoSection(colors),
        const SizedBox(height: 24),

        // Nom du groupe
        _buildNameField(colors),
        const SizedBox(height: 16),

        // Description
        _buildDescriptionField(colors),
        const SizedBox(height: 24),

        // Section membres
        _buildMembersSection(colors),
      ],
    );
  }

  /// Desktop layout: two-column layout with form on left, preview on right
  Widget _buildDesktopLayout(AppThemeData colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Form
        Expanded(
          flex: 3,
          child: ListView(
            padding: ResponsiveLayout.getScreenPadding(context),
            children: [
              // Photo du groupe
              _buildPhotoSection(colors),
              const SizedBox(height: 24),

              // Nom du groupe
              _buildNameField(colors),
              const SizedBox(height: 16),

              // Description
              _buildDescriptionField(colors),
              const SizedBox(height: 24),

              // Section membres
              _buildMembersSection(colors),
            ],
          ),
        ),

        // Right column: Preview panel
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              border: Border(
                left: BorderSide(color: colors.borderMedium),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Aperçu',
                  style: AppTheme.headingSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildGroupPreview(colors),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a preview of the group being created (desktop only)
  Widget _buildGroupPreview(AppThemeData colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: colors.borderMedium),
      ),
      child: Column(
        children: [
          // Photo preview
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
            child: _photoUrl != null
                ? ClipOval(
                    child: Image.asset(
                      'assets/images/groups/flutter_team.png',
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

          // Name preview
          Text(
            _nameController.text.isEmpty
                ? 'Nom du groupe'
                : _nameController.text,
            style: AppTheme.headingSmall.copyWith(
              color: _nameController.text.isEmpty
                  ? colors.textSecondary
                  : colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description preview
          if (_descriptionController.text.isNotEmpty)
            Text(
              _descriptionController.text,
              style: AppTheme.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),

          // Members count
          Text(
            '${_selectedMemberIds.length} membre${_selectedMemberIds.length > 1 ? 's' : ''}',
            style: AppTheme.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(AppThemeData colors) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Simuler la sélection d'une photo
          setState(() {
            _photoUrl = 'assets/images/groups/custom_${DateTime.now().millisecondsSinceEpoch}.png';
          });
        },
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colors.bgSecondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.borderMedium,
              width: 2,
            ),
          ),
          child: _photoUrl != null
              ? ClipOval(
                  child: Image.asset(
                    'assets/images/groups/flutter_team.png', // Fallback image
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
                  Icons.add_a_photo,
                  size: 40,
                  color: colors.textSecondary,
                ),
        ),
      ),
    );
  }

  Widget _buildNameField(AppThemeData colors) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nom du groupe',
        hintText: 'Ex: Équipe Dev Flutter',
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: colors.colorDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: colors.colorDanger, width: 2),
        ),
      ),
      style: AppTheme.bodyMedium.copyWith(color: colors.textPrimary),
      maxLength: 50,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Le nom du groupe est requis';
        }
        if (value.length > 50) {
          return 'Le nom du groupe est trop long (maximum 50 caractères)';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(AppThemeData colors) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description (optionnel)',
        hintText: 'Décrivez le but du groupe',
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
      maxLines: 3,
      maxLength: 200,
    );
  }

  Widget _buildMembersSection(AppThemeData colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajouter des membres',
          style: AppTheme.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_selectedMemberIds.length} membre${_selectedMemberIds.length > 1 ? 's' : ''} sélectionné${_selectedMemberIds.length > 1 ? 's' : ''}',
          style: AppTheme.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Barre de recherche
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher des membres',
            prefixIcon: Icon(Icons.search, color: colors.textSecondary),
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
        const SizedBox(height: 16),

        // Liste des utilisateurs
        ..._filteredUsers.map((user) => _buildUserTile(user, colors)),
      ],
    );
  }

  Widget _buildUserTile(_MockUser user, AppThemeData colors) {
    final isSelected = _selectedMemberIds.contains(user.id);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedMemberIds.remove(user.id);
          } else {
            _selectedMemberIds.add(user.id);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.colorPrimary.withValues(alpha: 0.1) : colors.bgSecondary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? colors.colorPrimary : colors.borderMedium,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundImage: AssetImage(user.avatarUrl),
              radius: 20,
            ),
            const SizedBox(width: 12),

            // Nom
            Expanded(
              child: Text(
                user.name,
                style: AppTheme.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            // Checkbox
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.colorPrimary,
                size: 24,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: colors.textSecondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Mock user pour la sélection de membres
class _MockUser {
  final String id;
  final String name;
  final String avatarUrl;

  _MockUser(this.id, this.name, this.avatarUrl);
}
