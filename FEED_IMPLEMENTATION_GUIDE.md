# 🚀 Guide d'Implémentation - Feed Social (Mis à jour Phase 3)

Ce guide explique comment intégrer les nouvelles fonctionnalités de feed social dans l'application TableRonde existante, incluant maintenant les fonctionnalités avancées de recherche de Phase 3.

## 📦 Nouveaux Fichiers Créés

### 🎯 Modèles de Données
```
lib/models/feed/
├── post_model.dart          # Modèle principal des posts
├── post_type.dart           # Types de posts (enum)
├── reaction_model.dart      # Modèle des réactions
├── reaction_type.dart       # Types de réactions (enum)
├── comment_model.dart       # Modèle des commentaires
└── README.md               # Documentation des modèles

lib/models/search/           # NOUVEAU - Phase 3
├── feed_search_result.dart  # Résultat de recherche avec score
└── text_range.dart         # Range de texte pour surlignage
```

### 🔄 Providers (Gestion d'État)
```
lib/providers/
├── feed_provider.dart           # Provider principal du feed
├── saved_posts_provider.dart    # Provider des posts sauvegardés
└── feed_search_provider.dart    # NOUVEAU - Provider de recherche avancée
```

### 🛠️ Utilitaires
```
lib/utils/
└── text_parser.dart         # Parser pour hashtags/mentions
```

### 📊 Données Mockées
```
lib/data/
├── mock_posts_data.dart     # 50+ posts mockés
└── mock_reactions_data.dart # Réactions mockées
```

### 🎨 Widgets du Feed
```
lib/widgets/feed/
├── create_post_widget.dart              # Création de posts
├── reaction_picker.dart                 # Sélecteur de réactions
├── comments_section.dart                # Section commentaires
├── advanced_post_card.dart              # Carte de post complète
├── complete_feed_widget.dart            # Widget de feed complet
├── feed_integration_example.dart        # Exemple d'intégration Phase 1-2
├── feed_search_bar.dart                 # NOUVEAU - Barre de recherche
├── feed_search_results.dart             # NOUVEAU - Résultats de recherche
├── hashtag_mention_navigator.dart       # NOUVEAU - Navigation sociale
├── highlighted_text.dart                # NOUVEAU - Surlignage de texte
├── advanced_feed_search.dart            # NOUVEAU - Recherche complète
├── feed_search_integration_example.dart # NOUVEAU - Exemple Phase 3
├── README.md                           # Documentation Phase 1-2
└── PHASE3_README.md                    # NOUVEAU - Documentation Phase 3
```

## 🔧 Étapes d'Intégration

### 1. Ajouter les Providers au main.dart

```dart
// Dans lib/main.dart
import 'package:provider/provider.dart';
import 'providers/feed_provider.dart';
import 'providers/saved_posts_provider.dart';
import 'providers/feed_search_provider.dart'; // NOUVEAU - Phase 3

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Providers existants...
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        
        // Providers pour le feed
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => SavedPostsProvider()),
        ChangeNotifierProvider(create: (_) => FeedSearchProvider()), // NOUVEAU
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Intégrer dans HomeScreen

**Option A: Remplacer le feed existant**
```dart
// Dans lib/screens/home_screen.dart
import '../widgets/feed/feed_integration_example.dart';

class HomeScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar existant
          const HomeSidebar(),
          
          // Remplacer HomeFeed par le nouveau feed
          const Expanded(
            child: FeedIntegrationExample(),
          ),
          
          // Right sidebar existant
          const HomeRightSidebar(),
        ],
      ),
    );
  }
}
```

**Option B: Ajouter un nouvel onglet**
```dart
// Ajouter un onglet "Feed Social" dans la navigation
class MainScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),                        # Onglet existant
          const FeedSearchIntegrationExample(),     # Nouvel onglet feed avec recherche
          const ChatListScreen(),                   # Onglet existant
          const ProfileScreen(),                    # Onglet existant
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
```

**Option C: Intégration avec Recherche Avancée (Phase 3)**
```dart
// Dans lib/screens/home_screen.dart
import '../widgets/feed/feed_search_integration_example.dart';

class HomeScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar existant
          const HomeSidebar(),
          
          // Feed avec recherche avancée intégrée
          const Expanded(
            child: FeedSearchIntegrationExample(),
          ),
          
          // Right sidebar existant
          const HomeRightSidebar(),
        ],
      ),
    );
  }
}
```
```dart
// Ajouter un onglet "Feed Social" dans la navigation
class MainScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),           // Onglet existant
          const FeedIntegrationExample(), // Nouvel onglet feed
          const ChatListScreen(),      // Onglet existant
          const ProfileScreen(),       // Onglet existant
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
```

### 3. Créer des Widgets Personnalisés

**Widget PostCard Personnalisé:**
```dart
// lib/widgets/feed/post_card.dart
class PostCard extends StatelessWidget {
  final PostModel post;
  
  const PostCard({Key? key, required this.post}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.themeColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec avatar et nom
          _buildHeader(),
          const SizedBox(height: 12),
          
          // Contenu avec hashtags/mentions cliquables
          TextParser.buildRichText(
            post.content,
            baseStyle: AppTheme.bodyMedium,
            onHashtagTap: (hashtag) => _navigateToHashtag(hashtag),
            onMentionTap: (mention) => _navigateToProfile(mention),
          ),
          
          // Images si présentes
          if (post.hasMedia) _buildMedia(),
          
          const SizedBox(height: 12),
          
          // Actions (like, comment, share, save)
          _buildActions(),
        ],
      ),
    );
  }
}
```

### 4. Ajouter la Recherche dans le Feed

```dart
// lib/widgets/feed/feed_search_bar.dart
class FeedSearchBar extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher dans le feed...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onChanged: (query) {
          // Implémenter la recherche
          context.read<FeedProvider>().searchPosts(query);
        },
      ),
    );
  }
}
```

### 5. Intégrer avec les Notifications

```dart
// Dans lib/providers/feed_provider.dart
// Ajouter une méthode pour créer des notifications

Future<void> reactToPost(String postId, ReactionType reactionType) async {
  // ... logique existante ...
  
  // Créer une notification pour l'auteur du post
  final post = _posts.firstWhere((p) => p.id == postId);
  if (post.authorId != _currentUserId) {
    final notification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.like,
      title: 'Nouvelle réaction',
      body: 'AlistairJr a réagi à votre post',
      timestamp: DateTime.now(),
      targetId: postId,
      targetType: 'post',
    );
    
    // Ajouter à NotificationProvider
    context.read<NotificationProvider>().addNotification(notification);
  }
}
```

## 🎨 Personnalisation de l'Interface

### Thème du Feed
```dart
// Dans lib/utils/app_theme.dart
class FeedTheme {
  static const Color reactionLikeColor = Color(0xFF1877F2);
  static const Color reactionLoveColor = Color(0xFFE91E63);
  static const Color hashtagColor = Color(0xFF1DA1F2);
  static const Color mentionColor = Color(0xFF9C27B0);
  
  static TextStyle get hashtagStyle => TextStyle(
    color: hashtagColor,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get mentionStyle => TextStyle(
    color: mentionColor,
    fontWeight: FontWeight.w600,
  );
}
```

### Animations
```dart
// Animations pour les réactions
class ReactionAnimation extends StatefulWidget {
  final ReactionType type;
  final VoidCallback onComplete;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.3),
          child: Text(
            type.emoji,
            style: TextStyle(fontSize: 20),
          ),
        );
      },
    );
  }
}
```

## 📱 Fonctionnalités Disponibles

### ✅ Phase 1-2: Implémentées
- ✅ Création de posts avec texte et images
- ✅ Système de réactions (6 types)
- ✅ Commentaires avec réponses
- ✅ Partage de posts
- ✅ Sauvegarde de posts
- ✅ Hashtags et mentions cliquables
- ✅ Filtres (tous, abonnements, tendances, sauvegardés)
- ✅ Tri (récent, populaire, tendances)
- ✅ Pagination infinie
- ✅ Pull-to-refresh
- ✅ Persistance locale des posts sauvegardés
- ✅ 50+ posts mockés avec engagement réaliste

### ✅ Phase 3: Recherche Avancée (NOUVEAU)
- ✅ Recherche en temps réel avec debounce
- ✅ Suggestions automatiques (hashtags, mentions, historique)
- ✅ Recherche par hashtags (`#flutter`)
- ✅ Recherche par mentions (`@username`)
- ✅ Recherche par auteur (`auteur:Sophie`)
- ✅ Recherche de phrases exactes (`"phrase exacte"`)
- ✅ Score de pertinence des résultats
- ✅ Surlignage des correspondances dans les résultats
- ✅ Filtres avancés (type, auteur, date)
- ✅ Navigation par hashtags et mentions
- ✅ Interface adaptative (desktop/mobile)
- ✅ Historique des recherches
- ✅ Statistiques de recherche

### 🔄 Actions Utilisateur

#### Feed Basique (Phase 1-2)
```dart
// Exemples d'utilisation du FeedProvider

final feedProvider = context.read<FeedProvider>();

// Créer un post
await feedProvider.createPost(
  content: 'Mon nouveau post ! #Flutter #Dev',
  imageUrls: ['assets/images/screenshot.png'],
);

// Réagir à un post
await feedProvider.reactToPost('post_123', ReactionType.love);

// Ajouter un commentaire
await feedProvider.addComment(
  postId: 'post_123',
  content: 'Super post ! @alistairjr',
);

// Partager un post
await feedProvider.sharePost('post_123', comment: 'À voir absolument !');

// Changer les filtres
feedProvider.setFilter('trending');
feedProvider.setSort('popular');
```

#### Recherche Avancée (Phase 3)
```dart
// Exemples d'utilisation du FeedSearchProvider

final searchProvider = context.read<FeedSearchProvider>();

// Initialiser avec le feed provider
searchProvider.setFeedProvider(feedProvider);

// Recherche générale
await searchProvider.search('flutter dev');

// Recherche spécialisée
await searchProvider.searchByHashtag('flutter');
await searchProvider.searchByMention('alistairjr');
await searchProvider.searchByAuthor('Sophie');

// Gestion des filtres avancés
searchProvider.togglePostTypeFilter(PostType.image);
searchProvider.setDateFilter(
  DateTime.now().subtract(Duration(days: 7)), 
  null
);

// Accès aux résultats avec métadonnées
final results = searchProvider.searchResults;
for (final result in results) {
  print('Post: ${result.post.content}');
  print('Score: ${result.relevanceScore}');
  print('Type: ${result.matchType}');
  print('Ranges: ${result.matchedRanges}');
}

// Statistiques de recherche
final hashtagStats = searchProvider.getPopularHashtagsInResults();
final authorStats = searchProvider.getActiveAuthorsInResults();

// Effacement
searchProvider.clearSearch();
searchProvider.clearFilters();
```

## 🔧 Configuration Avancée

### Personnaliser les Données Mockées
```dart
// Dans lib/data/mock_posts_data.dart
// Modifier les posts existants ou en ajouter de nouveaux

static List<PostModel> _generatePosts() {
  return [
    PostModel(
      id: 'custom_post_1',
      authorId: 'user_custom',
      authorName: 'Votre Nom',
      content: 'Contenu personnalisé avec #hashtag',
      timestamp: DateTime.now(),
      type: PostType.text,
      // ... autres propriétés
    ),
    // ... autres posts
  ];
}
```

### Ajouter de Nouveaux Types de Posts
```dart
// Dans lib/models/feed/post_type.dart
enum PostType {
  text,
  image,
  video,
  gif,
  poll,
  share,
  event,    // Nouveau type
  article,  // Nouveau type
}
```

## 🧪 Tests

### Tests Unitaires
```dart
// test/providers/feed_provider_test.dart
void main() {
  group('FeedProvider Tests', () {
    test('should create post successfully', () async {
      final provider = FeedProvider();
      
      final post = await provider.createPost(
        content: 'Test post',
      );
      
      expect(post.content, equals('Test post'));
      expect(provider.posts.length, equals(1));
    });
    
    test('should react to post', () async {
      final provider = FeedProvider();
      // ... test logic
    });
  });
}
```

### Tests d'Intégration
```dart
// test/integration/feed_integration_test.dart
void main() {
  testWidgets('Feed integration test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FeedProvider()),
        ],
        child: MaterialApp(
          home: FeedIntegrationExample(),
        ),
      ),
    );
    
    // Vérifier que le feed s'affiche
    expect(find.text('Feed Social'), findsOneWidget);
    
    // Tester la création d'un post
    await tester.tap(find.byIcon(Icons.add_box_outlined));
    await tester.pumpAndSettle();
    
    // ... autres tests
  });
}
```

## 🚀 Déploiement

### Checklist Avant Déploiement
- [ ] Tests unitaires passent
- [ ] Tests d'intégration passent
- [ ] Performance testée avec 100+ posts
- [ ] Thème cohérent avec l'app existante
- [ ] Accessibilité vérifiée
- [ ] Gestion d'erreurs implémentée
- [ ] Documentation mise à jour

### Migration des Données
Si vous avez des données existantes à migrer:
```dart
// lib/services/migration_service.dart
class MigrationService {
  static Future<void> migrateExistingPosts() async {
    // Logique de migration des anciens posts
    // vers le nouveau format PostModel
  }
}
```

## 📞 Support

Pour toute question sur l'implémentation:
1. Consulter la documentation des modèles (`lib/models/feed/README.md`)
2. Examiner l'exemple d'intégration (`lib/widgets/feed/feed_integration_example.dart`)
3. Tester avec les données mockées fournies
4. Adapter selon les besoins spécifiques de l'application

## 🔮 Prochaines Étapes

1. **Intégration Backend** - Remplacer les données mockées par des appels API
2. **Notifications Push** - Intégrer avec Firebase/OneSignal
3. **Analytics** - Ajouter le tracking des interactions
4. **Modération** - Système de signalement et modération
5. **Stories** - Fonctionnalité de stories temporaires
6. **Live Streaming** - Diffusion en direct
7. **Monétisation** - Posts sponsorisés et publicités