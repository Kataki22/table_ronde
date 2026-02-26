# 🌐 API Backend - TableRonde

Serveur JSON pour simuler un backend complet pour l'application TableRonde.

## 📦 Ce qui a été ajouté

### Fichiers Backend

- `package.json` - Configuration npm et scripts
- `db.json` - Base de données JSON avec données de démonstration
- `test_api.sh` / `test_api.bat` - Scripts de test de l'API

### Fichiers Flutter

- `lib/services/api_service.dart` - Service pour communiquer avec l'API
- `lib/providers/api_posts_provider.dart` - Provider pour gérer les posts via l'API
- `lib/examples/api_usage_example.dart` - Exemple d'utilisation complète
- `lib/models/chat_model.dart` - Ajout des méthodes `fromJson()` et `toJson()`

### Scripts et Documentation

- `scripts/generate_mock_data.dart` - Générateur de données mock complètes
- `SERVER_JSON_GUIDE.md` - Guide complet de l'API
- `QUICK_START_API.md` - Guide de démarrage rapide
- `README_API.md` - Ce fichier

### Configuration

- `android/app/src/main/AndroidManifest.xml` - Ajout des permissions réseau
- `.gitignore` - Ajout des exclusions Node.js

## 🚀 Démarrage Rapide

### 1. Installation

```bash
npm install
```

### 2. Démarrage du serveur

```bash
npm start
```

Le serveur démarre sur http://localhost:3000

### 3. Test de l'API

```bash
# Linux/Mac
./test_api.sh

# Windows
test_api.bat
```

### 4. Configuration Flutter

Ouvrez `lib/services/api_service.dart` et vérifiez l'URL :

```dart
// Android Emulator (par défaut)
static const String baseUrl = 'http://10.0.2.2:3000';

// iOS Simulator
// static const String baseUrl = 'http://localhost:3000';

// Appareil physique (remplacez par votre IP)
// static const String baseUrl = 'http://192.168.1.X:3000';
```

## 📡 Endpoints Disponibles

### Posts
- `GET /posts` - Liste tous les posts
- `GET /posts/:id` - Récupère un post
- `POST /posts` - Crée un post
- `PUT /posts/:id` - Met à jour un post
- `DELETE /posts/:id` - Supprime un post

### Profils
- `GET /profiles` - Liste tous les profils
- `GET /profiles/:id` - Récupère un profil
- `PUT /profiles/:id` - Met à jour un profil

### Chats
- `GET /chats` - Liste tous les chats
- `GET /chats/:id` - Récupère un chat

### Messages
- `GET /messages` - Liste tous les messages
- `GET /messages?chatId=1` - Messages d'un chat
- `POST /messages` - Envoie un message

### Commentaires
- `GET /comments` - Liste tous les commentaires
- `GET /comments?postId=post_1` - Commentaires d'un post
- `POST /comments` - Ajoute un commentaire

## 💡 Utilisation dans Flutter

### Avec le service API

```dart
import 'package:tableronde_app/services/api_service.dart';

// Charger les posts
final posts = await ApiService.getPosts();

// Créer un post
final newPost = PostModel(
  id: 'post_${DateTime.now().millisecondsSinceEpoch}',
  authorId: 'user_1',
  authorName: 'Mon Nom',
  content: 'Mon nouveau post !',
  timestamp: DateTime.now(),
  type: PostType.text,
);
await ApiService.createPost(newPost);
```

### Avec le provider

```dart
import 'package:provider/provider.dart';
import 'package:tableronde_app/providers/api_posts_provider.dart';

// Dans votre widget
final postsProvider = Provider.of<ApiPostsProvider>(context);

// Charger les posts
await postsProvider.loadPosts();

// Afficher les posts
ListView.builder(
  itemCount: postsProvider.posts.length,
  itemBuilder: (context, index) {
    final post = postsProvider.posts[index];
    return PostWidget(post: post);
  },
);

// Créer un post
await postsProvider.createPost(newPost);

// Liker un post
await postsProvider.toggleReaction(postId);
```

### Exemple complet

Un exemple d'interface complète est disponible dans :
`lib/examples/api_usage_example.dart`

## 🔧 Génération de Données

Pour générer plus de données (50+ posts, 20 profils, etc.) :

```bash
dart run scripts/generate_mock_data.dart
```

Puis redémarrez le serveur.

## 🧪 Tests

### Test manuel avec curl

```bash
# Récupérer les posts
curl http://localhost:3000/posts

# Créer un post
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -d '{"id":"test","authorId":"user_1","authorName":"Test","content":"Hello","timestamp":"2026-02-25T10:00:00.000Z","type":"text"}'
```

### Test avec le navigateur

Ouvrez http://localhost:3000 dans votre navigateur pour voir toutes les routes disponibles.

### Test avec les scripts

```bash
# Linux/Mac
./test_api.sh

# Windows
test_api.bat
```

## 📊 Structure des Données

### Post
```json
{
  "id": "post_1",
  "authorId": "user_1",
  "authorName": "AlistairJr",
  "authorUsername": "@alistairjr",
  "authorAvatar": "assets/images/Avatar1.png",
  "isAuthorVerified": true,
  "content": "Mon contenu...",
  "imageUrls": ["url1", "url2"],
  "timestamp": "2026-02-25T10:00:00.000Z",
  "type": "text",
  "reactionCount": 42,
  "commentCount": 8,
  "shareCount": 12,
  "viewCount": 156,
  "hashtags": ["Flutter", "Dev"],
  "mentions": [],
  "commentsEnabled": true
}
```

### Profile
```json
{
  "id": "user_1",
  "name": "AlistairJr",
  "username": "@alistairjr",
  "bio": "Développeur Flutter...",
  "phone": "+33 6 12 34 56 78",
  "avatarUrl": "assets/images/Avatar1.png",
  "createdAt": "2025-02-25T10:00:00.000Z",
  "isOnline": true,
  "currentActivity": "En train de coder"
}
```

### Message
```json
{
  "id": "msg_1",
  "chatId": "1",
  "text": "Salut !",
  "isSentByMe": false,
  "timestamp": "2026-02-25T08:00:00.000Z",
  "isRead": true,
  "type": "text"
}
```

## 🔍 Fonctionnalités Avancées

### Recherche
```
GET /posts?content_like=Flutter
GET /posts?authorName_like=Alistair
```

### Tri
```
GET /posts?_sort=timestamp&_order=desc
GET /posts?_sort=reactionCount&_order=desc
```

### Pagination
```
GET /posts?_page=1&_limit=10
GET /posts?_page=2&_limit=10
```

### Filtres multiples
```
GET /posts?authorId=user_1&type=image
GET /messages?chatId=1&isRead=false
```

### Opérateurs
```
GET /posts?reactionCount_gte=50
GET /posts?timestamp_lte=2026-02-25T00:00:00.000Z
```

## 🐛 Dépannage

### Le serveur ne démarre pas

1. Vérifiez Node.js : `node --version`
2. Réinstallez : `rm -rf node_modules && npm install`
3. Vérifiez le port 3000 : `lsof -ti:3000` (Mac/Linux)

### L'app Flutter ne se connecte pas

1. ✅ Serveur démarré ?
2. ✅ Bonne URL dans `api_service.dart` ?
3. ✅ Android Emulator → utilisez `10.0.2.2`
4. ✅ Permissions réseau dans `AndroidManifest.xml` ?

### Erreur CORS

json-server gère CORS automatiquement. Si problème, vérifiez que vous utilisez bien json-server et non un autre serveur.

## 📚 Documentation

- [SERVER_JSON_GUIDE.md](SERVER_JSON_GUIDE.md) - Guide complet
- [QUICK_START_API.md](QUICK_START_API.md) - Démarrage rapide
- [json-server documentation](https://github.com/typicode/json-server)

## 🎯 Prochaines Étapes

1. ✅ Démarrez le serveur : `npm start`
2. ✅ Testez l'API : `./test_api.sh`
3. ✅ Configurez Flutter : `lib/services/api_service.dart`
4. ✅ Testez l'exemple : `lib/examples/api_usage_example.dart`
5. ✅ Intégrez dans vos écrans existants
6. ✅ Générez plus de données : `dart run scripts/generate_mock_data.dart`

## 🌟 Avantages

- ✅ Backend fonctionnel sans serveur complexe
- ✅ Données persistantes entre les redémarrages
- ✅ API REST complète
- ✅ Facile à tester et déboguer
- ✅ Parfait pour le développement et les démos
- ✅ Peut être remplacé par un vrai backend plus tard

Bon développement ! 🚀
