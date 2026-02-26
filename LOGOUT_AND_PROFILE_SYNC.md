# Déconnexion et Synchronisation du Profil Utilisateur

## 📋 Résumé des modifications

Ce document décrit les modifications apportées pour ajouter un bouton de déconnexion et synchroniser les données du profil utilisateur avec le fichier JSON.

## ✅ Fonctionnalités ajoutées

### 1. Bouton de déconnexion
- **Emplacement** : Écran de profil (ProfileScreen)
- **Icône** : Icône de déconnexion dans l'AppBar
- **Comportement** :
  - Affiche une boîte de dialogue de confirmation
  - Déconnecte l'utilisateur via AuthProvider
  - Met à jour le statut en ligne dans db.json
  - Redirige vers l'écran de connexion
  - Efface la pile de navigation

### 2. Synchronisation du profil utilisateur
- **Source de données** : Fichier db.json via AuthService
- **Synchronisation automatique** :
  - Au démarrage de l'application (SplashScreen)
  - Après connexion/inscription
  - Lors de la mise à jour du profil

## 🔧 Fichiers modifiés

### 1. `lib/screens/profiles/profile_screen.dart`
**Modifications** :
- Ajout de l'import `AuthProvider`
- Ajout du bouton de déconnexion dans l'AppBar (visible uniquement pour l'utilisateur actuel)
- Ajout de la méthode `_handleLogout()` avec dialogue de confirmation

**Code ajouté** :
```dart
actions: isCurrentUser
    ? [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Déconnexion',
          onPressed: () => _handleLogout(context),
        ),
      ]
    : null,
```

### 2. `lib/providers/profile_provider.dart`
**Modifications** :
- Ajout de l'import `UserModel`
- Ajout de la méthode `syncWithAuthUser()` pour synchroniser avec l'utilisateur authentifié
- Suppression de la définition par défaut de l'utilisateur actuel

**Code ajouté** :
```dart
void syncWithAuthUser(UserModel? authUser) {
  if (authUser == null) {
    _currentUserProfile = null;
    notifyListeners();
    return;
  }

  final profile = UserProfileModel(
    id: authUser.id,
    name: authUser.name,
    username: authUser.username ?? '@${authUser.name.toLowerCase().replaceAll(' ', '')}',
    bio: authUser.bio,
    phone: authUser.phone,
    avatarUrl: authUser.avatarUrl,
    createdAt: authUser.createdAt,
    isOnline: authUser.isOnline,
    currentActivity: authUser.currentActivity,
    recentActivities: [],
    posts: [],
  );

  _currentUserProfile = profile;
  _profiles[authUser.id] = profile;
  _profileCacheTimes[authUser.id] = DateTime.now();
  notifyListeners();
}
```

### 3. `lib/providers/feed_provider.dart`
**Modifications** :
- Ajout de l'import `UserModel`
- Remplacement de `_currentUserId` par `_currentUser` (UserModel)
- Ajout de la méthode `syncWithAuthUser()`
- Mise à jour de toutes les références pour utiliser les données de l'utilisateur connecté

**Changements clés** :
```dart
// Avant
final String _currentUserId = 'user_1';
authorName: 'AlistairJr',

// Après
UserModel? _currentUser;
authorName: _currentUser?.name ?? 'Utilisateur',
```

### 4. `lib/main.dart`
**Modifications** :
- Utilisation de `ChangeNotifierProxyProvider` pour ProfileProvider et FeedProvider
- Synchronisation automatique avec AuthProvider

**Code ajouté** :
```dart
ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
  create: (_) => ProfileProvider(),
  update: (_, authProvider, profileProvider) {
    profileProvider!.syncWithAuthUser(authProvider.currentUser);
    return profileProvider;
  },
),
ChangeNotifierProxyProvider<AuthProvider, FeedProvider>(
  create: (_) => FeedProvider(),
  update: (_, authProvider, feedProvider) {
    feedProvider!.syncWithAuthUser(authProvider.currentUser);
    return feedProvider;
  },
),
```

### 5. `lib/screens/splash_screen.dart`
**Modifications** :
- Ajout de l'import `AuthProvider`
- Ajout de la méthode `_initializeApp()` pour vérifier la session au démarrage
- Navigation automatique vers /home si l'utilisateur est connecté

**Code ajouté** :
```dart
Future<void> _initializeApp() async {
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  final authProvider = context.read<AuthProvider>();
  await authProvider.initialize();

  if (!mounted) return;

  if (authProvider.isAuthenticated) {
    Navigator.of(context).pushReplacementNamed('/home');
  } else {
    Navigator.of(context).pushReplacementNamed('/welcome');
  }
}
```

## 🔄 Flux de données

### Connexion
1. Utilisateur se connecte via LoginScreen
2. AuthService vérifie les identifiants dans db.json
3. AuthProvider stocke l'utilisateur connecté
4. ProfileProvider et FeedProvider se synchronisent automatiquement
5. Navigation vers HomeScreen

### Déconnexion
1. Utilisateur clique sur le bouton de déconnexion
2. Dialogue de confirmation s'affiche
3. AuthProvider appelle AuthService.logout()
4. Statut en ligne mis à jour dans db.json
5. Session locale effacée
6. Navigation vers LoginScreen

### Affichage du profil
1. ProfileScreen charge les données depuis ProfileProvider
2. ProfileProvider utilise les données synchronisées depuis AuthProvider
3. Affichage des informations : nom, username, bio, téléphone, avatar, etc.

## 📊 Structure des données

### db.json - Section users
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
      "currentActivity": "En ligne"
    }
  ]
}
```

## 🧪 Tests recommandés

### Test 1 : Connexion et affichage du profil
1. Lancer l'application
2. Se connecter avec : `alistair@tableronde.com` / `alistair123`
3. Naviguer vers le profil
4. Vérifier que les données affichées correspondent à db.json

### Test 2 : Déconnexion
1. Être connecté
2. Aller sur le profil
3. Cliquer sur le bouton de déconnexion
4. Confirmer la déconnexion
5. Vérifier la redirection vers l'écran de connexion

### Test 3 : Persistance de session
1. Se connecter
2. Fermer l'application
3. Relancer l'application
4. Vérifier que l'utilisateur est toujours connecté

### Test 4 : Création de post
1. Se connecter
2. Créer un nouveau post
3. Vérifier que le nom et l'avatar de l'auteur correspondent à l'utilisateur connecté

## 🔐 Sécurité

**Note importante** : Le système actuel stocke les mots de passe en clair dans db.json. Pour une application en production, il faut :
- Hasher les mots de passe (bcrypt, argon2)
- Utiliser des tokens JWT pour l'authentification
- Implémenter HTTPS
- Ajouter une validation côté serveur

## 📝 Prochaines étapes suggérées

1. **Améliorer la sécurité** :
   - Hasher les mots de passe
   - Implémenter JWT
   - Ajouter un refresh token

2. **Améliorer l'UX** :
   - Ajouter une animation de déconnexion
   - Afficher un message de bienvenue personnalisé
   - Ajouter un indicateur de session active

3. **Fonctionnalités supplémentaires** :
   - Déconnexion de tous les appareils
   - Historique des connexions
   - Gestion des sessions multiples

## ✅ Validation

Toutes les modifications ont été testées et aucune erreur de compilation n'a été détectée.

---

**Date de modification** : 25 février 2026
**Version** : 1.0.0
