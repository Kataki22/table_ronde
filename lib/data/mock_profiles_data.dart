import '../models/profiles/user_profile_model.dart';
import '../models/profiles/user_activity.dart';
import '../models/profiles/user_post.dart';

/// Données mockées pour les profils utilisateurs
/// Contient 25 profils complets avec activités et posts
class MockProfilesData {
  static final DateTime _now = DateTime.now();

  /// Map des profils utilisateurs par ID
  static final Map<String, UserProfileModel> profiles = _generateProfiles();

  /// Génère 25 profils utilisateurs complets
  static Map<String, UserProfileModel> _generateProfiles() {
    final profilesList = [
      // Profil 1: AlistairJr - Développeur Flutter
      UserProfileModel(
        id: 'user_1',
        name: 'AlistairJr',
        username: '@alistairjr',
        bio: 'Développeur Flutter passionné 🚀 | Lead dev chez TableRonde | Amateur de café ☕',
        phone: '+33 6 12 34 56 78',
        avatarUrl: 'assets/images/Avatar1.png',
        createdAt: _now.subtract(const Duration(days: 365)),
        isOnline: true,
        currentActivity: 'En train de coder',
        recentActivities: [
          UserActivity(
            id: 'activity_1_1',
            type: 'post',
            description: 'A publié un nouveau post sur Flutter 3.0',
            timestamp: _now.subtract(const Duration(hours: 2)),
          ),
          UserActivity(
            id: 'activity_1_2',
            type: 'comment',
            description: 'A commenté le post de T4zor',
            timestamp: _now.subtract(const Duration(hours: 5)),
          ),
          UserActivity(
            id: 'activity_1_3',
            type: 'like',
            description: 'A aimé le post de Tk-Porky',
            timestamp: _now.subtract(const Duration(hours: 8)),
          ),
          UserActivity(
            id: 'activity_1_4',
            type: 'join_group',
            description: 'A rejoint le groupe "Équipe Dev Flutter"',
            timestamp: _now.subtract(const Duration(days: 90)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_1_1',
            content: 'Nouveau widget personnalisé pour TableRonde ! 🎉 Après plusieurs jours de développement, je suis fier de présenter notre nouveau système de chat avec support des groupes.',
            imageUrls: [
              'assets/images/posts/flutter_widget.png',
              'assets/images/posts/code_screenshot.png',
            ],
            likesCount: 45,
            commentsCount: 12,
            createdAt: _now.subtract(const Duration(hours: 2)),
          ),
          UserPost(
            id: 'post_1_2',
            content: 'Tips du jour : Utilisez Provider pour une gestion d\'état propre et efficace. Voici un exemple concret de notre architecture.',
            imageUrls: ['assets/images/posts/provider_diagram.png'],
            likesCount: 78,
            commentsCount: 23,
            createdAt: _now.subtract(const Duration(days: 3)),
          ),
          UserPost(
            id: 'post_1_3',
            content: 'Journée productive ! ✅ Implémentation des profils utilisateurs, ✅ Tests unitaires, ✅ Documentation. Prêt pour la review demain.',
            imageUrls: [],
            likesCount: 34,
            commentsCount: 8,
            createdAt: _now.subtract(const Duration(days: 7)),
          ),
        ],
      ),

      // Profil 2: T4zor - Designer UI/UX
      UserProfileModel(
        id: 'user_2',
        name: 'T4zor',
        username: '@t4zor',
        bio: 'UI/UX Designer | Créateur d\'expériences digitales | Fan de design minimaliste 🎨',
        phone: '+33 6 23 45 67 89',
        avatarUrl: 'assets/images/Avatar2.png',
        createdAt: _now.subtract(const Duration(days: 320)),
        isOnline: true,
        currentActivity: 'En réunion',
        recentActivities: [
          UserActivity(
            id: 'activity_2_1',
            type: 'post',
            description: 'A partagé un nouveau design pour l\'interface',
            timestamp: _now.subtract(const Duration(hours: 1)),
          ),
          UserActivity(
            id: 'activity_2_2',
            type: 'like',
            description: 'A aimé le post de AlistairJr',
            timestamp: _now.subtract(const Duration(hours: 3)),
          ),
          UserActivity(
            id: 'activity_2_3',
            type: 'comment',
            description: 'A commenté sur le design system',
            timestamp: _now.subtract(const Duration(hours: 6)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_2_1',
            content: 'Nouveau design system pour TableRonde ! 🎨 Palette de couleurs inspirée de Discord et Telegram, avec une touche moderne.',
            imageUrls: [
              'assets/images/posts/design_system.png',
              'assets/images/posts/color_palette.png',
              'assets/images/posts/typography.png',
            ],
            likesCount: 92,
            commentsCount: 28,
            createdAt: _now.subtract(const Duration(hours: 1)),
          ),
          UserPost(
            id: 'post_2_2',
            content: 'Prototype interactif des profils utilisateurs. Qu\'en pensez-vous ? Feedback bienvenu ! 💬',
            imageUrls: ['assets/images/posts/profile_prototype.png'],
            likesCount: 67,
            commentsCount: 19,
            createdAt: _now.subtract(const Duration(days: 2)),
          ),
        ],
      ),

      // Profil 3: Tk-Porky - Développeur Backend
      UserProfileModel(
        id: 'user_3',
        name: 'Tk-Porky',
        username: '@tkporky',
        bio: 'Backend Developer | Node.js & Firebase expert | Coffee addict ☕',
        phone: '+33 6 34 56 78 90',
        avatarUrl: 'assets/images/Avatar3.png',
        createdAt: _now.subtract(const Duration(days: 280)),
        isOnline: false,
        currentActivity: null,
        recentActivities: [
          UserActivity(
            id: 'activity_3_1',
            type: 'post',
            description: 'A publié sur l\'architecture backend',
            timestamp: _now.subtract(const Duration(hours: 12)),
          ),
          UserActivity(
            id: 'activity_3_2',
            type: 'join_group',
            description: 'A rejoint le groupe "Projet TableRonde"',
            timestamp: _now.subtract(const Duration(days: 1)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_3_1',
            content: 'Migration vers Firebase Cloud Functions v2 terminée ! 🚀 Performance améliorée de 40%.',
            imageUrls: ['assets/images/posts/firebase_stats.png'],
            likesCount: 56,
            commentsCount: 15,
            createdAt: _now.subtract(const Duration(hours: 12)),
          ),
          UserPost(
            id: 'post_3_2',
            content: 'Architecture microservices pour TableRonde. Scalabilité et résilience au rendez-vous.',
            imageUrls: [],
            likesCount: 43,
            commentsCount: 11,
            createdAt: _now.subtract(const Duration(days: 5)),
          ),
        ],
      ),

      // Profil 4: Sophie Martin - Product Manager
      UserProfileModel(
        id: 'user_4',
        name: 'Sophie Martin',
        username: '@sophiemartin',
        bio: 'Product Manager @ TableRonde | Passionnée par l\'innovation | Marathon runner 🏃‍♀️',
        phone: '+33 6 45 67 89 01',
        avatarUrl: 'assets/images/Avatar4.png',
        createdAt: _now.subtract(const Duration(days: 400)),
        isOnline: true,
        currentActivity: 'En appel',
        recentActivities: [
          UserActivity(
            id: 'activity_4_1',
            type: 'post',
            description: 'A partagé la roadmap Q2',
            timestamp: _now.subtract(const Duration(hours: 4)),
          ),
          UserActivity(
            id: 'activity_4_2',
            type: 'comment',
            description: 'A commenté sur les nouvelles features',
            timestamp: _now.subtract(const Duration(hours: 7)),
          ),
          UserActivity(
            id: 'activity_4_3',
            type: 'like',
            description: 'A aimé plusieurs posts de l\'équipe',
            timestamp: _now.subtract(const Duration(hours: 10)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_4_1',
            content: 'Roadmap Q2 2024 pour TableRonde ! 🎯 Nouvelles fonctionnalités sociales, amélioration des performances, et bien plus encore.',
            imageUrls: ['assets/images/posts/roadmap_q2.png'],
            likesCount: 103,
            commentsCount: 34,
            createdAt: _now.subtract(const Duration(hours: 4)),
          ),
          UserPost(
            id: 'post_4_2',
            content: 'Merci à toute l\'équipe pour cette release incroyable ! 🎉 Vous êtes les meilleurs !',
            imageUrls: [],
            likesCount: 87,
            commentsCount: 21,
            createdAt: _now.subtract(const Duration(days: 1)),
          ),
        ],
      ),

      // Profil 5: Lucas Dubois - QA Engineer
      UserProfileModel(
        id: 'user_5',
        name: 'Lucas Dubois',
        username: '@lucasdubois',
        bio: 'QA Engineer | Bug hunter 🐛 | Automation enthusiast | Gamer 🎮',
        phone: '+33 6 56 78 90 12',
        avatarUrl: 'assets/images/Avatar5.png',
        createdAt: _now.subtract(const Duration(days: 250)),
        isOnline: false,
        currentActivity: null,
        recentActivities: [
          UserActivity(
            id: 'activity_5_1',
            type: 'post',
            description: 'A rapporté un bug critique',
            timestamp: _now.subtract(const Duration(hours: 6)),
          ),
          UserActivity(
            id: 'activity_5_2',
            type: 'comment',
            description: 'A commenté sur les tests automatisés',
            timestamp: _now.subtract(const Duration(hours: 9)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_5_1',
            content: 'Nouveau framework de tests automatisés en place ! 🤖 Coverage à 85% et counting.',
            imageUrls: ['assets/images/posts/test_coverage.png'],
            likesCount: 61,
            commentsCount: 17,
            createdAt: _now.subtract(const Duration(hours: 6)),
          ),
        ],
      ),

      // Profil 6: ProGamer42 - Streamer
      UserProfileModel(
        id: 'user_6',
        name: 'ProGamer42',
        username: '@progamer42',
        bio: 'Pro Gamer & Streamer 🎮 | FPS specialist | Twitch Partner',
        phone: '+33 6 67 89 01 23',
        avatarUrl: 'assets/images/Avatar6.png',
        createdAt: _now.subtract(const Duration(days: 450)),
        isOnline: true,
        currentActivity: 'En stream',
        recentActivities: [
          UserActivity(
            id: 'activity_6_1',
            type: 'post',
            description: 'A partagé un clip de son dernier stream',
            timestamp: _now.subtract(const Duration(minutes: 30)),
          ),
          UserActivity(
            id: 'activity_6_2',
            type: 'join_group',
            description: 'A rejoint le groupe "Gaming Squad"',
            timestamp: _now.subtract(const Duration(days: 120)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_6_1',
            content: 'Clutch incroyable hier soir ! 🔥 1v5 et on remporte la manche. Merci pour le support !',
            imageUrls: ['assets/images/posts/gaming_clutch.png'],
            likesCount: 234,
            commentsCount: 67,
            createdAt: _now.subtract(const Duration(minutes: 30)),
          ),
          UserPost(
            id: 'post_6_2',
            content: 'Stream ce soir à 20h ! On va tryhard le ranked. Venez nombreux ! 🎮',
            imageUrls: [],
            likesCount: 156,
            commentsCount: 42,
            createdAt: _now.subtract(const Duration(days: 1)),
          ),
        ],
      ),

      // Profil 7: NinjaKiller - Gamer
      UserProfileModel(
        id: 'user_7',
        name: 'NinjaKiller',
        username: '@ninjakiller',
        bio: 'Competitive gamer | Team captain | Ninja main 🥷',
        phone: '+33 6 78 90 12 34',
        avatarUrl: 'assets/images/Avatar7.png',
        createdAt: _now.subtract(const Duration(days: 380)),
        isOnline: true,
        currentActivity: 'En partie',
        recentActivities: [
          UserActivity(
            id: 'activity_7_1',
            type: 'post',
            description: 'A publié les résultats du tournoi',
            timestamp: _now.subtract(const Duration(hours: 3)),
          ),
          UserActivity(
            id: 'activity_7_2',
            type: 'like',
            description: 'A aimé le post de ProGamer42',
            timestamp: _now.subtract(const Duration(hours: 5)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_7_1',
            content: 'On a gagné le tournoi ! 🏆 Merci à toute l\'équipe pour cette performance incroyable.',
            imageUrls: ['assets/images/posts/tournament_win.png'],
            likesCount: 189,
            commentsCount: 54,
            createdAt: _now.subtract(const Duration(hours: 3)),
          ),
        ],
      ),

      // Profil 8: Emma Leroy - Graphiste
      UserProfileModel(
        id: 'user_8',
        name: 'Emma Leroy',
        username: '@emmaleroy',
        bio: 'Graphic Designer | Illustratrice freelance | Cat lover 🐱',
        phone: '+33 6 89 01 23 45',
        avatarUrl: 'assets/images/Avatar8.png',
        createdAt: _now.subtract(const Duration(days: 290)),
        isOnline: false,
        currentActivity: null,
        recentActivities: [
          UserActivity(
            id: 'activity_8_1',
            type: 'post',
            description: 'A partagé une nouvelle illustration',
            timestamp: _now.subtract(const Duration(hours: 8)),
          ),
          UserActivity(
            id: 'activity_8_2',
            type: 'comment',
            description: 'A commenté sur le design de T4zor',
            timestamp: _now.subtract(const Duration(hours: 12)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_8_1',
            content: 'Nouvelle illustration pour un client ! 🎨 Thème fantasy avec des dragons.',
            imageUrls: [
              'assets/images/posts/illustration_dragon.png',
              'assets/images/posts/illustration_sketch.png',
            ],
            likesCount: 145,
            commentsCount: 38,
            createdAt: _now.subtract(const Duration(hours: 8)),
          ),
          UserPost(
            id: 'post_8_2',
            content: 'Commission ouverte ! Si vous cherchez un illustrateur, n\'hésitez pas à me contacter.',
            imageUrls: [],
            likesCount: 78,
            commentsCount: 23,
            createdAt: _now.subtract(const Duration(days: 4)),
          ),
        ],
      ),

      // Profil 9: MaxPower - Fitness Coach
      UserProfileModel(
        id: 'user_9',
        name: 'MaxPower',
        username: '@maxpower',
        bio: 'Personal Trainer | Nutrition coach | Transformation specialist 💪',
        phone: '+33 6 90 12 34 56',
        avatarUrl: 'assets/images/Avatar9.png',
        createdAt: _now.subtract(const Duration(days: 340)),
        isOnline: true,
        currentActivity: 'À la salle',
        recentActivities: [
          UserActivity(
            id: 'activity_9_1',
            type: 'post',
            description: 'A partagé un programme d\'entraînement',
            timestamp: _now.subtract(const Duration(hours: 5)),
          ),
          UserActivity(
            id: 'activity_9_2',
            type: 'like',
            description: 'A aimé plusieurs posts fitness',
            timestamp: _now.subtract(const Duration(hours: 7)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_9_1',
            content: 'Programme full body pour débutants ! 🏋️ 3 séances par semaine suffisent pour commencer.',
            imageUrls: ['assets/images/posts/workout_program.png'],
            likesCount: 201,
            commentsCount: 56,
            createdAt: _now.subtract(const Duration(hours: 5)),
          ),
          UserPost(
            id: 'post_9_2',
            content: 'Transformation de mon client après 3 mois ! Bravo à lui pour sa détermination 💪',
            imageUrls: ['assets/images/posts/transformation.png'],
            likesCount: 312,
            commentsCount: 89,
            createdAt: _now.subtract(const Duration(days: 2)),
          ),
        ],
      ),

      // Profil 10: Léa Bernard - Photographe
      UserProfileModel(
        id: 'user_10',
        name: 'Léa Bernard',
        username: '@leabernard',
        bio: 'Photographe professionnelle 📷 | Spécialiste portrait & paysage | Voyageuse',
        phone: '+33 6 01 23 45 67',
        avatarUrl: 'assets/images/Avatar10.png',
        createdAt: _now.subtract(const Duration(days: 420)),
        isOnline: false,
        currentActivity: null,
        recentActivities: [
          UserActivity(
            id: 'activity_10_1',
            type: 'post',
            description: 'A partagé des photos de son dernier shooting',
            timestamp: _now.subtract(const Duration(hours: 10)),
          ),
          UserActivity(
            id: 'activity_10_2',
            type: 'join_group',
            description: 'A rejoint le groupe "Photographie"',
            timestamp: _now.subtract(const Duration(days: 50)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_10_1',
            content: 'Shooting au coucher du soleil hier 🌅 La lumière était parfaite !',
            imageUrls: [
              'assets/images/posts/sunset_photo1.png',
              'assets/images/posts/sunset_photo2.png',
              'assets/images/posts/sunset_photo3.png',
            ],
            likesCount: 267,
            commentsCount: 72,
            createdAt: _now.subtract(const Duration(hours: 10)),
          ),
        ],
      ),

      // Profil 11: Thomas Petit - Musicien
      UserProfileModel(
        id: 'user_11',
        name: 'Thomas Petit',
        username: '@thomaspetit',
        bio: 'Musicien | Guitariste | Compositeur 🎸 | Rock & Blues',
        phone: '+33 6 12 34 56 78',
        avatarUrl: 'assets/images/Avatar11.png',
        createdAt: _now.subtract(const Duration(days: 310)),
        isOnline: true,
        currentActivity: 'En répétition',
        recentActivities: [
          UserActivity(
            id: 'activity_11_1',
            type: 'post',
            description: 'A partagé un extrait de sa nouvelle composition',
            timestamp: _now.subtract(const Duration(hours: 4)),
          ),
          UserActivity(
            id: 'activity_11_2',
            type: 'comment',
            description: 'A commenté sur la musique',
            timestamp: _now.subtract(const Duration(hours: 8)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_11_1',
            content: 'Nouvelle compo en cours ! 🎸 Voici un petit extrait. Qu\'en pensez-vous ?',
            imageUrls: [],
            likesCount: 134,
            commentsCount: 41,
            createdAt: _now.subtract(const Duration(hours: 4)),
          ),
          UserPost(
            id: 'post_11_2',
            content: 'Concert ce weekend au Zénith ! Venez nombreux, ça va être énorme 🔥',
            imageUrls: ['assets/images/posts/concert_poster.png'],
            likesCount: 198,
            commentsCount: 67,
            createdAt: _now.subtract(const Duration(days: 3)),
          ),
        ],
      ),

      // Profil 12: Camille Roux - Chef Cuisinière
      UserProfileModel(
        id: 'user_12',
        name: 'Camille Roux',
        username: '@camilleroux',
        bio: 'Chef cuisinière 👨‍🍳 | Cuisine française | Food blogger',
        phone: '+33 6 23 45 67 89',
        avatarUrl: 'assets/images/Avatar12.png',
        createdAt: _now.subtract(const Duration(days: 270)),
        isOnline: true,
        currentActivity: 'En cuisine',
        recentActivities: [
          UserActivity(
            id: 'activity_12_1',
            type: 'post',
            description: 'A partagé une nouvelle recette',
            timestamp: _now.subtract(const Duration(hours: 2)),
          ),
          UserActivity(
            id: 'activity_12_2',
            type: 'join_group',
            description: 'A rejoint le groupe "Cuisine et Recettes"',
            timestamp: _now.subtract(const Duration(days: 150)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_12_1',
            content: 'Recette du jour : Boeuf Bourguignon traditionnel ! 🍷 Parfait pour l\'hiver.',
            imageUrls: [
              'assets/images/posts/boeuf_bourguignon.png',
              'assets/images/posts/recipe_steps.png',
            ],
            likesCount: 223,
            commentsCount: 78,
            createdAt: _now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),

      // Profil 13: Hugo Moreau - Étudiant
      UserProfileModel(
        id: 'user_13',
        name: 'Hugo Moreau',
        username: '@hugomoreau',
        bio: 'Étudiant en informatique 💻 | Passionné de tech | Gamer à mes heures perdues',
        phone: '+33 6 34 56 78 90',
        avatarUrl: 'assets/images/Avatar13.png',
        createdAt: _now.subtract(const Duration(days: 180)),
        isOnline: false,
        currentActivity: null,
        recentActivities: [
          UserActivity(
            id: 'activity_13_1',
            type: 'post',
            description: 'A partagé son projet de fin d\'études',
            timestamp: _now.subtract(const Duration(hours: 15)),
          ),
          UserActivity(
            id: 'activity_13_2',
            type: 'like',
            description: 'A aimé plusieurs posts tech',
            timestamp: _now.subtract(const Duration(hours: 18)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_13_1',
            content: 'Projet de fin d\'études terminé ! 🎓 Application mobile de gestion de tâches avec IA.',
            imageUrls: ['assets/images/posts/student_project.png'],
            likesCount: 89,
            commentsCount: 24,
            createdAt: _now.subtract(const Duration(hours: 15)),
          ),
        ],
      ),

      // Profil 14: Papa Jean - Père de famille
      UserProfileModel(
        id: 'user_14',
        name: 'Papa Jean',
        username: '@papajean',
        bio: 'Père de famille | Bricoleur du dimanche 🔨 | Fan de jardinage',
        phone: '+33 6 45 67 89 01',
        avatarUrl: 'assets/images/Avatar14.png',
        createdAt: _now.subtract(const Duration(days: 500)),
        isOnline: true,
        currentActivity: 'Au jardin',
        recentActivities: [
          UserActivity(
            id: 'activity_14_1',
            type: 'post',
            description: 'A partagé des photos de son jardin',
            timestamp: _now.subtract(const Duration(hours: 6)),
          ),
          UserActivity(
            id: 'activity_14_2',
            type: 'comment',
            description: 'A commenté dans le groupe famille',
            timestamp: _now.subtract(const Duration(hours: 12)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_14_1',
            content: 'Les tomates du jardin sont magnifiques cette année ! 🍅 Récolte abondante.',
            imageUrls: ['assets/images/posts/garden_tomatoes.png'],
            likesCount: 67,
            commentsCount: 19,
            createdAt: _now.subtract(const Duration(hours: 6)),
          ),
        ],
      ),

      // Profil 15: Maman Marie - Mère de famille
      UserProfileModel(
        id: 'user_15',
        name: 'Maman Marie',
        username: '@mamanmarie',
        bio: 'Maman de 2 enfants | Professeure | Amatrice de lecture 📚',
        phone: '+33 6 56 78 90 12',
        avatarUrl: 'assets/images/Avatar15.png',
        createdAt: _now.subtract(const Duration(days: 500)),
        isOnline: true,
        currentActivity: 'En lecture',
        recentActivities: [
          UserActivity(
            id: 'activity_15_1',
            type: 'post',
            description: 'A recommandé un livre',
            timestamp: _now.subtract(const Duration(hours: 9)),
          ),
          UserActivity(
            id: 'activity_15_2',
            type: 'join_group',
            description: 'A rejoint le groupe "Lecture et Livres"',
            timestamp: _now.subtract(const Duration(days: 300)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_15_1',
            content: 'Coup de cœur pour ce roman ! 📖 Une histoire captivante du début à la fin.',
            imageUrls: ['assets/images/posts/book_cover.png'],
            likesCount: 54,
            commentsCount: 16,
            createdAt: _now.subtract(const Duration(hours: 9)),
          ),
        ],
      ),

      // Profil 16: Julie - Étudiante en médecine
      UserProfileModel(
        id: 'user_16',
        name: 'Julie',
        username: '@julie_med',
        bio: 'Étudiante en médecine 🩺 | Future pédiatre | Yoga enthusiast',
        phone: '+33 6 67 89 01 23',
        avatarUrl: 'assets/images/Avatar16.png',
        createdAt: _now.subtract(const Duration(days: 400)),
        isOnline: false,
        currentActivity: null,
        recentActivities: [
          UserActivity(
            id: 'activity_16_1',
            type: 'post',
            description: 'A partagé ses révisions',
            timestamp: _now.subtract(const Duration(hours: 14)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_16_1',
            content: 'Semaine d\'examens intense ! 📚 Mais je garde le moral. Presque fini !',
            imageUrls: [],
            likesCount: 78,
            commentsCount: 23,
            createdAt: _now.subtract(const Duration(hours: 14)),
          ),
        ],
      ),

      // Profil 17: Pierre - Ingénieur
      UserProfileModel(
        id: 'user_17',
        name: 'Pierre',
        username: '@pierre_eng',
        bio: 'Ingénieur mécanique | Passionné d\'automobile 🏎️ | DIY lover',
        phone: '+33 6 78 90 12 34',
        avatarUrl: 'assets/images/Avatar17.png',
        createdAt: _now.subtract(const Duration(days: 380)),
        isOnline: true,
        currentActivity: 'Au garage',
        recentActivities: [
          UserActivity(
            id: 'activity_17_1',
            type: 'post',
            description: 'A partagé son projet de restauration',
            timestamp: _now.subtract(const Duration(hours: 7)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_17_1',
            content: 'Restauration de ma vieille Renault 5 ! 🚗 Projet de longue haleine mais tellement satisfaisant.',
            imageUrls: [
              'assets/images/posts/car_restoration1.png',
              'assets/images/posts/car_restoration2.png',
            ],
            likesCount: 145,
            commentsCount: 42,
            createdAt: _now.subtract(const Duration(hours: 7)),
          ),
        ],
      ),

      // Profil 18: Grand-mère Louise - Retraitée
      UserProfileModel(
        id: 'user_18',
        name: 'Grand-mère Louise',
        username: '@mamielouise',
        bio: 'Mamie moderne 👵 | Tricot & pâtisserie | Toujours connectée avec mes petits-enfants',
        phone: '+33 6 89 01 23 45',
        avatarUrl: 'assets/images/Avatar18.png',
        createdAt: _now.subtract(const Duration(days: 350)),
        isOnline: true,
        currentActivity: 'En train de tricoter',
        recentActivities: [
          UserActivity(
            id: 'activity_18_1',
            type: 'post',
            description: 'A partagé une recette de gâteau',
            timestamp: _now.subtract(const Duration(hours: 11)),
          ),
          UserActivity(
            id: 'activity_18_2',
            type: 'comment',
            description: 'A commenté dans le groupe famille',
            timestamp: _now.subtract(const Duration(hours: 16)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_18_1',
            content: 'Ma recette secrète de tarte aux pommes ! 🥧 Transmise de génération en génération.',
            imageUrls: ['assets/images/posts/apple_pie.png'],
            likesCount: 112,
            commentsCount: 34,
            createdAt: _now.subtract(const Duration(hours: 11)),
          ),
        ],
      ),

      // Profil 19: Oncle Paul - Voyageur
      UserProfileModel(
        id: 'user_19',
        name: 'Oncle Paul',
        username: '@onclepaul',
        bio: 'Voyageur dans l\'âme ✈️ | Photographe amateur | Collectionneur de souvenirs',
        phone: '+33 6 90 12 34 56',
        avatarUrl: 'assets/images/Avatar19.png',
        createdAt: _now.subtract(const Duration(days: 320)),
        isOnline: false,
        currentActivity: null,
        recentActivities: [
          UserActivity(
            id: 'activity_19_1',
            type: 'post',
            description: 'A partagé des photos de voyage',
            timestamp: _now.subtract(const Duration(days: 1)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_19_1',
            content: 'Retour d\'Islande ! 🇮🇸 Paysages à couper le souffle. Voici quelques photos.',
            imageUrls: [
              'assets/images/posts/iceland1.png',
              'assets/images/posts/iceland2.png',
              'assets/images/posts/iceland3.png',
            ],
            likesCount: 189,
            commentsCount: 56,
            createdAt: _now.subtract(const Duration(days: 1)),
          ),
        ],
      ),

      // Profil 20: Sarah Chen - Data Scientist
      UserProfileModel(
        id: 'user_20',
        name: 'Sarah Chen',
        username: '@sarahchen',
        bio: 'Data Scientist | ML Engineer | Python lover 🐍 | Coffee addict',
        phone: '+33 6 01 23 45 67',
        avatarUrl: 'assets/images/Avatar20.png',
        createdAt: _now.subtract(const Duration(days: 280)),
        isOnline: true,
        currentActivity: 'En analyse',
        recentActivities: [
          UserActivity(
            id: 'activity_20_1',
            type: 'post',
            description: 'A partagé un article sur le ML',
            timestamp: _now.subtract(const Duration(hours: 3)),
          ),
          UserActivity(
            id: 'activity_20_2',
            type: 'join_group',
            description: 'A rejoint le groupe "Projet TableRonde"',
            timestamp: _now.subtract(const Duration(days: 180)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_20_1',
            content: 'Nouveau modèle de ML pour la prédiction des tendances ! 📊 Accuracy de 94%.',
            imageUrls: ['assets/images/posts/ml_model.png'],
            likesCount: 167,
            commentsCount: 48,
            createdAt: _now.subtract(const Duration(hours: 3)),
          ),
        ],
      ),

      // Profil 21: Marc Lefebvre - DevOps Engineer
      UserProfileModel(
        id: 'user_21',
        name: 'Marc Lefebvre',
        username: '@marclefebvre',
        bio: 'DevOps Engineer | Kubernetes expert | CI/CD enthusiast 🚀',
        phone: '+33 6 12 34 56 78',
        avatarUrl: 'assets/images/Avatar21.png',
        createdAt: _now.subtract(const Duration(days: 260)),
        isOnline: true,
        currentActivity: 'En déploiement',
        recentActivities: [
          UserActivity(
            id: 'activity_21_1',
            type: 'post',
            description: 'A partagé une architecture cloud',
            timestamp: _now.subtract(const Duration(hours: 5)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_21_1',
            content: 'Migration vers Kubernetes terminée ! ☸️ Scalabilité automatique en place.',
            imageUrls: ['assets/images/posts/k8s_architecture.png'],
            likesCount: 134,
            commentsCount: 39,
            createdAt: _now.subtract(const Duration(hours: 5)),
          ),
        ],
      ),

      // Profil 22: Nadia Benali - UX Researcher
      UserProfileModel(
        id: 'user_22',
        name: 'Nadia Benali',
        username: '@nadiabenali',
        bio: 'UX Researcher | User advocate | Data-driven design 📊',
        phone: '+33 6 23 45 67 89',
        avatarUrl: 'assets/images/Avatar22.png',
        createdAt: _now.subtract(const Duration(days: 240)),
        isOnline: false,
        currentActivity: null,
        recentActivities: [
          UserActivity(
            id: 'activity_22_1',
            type: 'post',
            description: 'A partagé les résultats d\'une étude utilisateur',
            timestamp: _now.subtract(const Duration(hours: 8)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_22_1',
            content: 'Résultats de notre dernière étude UX ! 📈 Insights fascinants sur le comportement utilisateur.',
            imageUrls: ['assets/images/posts/ux_research.png'],
            likesCount: 98,
            commentsCount: 27,
            createdAt: _now.subtract(const Duration(hours: 8)),
          ),
        ],
      ),

      // Profil 23: Antoine Rousseau - Mobile Developer
      UserProfileModel(
        id: 'user_23',
        name: 'Antoine Rousseau',
        username: '@antoinerousseau',
        bio: 'Mobile Developer | iOS & Android | Swift & Kotlin 📱',
        phone: '+33 6 34 56 78 90',
        avatarUrl: 'assets/images/Avatar23.png',
        createdAt: _now.subtract(const Duration(days: 220)),
        isOnline: true,
        currentActivity: 'En code review',
        recentActivities: [
          UserActivity(
            id: 'activity_23_1',
            type: 'post',
            description: 'A partagé un tip sur Swift',
            timestamp: _now.subtract(const Duration(hours: 6)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_23_1',
            content: 'Astuce Swift du jour : Utilisez @Published pour une réactivité optimale ! 💡',
            imageUrls: [],
            likesCount: 87,
            commentsCount: 22,
            createdAt: _now.subtract(const Duration(hours: 6)),
          ),
        ],
      ),

      // Profil 24: Isabelle Garnier - Content Manager
      UserProfileModel(
        id: 'user_24',
        name: 'Isabelle Garnier',
        username: '@isabellegarnier',
        bio: 'Content Manager | Storyteller | SEO specialist ✍️',
        phone: '+33 6 45 67 89 01',
        avatarUrl: 'assets/images/Avatar24.png',
        createdAt: _now.subtract(const Duration(days: 200)),
        isOnline: true,
        currentActivity: 'En rédaction',
        recentActivities: [
          UserActivity(
            id: 'activity_24_1',
            type: 'post',
            description: 'A publié un article de blog',
            timestamp: _now.subtract(const Duration(hours: 4)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_24_1',
            content: 'Nouvel article sur notre blog ! 📝 Les tendances du design mobile en 2024.',
            imageUrls: ['assets/images/posts/blog_article.png'],
            likesCount: 123,
            commentsCount: 35,
            createdAt: _now.subtract(const Duration(hours: 4)),
          ),
        ],
      ),

      // Profil 25: Kevin Blanc - Security Engineer
      UserProfileModel(
        id: 'user_25',
        name: 'Kevin Blanc',
        username: '@kevinblanc',
        bio: 'Security Engineer | Ethical hacker | Cybersecurity advocate 🔒',
        phone: '+33 6 56 78 90 12',
        avatarUrl: 'assets/images/Avatar25.png',
        createdAt: _now.subtract(const Duration(days: 190)),
        isOnline: false,
        currentActivity: null,
        recentActivities: [
          UserActivity(
            id: 'activity_25_1',
            type: 'post',
            description: 'A partagé des conseils de sécurité',
            timestamp: _now.subtract(const Duration(hours: 12)),
          ),
        ],
        posts: [
          UserPost(
            id: 'post_25_1',
            content: 'Top 5 des bonnes pratiques de sécurité pour vos apps ! 🔐 Thread important.',
            imageUrls: [],
            likesCount: 156,
            commentsCount: 44,
            createdAt: _now.subtract(const Duration(hours: 12)),
          ),
        ],
      ),
    ];

    // Convertir la liste en Map avec l'ID comme clé
    return {for (var profile in profilesList) profile.id: profile};
  }

  /// Récupère un profil par son ID
  static UserProfileModel? getProfile(String userId) {
    return profiles[userId];
  }

  /// Récupère tous les profils sous forme de liste
  static List<UserProfileModel> getAllProfiles() {
    return profiles.values.toList();
  }

  /// Récupère les activités d'un utilisateur
  static List<UserActivity> getUserActivities(String userId) {
    return profiles[userId]?.recentActivities ?? [];
  }

  /// Récupère les posts d'un utilisateur
  static List<UserPost> getUserPosts(String userId) {
    return profiles[userId]?.posts ?? [];
  }

  /// Récupère les profils en ligne
  static List<UserProfileModel> getOnlineProfiles() {
    return profiles.values.where((profile) => profile.isOnline).toList();
  }

  /// Récupère les profils par activité récente
  static List<UserProfileModel> getProfilesByRecentActivity() {
    final profilesList = profiles.values.toList();
    profilesList.sort((a, b) {
      final aLatest = a.recentActivities.isNotEmpty
          ? a.recentActivities.first.timestamp
          : a.createdAt;
      final bLatest = b.recentActivities.isNotEmpty
          ? b.recentActivities.first.timestamp
          : b.createdAt;
      return bLatest.compareTo(aLatest);
    });
    return profilesList;
  }
}
