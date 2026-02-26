# Guide du Serveur JSON - TableRonde Backend

Ce guide explique comment configurer et utiliser le serveur JSON pour simuler un backend pour l'application TableRonde.

## 📋 Prérequis

- Node.js installé (version 14 ou supérieure)
- npm ou yarn

## 🚀 Installation

1. Installez les dépendances Node.js :

```bash
npm install
```

## ▶️ Démarrage du serveur

### Mode normal

```bash
npm start
```

Le serveur démarre sur `http://localhost:3000`

### Mode avec délai (pour simuler la latence réseau)

```bash
npm run start:delay
```

Le serveur ajoute un délai de 500ms à chaque requête pour simuler des conditions réseau réelles.

## 🔧 Configuration de l'application Flutter

### Pour Android Emulator

Dans `lib/services/api_service.dart`, utilisez :

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

### Pour iOS Simulator

```dart
static const String baseUrl = 'http://localhost:3000';
```

### Pour un appareil physique

1. Trouvez l'adresse IP de votre machine :
   - Windows : `ipconfig`
   - Mac/Linux : `ifconfig` ou `ip addr`

2. Utilisez cette IP dans la configuration :

```dart
static const String baseUrl = 'http://192.168.1.X:3000';
```

3. Assurez-vous que votre appareil et votre ordinateur sont sur le même réseau WiFi.

## 📡 API Endpoints disponibles

### Posts

- `GET /posts` - Récupère tous les posts
- `GET /posts/:id` - Récupère un post spécifique
- `POST /posts` - Crée un nouveau post
- `PUT /posts/:id` - Met à jour un post
- `DELETE /posts/:id` - Supprime un post
- `GET /posts?authorId=user_1` - Filtre les posts par auteur

### Profils

- `GET /profiles` - Récupère tous les profils
- `GET /profiles/:id` - Récupère un profil spécifique
- `PUT /profiles/:id` - Met à jour un profil

### Chats

- `GET /chats` - Récupère tous les chats
- `GET /chats/:id` - Récupère un chat spécifique

### Messages

- `GET /messages` - Récupère tous les messages
- `GET /messages?chatId=1` - Récupère les messages d'un chat spécifique
- `POST /messages` - Envoie un nouveau message

### Commentaires

- `GET /comments` - Récupère tous les commentaires
- `GET /comments?postId=post_1` - Récupère les commentaires d'un post
- `POST /comments` - Ajoute un commentaire

## 💡 Exemples d'utilisation dans Flutter

### Récupérer les posts

```dart
import 'package:tableronde_app/services/api_service.dart';

// Dans votre widget ou provider
Future<void> loadPosts() async {
  try {
    final posts = await ApiService.getPosts();
    setState(() {
      _posts = posts;
    });
  } catch (e) {
    print('Erreur: $e');
  }
}
```

### Créer un nouveau post

```dart
final newPost = PostModel(
  id: 'post_${DateTime.now().millisecondsSinceEpoch}',
  authorId: 'user_1',
  authorName: 'Mon Nom',
  authorUsername: '@monusername',
  content: 'Mon nouveau post !',
  timestamp: DateTime.now(),
  type: PostType.text,
);

try {
  final createdPost = await ApiService.createPost(newPost);
  print('Post créé: ${createdPost.id}');
} catch (e) {
  print('Erreur: $e');
}
```

### Envoyer un message

```dart
final message = MessageModel(
  chatId: '1',
  text: 'Bonjour !',
  isSentByMe: true,
  timestamp: DateTime.now(),
);

try {
  await ApiService.sendMessage(message);
} catch (e) {
  print('Erreur: $e');
}
```

## 🔍 Fonctionnalités avancées de json-server

### Recherche

```
GET /posts?content_like=Flutter
```

### Tri

```
GET /posts?_sort=timestamp&_order=desc
```

### Pagination

```
GET /posts?_page=1&_limit=10
```

### Relations

```
GET /posts?_embed=comments
```

### Opérateurs

- `_gte` : supérieur ou égal
- `_lte` : inférieur ou égal
- `_ne` : différent de
- `_like` : contient (regex)

Exemple :
```
GET /posts?reactionCount_gte=50
```

## 📝 Structure de la base de données

Le fichier `db.json` contient :

- `posts` : Les publications du feed social
- `profiles` : Les profils utilisateurs
- `chats` : Les conversations
- `messages` : Les messages des conversations
- `comments` : Les commentaires sur les posts

Vous pouvez modifier `db.json` directement pour ajouter ou modifier des données. Le serveur se recharge automatiquement.

## 🛠️ Personnalisation

### Ajouter de nouvelles données

Éditez `db.json` et ajoutez vos données dans les collections appropriées.

### Ajouter de nouveaux endpoints

json-server crée automatiquement des endpoints REST pour chaque collection dans `db.json`.

### Middleware personnalisé

Créez un fichier `server.js` pour ajouter des middlewares personnalisés :

```javascript
const jsonServer = require('json-server');
const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();

// Middleware personnalisé
server.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

server.use(middlewares);
server.use(router);

server.listen(3000, () => {
  console.log('JSON Server is running');
});
```

Puis lancez avec : `node server.js`

## 🐛 Dépannage

### Le serveur ne démarre pas

- Vérifiez que Node.js est installé : `node --version`
- Vérifiez que le port 3000 n'est pas déjà utilisé
- Réinstallez les dépendances : `rm -rf node_modules && npm install`

### L'application Flutter ne peut pas se connecter

- Vérifiez que le serveur est bien démarré
- Vérifiez l'URL dans `api_service.dart`
- Pour Android Emulator, utilisez `10.0.2.2` au lieu de `localhost`
- Vérifiez les permissions réseau dans `AndroidManifest.xml`

### Erreur CORS

json-server gère automatiquement CORS, mais si vous avez des problèmes, ajoutez dans `server.js` :

```javascript
server.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});
```

## 📚 Ressources

- [Documentation json-server](https://github.com/typicode/json-server)
- [API REST best practices](https://restfulapi.net/)

## 🎯 Prochaines étapes

1. Démarrez le serveur : `npm start`
2. Testez les endpoints avec un outil comme Postman ou curl
3. Intégrez l'API dans votre application Flutter
4. Ajoutez plus de données dans `db.json` selon vos besoins
