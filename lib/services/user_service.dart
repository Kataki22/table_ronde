import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth/user_model.dart';
import '../models/chat_model.dart';

/// Service pour gérer les utilisateurs et les conversations
class UserService {
  static const String baseUrl = 'http://localhost:3000';

  /// Récupère tous les utilisateurs du serveur
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des utilisateurs');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupère un utilisateur par son ID
  static Future<UserModel> getUserById(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Utilisateur non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Recherche des utilisateurs par nom ou username
  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final users = data.map((json) => UserModel.fromJson(json)).toList();

        // Filtrer localement
        return users.where((user) {
          final nameLower = user.name.toLowerCase();
          final usernameLower = (user.username ?? '').toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower) || usernameLower.contains(queryLower);
        }).toList();
      } else {
        throw Exception('Erreur lors de la recherche');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Crée ou récupère une conversation avec un utilisateur
  static Future<ChatModel> getOrCreateConversation(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      // Récupérer l'utilisateur cible
      final targetUser = await getUserById(targetUserId);

      // Créer un ID de conversation unique basé sur les deux IDs
      final chatId = _generateChatId(currentUserId, targetUserId);

      // Vérifier si la conversation existe déjà
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/messages?chatId=$chatId'),
        );

        if (response.statusCode == 200) {
          final List<dynamic> messages = json.decode(response.body);
          
          // Retourner le chat existant
          return ChatModel(
            id: chatId,
            name: targetUser.name,
            avatarUrl: targetUser.avatarUrl,
            isOnline: targetUser.isOnline,
            lastMessage: messages.isNotEmpty 
                ? messages.last['text'] as String?
                : null,
            lastMessageTime: messages.isNotEmpty
                ? DateTime.parse(messages.last['timestamp'] as String)
                : null,
            unreadCount: 0,
            bio: targetUser.bio,
            phone: targetUser.phone,
            username: targetUser.username,
            createdAt: targetUser.createdAt,
            currentActivity: targetUser.currentActivity,
          );
        }
      } catch (e) {
        // La conversation n'existe pas encore, on la crée
      }

      // Créer une nouvelle conversation
      return ChatModel(
        id: chatId,
        name: targetUser.name,
        avatarUrl: targetUser.avatarUrl,
        isOnline: targetUser.isOnline,
        lastMessage: null,
        lastMessageTime: null,
        unreadCount: 0,
        bio: targetUser.bio,
        phone: targetUser.phone,
        username: targetUser.username,
        createdAt: targetUser.createdAt,
        currentActivity: targetUser.currentActivity,
      );
    } catch (e) {
      throw Exception('Erreur lors de la création de la conversation: $e');
    }
  }

  /// Génère un ID de conversation unique pour deux utilisateurs
  static String _generateChatId(String userId1, String userId2) {
    // Trier les IDs pour avoir toujours le même ordre
    final ids = [userId1, userId2]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  /// Récupère les utilisateurs en ligne
  static Future<List<UserModel>> getOnlineUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users?isOnline=true'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des utilisateurs en ligne');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupère les utilisateurs par rôle
  static Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users?role=$role'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des utilisateurs');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
