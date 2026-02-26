import '../models/feed/post_model.dart';
import '../models/feed/post_type.dart';
import '../utils/avatar_helper.dart';

/// Données mockées pour les posts du feed social
/// Contient 50+ posts variés avec différents types de contenu et niveaux d'engagement
class MockPostsData {
  static final DateTime _now = DateTime.now();

  /// Liste des posts mockés
  static final List<PostModel> posts = _generatePosts();

  /// Génère 50+ posts variés pour le feed
  static List<PostModel> _generatePosts() {
    return [
      // Post 1: AlistairJr - Post technique avec image
      PostModel(
        id: 'post_1',
        authorId: 'user_1',
        authorName: 'AlistairJr',
        authorUsername: '@alistairjr',
        authorAvatar: 'assets/images/Avatar1.png',
        isAuthorVerified: true,
        content: 'Nouvelle fonctionnalité Flutter 3.16 disponible ! 🚀\n\nLes animations sont maintenant 40% plus fluides grâce aux optimisations du moteur Impeller. Parfait pour nos apps mobiles ! #Flutter #Dev #Mobile',
        imageUrls: ['assets/images/test.png'],
        timestamp: _now.subtract(const Duration(minutes: 15)),
        type: PostType.image,
        reactionCount: 42,
        commentCount: 8,
        shareCount: 12,
        viewCount: 156,
        hashtags: ['Flutter', 'Dev', 'Mobile'],
        mentions: [],
        commentsEnabled: true,
      ),

      // Post 2: T4zor - Post gaming drôle
      PostModel(
        id: 'post_2',
        authorId: 'user_2',
        authorName: 'T4zor',
        authorUsername: '@t4zor',
        authorAvatar: 'assets/images/Avatar2.png',
        content: 'Quand le boss final te dit "gg ez" après t\'avoir tué 47 fois... 😤\n\nMais bon, on lâche rien ! 💪 #Gaming #Perseverance #NeverGiveUp',
        imageUrls: ['assets/images/test2.png'],
        timestamp: _now.subtract(const Duration(hours: 2)),
        type: PostType.image,
        reactionCount: 89,
        commentCount: 23,
        shareCount: 5,
        viewCount: 234,
        hashtags: ['Gaming', 'Perseverance', 'NeverGiveUp'],
        mentions: [],
      ),

      // Post 3: Tk-Porky - Post inspirant
      PostModel(
        id: 'post_3',
        authorId: 'user_3',
        authorName: 'Tk-Porky',
        authorUsername: '@tkporky',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        content: 'La programmation, c\'est comme la cuisine 👨‍🍳\n\nTu peux suivre la recette à la lettre, mais c\'est quand tu improvises que tu crées les meilleurs plats ! ✨\n\n#CodeLife #Programming #Creativity',
        timestamp: _now.subtract(const Duration(hours: 4)),
        type: PostType.text,
        reactionCount: 67,
        commentCount: 15,
        shareCount: 18,
        viewCount: 189,
        hashtags: ['CodeLife', 'Programming', 'Creativity'],
        mentions: [],
      ),

      // Post 4: Sophie Martin - Post professionnel
      PostModel(
        id: 'post_4',
        authorId: 'user_4',
        authorName: 'Sophie Martin',
        authorUsername: '@sophiemartin',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        isAuthorVerified: true,
        content: 'Excellente présentation aujourd\'hui sur l\'architecture microservices ! 🏗️\n\nMerci à tous les participants pour vos questions pertinentes. Les slides sont disponibles sur notre repo GitHub.\n\n@alistairjr @t4zor merci pour votre participation active ! 👏',
        timestamp: _now.subtract(const Duration(hours: 6)),
        type: PostType.text,
        reactionCount: 34,
        commentCount: 12,
        shareCount: 8,
        viewCount: 98,
        hashtags: [],
        mentions: ['alistairjr', 't4zor'],
      ),

      // Post 5: Lucas Dubois - Post avec vidéo
      PostModel(
        id: 'post_5',
        authorId: 'user_5',
        authorName: 'Lucas Dubois',
        authorUsername: '@lucasdubois',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        content: 'Tutoriel rapide : Comment optimiser vos requêtes SQL en 3 étapes ! ⚡\n\nVidéo de 5 minutes qui peut vous faire gagner des heures de debug 😅\n\n#SQL #Database #Performance #Tutorial',
        videoUrl: 'assets/videos/sql_tutorial.mp4',
        timestamp: _now.subtract(const Duration(hours: 8)),
        type: PostType.video,
        reactionCount: 156,
        commentCount: 31,
        shareCount: 45,
        viewCount: 567,
        hashtags: ['SQL', 'Database', 'Performance', 'Tutorial'],
        mentions: [],
      ),

      // Post 6: ProGamer42 - Post gaming avec GIF
      PostModel(
        id: 'post_6',
        authorId: 'user_6',
        authorName: 'ProGamer42',
        authorUsername: '@progamer42',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        content: 'Moi quand je réussis enfin ce combo impossible après 200 essais 🎮\n\n#Gaming #Victory #PracticesMakesPerfect',
        gifUrl: 'assets/gifs/victory_dance.gif',
        timestamp: _now.subtract(const Duration(hours: 10)),
        type: PostType.gif,
        reactionCount: 78,
        commentCount: 19,
        shareCount: 12,
        viewCount: 145,
        hashtags: ['Gaming', 'Victory', 'PracticesMakesPerfect'],
        mentions: [],
      ),

      // Post 7: NinjaKiller - Post mystérieux
      PostModel(
        id: 'post_7',
        authorId: 'user_7',
        authorName: 'NinjaKiller',
        authorUsername: '@ninjakiller',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        content: 'Dans l\'ombre, nous codons. Dans la lumière, nous déployons. 🥷\n\nNouveau projet secret en cours... Stay tuned ! 👀\n\n#Ninja #Code #Mystery #ComingSoon',
        timestamp: _now.subtract(const Duration(hours: 12)),
        type: PostType.text,
        reactionCount: 23,
        commentCount: 7,
        shareCount: 3,
        viewCount: 67,
        hashtags: ['Ninja', 'Code', 'Mystery', 'ComingSoon'],
        mentions: [],
      ),

      // Post 8: Emma Leroy - Post éducatif avec images multiples
      PostModel(
        id: 'post_8',
        authorId: 'user_8',
        authorName: 'Emma Leroy',
        authorUsername: '@emmaleroy',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        isAuthorVerified: true,
        content: 'Les 5 principes SOLID expliqués avec des exemples concrets ! 📚\n\nThread 🧵 pour mieux comprendre l\'architecture logicielle propre.\n\n1️⃣ Single Responsibility Principle\n2️⃣ Open/Closed Principle\n3️⃣ Liskov Substitution Principle\n4️⃣ Interface Segregation Principle\n5️⃣ Dependency Inversion Principle\n\n#SOLID #CleanCode #Architecture #SoftwareEngineering',
        imageUrls: [
          'assets/images/solid_1.png',
          'assets/images/solid_2.png',
          'assets/images/solid_3.png',
        ],
        timestamp: _now.subtract(const Duration(hours: 14)),
        type: PostType.image,
        reactionCount: 234,
        commentCount: 45,
        shareCount: 67,
        viewCount: 789,
        hashtags: ['SOLID', 'CleanCode', 'Architecture', 'SoftwareEngineering'],
        mentions: [],
      ),

      // Post 9: MaxPower - Post motivationnel
      PostModel(
        id: 'post_9',
        authorId: 'user_9',
        authorName: 'MaxPower',
        authorUsername: '@maxpower',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        content: '💪 MOTIVATION DU JOUR 💪\n\n"Le code que tu écris aujourd\'hui détermine le développeur que tu seras demain."\n\nChaque bug fixé, chaque feature implémentée, chaque refactoring... tout compte ! 🚀\n\nContinuez à coder, les amis ! 👨‍💻👩‍💻\n\n#Motivation #Coding #GrowthMindset #KeepCoding',
        timestamp: _now.subtract(const Duration(hours: 16)),
        type: PostType.text,
        reactionCount: 145,
        commentCount: 28,
        shareCount: 34,
        viewCount: 298,
        hashtags: ['Motivation', 'Coding', 'GrowthMindset', 'KeepCoding'],
        mentions: [],
      ),

      // Post 10: Julie Bernard - Post technique avancé
      PostModel(
        id: 'post_10',
        authorId: 'user_10',
        authorName: 'Julie Bernard',
        authorUsername: '@juliebernard',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        isAuthorVerified: true,
        content: 'Deep dive dans les WebAssembly modules ! 🌐\n\nComment intégrer WASM dans vos apps Flutter pour des performances natives ⚡\n\nBenchmarks impressionnants : 300% plus rapide pour les calculs intensifs ! 📊\n\n#WebAssembly #Flutter #Performance #NativeSpeed',
        imageUrls: ['assets/images/wasm_benchmark.png'],
        timestamp: _now.subtract(const Duration(hours: 18)),
        type: PostType.image,
        reactionCount: 89,
        commentCount: 22,
        shareCount: 15,
        viewCount: 167,
        hashtags: ['WebAssembly', 'Flutter', 'Performance', 'NativeSpeed'],
        mentions: [],
      ),

      // Post 11: AlistairJr - Post partagé
      PostModel(
        id: 'post_11',
        authorId: 'user_1',
        authorName: 'AlistairJr',
        authorUsername: '@alistairjr',
        authorAvatar: 'assets/images/Avatar1.png',
        isAuthorVerified: true,
        content: 'Excellent article de @juliebernard sur WebAssembly ! 👏\n\nÀ lire absolument si vous voulez booster les performances de vos apps.',
        timestamp: _now.subtract(const Duration(hours: 17)),
        type: PostType.share,
        reactionCount: 23,
        commentCount: 5,
        shareCount: 8,
        viewCount: 78,
        originalPostId: 'post_10',
        hashtags: [],
        mentions: ['juliebernard'],
      ),

      // Post 12: T4zor - Post gaming avec localisation
      PostModel(
        id: 'post_12',
        authorId: 'user_2',
        authorName: 'T4zor',
        authorUsername: '@t4zor',
        authorAvatar: 'assets/images/Avatar2.png',
        content: 'LAN party ce weekend ! 🎮🔥\n\nQui est chaud pour du CS2 et du Valorant ? On a besoin de 2 joueurs de plus !\n\n#Gaming #LANParty #CS2 #Valorant #Weekend',
        timestamp: _now.subtract(const Duration(hours: 20)),
        type: PostType.text,
        reactionCount: 34,
        commentCount: 12,
        shareCount: 6,
        viewCount: 89,
        location: 'Paris Gaming Center',
        hashtags: ['Gaming', 'LANParty', 'CS2', 'Valorant', 'Weekend'],
        mentions: [],
      ),

      // Post 13: Tk-Porky - Post philosophique
      PostModel(
        id: 'post_13',
        authorId: 'user_3',
        authorName: 'Tk-Porky',
        authorUsername: '@tkporky',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        content: '🤔 Réflexion du soir...\n\nPourquoi on dit "debugger" et pas "déboguer" ? 🐛\n\nLa langue française et l\'informatique, tout un programme ! 😅\n\n#Reflexion #Francais #Informatique #Debug #Langue',
        timestamp: _now.subtract(const Duration(hours: 22)),
        type: PostType.text,
        reactionCount: 56,
        commentCount: 18,
        shareCount: 4,
        viewCount: 123,
        hashtags: ['Reflexion', 'Francais', 'Informatique', 'Debug', 'Langue'],
        mentions: [],
      ),

      // Post 14: Sophie Martin - Annonce importante
      PostModel(
        id: 'post_14',
        authorId: 'user_4',
        authorName: 'Sophie Martin',
        authorUsername: '@sophiemartin',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        isAuthorVerified: true,
        content: '📢 ANNONCE IMPORTANTE 📢\n\nNouvelle formation "Flutter Avancé" disponible dès lundi ! 🎓\n\n✅ State Management avec Riverpod\n✅ Architecture Clean\n✅ Tests automatisés\n✅ CI/CD avec GitHub Actions\n\nInscriptions ouvertes ! Lien en bio 👆\n\n#Formation #Flutter #Riverpod #CleanArchitecture #Testing #CICD',
        timestamp: _now.subtract(const Duration(days: 1)),
        type: PostType.text,
        reactionCount: 178,
        commentCount: 34,
        shareCount: 56,
        viewCount: 445,
        isPinned: true,
        hashtags: ['Formation', 'Flutter', 'Riverpod', 'CleanArchitecture', 'Testing', 'CICD'],
        mentions: [],
      ),

      // Post 15: Lucas Dubois - Post technique avec code
      PostModel(
        id: 'post_15',
        authorId: 'user_5',
        authorName: 'Lucas Dubois',
        authorUsername: '@lucasdubois',
        authorAvatar: AvatarHelper.getRandomAvatar(),
        content: 'Astuce SQL du jour ! 💡\n\nUtilisez EXPLAIN ANALYZE pour optimiser vos requêtes :\n\n```sql\nEXPLAIN ANALYZE\nSELECT * FROM users \nWHERE created_at > \'2024-01-01\'\nORDER BY name;\n```\n\nVous verrez exactement où votre requête perd du temps ! ⏱️\n\n#SQL #Optimization #Database #Performance #DevTips',
        timestamp: _now.subtract(const Duration(days: 1, hours: 2)),
        type: PostType.text,
        reactionCount: 67,
        commentCount: 15,
        shareCount: 23,
        viewCount: 134,
        hashtags: ['SQL', 'Optimization', 'Database', 'Performance', 'DevTips'],
        mentions: [],
      ),

      // Ajouter plus de posts pour atteindre 50+...
      // Posts 16-50 avec variations similaires
      ...List.generate(35, (index) {
        final postIndex = index + 16;
        final userIndex = (index % 10) + 1;
        final hoursAgo = 24 + (index * 2);
        
        return PostModel(
          id: 'post_$postIndex',
          authorId: 'user_$userIndex',
          authorName: _getRandomName(userIndex),
          authorUsername: '@${_getRandomUsername(userIndex)}',
          authorAvatar: AvatarHelper.getRandomAvatar(),
          isAuthorVerified: index % 7 == 0, // Quelques utilisateurs vérifiés
          content: _getRandomContent(postIndex),
          imageUrls: index % 3 == 0 ? ['assets/images/test.png'] : null,
          timestamp: _now.subtract(Duration(hours: hoursAgo)),
          type: _getRandomPostType(index),
          reactionCount: 10 + (index % 50),
          commentCount: 2 + (index % 15),
          shareCount: index % 10,
          viewCount: 50 + (index % 200),
          hashtags: _getRandomHashtags(index),
          mentions: index % 5 == 0 ? ['alistairjr'] : [],
        );
      }),
    ];
  }

  /// Génère un nom aléatoire basé sur l'index
  static String _getRandomName(int index) {
    final names = [
      'AlistairJr', 'T4zor', 'Tk-Porky', 'Sophie Martin', 'Lucas Dubois',
      'ProGamer42', 'NinjaKiller', 'Emma Leroy', 'MaxPower', 'Julie Bernard',
    ];
    return names[index % names.length];
  }

  /// Génère un username aléatoire basé sur l'index
  static String _getRandomUsername(int index) {
    final usernames = [
      'alistairjr', 't4zor', 'tkporky', 'sophiemartin', 'lucasdubois',
      'progamer42', 'ninjakiller', 'emmaleroy', 'maxpower', 'juliebernard',
    ];
    return usernames[index % usernames.length];
  }

  /// Génère un contenu aléatoire basé sur l'index
  static String _getRandomContent(int index) {
    final contents = [
      'Nouvelle découverte en programmation ! 🚀',
      'Qui d\'autre galère avec ce bug ? 😅',
      'Excellent article sur l\'architecture logicielle 📚',
      'Weekend coding session ! ⌨️',
      'Astuce du jour pour optimiser votre code 💡',
      'Retour de conférence très inspirant ! 🎤',
      'Nouveau projet en cours de développement 🔧',
      'Débat : quel est le meilleur framework ? 🤔',
      'Tutoriel disponible sur ma chaîne ! 📺',
      'Merci pour tous vos retours positifs ! 🙏',
    ];
    return contents[index % contents.length];
  }

  /// Génère un type de post aléatoire basé sur l'index
  static PostType _getRandomPostType(int index) {
    final types = [PostType.text, PostType.image, PostType.text, PostType.text];
    return types[index % types.length];
  }

  /// Génère des hashtags aléatoires basés sur l'index
  static List<String> _getRandomHashtags(int index) {
    final hashtagSets = [
      ['Flutter', 'Dev'],
      ['Gaming', 'Fun'],
      ['Code', 'Programming'],
      ['Tech', 'Innovation'],
      ['Tutorial', 'Learning'],
    ];
    return hashtagSets[index % hashtagSets.length];
  }
}