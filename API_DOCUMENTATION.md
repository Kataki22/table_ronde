# Documentation API - TableRonde

## Vue d'ensemble

Cette documentation décrit tous les endpoints disponibles dans l'API REST de TableRonde, qui utilise json-server pour simuler un backend. L'API permet de gérer les posts, profils, groupes, messages, notifications, médias et réactions.

## Configuration

### URL de base

L'URL de base dépend de votre environnement :

- **Android Emulator** : `http://10.0.2.2:3000`
- **iOS Simulator** : `http://localhost:3000`
- **Appareil physique** : `http://[VOTRE_IP]:3000` (ex: `http://192.168.1.10:3000`)

### Démarrage du serveur

```bash
# Installation de json-server (si nécessaire)
npm install -g json-server

# Démarrage du serveur
json-server --watch db.json --port 3000

# Le serveur sera accessible sur http://localhost:3000
```

## Structure de db.json

Le fichier `db.json` contient 8 collections principales :

```json
{
  "users": [],        // Utilisateurs avec authentification
  "profiles": [],     // Profils publics des utilisateurs
  "posts": [],        // Publications du feed social
  "groups": [],       // Groupes de discussion
  "messages": [],     // Messages des chats et groupes
  "comments": [],     // Commentaires sur les posts
  "notifications": [], // Notifications utilisateur
  "media": [],        // Médias partagés dans les chats
  "reactions": []     // Réactions (likes, etc.) sur les posts
}
```

---

## Endpoints API

### 📝 Posts

#### GET /posts
Récupère tous les posts du feed.

**Paramètres de requête (optionnels)** :
- `_page` : Numéro de page (pagination)
- `_limit` : Nombre d'éléments par page
- `_sort` : Champ de tri (ex: `timestamp`)
- `_order` : Ordre de tri (`asc` ou `desc`)

**Exemple curl** :
```bash
# Récupérer tous les posts
curl http://localhost:3000/posts

# Récupérer les 10 premiers posts triés par date décroissante
curl "http://localhost:3000/posts?_sort=timestamp&_order=desc&_limit=10"

# Pagination : page 2, 20 posts par page
curl "http://localhost:3000/posts?_page=2&_limit=20"
```

**Réponse** :
```json
[
  {
    "id": "post_1",
    "authorId": "user_1",
    "authorName": "AlistairJr",
    "authorUsername": "@alistairjr",
    "authorAvatar": "assets/images/Avatar1.png",
    "isAuthorVerified": true,
    "content": "Nouvelle fonctionnalité Flutter 3.16 disponible ! 🚀",
    "imageUrls": ["assets/images/test.png"],
    "videoUrl": null,
    "gifUrl": null,
    "timestamp": "2026-02-25T10:00:00.000Z",
    "type": "image",
    "reactionCount": 42,
    "commentCount": 8,
    "shareCount": 12,
    "viewCount": 156,
    "hashtags": ["Flutter", "Dev", "Mobile"],
    "mentions": [],
    "location": null,
    "isPinned": false,
    "commentsEnabled": true,
    "originalPostId": null
  }
]
```

#### GET /posts/:id
Récupère un post spécifique par son ID.

**Exemple curl** :
```bash
curl http://localhost:3000/posts/post_1
```

#### POST /posts
Crée un nouveau post.

**Headers requis** :
- `Content-Type: application/json`

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -d '{
    "authorId": "user_1",
    "authorName": "AlistairJr",
    "authorUsername": "@alistairjr",
    "authorAvatar": "assets/images/Avatar1.png",
    "isAuthorVerified": true,
    "content": "Mon nouveau post !",
    "imageUrls": null,
    "videoUrl": null,
    "gifUrl": null,
    "timestamp": "2026-02-25T12:00:00.000Z",
    "type": "text",
    "reactionCount": 0,
    "commentCount": 0,
    "shareCount": 0,
    "viewCount": 0,
    "hashtags": [],
    "mentions": [],
    "location": null,
    "isPinned": false,
    "commentsEnabled": true,
    "originalPostId": null
  }'
```

#### PUT /posts/:id
Met à jour un post existant.

**Exemple curl** :
```bash
curl -X PUT http://localhost:3000/posts/post_1 \
  -H "Content-Type: application/json" \
  -d '{
    "id": "post_1",
    "authorId": "user_1",
    "content": "Contenu mis à jour",
    "reactionCount": 50
  }'
```

#### DELETE /posts/:id
Supprime un post.

**Exemple curl** :
```bash
curl -X DELETE http://localhost:3000/posts/post_1
```

---

### 👤 Profils

#### GET /profiles
Récupère tous les profils utilisateurs.

**Exemple curl** :
```bash
curl http://localhost:3000/profiles
```

**Réponse** :
```json
[
  {
    "id": "user_1",
    "name": "AlistairJr",
    "username": "@alistairjr",
    "bio": "Développeur Flutter passionné 🚀",
    "phone": "+33 6 12 34 56 78",
    "avatarUrl": "assets/images/Avatar1.png",
    "createdAt": "2025-02-25T10:00:00.000Z",
    "isOnline": true,
    "currentActivity": "En train de coder"
  }
]
```

#### GET /profiles/:id
Récupère un profil spécifique.

**Exemple curl** :
```bash
curl http://localhost:3000/profiles/user_1
```

#### PUT /profiles/:id
Met à jour un profil utilisateur.

**Exemple curl** :
```bash
curl -X PUT http://localhost:3000/profiles/user_1 \
  -H "Content-Type: application/json" \
  -d '{
    "id": "user_1",
    "name": "AlistairJr",
    "bio": "Nouvelle bio mise à jour",
    "currentActivity": "En pause café"
  }'
```

---

### 👥 Groupes

#### GET /groups
Récupère tous les groupes de discussion.

**Exemple curl** :
```bash
curl http://localhost:3000/groups
```

**Réponse** :
```json
[
  {
    "id": "group_1",
    "name": "Équipe Dev Flutter",
    "description": "Discussions techniques sur le développement Flutter",
    "photoUrl": "assets/images/test.png",
    "members": [
      {
        "userId": "user_1",
        "name": "AlistairJr",
        "avatarUrl": "assets/images/Avatar1.png",
        "permission": "admin",
        "joinedAt": "2025-11-27T10:00:00.000Z"
      }
    ],
    "createdAt": "2025-11-27T10:00:00.000Z",
    "lastMessage": "Le nouveau widget est prêt pour review",
    "lastMessageTime": "2026-02-25T08:00:00.000Z",
    "unreadCount": 3
  }
]
```

#### GET /groups/:id
Récupère un groupe spécifique.

**Exemple curl** :
```bash
curl http://localhost:3000/groups/group_1
```

#### POST /groups
Crée un nouveau groupe.

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/groups \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Nouveau Groupe",
    "description": "Description du groupe",
    "photoUrl": null,
    "members": [
      {
        "userId": "user_1",
        "name": "AlistairJr",
        "avatarUrl": "assets/images/Avatar1.png",
        "permission": "admin",
        "joinedAt": "2026-02-25T12:00:00.000Z"
      }
    ],
    "createdAt": "2026-02-25T12:00:00.000Z",
    "lastMessage": null,
    "lastMessageTime": null,
    "unreadCount": 0
  }'
```

#### PUT /groups/:id
Met à jour un groupe.

**Exemple curl** :
```bash
curl -X PUT http://localhost:3000/groups/group_1 \
  -H "Content-Type: application/json" \
  -d '{
    "id": "group_1",
    "name": "Équipe Dev Flutter - Mise à jour",
    "description": "Nouvelle description"
  }'
```

#### DELETE /groups/:id
Supprime un groupe.

**Exemple curl** :
```bash
curl -X DELETE http://localhost:3000/groups/group_1
```

---

### 💬 Messages

#### GET /messages
Récupère tous les messages (généralement filtré par chatId).

**Paramètres de requête** :
- `chatId` : ID du chat ou groupe (recommandé)

**Exemple curl** :
```bash
# Récupérer tous les messages d'un chat
curl "http://localhost:3000/messages?chatId=group_1"

# Récupérer tous les messages
curl http://localhost:3000/messages
```

**Réponse** :
```json
[
  {
    "id": "msg_g1_1",
    "chatId": "group_1",
    "text": "Bonjour l'équipe !",
    "senderId": "user_1",
    "senderName": "AlistairJr",
    "isSentByMe": false,
    "timestamp": "2026-02-25T02:00:00.000Z",
    "isRead": true
  }
]
```

#### POST /messages
Envoie un nouveau message.

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/messages \
  -H "Content-Type: application/json" \
  -d '{
    "chatId": "group_1",
    "text": "Nouveau message !",
    "senderId": "user_1",
    "senderName": "AlistairJr",
    "isSentByMe": true,
    "timestamp": "2026-02-25T12:00:00.000Z",
    "isRead": false
  }'
```

#### DELETE /messages/:id
Supprime un message.

**Exemple curl** :
```bash
curl -X DELETE http://localhost:3000/messages/msg_g1_1
```

---

### 🔔 Notifications

#### GET /notifications
Récupère les notifications (généralement filtré par userId).

**Paramètres de requête** :
- `userId` : ID de l'utilisateur (recommandé)

**Exemple curl** :
```bash
# Récupérer les notifications d'un utilisateur
curl "http://localhost:3000/notifications?userId=user_1"

# Récupérer toutes les notifications
curl http://localhost:3000/notifications
```

**Réponse** :
```json
[
  {
    "id": "notif_1",
    "userId": "user_1",
    "type": "message",
    "title": "Nouveau message de T4zor",
    "body": "Hey, tu as vu le dernier commit ?",
    "timestamp": "2026-02-25T09:55:00.000Z",
    "isRead": false,
    "avatarUrl": "assets/images/Avatar2.png",
    "targetId": "chat_user_2",
    "targetType": "chat"
  }
]
```

#### POST /notifications
Crée une nouvelle notification.

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/notifications \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user_1",
    "type": "like",
    "title": "Nouveau like",
    "body": "Quelqu'\''un a aimé votre post",
    "timestamp": "2026-02-25T12:00:00.000Z",
    "isRead": false,
    "avatarUrl": null,
    "targetId": "post_1",
    "targetType": "post"
  }'
```

#### PATCH /notifications/:id
Marque une notification comme lue (mise à jour partielle).

**Exemple curl** :
```bash
curl -X PATCH http://localhost:3000/notifications/notif_1 \
  -H "Content-Type: application/json" \
  -d '{
    "isRead": true
  }'
```

#### DELETE /notifications/:id
Supprime une notification.

**Exemple curl** :
```bash
curl -X DELETE http://localhost:3000/notifications/notif_1
```

---

### 📷 Médias

#### GET /media
Récupère les médias (généralement filtré par chatId).

**Paramètres de requête** :
- `chatId` : ID du chat ou groupe (recommandé)
- `type` : Type de média (photo, video, document, voice, link)

**Exemple curl** :
```bash
# Récupérer tous les médias d'un chat
curl "http://localhost:3000/media?chatId=group_1"

# Filtrer par type
curl "http://localhost:3000/media?chatId=group_1&type=photo"

# Récupérer tous les médias
curl http://localhost:3000/media
```

**Réponse** :
```json
[
  {
    "id": "media_g1_1",
    "chatId": "group_1",
    "type": "photo",
    "url": "assets/images/test.png",
    "thumbnailUrl": null,
    "fileName": null,
    "fileSize": null,
    "duration": null,
    "timestamp": "2026-02-20T10:00:00.000Z",
    "senderId": "user_1",
    "senderName": "AlistairJr"
  }
]
```

#### POST /media
Upload un nouveau média.

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/media \
  -H "Content-Type: application/json" \
  -d '{
    "chatId": "group_1",
    "type": "photo",
    "url": "assets/images/new_photo.png",
    "thumbnailUrl": null,
    "fileName": "photo.png",
    "fileSize": 1024000,
    "duration": null,
    "timestamp": "2026-02-25T12:00:00.000Z",
    "senderId": "user_1",
    "senderName": "AlistairJr"
  }'
```

#### DELETE /media/:id
Supprime un média.

**Exemple curl** :
```bash
curl -X DELETE http://localhost:3000/media/media_g1_1
```

---

### ❤️ Réactions

#### GET /reactions
Récupère les réactions (généralement filtré par postId).

**Paramètres de requête** :
- `postId` : ID du post (recommandé)

**Exemple curl** :
```bash
# Récupérer les réactions d'un post
curl "http://localhost:3000/reactions?postId=post_1"

# Récupérer toutes les réactions
curl http://localhost:3000/reactions
```

**Réponse** :
```json
[
  {
    "id": "reaction_1_1",
    "postId": "post_1",
    "userId": "user_2",
    "userName": "T4zor",
    "userAvatar": "assets/images/Avatar2.png",
    "type": "like",
    "timestamp": "2026-02-25T10:05:00.000Z"
  }
]
```

#### POST /reactions
Ajoute une réaction à un post.

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/reactions \
  -H "Content-Type: application/json" \
  -d '{
    "postId": "post_1",
    "userId": "user_1",
    "userName": "AlistairJr",
    "userAvatar": "assets/images/Avatar1.png",
    "type": "like",
    "timestamp": "2026-02-25T12:00:00.000Z"
  }'
```

#### DELETE /reactions/:id
Supprime une réaction.

**Exemple curl** :
```bash
curl -X DELETE http://localhost:3000/reactions/reaction_1_1
```

---

## Fonctionnalités json-server

### Pagination

```bash
# Page 1, 10 éléments
curl "http://localhost:3000/posts?_page=1&_limit=10"

# Page 2, 20 éléments
curl "http://localhost:3000/posts?_page=2&_limit=20"
```

### Tri

```bash
# Tri croissant par timestamp
curl "http://localhost:3000/posts?_sort=timestamp&_order=asc"

# Tri décroissant par reactionCount
curl "http://localhost:3000/posts?_sort=reactionCount&_order=desc"

# Tri multiple
curl "http://localhost:3000/posts?_sort=timestamp,reactionCount&_order=desc,asc"
```

### Filtrage

```bash
# Filtrer par authorId
curl "http://localhost:3000/posts?authorId=user_1"

# Filtrer par type
curl "http://localhost:3000/posts?type=image"

# Filtrer par plusieurs critères
curl "http://localhost:3000/posts?authorId=user_1&type=text"
```

### Recherche full-text

```bash
# Rechercher dans le contenu
curl "http://localhost:3000/posts?q=Flutter"
```

### Opérateurs

```bash
# Greater than or equal (gte)
curl "http://localhost:3000/posts?reactionCount_gte=50"

# Less than or equal (lte)
curl "http://localhost:3000/posts?viewCount_lte=200"

# Not equal (ne)
curl "http://localhost:3000/posts?type_ne=text"

# Like (recherche partielle)
curl "http://localhost:3000/posts?content_like=Flutter"
```

---

## Codes de statut HTTP

- **200 OK** : Requête réussie (GET, PUT, DELETE)
- **201 Created** : Ressource créée avec succès (POST)
- **204 No Content** : Suppression réussie sans contenu de retour
- **404 Not Found** : Ressource non trouvée
- **409 Conflict** : Conflit (ressource existe déjà)
- **500 Internal Server Error** : Erreur serveur

---

## Gestion des erreurs

### Erreurs courantes

1. **Serveur non démarré**
   ```
   Error: connect ECONNREFUSED
   ```
   Solution : Démarrer json-server avec `json-server --watch db.json`

2. **Port déjà utilisé**
   ```
   Error: Port 3000 is already in use
   ```
   Solution : Utiliser un autre port avec `json-server --watch db.json --port 3001`

3. **Ressource non trouvée (404)**
   ```json
   {}
   ```
   Solution : Vérifier que l'ID existe dans db.json

4. **Données JSON invalides**
   ```
   SyntaxError: Unexpected token
   ```
   Solution : Valider le JSON avec un outil comme jsonlint.com

---

## Exemples d'utilisation dans Flutter

### Récupérer les posts

```dart
final posts = await ApiService.getPosts();
print('${posts.length} posts récupérés');
```

### Créer un post

```dart
final newPost = PostModel(
  id: '',
  authorId: 'user_1',
  authorName: 'AlistairJr',
  content: 'Mon nouveau post',
  timestamp: DateTime.now(),
  type: PostType.text,
  // ... autres champs
);

final createdPost = await ApiService.createPost(newPost);
print('Post créé avec ID: ${createdPost.id}');
```

### Envoyer un message

```dart
final message = MessageModel(
  id: '',
  chatId: 'group_1',
  text: 'Bonjour !',
  senderId: 'user_1',
  senderName: 'AlistairJr',
  timestamp: DateTime.now(),
  isSentByMe: true,
  isRead: false,
);

final sentMessage = await ApiService.sendMessage(message);
print('Message envoyé: ${sentMessage.id}');
```

### Marquer une notification comme lue

```dart
await ApiService.markNotificationAsRead('notif_1');
print('Notification marquée comme lue');
```

---

## Conseils de développement

1. **Utiliser Postman ou curl** pour tester les endpoints avant de les intégrer dans Flutter
2. **Vérifier db.json** régulièrement pour voir les modifications en temps réel
3. **Utiliser les paramètres de tri et pagination** pour optimiser les performances
4. **Gérer les erreurs** avec try-catch dans tous les appels API
5. **Implémenter un cache** pour réduire les appels réseau
6. **Utiliser des timestamps ISO 8601** pour la cohérence des dates
7. **Valider les données** côté client avant l'envoi au serveur

---

## Ressources

- [Documentation json-server](https://github.com/typicode/json-server)
- [Guide de démarrage Flutter](https://flutter.dev/docs/get-started)
- [Package http pour Flutter](https://pub.dev/packages/http)

---

**Dernière mise à jour** : 25 février 2026
