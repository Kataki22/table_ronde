# 📱 Module Feed Social - Modèles de Données

Ce dossier contient tous les modèles de données pour le système de feed social de l'application TableRonde.

## 📋 Structure des Modèles

### 🎯 PostModel
**Fichier:** `post_model.dart`

Modèle principal représentant un post dans le feed social.

**Propriétés principales:**
- `id` - Identifiant unique du post
- `authorId`, `authorName`, `authorUsername` - Informations de l'auteur
- `content` - Contenu textuel du post
- `imageUrls`, `videoUrl`, `gifUrl` - Médias attachés
- `timestamp` - Date de publication
- `type` - Type de post (texte, image, vidéo, GIF, poll, partage)
- `reactionCount`, `commentCount`, `shareCount` - Compteurs d'engagement
- `hashtags`, `mentions` - Éléments extraits du contenu
- `location` - Localisation optionnelle

**Méthodes utiles:**
- `copyWith()` - Crée une copie modifiée
- `hasMedia` - Vérifie la présence de médias
- `isSharedPost` - Vérifie si c'est un partage
- `timeAgo` - Temps écoulé formaté
- `totalEngagement` - Engagement total

### 🎭 ReactionModel
**Fichier:** `reaction_model.dart`

Représente une réaction sur un post (like, love, laugh, etc.).

**Propriétés:**
- `id` - Identifiant unique
- `postId` - ID du post réagi
- `userId`, `userName` - Utilisateur qui a réagi
- `type` - Type de réaction (ReactionType)
- `timestamp` - Date de la réaction

### 💬 CommentModel
**Fichier:** `comment_model.dart`

Représente un commentaire sur un post avec support des réponses.

**Propriétés:**
- `id` - Identifiant unique
- `postId` - ID du post commenté
- `parentCommentId` - ID du commentaire parent (pour les réponses)
- `authorId`, `authorName` - Auteur du commentaire
- `content` - Contenu du commentaire
- `likeCount` - Nombre de likes sur le commentaire
- `replies` - Liste des réponses
- `hashtags`, `mentions` - Éléments extraits

**Méthodes:**
- `isMainComment` - Vérifie si c'est un commentaire principal
- `isReply` - Vérifie si c'est une réponse
- `totalRepliesCount` - Nombre total de réponses (récursif)

### 📝 PostType (Enum)
**Fichier:** `post_type.dart`

Types de posts supportés:
- `text` - Post texte uniquement
- `image` - Post avec image(s)
- `video` - Post avec vidéo
- `gif` - Post avec GIF
- `poll` - Sondage/Poll
- `share` - Partage d'un autre post

**Extensions:**
- `icon` - Emoji associé au type
- `displayName` - Nom lisible

### 😊 ReactionType (Enum)
**Fichier:** `reaction_type.dart`

Types de réactions disponibles:
- `like` - J'aime (👍)
- `love` - J'adore (❤️)
- `laugh` - Drôle (😂)
- `wow` - Impressionnant (😮)
- `sad` - Triste (😢)
- `angry` - En colère (😠)

**Extensions:**
- `emoji` - Emoji de la réaction
- `name` - Nom de la réaction
- `colorHex` - Couleur associée

## 🔄 Sérialisation JSON

Tous les modèles supportent la sérialisation JSON avec:
- `fromJson()` - Création depuis JSON
- `toJson()` - Conversion vers JSON

## 📊 Exemple d'Utilisation

```dart
// Créer un nouveau post
final post = PostModel(
  id: 'post_123',
  authorId: 'user_1',
  authorName: 'AlistairJr',
  content: 'Mon premier post ! #Flutter #Dev',
  timestamp: DateTime.now(),
  type: PostType.text,
  hashtags: ['Flutter', 'Dev'],
);

// Créer une réaction
final reaction = ReactionModel(
  id: 'reaction_456',
  postId: 'post_123',
  userId: 'user_2',
  userName: 'T4zor',
  type: ReactionType.like,
  timestamp: DateTime.now(),
);

// Créer un commentaire
final comment = CommentModel(
  id: 'comment_789',
  postId: 'post_123',
  authorId: 'user_3',
  authorName: 'Tk-Porky',
  content: 'Super post ! @alistairjr',
  timestamp: DateTime.now(),
  mentions: ['alistairjr'],
);
```

## 🎨 Intégration avec l'UI

Ces modèles sont conçus pour être utilisés avec:
- `FeedProvider` - Gestion d'état des posts
- `SavedPostsProvider` - Gestion des posts sauvegardés
- `TextParser` - Extraction des hashtags/mentions
- Widgets de feed personnalisés

## 🔧 Validation et Contraintes

- Les IDs doivent être uniques
- Le contenu ne peut pas être vide
- Les timestamps sont automatiquement gérés
- Les hashtags/mentions sont extraits automatiquement
- Support de l'immutabilité avec `copyWith()`

## 📈 Performance

- Modèles optimisés pour les listes longues
- Sérialisation JSON efficace
- Comparaisons optimisées avec `==` et `hashCode`
- Support du lazy loading pour les médias

## 🧪 Tests

Chaque modèle inclut:
- Tests unitaires de sérialisation
- Tests de validation des données
- Tests de performance pour les listes
- Tests d'égalité et de hashCode

## 🔮 Évolutions Futures

- Support des polls/sondages
- Réactions personnalisées
- Commentaires avec médias
- Géolocalisation avancée
- Analytics d'engagement