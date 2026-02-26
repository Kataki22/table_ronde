import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/user_model.dart';

/// Service d'authentification
/// 
/// Gère l'inscription, la connexion et la session utilisateur
class AuthService {
  static const String baseUrl = 'http://localhost:3000';
  // Pour iOS Simulator: 'http://localhost:3000'
  // Pour appareil physique: 'http://192.168.1.X:3000'

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  /// Inscrit un nouvel utilisateur
  static Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? username,
  }) async {
    try {
      // Vérifier si l'email existe déjà
      final existingUsers = await http.get(
        Uri.parse('$baseUrl/users?email=$email'),
      );

      if (existingUsers.statusCode == 200) {
        final List<dynamic> users = json.decode(existingUsers.body);
        if (users.isNotEmpty) {
          throw Exception('Cet email est déjà utilisé');
        }
      }

      // Créer le nouvel utilisateur
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final newUser = {
        'id': userId,
        'email': email,
        'password': password, // En production, hasher le mot de passe !
        'name': name,
        'username': username ?? '@${name.toLowerCase().replaceAll(' ', '')}',
        'bio': null,
        'phone': null,
        'avatarUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
        'isOnline': true,
        'currentActivity': 'En ligne',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newUser),
      );

      if (response.statusCode == 201) {
        final userData = json.decode(response.body);
        final user = UserModel.fromJson(userData);
        
        // Sauvegarder la session
        await _saveSession(userId, email);
        
        return user;
      } else {
        throw Exception('Erreur lors de l\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  /// Connecte un utilisateur existant
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Rechercher l'utilisateur par email
      final response = await http.get(
        Uri.parse('$baseUrl/users?email=$email'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        
        if (users.isEmpty) {
          throw Exception('Email ou mot de passe incorrect');
        }

        final userData = users[0];
        
        // Vérifier le mot de passe
        if (userData['password'] != password) {
          throw Exception('Email ou mot de passe incorrect');
        }

        // Mettre à jour le statut en ligne
        await http.patch(
          Uri.parse('$baseUrl/users/${userData['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'isOnline': true,
            'currentActivity': 'En ligne',
          }),
        );

        final user = UserModel.fromJson(userData);
        
        // Sauvegarder la session
        await _saveSession(user.id, email);
        
        return user;
      } else {
        throw Exception('Erreur de connexion');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Déconnecte l'utilisateur actuel
  static Future<void> logout() async {
    try {
      final userId = await getCurrentUserId();
      
      if (userId != null) {
        // Mettre à jour le statut hors ligne
        await http.patch(
          Uri.parse('$baseUrl/users/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'isOnline': false,
            'currentActivity': null,
          }),
        );
      }

      // Supprimer la session locale
      await _clearSession();
    } catch (e) {
      // Supprimer la session même en cas d'erreur
      await _clearSession();
    }
  }

  /// Récupère l'utilisateur actuellement connecté
  static Future<UserModel?> getCurrentUser() async {
    try {
      final userId = await getCurrentUserId();
      
      if (userId == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return UserModel.fromJson(userData);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si un utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final userId = await getCurrentUserId();
    return userId != null;
  }

  /// Récupère l'ID de l'utilisateur connecté
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Met à jour le profil de l'utilisateur
  static Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? username,
    String? bio,
    String? phone,
    String? avatarUrl,
    String? currentActivity,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (name != null) updates['name'] = name;
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      if (currentActivity != null) updates['currentActivity'] = currentActivity;

      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return UserModel.fromJson(userData);
      } else {
        throw Exception('Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      throw Exception('Erreur de mise à jour: $e');
    }
  }

  /// Change le mot de passe de l'utilisateur
  static Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Récupérer l'utilisateur
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        
        // Vérifier l'ancien mot de passe
        if (userData['password'] != oldPassword) {
          throw Exception('Ancien mot de passe incorrect');
        }

        // Mettre à jour le mot de passe
        await http.patch(
          Uri.parse('$baseUrl/users/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'password': newPassword}),
        );
      } else {
        throw Exception('Utilisateur non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur de changement de mot de passe: $e');
    }
  }

  /// Sauvegarde la session utilisateur
  static Future<void> _saveSession(String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_tokenKey, email); // Utiliser email comme token simple
  }

  /// Supprime la session utilisateur
  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_tokenKey);
  }
}
