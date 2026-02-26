# 🚀 Démarrage Rapide - API Backend

Guide ultra-rapide pour démarrer avec le serveur JSON backend.

## ⚡ Installation en 2 minutes

### 1. Installer Node.js

Si vous n'avez pas Node.js, téléchargez-le depuis [nodejs.org](https://nodejs.org/)

Vérifiez l'installation :
```bash
node --version
npm --version
```

### 2. Installer les dépendances

```bash
npm install
```

### 3. Démarrer le serveur

```bash
npm start
```

✅ Le serveur est maintenant accessible sur `http://localhost:3000`

## 📱 Configuration Flutter

### Android Emulator

Dans `lib/services/api_service.dart`, la configuration par défaut fonctionne :

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

### iOS Simulator

Changez l'URL en :

```dart
static const String baseUrl = 'http://localhost:3000';
```

### Appareil Physique

1. Trouvez votre IP locale :
   ```bash
   # Windows
   ipconfig
   
   # Mac/Linux
   ifconfig
   ```

2. Utilisez votre IP :
   ```dart
   static const String baseUrl = 'http://192.168.1.X:3000';
   ```

## 🧪 Tester l'API

### Avec curl

```bash
# Récupérer tous les posts
curl http://localhost:3000/posts

# Récupérer un post spécifique
curl http://localhost:3000/posts/post_1

# Créer un nouveau post
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -d '{"id":"post_test","authorId":"user_1","authorName":"Test","content":"Hello!","timestamp":"2026-02-25T10:00:00.000Z","type":"text"}'
```

### Avec le navigateur

Ouvrez simplement :
- http://localhost:3000/posts
- http://localhost:3000/profiles
- http://localhost:3000/chats

## 🎯 Exemple d'utilisation dans Flutter

```dart
import 'package:tableronde_app/services/api_service.dart';

// Charger les posts
final posts = await ApiService.getPosts();

// Créer un post
final newPost = PostModel(
  id: 'post_${DateTime.now().millisecondsSinceEpoch}',
  authorId: 'user_1',
  authorName: 'Mon Nom',
  content: 'Mon premier post via API !',
  timestamp: DateTime.now(),
  type: PostType.text,
);
await ApiService.createPost(newPost);
```

## 📊 Données disponibles

Le fichier `db.json` contient :
- ✅ 3 posts de démonstration
- ✅ 3 profils utilisateurs
- ✅ 2 conversations
- ✅ 2 messages
- ✅ 1 commentaire

### Générer plus de données

Pour créer 50+ posts, 20 profils, etc. :

```bash
dart run scripts/generate_mock_data.dart
```

Puis redémarrez le serveur.

## 🔧 Commandes utiles

```bash
# Démarrer le serveur
npm start

# Démarrer avec délai (simule latence réseau)
npm run start:delay

# Générer des données complètes
dart run scripts/generate_mock_data.dart
```

## 🐛 Problèmes courants

### "Cannot connect to server"

1. ✅ Vérifiez que le serveur est démarré (`npm start`)
2. ✅ Vérifiez l'URL dans `api_service.dart`
3. ✅ Pour Android Emulator, utilisez `10.0.2.2` au lieu de `localhost`
4. ✅ Vérifiez les permissions réseau dans `AndroidManifest.xml`

### "Port 3000 already in use"

Arrêtez le processus qui utilise le port :

```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:3000 | xargs kill -9
```

Ou changez le port dans `package.json` :
```json
"start": "json-server --watch db.json --port 3001"
```

## 📚 Documentation complète

Pour plus de détails, consultez [SERVER_JSON_GUIDE.md](SERVER_JSON_GUIDE.md)

## 🎨 Exemple d'interface

Un exemple complet d'utilisation de l'API est disponible dans :
`lib/examples/api_usage_example.dart`

Pour l'utiliser, ajoutez-le à votre navigation :

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ApiUsageExample(),
  ),
);
```

## ✨ Prochaines étapes

1. ✅ Démarrez le serveur : `npm start`
2. ✅ Testez avec curl ou le navigateur
3. ✅ Lancez votre app Flutter
4. ✅ Testez l'exemple : `lib/examples/api_usage_example.dart`
5. ✅ Intégrez l'API dans vos écrans existants

Bon développement ! 🚀
