# 🎭 Système de Rôles et Authentification Multi-Comptes

## 📋 Vue d'ensemble

Ce document décrit l'implémentation complète du système de rôles utilisateur et de l'authentification multi-comptes pour TableRonde, permettant les tests avec plusieurs appareils connectés au même serveur JSON.

## ✅ Fonctionnalités implémentées

### 1. 🎭 Système de Rôles

#### Rôles disponibles

| Rôle | Icône | Description | Permissions |
|------|-------|-------------|-------------|
| **Administrateur** | 👑 | Accès complet | Toutes les permissions |
| **Modérateur** | 🛡️ | Modération | Gestion des messages, annonces, expulsion |
| **Membre** | 👤 | Accès basique | Chat et fonctionnalités standard |

#### Permissions détaillées

**Messagerie:**
- ✅ Tous : Envoyer des messages, supprimer/éditer ses propres messages
- 🛡️ Modérateur+ : Supprimer les messages des autres, épingler des messages
- 👑 Admin : Éditer les messages des autres

**Groupes:**
- ✅ Tous : Créer des groupes
- 🛡️ Modérateur+ : Modifier les paramètres, ajouter/expulser des membres
- 👑 Admin : Supprimer des groupes, bannir des membres, gérer les rôles

**Annonces:**
- 🛡️ Modérateur+ : Créer, modifier, supprimer des annonces

**Modération:**
- ✅ Tous : Signaler du contenu
- 🛡️ Modérateur+ : Bloquer des utilisateurs, gérer les signalements, voir les logs
- 👑 Admin : Accès aux paramètres serveur, statistiques, gestion des permissions

### 2. 👥 Authentification Multi-Comptes

#### Comptes de test disponibles

```
📧 Email: alistair@tableronde.com
🔑 Mot de passe: alistair123
👑 Rôle: Administrateur

📧 Email: t4zor@tableronde.com
🔑 Mot de passe: t4zor123
🛡️ Rôle: Modérateur

📧 Email: tkporky@tableronde.com
🔑 Mot de passe: tkporky123
👤 Rôle: Membre

📧 Email: sophie@tableronde.com
🔑 Mot de passe: sophie123
🛡️ Rôle: Modérateur

📧 Email: lucas@tableronde.com
🔑 Mot de passe: lucas123
👤 Rôle: Membre

📧 Email: test@tableronde.com
🔑 Mot de passe: test123
👤 Rôle: Membre
```

#### Fonctionnalités d'authentification

- ✅ Connexion/Déconnexion
- ✅ Gestion de session persistante
- ✅ Vérification automatique au démarrage
- ✅ Changement de compte facile
- ✅ Statut en ligne synchronisé avec le serveur

### 3. 💬 Messagerie Universelle

#### Fonctionnalités

- **Liste de tous les utilisateurs** : Accès via le bouton "Tous les membres" (icône 👥) dans l'écran des chats
- **Recherche de membres** : Barre de recherche par nom ou username
- **Filtres avancés** :
  - Tous les membres
  - En ligne uniquement
  - Par rôle (Admin, Modérateur, Membre)
- **Démarrage de conversation** : Un clic sur un utilisateur démarre une conversation
- **Indicateurs visuels** :
  - Badge de rôle (👑 🛡️ 👤)
  - Statut en ligne (point vert)
  - Activité actuelle

## 🏗️ Architecture technique

### Modèles de données

#### 1. `UserRole` (lib/models/auth/user_role.dart)

```dart
enum UserRole {
  admin,
  moderator,
  member;
}
```

**Méthodes utiles:**
- `displayName` : Nom d'affichage du rôle
- `description` : Description des permissions
- `icon` : Icône emoji du rôle
- `fromString(String)` : Conversion depuis une chaîne

#### 2. `RolePermissions` (lib/models/auth/user_role.dart)

```dart
class RolePermissions {
  final UserRole role;
  
  bool get canSendMessages => true;
  bool get canDeleteOthersMessages => role == UserRole.admin || role == UserRole.moderator;
  // ... autres permissions
}
```

**Méthodes utiles:**
- `hasPermission(String)` : Vérifie une permission spécifique
- `getAllPermissions()` : Retourne toutes les permissions

#### 3. `UserModel` (lib/models/auth/user_model.dart)

Ajout du champ `role`:

```dart
class UserModel {
  final UserRole role;
  
  // Méthodes utiles
  RolePermissions get permissions => RolePermissions(role);
  bool hasPermission(String permission) => permissions.hasPermission(permission);
  bool get isAdmin => role == UserRole.admin;
  bool get isModerator => role == UserRole.moderator || role == UserRole.admin;
}
```

### Services

#### 1. `UserService` (lib/services/user_service.dart)

Service pour gérer les utilisateurs et les conversations:

```dart
class UserService {
  // Récupère tous les utilisateurs
  static Future<List<UserModel>> getAllUsers();
  
  // Recherche des utilisateurs
  static Future<List<UserModel>> searchUsers(String query);
  
  // Crée ou récupère une conversation
  static Future<ChatModel> getOrCreateConversation(String currentUserId, String targetUserId);
  
  // Récupère les utilisateurs en ligne
  static Future<List<UserModel>> getOnlineUsers();
  
  // Récupère les utilisateurs par rôle
  static Future<List<UserModel>> getUsersByRole(String role);
}
```

#### 2. `AuthService` (lib/services/auth_service.dart)

Déjà existant, gère l'authentification:
- `login()` : Connexion
- `logout()` : Déconnexion avec mise à jour du statut
- `register()` : Inscription
- `getCurrentUser()` : Récupère l'utilisateur connecté
- `isLoggedIn()` : Vérifie si un utilisateur est connecté

### Écrans

#### 1. `AllUsersScreen` (lib/screens/users/all_users_screen.dart)

Écran affichant tous les membres du serveur:

**Fonctionnalités:**
- Liste de tous les utilisateurs (sauf l'utilisateur actuel)
- Barre de recherche
- Filtres par statut et rôle
- Démarrage de conversation en un clic
- Actualisation manuelle
- Gestion des erreurs

**Navigation:**
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const AllUsersScreen(),
  ),
);
```

## 📊 Structure du fichier db.json

### Section users

```json
{
  "users": [
    {
      "id": "user_1",
      "email": "alistair@tableronde.com",
      "password": "alistair123",
      "name": "AlistairJr",
      "username": "@alistairjr",
      "bio": "Développeur Flutter passionné 🚀",
      "phone": "+33 6 12 34 56 78",
      "avatarUrl": "assets/images/Avatar1.png",
      "createdAt": "2025-02-25T10:00:00.000Z",
      "isOnline": true,
      "currentActivity": "En ligne",
      "role": "admin"
    }
  ]
}
```

**Champs importants:**
- `role` : "admin", "moderator", ou "member"
- `isOnline` : Statut en ligne (mis à jour à la connexion/déconnexion)
- `currentActivity` : Activité actuelle de l'utilisateur

## 🔄 Flux de données

### Connexion multi-appareils

```
Appareil 1                    Serveur JSON                    Appareil 2
    |                              |                              |
    |-- POST /users (login) ------>|                              |
    |<-- User data + session ------|                              |
    |                              |                              |
    |                              |<---- POST /users (login) ----|
    |                              |------ User data + session -->|
    |                              |                              |
    |-- GET /users --------------->|                              |
    |<-- Liste des utilisateurs ---|                              |
    |                              |                              |
    |-- POST /messages ----------->|                              |
    |                              |---- Notification ----------->|
    |                              |<---- GET /messages ----------|
    |                              |------ Messages ------------->|
```

### Démarrage de conversation

```
1. Utilisateur A ouvre "Tous les membres"
2. Recherche ou filtre les utilisateurs
3. Clique sur Utilisateur B
4. Le système génère un chatId unique: chat_userA_userB
5. Vérifie si des messages existent déjà
6. Crée un ChatModel avec les infos de B
7. Navigation vers ChatScreen
8. Les messages sont synchronisés via le serveur JSON
```

### Vérification des permissions

```dart
// Dans un widget ou service
final currentUser = context.read<AuthProvider>().currentUser;

// Vérifier une permission spécifique
if (currentUser?.hasPermission('delete_others_messages') ?? false) {
  // Afficher le bouton de suppression
}

// Vérifier le rôle
if (currentUser?.isAdmin ?? false) {
  // Afficher les paramètres admin
}

// Utiliser les permissions
final permissions = currentUser?.permissions;
if (permissions?.canCreateAnnouncements ?? false) {
  // Permettre la création d'annonces
}
```

## 🧪 Tests recommandés

### Test 1 : Connexion multi-appareils

1. **Appareil 1** : Se connecter avec `alistair@tableronde.com`
2. **Appareil 2** : Se connecter avec `t4zor@tableronde.com`
3. **Appareil 1** : Aller dans "Tous les membres"
4. **Appareil 1** : Cliquer sur "T4zor" pour démarrer une conversation
5. **Appareil 1** : Envoyer un message
6. **Appareil 2** : Vérifier la réception du message

### Test 2 : Permissions par rôle

1. Se connecter avec un compte **Membre** (lucas@tableronde.com)
2. Vérifier que certaines options sont masquées
3. Se déconnecter
4. Se connecter avec un compte **Modérateur** (t4zor@tableronde.com)
5. Vérifier que plus d'options sont disponibles
6. Se déconnecter
7. Se connecter avec un compte **Admin** (alistair@tableronde.com)
8. Vérifier l'accès complet

### Test 3 : Recherche et filtres

1. Aller dans "Tous les membres"
2. Tester la recherche par nom
3. Tester la recherche par username
4. Tester les filtres (En ligne, Admin, Modérateur, Membre)
5. Vérifier que les résultats sont corrects

### Test 4 : Statut en ligne

1. **Appareil 1** : Se connecter
2. **Appareil 2** : Aller dans "Tous les membres"
3. **Appareil 2** : Vérifier que l'utilisateur de l'Appareil 1 apparaît en ligne
4. **Appareil 1** : Se déconnecter
5. **Appareil 2** : Actualiser la liste
6. **Appareil 2** : Vérifier que l'utilisateur apparaît hors ligne

### Test 5 : Conversation universelle

1. Se connecter avec n'importe quel compte
2. Aller dans "Tous les membres"
3. Démarrer une conversation avec un utilisateur jamais contacté
4. Envoyer un message
5. Vérifier que la conversation apparaît dans la liste des chats
6. Se connecter avec l'autre compte sur un autre appareil
7. Vérifier la réception du message

## 🔐 Sécurité et bonnes pratiques

### Actuellement implémenté

- ✅ Vérification des rôles côté client
- ✅ Gestion de session avec SharedPreferences
- ✅ Mise à jour du statut en ligne
- ✅ Exclusion de l'utilisateur actuel de la liste

### À implémenter pour la production

- ⚠️ **Hasher les mots de passe** (bcrypt, argon2)
- ⚠️ **Tokens JWT** pour l'authentification
- ⚠️ **Vérification des permissions côté serveur**
- ⚠️ **Rate limiting** pour éviter les abus
- ⚠️ **HTTPS** pour les communications
- ⚠️ **Validation des entrées** côté serveur
- ⚠️ **Logs d'audit** pour les actions sensibles

## 📱 Configuration du serveur JSON

### Démarrage du serveur

```bash
# Installer json-server si ce n'est pas déjà fait
npm install -g json-server

# Démarrer le serveur
json-server --watch db.json --port 3000 --host 0.0.0.0
```

### Configuration réseau

**Pour les tests locaux:**
```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://localhost:3000';
```

**Pour les tests sur appareil physique:**
```dart
// Remplacer par l'IP de votre machine
static const String baseUrl = 'http://192.168.1.X:3000';
```

**Pour Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

### Trouver votre IP locale

**Windows:**
```bash
ipconfig
# Chercher "Adresse IPv4"
```

**macOS/Linux:**
```bash
ifconfig
# ou
ip addr show
```

## 🎯 Utilisation dans le code

### Vérifier les permissions

```dart
// Dans un widget
final currentUser = context.watch<AuthProvider>().currentUser;

// Afficher conditionnellement un bouton
if (currentUser?.hasPermission('delete_others_messages') ?? false) {
  IconButton(
    icon: Icon(Icons.delete),
    onPressed: () => _deleteMessage(message),
  ),
}
```

### Afficher le rôle de l'utilisateur

```dart
// Badge de rôle
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: _getRoleColor(user.role),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(user.role.icon),
      SizedBox(width: 4),
      Text(user.role.displayName),
    ],
  ),
)
```

### Démarrer une conversation

```dart
// Depuis n'importe où dans l'app
final currentUser = context.read<AuthProvider>().currentUser;
final chat = await UserService.getOrCreateConversation(
  currentUser!.id,
  targetUserId,
);

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ChatScreen(chat: chat),
  ),
);
```

## 📝 Fichiers modifiés/créés

### Nouveaux fichiers

1. `lib/models/auth/user_role.dart` - Modèle de rôles et permissions
2. `lib/services/user_service.dart` - Service de gestion des utilisateurs
3. `lib/screens/users/all_users_screen.dart` - Écran de liste des utilisateurs
4. `ROLES_AND_MULTI_USER_SYSTEM.md` - Cette documentation

### Fichiers modifiés

1. `lib/models/auth/user_model.dart` - Ajout du champ `role` et méthodes de permissions
2. `lib/screens/chat_list_screen.dart` - Ajout du bouton "Tous les membres"
3. `db.json` - Ajout du champ `role` pour tous les utilisateurs + nouveaux comptes

## 🚀 Prochaines étapes

### Fonctionnalités suggérées

1. **Interface de gestion des rôles** (Admin uniquement)
   - Promouvoir/rétrograder des membres
   - Interface visuelle de gestion

2. **Logs de modération**
   - Historique des actions de modération
   - Qui a fait quoi et quand

3. **Permissions personnalisées**
   - Créer des rôles personnalisés
   - Définir des permissions granulaires

4. **Notifications de rôle**
   - Notifier quand un utilisateur est promu
   - Alertes pour les actions de modération

5. **Statistiques par rôle**
   - Nombre de messages par rôle
   - Activité des modérateurs

## ✅ Validation

Toutes les modifications ont été testées et aucune erreur de compilation n'a été détectée.

---

**Date de création** : 25 février 2026
**Version** : 1.0.0
**Auteur** : Kiro AI Assistant
