import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth/user_model.dart';
import '../../models/auth/user_role.dart';
import '../../services/user_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';

/// Écran affichant tous les utilisateurs du serveur
/// Permet de démarrer une conversation avec n'importe quel membre
class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, online, admin, moderator, member

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await UserService.getAllUsers();
      final currentUser = context.read<AuthProvider>().currentUser;

      setState(() {
        // Exclure l'utilisateur actuel de la liste
        _allUsers = users.where((user) => user.id != currentUser?.id).toList();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<UserModel> filtered = List.from(_allUsers);

    // Appliquer le filtre de rôle/statut
    switch (_selectedFilter) {
      case 'online':
        filtered = filtered.where((user) => user.isOnline).toList();
        break;
      case 'admin':
        filtered = filtered.where((user) => user.role == UserRole.admin).toList();
        break;
      case 'moderator':
        filtered = filtered.where((user) => user.role == UserRole.moderator).toList();
        break;
      case 'member':
        filtered = filtered.where((user) => user.role == UserRole.member).toList();
        break;
    }

    // Appliquer le filtre de recherche
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(query) ||
            (user.username ?? '').toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredUsers = filtered;
    });
  }

  void _filterUsers() {
    _applyFilters();
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  Future<void> _startConversation(UserModel user) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: context.themeColors.colorPrimary,
          ),
        ),
      );

      // Créer ou récupérer la conversation
      final chat = await UserService.getOrCreateConversation(
        currentUser.id,
        user.id,
      );

      if (mounted) {
        // Fermer le dialogue de chargement
        Navigator.of(context).pop();

        // Naviguer vers l'écran de chat
        Navigator.of(context).pushNamed(
          '/chat',
          arguments: chat,
        );
      }
    } catch (e) {
      if (mounted) {
        // Fermer le dialogue de chargement
        Navigator.of(context).pop();

        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: context.themeColors.colorDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      appBar: AppBar(
        title: Text(
          'Tous les membres',
          style: TextStyle(color: context.themeColors.textPrimary),
        ),
        backgroundColor: context.themeColors.bgSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: context.themeColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un membre...',
                hintStyle: TextStyle(color: context.themeColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: context.themeColors.textSecondary),
                filled: true,
                fillColor: context.themeColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: context.themeColors.textPrimary),
            ),
          ),

          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Tous', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('En ligne', 'online'),
                const SizedBox(width: 8),
                _buildFilterChip('${UserRole.admin.icon} Admins', 'admin'),
                const SizedBox(width: 8),
                _buildFilterChip('${UserRole.moderator.icon} Modérateurs', 'moderator'),
                const SizedBox(width: 8),
                _buildFilterChip('${UserRole.member.icon} Membres', 'member'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Liste des utilisateurs
          Expanded(
            child: _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _changeFilter(value),
      backgroundColor: context.themeColors.bgSurface,
      selectedColor: context.themeColors.colorPrimary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? context.themeColors.colorPrimary
            : context.themeColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? context.themeColors.colorPrimary
            : context.themeColors.borderMedium,
      ),
    );
  }

  Widget _buildUsersList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.themeColors.colorPrimary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.themeColors.colorDanger,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: AppTheme.bodyLarge.copyWith(
                color: context.themeColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: AppTheme.bodyMedium.copyWith(
                  color: context.themeColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.themeColors.colorPrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: context.themeColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun membre trouvé',
              style: AppTheme.bodyLarge.copyWith(
                color: context.themeColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredUsers.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(UserModel user) {
    return Card(
      color: context.themeColors.bgSurface,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: user.avatarUrl != null
                  ? AssetImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.name[0].toUpperCase(),
                      style: TextStyle(color: context.themeColors.textPrimary),
                    )
                  : null,
            ),
            if (user.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.themeColors.colorOnline,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.themeColors.bgSurface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: TextStyle(
                  color: context.themeColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              user.role.icon,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.username != null)
              Text(
                user.username!,
                style: TextStyle(
                  color: context.themeColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            if (user.currentActivity != null)
              Text(
                user.currentActivity!,
                style: TextStyle(
                  color: context.themeColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.message,
            color: context.themeColors.colorPrimary,
          ),
          onPressed: () => _startConversation(user),
          tooltip: 'Envoyer un message',
        ),
        onTap: () => _startConversation(user),
      ),
    );
  }
}
