# 🔐 Guide d'Utilisation des Permissions

## 📋 Introduction

Ce guide explique comment utiliser le système de permissions dans votre code pour contrôler l'accès aux fonctionnalités selon le rôle de l'utilisateur.

## 🎯 Accès rapide

### Récupérer l'utilisateur actuel

```dart
// Dans un widget avec accès au context
final currentUser = context.read<AuthProvider>().currentUser;

// Ou avec watch pour réactivité
final currentUser = context.watch<AuthProvider>().currentUser;
```

### Vérifier une permission

```dart
// Méthode 1 : Via l'utilisateur
if (currentUser?.hasPermission('delete_others_messages') ?? false) {
  // L'utilisateur peut supprimer les messages des autres
}

// Méthode 2 : Via les permissions
final permissions = currentUser?.permissions;
if (permissions?.canDeleteOthersMessages ?? false) {
  // L'utilisateur peut supprimer les messages des autres
}

// Méthode 3 : Vérifier le rôle directement
if (currentUser?.isAdmin ?? false) {
  // L'utilisateur est administrateur
}

if (currentUser?.isModerator ?? false) {
  // L'utilisateur est modérateur ou admin
}
```

## 📚 Exemples pratiques

### 1. Affichage conditionnel d'un bouton

```dart
// Bouton de suppression de message
Widget _buildDeleteButton(MessageModel message) {
  final currentUser = context.watch<AuthProvider>().currentUser;
  
  // Vérifier si l'utilisateur peut supprimer ce message
  final canDelete = message.senderId == currentUser?.id || 
                    (currentUser?.hasPermission('delete_others_messages') ?? false);
  
  if (!canDelete) {
    return const SizedBox.shrink(); // Ne rien afficher
  }
  
  return IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () => _deleteMessage(message),
    tooltip: 'Supprimer',
  );
}
```

### 2. Menu contextuel avec options selon le rôle

```dart
void _showMessageMenu(BuildContext context, MessageModel message) {
  final currentUser = context.read<AuthProvider>().currentUser;
  final isOwnMessage = message.senderId == currentUser?.id;
  
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tout le monde peut répondre
        ListTile(
          leading: const Icon(Icons.reply),
          title: const Text('Répondre'),
          onTap: () => _replyToMessage(message),
        ),
        
        // Seulement l'auteur peut éditer
        if (isOwnMessage && (currentUser?.hasPermission('edit_own_messages') ?? false))
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modifier'),
            onTap: () => _editMessage(message),
          ),
        
        // L'auteur ou les modérateurs peuvent supprimer
        if (isOwnMessage || (currentUser?.hasPermission('delete_others_messages') ?? false))
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Supprimer'),
            onTap: () => _deleteMessage(message),
          ),
        
        // Seulement les modérateurs peuvent épingler
        if (currentUser?.hasPermission('pin_messages') ?? false)
          ListTile(
            leading: const Icon(Icons.push_pin),
            title: const Text('Épingler'),
            onTap: () => _pinMessage(message),
          ),
        
        // Tout le monde peut signaler
        if (!isOwnMessage)
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Signaler'),
            onTap: () => _reportMessage(message),
          ),
      ],
    ),
  );
}
```

### 3. Page de paramètres avec sections selon le rôle

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    
    return ListView(
      children: [
        // Section profil (tous)
        _buildSection(
          title: 'Profil',
          children: [
            ListTile(
              title: const Text('Modifier le profil'),
              onTap: () => _editProfile(),
            ),
          ],
        ),
        
        // Section modération (modérateurs+)
        if (currentUser?.isModerator ?? false)
          _buildSection(
            title: 'Modération',
            children: [
              if (currentUser?.hasPermission('view_moderation_logs') ?? false)
                ListTile(
                  title: const Text('Logs de modération'),
                  onTap: () => _viewModerationLogs(),
                ),
              if (currentUser?.hasPermission('manage_reports') ?? false)
                ListTile(
                  title: const Text('Gérer les signalements'),
                  onTap: () => _manageReports(),
                ),
            ],
          ),
        
        // Section administration (admins uniquement)
        if (currentUser?.isAdmin ?? false)
          _buildSection(
            title: 'Administration',
            children: [
              ListTile(
                title: const Text('Paramètres du serveur'),
                onTap: () => _serverSettings(),
              ),
              ListTile(
                title: const Text('Gestion des rôles'),
                onTap: () => _manageRoles(),
              ),
              ListTile(
                title: const Text('Statistiques'),
                onTap: () => _viewStatistics(),
              ),
            ],
          ),
      ],
    );
  }
}
```

### 4. Validation avant action

```dart
Future<void> _deleteGroup(String groupId) async {
  final currentUser = context.read<AuthProvider>().currentUser;
  
  // Vérifier la permission
  if (!(currentUser?.hasPermission('delete_groups') ?? false)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vous n\'avez pas la permission de supprimer des groupes'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Confirmer l'action
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer le groupe'),
      content: const Text('Êtes-vous sûr de vouloir supprimer ce groupe ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  
  if (confirmed == true) {
    try {
      await ApiService.deleteGroup(groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Groupe supprimé')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### 5. Badge de rôle personnalisé

```dart
Widget _buildRoleBadge(UserModel user) {
  Color badgeColor;
  IconData badgeIcon;
  
  switch (user.role) {
    case UserRole.admin:
      badgeColor = Colors.amber;
      badgeIcon = Icons.admin_panel_settings;
      break;
    case UserRole.moderator:
      badgeColor = Colors.blue;
      badgeIcon = Icons.shield;
      break;
    case UserRole.member:
      badgeColor = Colors.grey;
      badgeIcon = Icons.person;
      break;
  }
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: badgeColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: badgeColor),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(badgeIcon, size: 16, color: badgeColor),
        const SizedBox(width: 4),
        Text(
          user.role.displayName,
          style: TextStyle(
            color: badgeColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
```

### 6. Liste des membres avec filtrage par rôle

```dart
class MembersListScreen extends StatefulWidget {
  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  UserRole? _selectedRole;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtres de rôle
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildRoleFilter('Tous', null),
              const SizedBox(width: 8),
              _buildRoleFilter('Admins', UserRole.admin),
              const SizedBox(width: 8),
              _buildRoleFilter('Modérateurs', UserRole.moderator),
              const SizedBox(width: 8),
              _buildRoleFilter('Membres', UserRole.member),
            ],
          ),
        ),
        
        // Liste des membres
        Expanded(
          child: FutureBuilder<List<UserModel>>(
            future: _selectedRole == null
                ? UserService.getAllUsers()
                : UserService.getUsersByRole(_selectedRole!.name),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final user = snapshot.data![index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatarUrl != null
                            ? AssetImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(user.name[0])
                            : null,
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.role.displayName),
                      trailing: _buildRoleBadge(user),
                    );
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildRoleFilter(String label, UserRole? role) {
    final isSelected = _selectedRole == role;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRole = selected ? role : null;
        });
      },
    );
  }
}
```

### 7. Gestion des annonces (modérateurs+)

```dart
class AnnouncementsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final canCreateAnnouncements = currentUser?.hasPermission('create_announcements') ?? false;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annonces'),
        actions: [
          if (canCreateAnnouncements)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _createAnnouncement(context),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          return _buildAnnouncementCard(context, announcement);
        },
      ),
    );
  }
  
  Widget _buildAnnouncementCard(BuildContext context, Announcement announcement) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final canEdit = currentUser?.hasPermission('edit_announcements') ?? false;
    final canDelete = currentUser?.hasPermission('delete_announcements') ?? false;
    
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(announcement.title),
            subtitle: Text(announcement.content),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                if (canEdit)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Modifier'),
                  ),
                if (canDelete)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Supprimer'),
                  ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _editAnnouncement(context, announcement);
                } else if (value == 'delete') {
                  _deleteAnnouncement(context, announcement);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## 📋 Liste complète des permissions

### Permissions de messagerie

```dart
'send_messages'              // Tous
'delete_own_messages'        // Tous
'delete_others_messages'     // Modérateur+
'edit_own_messages'          // Tous
'edit_others_messages'       // Admin
'pin_messages'               // Modérateur+
```

### Permissions de groupe

```dart
'create_groups'              // Tous
'delete_groups'              // Admin
'edit_group_settings'        // Modérateur+
'add_members'                // Modérateur+
'kick_members'               // Modérateur+
'ban_members'                // Admin
'manage_roles'               // Admin
```

### Permissions d'annonces

```dart
'create_announcements'       // Modérateur+
'edit_announcements'         // Modérateur+
'delete_announcements'       // Modérateur+
```

### Permissions de modération

```dart
'view_moderation_logs'       // Modérateur+
'block_users'                // Modérateur+
'report_content'             // Tous
'manage_reports'             // Modérateur+
```

### Permissions système

```dart
'access_server_settings'     // Admin
'view_statistics'            // Modérateur+
'manage_permissions'         // Admin
```

## 🎨 Bonnes pratiques

### 1. Toujours vérifier les permissions

```dart
// ❌ Mauvais
void deleteMessage(String messageId) {
  ApiService.deleteMessage(messageId);
}

// ✅ Bon
void deleteMessage(String messageId) {
  final currentUser = context.read<AuthProvider>().currentUser;
  if (!(currentUser?.hasPermission('delete_others_messages') ?? false)) {
    _showPermissionError();
    return;
  }
  ApiService.deleteMessage(messageId);
}
```

### 2. Utiliser des getters pour la lisibilité

```dart
// ❌ Moins lisible
if (currentUser?.hasPermission('delete_others_messages') ?? false) {
  // ...
}

// ✅ Plus lisible
if (currentUser?.permissions.canDeleteOthersMessages ?? false) {
  // ...
}
```

### 3. Gérer les cas null

```dart
// ❌ Peut causer des erreurs
if (currentUser.hasPermission('delete_groups')) {
  // ...
}

// ✅ Gère le cas null
if (currentUser?.hasPermission('delete_groups') ?? false) {
  // ...
}
```

### 4. Afficher des messages d'erreur clairs

```dart
void _showPermissionError() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Vous n\'avez pas la permission d\'effectuer cette action'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
}
```

### 5. Documenter les permissions requises

```dart
/// Supprime un message
/// 
/// Permissions requises:
/// - `delete_own_messages` si c'est son propre message
/// - `delete_others_messages` pour supprimer les messages des autres
Future<void> deleteMessage(String messageId) async {
  // ...
}
```

## 🔍 Débogage

### Afficher toutes les permissions d'un utilisateur

```dart
void _debugPermissions() {
  final currentUser = context.read<AuthProvider>().currentUser;
  if (currentUser == null) return;
  
  print('=== Permissions de ${currentUser.name} ===');
  print('Rôle: ${currentUser.role.displayName}');
  print('');
  
  final permissions = currentUser.permissions.getAllPermissions();
  permissions.forEach((key, value) {
    print('$key: ${value ? "✅" : "❌"}');
  });
}
```

### Vérifier pourquoi une permission est refusée

```dart
void _checkPermission(String permission) {
  final currentUser = context.read<AuthProvider>().currentUser;
  
  if (currentUser == null) {
    print('❌ Aucun utilisateur connecté');
    return;
  }
  
  final hasPermission = currentUser.hasPermission(permission);
  print('Permission "$permission":');
  print('  Utilisateur: ${currentUser.name}');
  print('  Rôle: ${currentUser.role.displayName}');
  print('  Résultat: ${hasPermission ? "✅ Accordée" : "❌ Refusée"}');
}
```

## 📚 Ressources

- **Documentation complète** : `ROLES_AND_MULTI_USER_SYSTEM.md`
- **Guide de démarrage** : `QUICK_START_MULTI_USER.md`
- **Code source** : `lib/models/auth/user_role.dart`

---

**Bon développement ! 🚀**
