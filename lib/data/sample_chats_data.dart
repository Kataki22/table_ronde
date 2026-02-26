import 'package:tableronde_app/models/chat_model.dart';
import '../utils/avatar_helper.dart';

/// Service pour fournir des conversations pré-enregistrées
class SampleChatsData {
  /// Retourne la liste de conversations d'exemple
  static List<ChatModel> getSampleChats() {
    final now = DateTime.now();

    return [
      ChatModel(
        id: '1',
        name: 'T4zor',
        lastMessage: 'Il me dit f*ck you mdr.',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        avatarUrl: AvatarHelper.getAvatarUrl('1'),
        isOnline: true,
        unreadCount: 1,
        bio: 'Passionné de gaming et de tech 🎮',
        username: '@t4zor',
        phone: '+33 6 12 34 56 78',
        createdAt: DateTime(2025, 12, 15),
        currentActivity: 'Joue à Valorant',
      ),
      ChatModel(
        id: '2',
        name: 'Tk-Porky',
        lastMessage: 'Seigneur.💔🙌 !!',
        lastMessageTime: now.subtract(const Duration(hours: 4)),
        avatarUrl: AvatarHelper.getAvatarUrl('2'),
        isOnline: false,
        unreadCount: 0,
        bio: 'Développeur full-stack 💻',
        username: '@tkporky',
        phone: '+33 6 23 45 67 89',
        createdAt: DateTime(2025, 11, 20),
        currentActivity: 'Vu récemment',
      ),
      ChatModel(
        id: '3',
        name: 'AlistairJr',
        lastMessage: 'N\'oubliez pas de mettre à jour...',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        avatarUrl: '',
        isOnline: true,
        unreadCount: 3,
        bio: 'Chef de projet et développeur senior',
        username: '@alistairjr',
        phone: '+33 6 34 56 78 90',
        createdAt: DateTime(2025, 10, 5),
        currentActivity: 'Au travail',
      ),
    ];
  }

  /// Retourne des messages d'exemple pour une conversation spécifique
  static List<MessageModel> getSampleMessages(String chatId) {
    final now = DateTime.now();

    // Messages par défaut pour toutes les conversations
    // Note: senderId et senderName doivent être définis selon le contexte d'utilisation
    return [
      MessageModel(
        id: 'msg_${chatId}_1',
        text: 'Salut ! Comment ça va ? 😊',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
        senderId: 'other_user',
        senderName: 'Contact',
      ),
      MessageModel(
        id: 'msg_${chatId}_2',
        text: 'Ça va super bien ! Et toi ?',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 55)),
        isRead: true,
        senderId: 'current_user',
        senderName: 'Moi',
      ),
      MessageModel(
        id: 'msg_${chatId}_3',
        text: 'Très bien aussi ! Je travaille sur un nouveau projet.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
        isRead: true,
        senderId: 'other_user',
        senderName: 'Contact',
      ),
      MessageModel(
        id: 'msg_${chatId}_4',
        text: 'Intéressant ! Tu peux m\'en dire plus ?',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        isRead: true,
        senderId: 'current_user',
        senderName: 'Moi',
      ),
      MessageModel(
        id: 'msg_${chatId}_5',
        text: 'C\'est un projet de développement mobile avec Flutter',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 40)),
        isRead: true,
        senderId: 'other_user',
        senderName: 'Contact',
      ),
      MessageModel(
        id: 'msg_${chatId}_6',
        text: 'Excellent choix ! Flutter est vraiment puissant 💪',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isRead: true,
        senderId: 'current_user',
        senderName: 'Moi',
      ),
    ];
  }
}
