# 🔐 Guide d'Authentification - TableRonde

Système complet d'authentification avec inscription, connexion et gestion des utilisateurs.

## 📦 Ce qui a été ajouté

### Modèles
- `lib/models/auth/user_model.dart` - Modèle utilisateur avec sérialisation JSON

### Services
- `lib/services/auth_service.dart` - Service d'authentification (inscription, connexion, déconnexion)

### Providers
- `lib/providers/auth_provider.dart` - Provider pour gérer l'état d'authentification

### Écrans
- `lib/screens/auth/login_screen.dart` - Écran de connexion
- `lib/screens/auth/register_screen.dart` - Écran d'inscription

### Widgets
- `lib/widgets/auth/auth_guard.dart` - Widget de protection des routes
- `lib/examples/auth_example.dart` - Exemple complet d'utilisation

### Base de Données
- `db.json` - Ajout de la collection `users` avec mots de passe

## 🚀 Démarrage Rapide

### 1. Ajouter le Provider dans main.dart

```dart
import 'package:provider/provider.dart';
import 'package:tableronde_app/providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Provider d'authentification
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
        
        // Vos autres providers...
      ],
      child: const MyApp(),
    ),
  );
}
```

### 2. Protéger vos écrans

```dart
import 'package:tableronde_app/widgets/auth/auth_guard.dart';

class MyProtectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('Écran Protégé')),
        body: const Center(
          child: Text('Contenu accessible uniquement si connecté'),
        ),
      ),
    );
  }
}
```

### 3. Tester l'exemple

```dart
import 'package:tableronde_app/examples/auth_example.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AuthExample(),
  ),
);
```

## 👤 Comptes de Test

### Compte 1 - Test
- **Email:** test@tableronde.com
- **Mot de passe:** test123

### Compte 2 - AlistairJr
- **Email:** alistair@tableronde.com
- **Mot de passe:** alistair123

### Compte 3 - T4zor
- **Email:** t4zor@tableronde.com
- **Mot de passe:** t4zor123

### Compte 4 - Tk-Porky
- **Email:** tkporky@tableronde.com
- **Mot de passe:** tkporky123

## 📡 API Endpoints

### Inscription
```
POST /users
Body: {
  "id": "user_xxx",
  "email": "user@example.com",
  "password": "password123",
  "name": "Nom Utilisateur",
  "username": "@username",
  "createdAt": "2026-02-25T10:00:00.000Z",
  "isOnline": true
}
```

### Connexion
```
GET /users?email=user@example.com
Vérification du mot de passe côté client
```

### Mise à jour du profil
```
PATCH /users/:id
Body: {
  "name": "Nouveau Nom",
  "bio": "Ma bio",
  "phone": "+33 6 12 34 56 78"
}
```

### Changement de mot de passe
```
PATCH /users/:id
Body: {
  "password": "nouveau_mot_de_passe"
}
```

## 💡 Utilisation

### Inscription

```dart
final authProvider = context.read<AuthProvider>();

final success = await authProvider.register(
  email: 'user@example.com',
  password: 'password123',
  name: 'Nom Utilisateur',
  username: '@username', // optionnel
);

if (success) {
  print('Inscription réussie !');
} else {
  print('Erreur: ${authProvider.error}');
}
```

### Connexion

```dart
final authProvider = context.read<AuthProvider>();

final success = await authProvider.login(
  email: 'user@example.com',
  password: 'password123',
);

if (success) {
  print('Connexion réussie !');
  print('Utilisateur: ${authProvider.currentUser?.name}');
} else {
  print('Erreur: ${authProvider.error}');
}
```

### Déconnexion

```dart
await context.read<AuthProvider>().logout();
```

### Récupérer l'utilisateur connecté

```dart
// Option 1: Avec Consumer
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    final user = authProvider.currentUser;
    if (user == null) {
      return const Text('Non connecté');
    }
    return Text('Bonjour ${user.name}');
  },
)

// Option 2: Avec le widget CurrentUserWidget
CurrentUserWidget(
  builder: (context, user) {
    return Text('Bonjour ${user.name}');
  },
)

// Option 3: Directement
final authProvider = context.watch<AuthProvider>();
final user = authProvider.currentUser;
```

### Vérifier l'authentification

```dart
final authProvider = context.watch<AuthProvider>();

if (authProvider.isAuthenticated) {
  // Utilisateur connecté
} else {
  // Utilisateur non connecté
}
```

### Mettre à jour le profil

```dart
final authProvider = context.read<AuthProvider>();

final success = await authProvider.updateProfile(
  name: 'Nouveau Nom',
  bio: 'Ma nouvelle bio',
  phone: '+33 6 12 34 56 78',
  currentActivity: 'En train de coder',
);

if (success) {
  print('Profil mis à jour !');
}
```

### Changer le mot de passe

```dart
final authProvider = context.read<AuthProvider>();

final success = await authProvider.changePassword(
  oldPassword: 'ancien_mot_de_passe',
  newPassword: 'nouveau_mot_de_passe',
);

if (success) {
  print('Mot de passe changé !');
}
```

## 🔒 Sécurité

### ⚠️ Important pour la Production

Le système actuel est conçu pour le développement et les tests. Pour la production :

1. **Hasher les mots de passe**
   ```dart
   // Utiliser un package comme crypto ou bcrypt
   import 'package:crypto/crypto.dart';
   
   String hashPassword(String password) {
     return sha256.convert(utf8.encode(password)).toString();
   }
   ```

2. **Utiliser des tokens JWT**
   ```dart
   // Implémenter un système de tokens
   // Stocker le token dans SharedPreferences
   // Envoyer le token dans les headers HTTP
   ```

3. **HTTPS uniquement**
   ```dart
   // Utiliser uniquement des URLs HTTPS en production
   static const String baseUrl = 'https://api.tableronde.com';
   ```

4. **Validation côté serveur**
   - Valider tous les inputs
   - Limiter les tentatives de connexion
   - Implémenter un système de récupération de mot de passe

5. **Expiration de session**
   ```dart
   // Ajouter une expiration aux tokens
   // Rafraîchir automatiquement les tokens
   ```

## 🎨 Personnalisation

### Personnaliser l'écran de connexion

```dart
// Modifier lib/screens/auth/login_screen.dart
// Changer les couleurs, le logo, les textes, etc.
```

### Ajouter des champs au profil

1. Modifier `UserModel` :
```dart
class UserModel {
  // Ajouter vos champs
  final String? company;
  final String? website;
  // ...
}
```

2. Mettre à jour `fromJson()` et `toJson()`

3. Ajouter les champs dans la base de données

### Ajouter une authentification sociale

```dart
// Exemple avec Google Sign-In
import 'package:google_sign_in/google_sign_in.dart';

Future<UserModel?> signInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GoogleSignInAccount? account = await googleSignIn.signIn();
  
  if (account != null) {
    // Créer ou récupérer l'utilisateur dans votre base
    return await AuthService.register(
      email: account.email,
      password: 'google_auth', // Utiliser un token
      name: account.displayName ?? '',
    );
  }
  return null;
}
```

## 🧪 Tests

### Test de l'inscription

```dart
void main() {
  test('Register creates a new user', () async {
    final user = await AuthService.register(
      email: 'test@example.com',
      password: 'test123',
      name: 'Test User',
    );
    
    expect(user.email, 'test@example.com');
    expect(user.name, 'Test User');
  });
}
```

### Test de la connexion

```dart
void main() {
  test('Login with valid credentials', () async {
    final user = await AuthService.login(
      email: 'test@tableronde.com',
      password: 'test123',
    );
    
    expect(user, isNotNull);
    expect(user.email, 'test@tableronde.com');
  });
  
  test('Login with invalid credentials fails', () async {
    expect(
      () => AuthService.login(
        email: 'test@tableronde.com',
        password: 'wrong_password',
      ),
      throwsException,
    );
  });
}
```

## 🔄 Intégration avec les Posts

### Créer un post avec l'utilisateur connecté

```dart
final authProvider = context.read<AuthProvider>();
final user = authProvider.currentUser;

if (user != null) {
  final newPost = PostModel(
    id: 'post_${DateTime.now().millisecondsSinceEpoch}',
    authorId: user.id,
    authorName: user.name,
    authorUsername: user.username,
    authorAvatar: user.avatarUrl,
    content: 'Mon nouveau post !',
    timestamp: DateTime.now(),
    type: PostType.text,
  );
  
  await ApiService.createPost(newPost);
}
```

### Filtrer les posts de l'utilisateur

```dart
final authProvider = context.read<AuthProvider>();
final userId = authProvider.currentUser?.id;

if (userId != null) {
  final myPosts = await http.get(
    Uri.parse('$baseUrl/posts?authorId=$userId'),
  );
}
```

## 📊 Structure de la Base de Données

### Collection users

```json
{
  "users": [
    {
      "id": "user_1",
      "email": "user@example.com",
      "password": "hashed_password",
      "name": "Nom Utilisateur",
      "username": "@username",
      "bio": "Ma bio",
      "phone": "+33 6 12 34 56 78",
      "avatarUrl": "assets/images/avatar.png",
      "createdAt": "2026-02-25T10:00:00.000Z",
      "isOnline": true,
      "currentActivity": "En ligne"
    }
  ]
}
```

## 🐛 Dépannage

### L'inscription ne fonctionne pas

1. Vérifier que le serveur est démarré
2. Vérifier l'URL dans `auth_service.dart`
3. Vérifier que l'email n'existe pas déjà

### La connexion échoue

1. Vérifier les identifiants
2. Vérifier que l'utilisateur existe dans `db.json`
3. Vérifier les logs du serveur

### La session n'est pas persistante

1. Vérifier que `shared_preferences` est installé
2. Vérifier que `initialize()` est appelé au démarrage
3. Vérifier les permissions de stockage

## 📚 Ressources

- [Provider Documentation](https://pub.dev/packages/provider)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [HTTP Package](https://pub.dev/packages/http)
- [JWT Authentication](https://jwt.io/)

## ✨ Prochaines Étapes

1. ✅ Tester l'inscription et la connexion
2. ✅ Protéger vos écrans avec `AuthGuard`
3. ✅ Personnaliser les écrans d'authentification
4. ✅ Intégrer avec vos fonctionnalités existantes
5. ✅ Implémenter la sécurité pour la production

Bon développement ! 🚀
