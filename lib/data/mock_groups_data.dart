import '../models/groups/group_chat_model.dart';
import '../models/groups/group_member_model.dart';
import '../models/groups/group_permission.dart';
import '../models/chat_model.dart';

/// Données mockées pour les groupes de discussion
/// Contient des groupes avec membres et messages pour les tests
class MockGroupsData {
  static final DateTime _now = DateTime.now();

  /// Liste des groupes mockés
  static final List<GroupChatModel> groups = _generateGroups();

  /// Messages par groupe
  static final Map<String, List<MessageModel>> groupMessages = _generateGroupMessages();

  /// Génère 12 groupes avec membres variés
  static List<GroupChatModel> _generateGroups() {
    return [
      // Groupe 1: Équipe Dev Flutter (5 membres, admin + moderators)
      GroupChatModel(
        id: 'group_1',
        name: 'Équipe Dev Flutter',
        description: 'Discussions techniques sur le développement Flutter',
        photoUrl: 'assets/images/groups/flutter_team.png',
        members: [
          GroupMemberModel(
            userId: 'user_1',
            name: 'AlistairJr',
            avatarUrl: 'assets/images/Avatar1.png',
            permission: GroupPermission.admin,
            joinedAt: _now.subtract(const Duration(days: 90)),
          ),
          GroupMemberModel(
            userId: 'user_2',
            name: 'T4zor',
            avatarUrl: 'assets/images/Avatar2.png',
            permission: GroupPermission.moderator,
            joinedAt: _now.subtract(const Duration(days: 85)),
          ),
          GroupMemberModel(
            userId: 'user_3',
            name: 'Tk-Porky',
            avatarUrl: 'assets/images/Avatar3.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 80)),
          ),
          GroupMemberModel(
            userId: 'user_4',
            name: 'Sophie Martin',
            avatarUrl: 'assets/images/Avatar4.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 75)),
          ),
          GroupMemberModel(
            userId: 'user_5',
            name: 'Lucas Dubois',
            avatarUrl: 'assets/images/Avatar5.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 70)),
          ),
        ],
        createdAt: _now.subtract(const Duration(days: 90)),
        lastMessage: 'Le nouveau widget est prêt pour review',
        lastMessageTime: _now.subtract(const Duration(hours: 2)),
        unreadCount: 3,
      ),

      // Groupe 2: Gaming Squad (8 membres)
      GroupChatModel(
        id: 'group_2',
        name: 'Gaming Squad 🎮',
        description: 'Pour organiser nos sessions de jeu',
        photoUrl: 'assets/images/groups/gaming.png',
        members: [
          GroupMemberModel(
            userId: 'user_6',
            name: 'ProGamer42',
            avatarUrl: 'assets/images/Avatar6.png',
            permission: GroupPermission.admin,
            joinedAt: _now.subtract(const Duration(days: 120)),
          ),
          GroupMemberModel(
            userId: 'user_7',
            name: 'NinjaKiller',
            avatarUrl: 'assets/images/Avatar7.png',
            permission: GroupPermission.moderator,
            joinedAt: _now.subtract(const Duration(days: 115)),
          ),
          GroupMemberModel(
            userId: 'user_8',
            name: 'Emma Leroy',
            avatarUrl: 'assets/images/Avatar8.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 110)),
          ),
          GroupMemberModel(
            userId: 'user_9',
            name: 'MaxPower',
            avatarUrl: 'assets/images/Avatar9.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 105)),
          ),
          GroupMemberModel(
            userId: 'user_10',
            name: 'Léa Bernard',
            avatarUrl: 'assets/images/Avatar10.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 100)),
          ),
          GroupMemberModel(
            userId: 'user_11',
            name: 'Thomas Petit',
            avatarUrl: 'assets/images/Avatar11.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 95)),
          ),
          GroupMemberModel(
            userId: 'user_12',
            name: 'Camille Roux',
            avatarUrl: 'assets/images/Avatar12.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 90)),
          ),
          GroupMemberModel(
            userId: 'user_13',
            name: 'Hugo Moreau',
            avatarUrl: 'assets/images/Avatar13.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 85)),
          ),
        ],
        createdAt: _now.subtract(const Duration(days: 120)),
        lastMessage: 'On se fait une partie ce soir ?',
        lastMessageTime: _now.subtract(const Duration(minutes: 45)),
        unreadCount: 5,
      ),

      // Groupe 3: Famille Dupont (6 membres)
      GroupChatModel(
        id: 'group_3',
        name: 'Famille Dupont 👨‍👩‍👧‍👦',
        description: 'Notre groupe familial',
        photoUrl: 'assets/images/groups/family.png',
        members: [
          GroupMemberModel(
            userId: 'user_14',
            name: 'Papa Jean',
            avatarUrl: 'assets/images/Avatar14.png',
            permission: GroupPermission.admin,
            joinedAt: _now.subtract(const Duration(days: 365)),
          ),
          GroupMemberModel(
            userId: 'user_15',
            name: 'Maman Marie',
            avatarUrl: 'assets/images/Avatar15.png',
            permission: GroupPermission.admin,
            joinedAt: _now.subtract(const Duration(days: 365)),
          ),
          GroupMemberModel(
            userId: 'user_16',
            name: 'Julie',
            avatarUrl: 'assets/images/Avatar16.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 365)),
          ),
          GroupMemberModel(
            userId: 'user_17',
            name: 'Pierre',
            avatarUrl: 'assets/images/Avatar17.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 365)),
          ),
          GroupMemberModel(
            userId: 'user_18',
            name: 'Grand-mère Louise',
            avatarUrl: 'assets/images/Avatar18.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 300)),
          ),
          GroupMemberModel(
            userId: 'user_19',
            name: 'Oncle Paul',
            avatarUrl: 'assets/images/Avatar19.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 250)),
          ),
        ],
        createdAt: _now.subtract(const Duration(days: 365)),
        lastMessage: 'N\'oubliez pas le repas de dimanche !',
        lastMessageTime: _now.subtract(const Duration(hours: 5)),
        unreadCount: 2,
      ),

      // Groupe 4: Projet TableRonde (12 membres)
      GroupChatModel(
        id: 'group_4',
        name: 'Projet TableRonde',
        description: 'Coordination du projet TableRonde',
        photoUrl: 'assets/images/groups/tableronde.png',
        members: [
          GroupMemberModel(
            userId: 'user_1',
            name: 'AlistairJr',
            avatarUrl: 'assets/images/Avatar1.png',
            permission: GroupPermission.admin,
            joinedAt: _now.subtract(const Duration(days: 180)),
          ),
          GroupMemberModel(
            userId: 'user_20',
            name: 'Sarah Chen',
            avatarUrl: 'assets/images/Avatar20.png',
            permission: GroupPermission.admin,
            joinedAt: _now.subtract(const Duration(days: 180)),
          ),
          GroupMemberModel(
            userId: 'user_21',
            name: 'Marc Lefebvre',
            avatarUrl: 'assets/images/Avatar21.png',
            permission: GroupPermission.moderator,
            joinedAt: _now.subtract(const Duration(days: 175)),
          ),
          GroupMemberModel(
            userId: 'user_22',
            name: 'Nadia Benali',
            avatarUrl: 'assets/images/Avatar22.png',
            permission: GroupPermission.moderator,
            joinedAt: _now.subtract(const Duration(days: 170)),
          ),
          GroupMemberModel(
            userId: 'user_23',
            name: 'Antoine Rousseau',
            avatarUrl: 'assets/images/Avatar23.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 165)),
          ),
          GroupMemberModel(
            userId: 'user_24',
            name: 'Isabelle Garnier',
            avatarUrl: 'assets/images/Avatar24.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 160)),
          ),
          GroupMemberModel(
            userId: 'user_25',
            name: 'Kevin Blanc',
            avatarUrl: 'assets/images/Avatar25.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 155)),
          ),
          GroupMemberModel(
            userId: 'user_26',
            name: 'Fatima Diallo',
            avatarUrl: 'assets/images/Avatar26.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 150)),
          ),
          GroupMemberModel(
            userId: 'user_27',
            name: 'Julien Mercier',
            avatarUrl: 'assets/images/Avatar27.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 145)),
          ),
          GroupMemberModel(
            userId: 'user_28',
            name: 'Claire Fontaine',
            avatarUrl: 'assets/images/Avatar28.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 140)),
          ),
          GroupMemberModel(
            userId: 'user_29',
            name: 'David Lambert',
            avatarUrl: 'assets/images/Avatar29.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 135)),
          ),
          GroupMemberModel(
            userId: 'user_30',
            name: 'Amélie Girard',
            avatarUrl: 'assets/images/Avatar30.png',
            permission: GroupPermission.member,
            joinedAt: _now.subtract(const Duration(days: 130)),
          ),
        ],
        createdAt: _now.subtract(const Duration(days: 180)),
        lastMessage: 'La release v2.0 est prévue pour vendredi',
        lastMessageTime: _now.subtract(const Duration(hours: 1)),
        unreadCount: 7,
      ),

    ];
  }

  /// Génère des messages pour chaque groupe
  static Map<String, List<MessageModel>> _generateGroupMessages() {
    return {
      'group_1': _generateMessagesForGroup1(),
      'group_2': _generateMessagesForGroup2(),
      'group_3': _generateMessagesForGroup3(),
      'group_4': _generateMessagesForGroup4(),
    };
  }

  // Messages pour Groupe 1: Équipe Dev Flutter
  static List<MessageModel> _generateMessagesForGroup1() {
    return [
      MessageModel(
        id: 'msg_g1_1',
        text: 'Bonjour l\'équipe ! On commence le sprint aujourd\'hui',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 8)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g1_2',
        text: 'Super ! J\'ai terminé le widget de navigation',
        isSentByMe: true,
        timestamp: _now.subtract(const Duration(hours: 7, minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g1_3',
        text: 'Excellent travail ! On peut faire une review cet après-midi ?',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 7)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g1_4',
        text: 'Oui, 14h ça vous va ?',
        isSentByMe: true,
        timestamp: _now.subtract(const Duration(hours: 6, minutes: 45)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g1_5',
        text: 'Parfait pour moi 👍',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 6, minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g1_6',
        text: 'Le nouveau widget est prêt pour review',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ];
  }

  // Messages pour Groupe 2: Gaming Squad
  static List<MessageModel> _generateMessagesForGroup2() {
    return [
      MessageModel(
        id: 'msg_g2_1',
        text: 'Qui est dispo ce soir pour une partie ?',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g2_2',
        text: 'Moi je suis chaud ! 🔥',
        isSentByMe: true,
        timestamp: _now.subtract(const Duration(hours: 4, minutes: 50)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g2_3',
        text: 'Pareil, on fait quelle map ?',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 4, minutes: 40)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g2_4',
        text: 'Ascent ou Haven ?',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 4, minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g2_5',
        text: 'Ascent c\'est mieux !',
        isSentByMe: true,
        timestamp: _now.subtract(const Duration(hours: 4, minutes: 20)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g2_6',
        text: 'Ok, RDV à 20h sur Discord',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g2_7',
        text: 'On se fait une partie ce soir ?',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(minutes: 45)),
        isRead: false,
      ),
    ];
  }

  // Messages pour Groupe 3: Famille Dupont
  static List<MessageModel> _generateMessagesForGroup3() {
    return [
      MessageModel(
        id: 'msg_g3_1',
        text: 'Bonjour tout le monde ! 😊',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 10)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g3_2',
        text: 'Bonjour maman !',
        isSentByMe: true,
        timestamp: _now.subtract(const Duration(hours: 9, minutes: 50)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g3_3',
        text: 'N\'oubliez pas le repas de dimanche chez grand-mère',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 9, minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g3_4',
        text: 'Oui, on sera là ! Je ramène le dessert',
        isSentByMe: true,
        timestamp: _now.subtract(const Duration(hours: 9)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g3_5',
        text: 'Merci ma chérie ! À dimanche 💕',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 8, minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g3_6',
        text: 'N\'oubliez pas le repas de dimanche !',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 5)),
        isRead: false,
      ),
    ];
  }

  // Messages pour Groupe 4: Projet TableRonde
  static List<MessageModel> _generateMessagesForGroup4() {
    return [
      MessageModel(
        id: 'msg_g4_1',
        text: 'Réunion de sprint planning dans 30 minutes',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 6)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g4_2',
        text: 'J\'ai mis à jour le board Jira',
        isSentByMe: true,
        timestamp: _now.subtract(const Duration(hours: 5, minutes: 45)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g4_3',
        text: 'Merci ! Les nouvelles user stories sont claires',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 5, minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g4_4',
        text: 'On vise la release v2.0 pour vendredi',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g4_5',
        text: 'Tous les tests passent, on est prêts !',
        isSentByMe: true,
        timestamp: _now.subtract(const Duration(hours: 4, minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g4_6',
        text: 'Excellent ! On fait une démo demain ?',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_g4_7',
        text: 'La release v2.0 est prévue pour vendredi',
        isSentByMe: false,
        timestamp: _now.subtract(const Duration(hours: 1)),
        isRead: false,
      ),
    ];
  }
}
