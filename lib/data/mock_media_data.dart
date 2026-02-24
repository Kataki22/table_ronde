import '../models/media/media_item.dart';
import '../models/media/media_type.dart';

/// Données mockées pour les médias partagés
/// Contient des médias de tous types pour chaque conversation
class MockMediaData {
  static final DateTime _now = DateTime.now();

  /// Médias organisés par conversation/chat ID
  static final Map<String, List<MediaItem>> mediaByChat = _generateMediaByChat();

  /// Génère des médias pour chaque conversation (groupes et chats 1-to-1)
  static Map<String, List<MediaItem>> _generateMediaByChat() {
    return {
      // Groupe 1: Équipe Dev Flutter - Médias techniques
      'group_1': [
        // Photos
        MediaItem(
          id: 'media_g1_1',
          type: MediaType.photo,
          url: 'assets/images/media/flutter_screenshot_1.png',
          timestamp: _now.subtract(const Duration(days: 5)),
          senderId: 'user_1',
          senderName: 'AlistairJr',
        ),
        MediaItem(
          id: 'media_g1_2',
          type: MediaType.photo,
          url: 'assets/images/media/ui_mockup.png',
          timestamp: _now.subtract(const Duration(days: 4)),
          senderId: 'user_2',
          senderName: 'T4zor',
        ),
        MediaItem(
          id: 'media_g1_3',
          type: MediaType.photo,
          url: 'assets/images/media/code_review.png',
          timestamp: _now.subtract(const Duration(days: 3)),
          senderId: 'user_3',
          senderName: 'Tk-Porky',
        ),
        // Vidéos
        MediaItem(
          id: 'media_g1_4',
          type: MediaType.video,
          url: 'assets/videos/demo_app.mp4',
          thumbnailUrl: 'assets/images/media/demo_thumb.png',
          duration: 145,
          fileSize: 8500000,
          timestamp: _now.subtract(const Duration(days: 2)),
          senderId: 'user_1',
          senderName: 'AlistairJr',
        ),
        MediaItem(
          id: 'media_g1_5',
          type: MediaType.video,
          url: 'assets/videos/tutorial.mp4',
          thumbnailUrl: 'assets/images/media/tutorial_thumb.png',
          duration: 320,
          fileSize: 15200000,
          timestamp: _now.subtract(const Duration(days: 1)),
          senderId: 'user_4',
          senderName: 'Sophie Martin',
        ),
        // Documents
        MediaItem(
          id: 'media_g1_6',
          type: MediaType.document,
          url: 'assets/documents/architecture.pdf',
          fileName: 'architecture_v2.pdf',
          fileSize: 2450000,
          timestamp: _now.subtract(const Duration(days: 7)),
          senderId: 'user_1',
          senderName: 'AlistairJr',
        ),
        MediaItem(
          id: 'media_g1_7',
          type: MediaType.document,
          url: 'assets/documents/api_specs.pdf',
          fileName: 'api_specifications.pdf',
          fileSize: 1850000,
          timestamp: _now.subtract(const Duration(days: 6)),
          senderId: 'user_2',
          senderName: 'T4zor',
        ),
        // Liens
        MediaItem(
          id: 'media_g1_8',
          type: MediaType.link,
          url: 'https://flutter.dev/docs',
          timestamp: _now.subtract(const Duration(days: 8)),
          senderId: 'user_3',
          senderName: 'Tk-Porky',
        ),
        MediaItem(
          id: 'media_g1_9',
          type: MediaType.link,
          url: 'https://pub.dev/packages/provider',
          timestamp: _now.subtract(const Duration(days: 5)),
          senderId: 'user_5',
          senderName: 'Lucas Dubois',
        ),
        // Messages vocaux
        MediaItem(
          id: 'media_g1_10',
          type: MediaType.voice,
          url: 'assets/audio/voice_note_1.m4a',
          duration: 45,
          fileSize: 350000,
          timestamp: _now.subtract(const Duration(hours: 12)),
          senderId: 'user_1',
          senderName: 'AlistairJr',
        ),
      ],

      // Groupe 2: Gaming Squad - Médias gaming
      'group_2': [
        // Photos
        MediaItem(
          id: 'media_g2_1',
          type: MediaType.photo,
          url: 'assets/images/media/game_screenshot_1.png',
          timestamp: _now.subtract(const Duration(days: 3)),
          senderId: 'user_6',
          senderName: 'ProGamer42',
        ),
        MediaItem(
          id: 'media_g2_2',
          type: MediaType.photo,
          url: 'assets/images/media/game_screenshot_2.png',
          timestamp: _now.subtract(const Duration(days: 2)),
          senderId: 'user_7',
          senderName: 'NinjaKiller',
        ),
        MediaItem(
          id: 'media_g2_3',
          type: MediaType.photo,
          url: 'assets/images/media/victory_screen.png',
          timestamp: _now.subtract(const Duration(days: 1)),
          senderId: 'user_8',
          senderName: 'Emma Leroy',
        ),
        MediaItem(
          id: 'media_g2_4',
          type: MediaType.photo,
          url: 'assets/images/media/team_photo.png',
          timestamp: _now.subtract(const Duration(hours: 18)),
          senderId: 'user_9',
          senderName: 'MaxPower',
        ),
        // Vidéos
        MediaItem(
          id: 'media_g2_5',
          type: MediaType.video,
          url: 'assets/videos/gameplay_1.mp4',
          thumbnailUrl: 'assets/images/media/gameplay_thumb_1.png',
          duration: 420,
          fileSize: 25600000,
          timestamp: _now.subtract(const Duration(days: 4)),
          senderId: 'user_6',
          senderName: 'ProGamer42',
        ),
        MediaItem(
          id: 'media_g2_6',
          type: MediaType.video,
          url: 'assets/videos/epic_moment.mp4',
          thumbnailUrl: 'assets/images/media/epic_thumb.png',
          duration: 180,
          fileSize: 12800000,
          timestamp: _now.subtract(const Duration(days: 2)),
          senderId: 'user_7',
          senderName: 'NinjaKiller',
        ),
        // Liens
        MediaItem(
          id: 'media_g2_7',
          type: MediaType.link,
          url: 'https://twitch.tv/progamer42',
          timestamp: _now.subtract(const Duration(days: 5)),
          senderId: 'user_6',
          senderName: 'ProGamer42',
        ),
        MediaItem(
          id: 'media_g2_8',
          type: MediaType.link,
          url: 'https://discord.gg/gamingsquad',
          timestamp: _now.subtract(const Duration(days: 3)),
          senderId: 'user_10',
          senderName: 'Léa Bernard',
        ),
        // Messages vocaux
        MediaItem(
          id: 'media_g2_9',
          type: MediaType.voice,
          url: 'assets/audio/voice_note_2.m4a',
          duration: 28,
          fileSize: 220000,
          timestamp: _now.subtract(const Duration(hours: 6)),
          senderId: 'user_11',
          senderName: 'Thomas Petit',
        ),
        MediaItem(
          id: 'media_g2_10',
          type: MediaType.voice,
          url: 'assets/audio/voice_note_3.m4a',
          duration: 52,
          fileSize: 410000,
          timestamp: _now.subtract(const Duration(hours: 3)),
          senderId: 'user_12',
          senderName: 'Camille Roux',
        ),
      ],

      // Groupe 3: Famille Dupont - Photos de famille
      'group_3': [
        // Photos
        MediaItem(
          id: 'media_g3_1',
          type: MediaType.photo,
          url: 'assets/images/media/family_dinner.png',
          timestamp: _now.subtract(const Duration(days: 7)),
          senderId: 'user_14',
          senderName: 'Papa Jean',
        ),
        MediaItem(
          id: 'media_g3_2',
          type: MediaType.photo,
          url: 'assets/images/media/kids_playing.png',
          timestamp: _now.subtract(const Duration(days: 6)),
          senderId: 'user_15',
          senderName: 'Maman Marie',
        ),
        MediaItem(
          id: 'media_g3_3',
          type: MediaType.photo,
          url: 'assets/images/media/birthday_cake.png',
          timestamp: _now.subtract(const Duration(days: 5)),
          senderId: 'user_16',
          senderName: 'Julie',
        ),
        MediaItem(
          id: 'media_g3_4',
          type: MediaType.photo,
          url: 'assets/images/media/vacation_beach.png',
          timestamp: _now.subtract(const Duration(days: 4)),
          senderId: 'user_17',
          senderName: 'Pierre',
        ),
        MediaItem(
          id: 'media_g3_5',
          type: MediaType.photo,
          url: 'assets/images/media/grandma_garden.png',
          timestamp: _now.subtract(const Duration(days: 3)),
          senderId: 'user_18',
          senderName: 'Grand-mère Louise',
        ),
        // Vidéos
        MediaItem(
          id: 'media_g3_6',
          type: MediaType.video,
          url: 'assets/videos/birthday_party.mp4',
          thumbnailUrl: 'assets/images/media/birthday_thumb.png',
          duration: 240,
          fileSize: 18500000,
          timestamp: _now.subtract(const Duration(days: 5)),
          senderId: 'user_15',
          senderName: 'Maman Marie',
        ),
        MediaItem(
          id: 'media_g3_7',
          type: MediaType.video,
          url: 'assets/videos/kids_dance.mp4',
          thumbnailUrl: 'assets/images/media/dance_thumb.png',
          duration: 95,
          fileSize: 7200000,
          timestamp: _now.subtract(const Duration(days: 2)),
          senderId: 'user_16',
          senderName: 'Julie',
        ),
        // Messages vocaux
        MediaItem(
          id: 'media_g3_8',
          type: MediaType.voice,
          url: 'assets/audio/voice_note_4.m4a',
          duration: 35,
          fileSize: 280000,
          timestamp: _now.subtract(const Duration(hours: 8)),
          senderId: 'user_18',
          senderName: 'Grand-mère Louise',
        ),
      ],

      // Groupe 4: Projet TableRonde - Documents de travail
      'group_4': [
        // Photos
        MediaItem(
          id: 'media_g4_1',
          type: MediaType.photo,
          url: 'assets/images/media/whiteboard_design.png',
          timestamp: _now.subtract(const Duration(days: 10)),
          senderId: 'user_1',
          senderName: 'AlistairJr',
        ),
        MediaItem(
          id: 'media_g4_2',
          type: MediaType.photo,
          url: 'assets/images/media/sprint_board.png',
          timestamp: _now.subtract(const Duration(days: 8)),
          senderId: 'user_20',
          senderName: 'Sarah Chen',
        ),
        // Documents
        MediaItem(
          id: 'media_g4_3',
          type: MediaType.document,
          url: 'assets/documents/project_plan.pdf',
          fileName: 'project_plan_v3.pdf',
          fileSize: 3200000,
          timestamp: _now.subtract(const Duration(days: 15)),
          senderId: 'user_1',
          senderName: 'AlistairJr',
        ),
        MediaItem(
          id: 'media_g4_4',
          type: MediaType.document,
          url: 'assets/documents/requirements.pdf',
          fileName: 'requirements_doc.pdf',
          fileSize: 2800000,
          timestamp: _now.subtract(const Duration(days: 12)),
          senderId: 'user_21',
          senderName: 'Marc Lefebvre',
        ),
        MediaItem(
          id: 'media_g4_5',
          type: MediaType.document,
          url: 'assets/documents/sprint_report.pdf',
          fileName: 'sprint_3_report.pdf',
          fileSize: 1500000,
          timestamp: _now.subtract(const Duration(days: 7)),
          senderId: 'user_22',
          senderName: 'Nadia Benali',
        ),
        MediaItem(
          id: 'media_g4_6',
          type: MediaType.document,
          url: 'assets/documents/budget.xlsx',
          fileName: 'budget_2024.xlsx',
          fileSize: 850000,
          timestamp: _now.subtract(const Duration(days: 5)),
          senderId: 'user_23',
          senderName: 'Antoine Rousseau',
        ),
        // Liens
        MediaItem(
          id: 'media_g4_7',
          type: MediaType.link,
          url: 'https://github.com/tableronde/project',
          timestamp: _now.subtract(const Duration(days: 20)),
          senderId: 'user_1',
          senderName: 'AlistairJr',
        ),
        MediaItem(
          id: 'media_g4_8',
          type: MediaType.link,
          url: 'https://figma.com/tableronde-design',
          timestamp: _now.subtract(const Duration(days: 14)),
          senderId: 'user_20',
          senderName: 'Sarah Chen',
        ),
        MediaItem(
          id: 'media_g4_9',
          type: MediaType.link,
          url: 'https://trello.com/tableronde-board',
          timestamp: _now.subtract(const Duration(days: 10)),
          senderId: 'user_21',
          senderName: 'Marc Lefebvre',
        ),
        // Vidéos
        MediaItem(
          id: 'media_g4_10',
          type: MediaType.video,
          url: 'assets/videos/demo_presentation.mp4',
          thumbnailUrl: 'assets/images/media/demo_pres_thumb.png',
          duration: 600,
          fileSize: 45000000,
          timestamp: _now.subtract(const Duration(days: 3)),
          senderId: 'user_1',
          senderName: 'AlistairJr',
        ),
      ],

      // Groupe 8: Cuisine et Recettes - Photos de plats
      'group_8': [
        // Photos
        MediaItem(
          id: 'media_g8_1',
          type: MediaType.photo,
          url: 'assets/images/media/apple_pie.png',
          timestamp: _now.subtract(const Duration(days: 2)),
          senderId: 'user_52',
          senderName: 'Chef Antoine',
        ),
        MediaItem(
          id: 'media_g8_2',
          type: MediaType.photo,
          url: 'assets/images/media/chocolate_cake.png',
          timestamp: _now.subtract(const Duration(days: 4)),
          senderId: 'user_55',
          senderName: 'Sophie Pâtissière',
        ),
        MediaItem(
          id: 'media_g8_3',
          type: MediaType.photo,
          url: 'assets/images/media/pasta_dish.png',
          timestamp: _now.subtract(const Duration(days: 6)),
          senderId: 'user_54',
          senderName: 'Pierre Gourmet',
        ),
        // Vidéos
        MediaItem(
          id: 'media_g8_4',
          type: MediaType.video,
          url: 'assets/videos/cooking_tutorial.mp4',
          thumbnailUrl: 'assets/images/media/cooking_thumb.png',
          duration: 360,
          fileSize: 22000000,
          timestamp: _now.subtract(const Duration(days: 5)),
          senderId: 'user_52',
          senderName: 'Chef Antoine',
        ),
        // Documents
        MediaItem(
          id: 'media_g8_5',
          type: MediaType.document,
          url: 'assets/documents/recipe_book.pdf',
          fileName: 'recettes_favorites.pdf',
          fileSize: 4500000,
          timestamp: _now.subtract(const Duration(days: 15)),
          senderId: 'user_52',
          senderName: 'Chef Antoine',
        ),
        // Liens
        MediaItem(
          id: 'media_g8_6',
          type: MediaType.link,
          url: 'https://marmiton.org/recette-tarte-pommes',
          timestamp: _now.subtract(const Duration(days: 2)),
          senderId: 'user_55',
          senderName: 'Sophie Pâtissière',
        ),
        // Messages vocaux
        MediaItem(
          id: 'media_g8_7',
          type: MediaType.voice,
          url: 'assets/audio/voice_note_8.m4a',
          duration: 42,
          fileSize: 330000,
          timestamp: _now.subtract(const Duration(hours: 10)),
          senderId: 'user_52',
          senderName: 'Chef Antoine',
        ),
      ],

      // Chat 1-to-1 exemple: conversation avec T4zor
      'chat_user_2': [
        // Photos
        MediaItem(
          id: 'media_c2_1',
          type: MediaType.photo,
          url: 'assets/images/media/screenshot_bug.png',
          timestamp: _now.subtract(const Duration(days: 3)),
          senderId: 'user_2',
          senderName: 'T4zor',
        ),
        MediaItem(
          id: 'media_c2_2',
          type: MediaType.photo,
          url: 'assets/images/media/new_feature.png',
          timestamp: _now.subtract(const Duration(days: 1)),
          senderId: 'user_1',
          senderName: 'AlistairJr',
        ),
        // Documents
        MediaItem(
          id: 'media_c2_3',
          type: MediaType.document,
          url: 'assets/documents/code_review.pdf',
          fileName: 'code_review_notes.pdf',
          fileSize: 950000,
          timestamp: _now.subtract(const Duration(days: 5)),
          senderId: 'user_2',
          senderName: 'T4zor',
        ),
        // Liens
        MediaItem(
          id: 'media_c2_4',
          type: MediaType.link,
          url: 'https://stackoverflow.com/questions/12345',
          timestamp: _now.subtract(const Duration(days: 4)),
          senderId: 'user_2',
          senderName: 'T4zor',
        ),
        // Messages vocaux
        MediaItem(
          id: 'media_c2_5',
          type: MediaType.voice,
          url: 'assets/audio/voice_note_5.m4a',
          duration: 62,
          fileSize: 490000,
          timestamp: _now.subtract(const Duration(hours: 4)),
          senderId: 'user_2',
          senderName: 'T4zor',
        ),
      ],

      // Chat 1-to-1 exemple: conversation avec Tk-Porky
      'chat_user_3': [
        // Photos
        MediaItem(
          id: 'media_c3_1',
          type: MediaType.photo,
          url: 'assets/images/media/meme_funny.png',
          timestamp: _now.subtract(const Duration(days: 2)),
          senderId: 'user_3',
          senderName: 'Tk-Porky',
        ),
        // Vidéos
        MediaItem(
          id: 'media_c3_2',
          type: MediaType.video,
          url: 'assets/videos/funny_clip.mp4',
          thumbnailUrl: 'assets/images/media/funny_thumb.png',
          duration: 45,
          fileSize: 3500000,
          timestamp: _now.subtract(const Duration(days: 1)),
          senderId: 'user_3',
          senderName: 'Tk-Porky',
        ),
        // Messages vocaux
        MediaItem(
          id: 'media_c3_3',
          type: MediaType.voice,
          url: 'assets/audio/voice_note_6.m4a',
          duration: 38,
          fileSize: 300000,
          timestamp: _now.subtract(const Duration(hours: 2)),
          senderId: 'user_1',
          senderName: 'AlistairJr',
        ),
        MediaItem(
          id: 'media_c3_4',
          type: MediaType.voice,
          url: 'assets/audio/voice_note_7.m4a',
          duration: 55,
          fileSize: 435000,
          timestamp: _now.subtract(const Duration(hours: 1)),
          senderId: 'user_3',
          senderName: 'Tk-Porky',
        ),
      ],
    };
  }
}
