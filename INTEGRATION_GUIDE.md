# 🔌 Guide d'Intégration API

Ce guide vous montre comment intégrer l'API backend dans vos écrans existants.

## 📋 Checklist d'Intégration

- [ ] Serveur JSON installé et démarré
- [ ] Permissions réseau ajoutées (Android)
- [ ] URL configurée dans `api_service.dart`
- [ ] Provider ajouté à l'application
- [ ] Écrans mis à jour pour utiliser l'API

## 🔧 Étape 1 : Configuration du Provider

### Ajouter le provider dans `main.dart`

```dart
import 'package:provider/provider.dart';
import 'package:tableronde_app/providers/api_posts_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Vos providers existants...
        
        // Nouveau provider pour l'API
        ChangeNotifierProvider(
          create: (_) => ApiPostsProvider()..loadPosts(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

## 📱 Étape 2 : Mise à Jour des Écrans

### Exemple : Feed Screen

#### Avant (avec données mock)

```dart
import '../data/mock_posts_data.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final posts = MockPostsData.posts;
    
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostWidget(post: posts[index]);
      },
    );
  }
}
```

#### Après (avec API)

```dart
import 'package:provider/provider.dart';
import '../providers/api_posts_provider.dart';

class FeedScreen extends StatefulWidget {
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les posts au démarrage
    Future.microtask(() {
      context.read<ApiPostsProvider>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiPostsProvider>(
      builder: (context, provider, child) {
        // Afficher un loader pendant le chargement
        if (provider.isLoading && provider.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Afficher une erreur si nécessaire
        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadPosts(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        // Afficher les posts
        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: ListView.builder(
            itemCount: provider.posts.length,
            itemBuilder: (context, index) {
              return PostWidget(post: provider.posts[index]);
            },
          ),
        );
      },
    );
  }
}
```

### Exemple : Créer un Post

```dart
Future<void> _createPost() async {
  final provider = context.read<ApiPostsProvider>();
  
  final newPost = PostModel(
    id: 'post_${DateTime.now().millisecondsSinceEpoch}',
    authorId: 'user_1',
    authorName: 'Mon Nom',
    authorUsername: '@monusername',
    content: _contentController.text,
    timestamp: DateTime.now(),
    type: PostType.text,
    hashtags: _extractHashtags(_contentController.text),
  );

  final success = await provider.createPost(newPost);
  
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post créé avec succès !')),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: ${provider.error}')),
    );
  }
}
```

### Exemple : Liker un Post

```dart
Future<void> _toggleLike(String postId) async {
  final provider = context.read<ApiPostsProvider>();
  
  final success = await provider.toggleReaction(postId);
  
  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: ${provider.error}')),
    );
  }
}
```

### Exemple : Supprimer un Post

```dart
Future<void> _deletePost(String postId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmer la suppression'),
      content: const Text('Voulez-vous vraiment supprimer ce post ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final provider = context.read<ApiPostsProvider>();
    final success = await provider.deletePost(postId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post supprimé')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${provider.error}')),
      );
    }
  }
}
```

## 🔄 Étape 3 : Gestion du Cache (Optionnel)

Pour améliorer les performances, vous pouvez ajouter un cache :

```dart
class ApiPostsProvider with ChangeNotifier {
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  Future<void> loadPosts({bool forceRefresh = false}) async {
    // Utiliser le cache si disponible et récent
    if (!forceRefresh && 
        _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _cacheDuration &&
        _posts.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await ApiService.getPosts();
      _lastFetch = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadPosts(forceRefresh: true);
  }
}
```

## 🎨 Étape 4 : Widgets Réutilisables

### Widget de Gestion d'État

```dart
class ApiStateBuilder<T> extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final T? data;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  const ApiStateBuilder({
    super.key,
    required this.isLoading,
    required this.error,
    required this.data,
    required this.builder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $error'),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      );
    }

    if (data == null) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    return builder(data!);
  }
}
```

### Utilisation

```dart
Consumer<ApiPostsProvider>(
  builder: (context, provider, child) {
    return ApiStateBuilder<List<PostModel>>(
      isLoading: provider.isLoading,
      error: provider.error,
      data: provider.posts.isEmpty ? null : provider.posts,
      onRetry: () => provider.loadPosts(),
      builder: (posts) {
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostWidget(post: posts[index]);
          },
        );
      },
    );
  },
)
```

## 🧪 Étape 5 : Tests

### Test du Service API

```dart
void main() {
  test('ApiService.getPosts returns list of posts', () async {
    final posts = await ApiService.getPosts();
    expect(posts, isA<List<PostModel>>());
    expect(posts.isNotEmpty, true);
  });

  test('ApiService.createPost creates a new post', () async {
    final newPost = PostModel(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      authorId: 'user_1',
      authorName: 'Test',
      content: 'Test post',
      timestamp: DateTime.now(),
      type: PostType.text,
    );

    final createdPost = await ApiService.createPost(newPost);
    expect(createdPost.id, newPost.id);
    expect(createdPost.content, newPost.content);
  });
}
```

## 🚀 Étape 6 : Migration Progressive

Vous pouvez migrer progressivement en gardant les deux systèmes :

```dart
class PostsProvider with ChangeNotifier {
  final bool useApi;
  
  PostsProvider({this.useApi = false});

  Future<List<PostModel>> getPosts() async {
    if (useApi) {
      return await ApiService.getPosts();
    } else {
      return MockPostsData.posts;
    }
  }
}
```

Puis dans `main.dart` :

```dart
ChangeNotifierProvider(
  create: (_) => PostsProvider(
    useApi: true, // Changez à true pour utiliser l'API
  ),
),
```

## 📊 Étape 7 : Monitoring

Ajoutez des logs pour suivre les appels API :

```dart
class ApiService {
  static Future<List<PostModel>> getPosts() async {
    print('🌐 API Call: GET /posts');
    final startTime = DateTime.now();
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));
      final duration = DateTime.now().difference(startTime);
      
      print('✅ API Response: GET /posts (${duration.inMilliseconds}ms)');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      print('❌ API Error: GET /posts (${duration.inMilliseconds}ms) - $e');
      rethrow;
    }
  }
}
```

## ✅ Checklist Finale

Avant de passer en production :

- [ ] Tous les écrans utilisent l'API
- [ ] Gestion d'erreur implémentée partout
- [ ] Loading states affichés
- [ ] Pull-to-refresh fonctionnel
- [ ] Cache implémenté si nécessaire
- [ ] Tests écrits et passants
- [ ] Logs de debug ajoutés
- [ ] Documentation mise à jour

## 🎯 Prochaines Étapes

1. Commencez par un écran simple (ex: liste des posts)
2. Testez avec le serveur JSON local
3. Ajoutez la gestion d'erreur
4. Migrez les autres écrans progressivement
5. Ajoutez des fonctionnalités avancées (cache, offline, etc.)
6. Préparez la migration vers un vrai backend

Bon développement ! 🚀
