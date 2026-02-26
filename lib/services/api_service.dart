import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feed/post_model.dart';
import '../models/profiles/user_profile_model.dart';
import '../models/chat_model.dart';
import '../models/groups/group_chat_model.dart';
import '../models/notifications/notification_model.dart';
import '../models/media/media_item.dart';
import '../models/feed/reaction_model.dart';

/// Service pour communiquer avec le serveur JSON
class ApiService {
  // Configuration de l'URL de base
  // Pour Android Emulator: utilisez 10.0.2.2
  // Pour iOS Simulator: utilisez localhost
  // Pour un appareil physique: utilisez l'IP de votre machine
  static const String baseUrl = 'http://localhost:3000';

  // Alternative pour iOS Simulator
  // static const String baseUrl = 'http://localhost:3000';

  // Alternative pour appareil physique (remplacez par votre IP)
  // static const String baseUrl = 'http://192.168.1.X:3000';

  /// Récupère tous les posts
  static Future<List<PostModel>> getPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des posts');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupère un post par son ID
  static Future<PostModel> getPost(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/$id'));

      if (response.statusCode == 200) {
        return PostModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Post non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Crée un nouveau post
  static Future<PostModel> createPost(PostModel post) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 201) {
        return PostModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la création du post');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Met à jour un post
  static Future<PostModel> updatePost(String id, PostModel post) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 200) {
        return PostModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la mise à jour du post');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Supprime un post
  static Future<void> deletePost(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression du post');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupère tous les profils
  static Future<List<UserProfileModel>> getProfiles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profiles'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserProfileModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des profils');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupère un profil par son ID
  static Future<UserProfileModel> getProfile(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profiles/$id'));

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Profil non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupère tous les chats
  static Future<List<ChatModel>> getChats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/chats'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des chats');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupère les messages d'un chat
  static Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages?chatId=$chatId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des messages');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Envoie un nouveau message
  static Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );

      if (response.statusCode == 201) {
        return MessageModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de l\'envoi du message');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Supprime un message
  static Future<void> deleteMessage(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/messages/$id'));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression du message');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ==================== Groupes ====================

  /// Récupère tous les groupes
  static Future<List<GroupChatModel>> getGroups() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/groups'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => GroupChatModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des groupes');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupère un groupe par son ID
  static Future<GroupChatModel> getGroup(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/groups/$id'));

      if (response.statusCode == 200) {
        return GroupChatModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Groupe non trouvé');
      } else {
        throw Exception('Erreur lors du chargement du groupe');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Crée un nouveau groupe
  static Future<GroupChatModel> createGroup(GroupChatModel group) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/groups'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(group.toJson()),
      );

      if (response.statusCode == 201) {
        return GroupChatModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 409) {
        throw Exception('Ce groupe existe déjà');
      } else {
        throw Exception('Erreur lors de la création du groupe');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Met à jour un groupe
  static Future<GroupChatModel> updateGroup(String id, GroupChatModel group) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/groups/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(group.toJson()),
      );

      if (response.statusCode == 200) {
        return GroupChatModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Groupe non trouvé');
      } else {
        throw Exception('Erreur lors de la mise à jour du groupe');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Supprime un groupe
  static Future<void> deleteGroup(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/groups/$id'));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression du groupe');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ==================== Profils ====================

  /// Met à jour un profil
  static Future<UserProfileModel> updateProfile(String id, UserProfileModel profile) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profiles/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Profil non trouvé');
      } else {
        throw Exception('Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ==================== Notifications ====================

  /// Récupère les notifications d'un utilisateur
  static Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des notifications');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Crée une nouvelle notification
  static Future<NotificationModel> createNotification(NotificationModel notification) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(notification.toJson()),
      );

      if (response.statusCode == 201) {
        return NotificationModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la création de la notification');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Marque une notification comme lue
  static Future<NotificationModel> markNotificationAsRead(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isRead': true}),
      );

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Notification non trouvée');
      } else {
        throw Exception('Erreur lors de la mise à jour de la notification');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Supprime une notification
  static Future<void> deleteNotification(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/notifications/$id'));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de la notification');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ==================== Médias ====================

  /// Récupère les médias d'un chat
  static Future<List<MediaItem>> getMediaByChat(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/media?chatId=$chatId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MediaItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des médias');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Upload un nouveau média
  static Future<MediaItem> uploadMedia(MediaItem media) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/media'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(media.toJson()),
      );

      if (response.statusCode == 201) {
        return MediaItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de l\'upload du média');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Supprime un média
  static Future<void> deleteMedia(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/media/$id'));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression du média');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ==================== Réactions ====================

  /// Récupère les réactions d'un post
  static Future<List<ReactionModel>> getReactions(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reactions?postId=$postId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ReactionModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des réactions');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Ajoute une réaction
  static Future<ReactionModel> addReaction(ReactionModel reaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reaction.toJson()),
      );

      if (response.statusCode == 201) {
        return ReactionModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de l\'ajout de la réaction');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Supprime une réaction
  static Future<void> removeReaction(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/reactions/$id'));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de la réaction');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
