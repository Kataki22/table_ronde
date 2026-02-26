import 'package:flutter/foundation.dart';
import '../models/auth/user_model.dart';
import '../services/auth_service.dart';

/// Provider pour gérer l'authentification
class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  /// Initialise le provider en vérifiant la session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await AuthService.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inscrit un nouvel utilisateur
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.register(
        email: email,
        password: password,
        name: name,
        username: username,
      );
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Connecte un utilisateur
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.login(
        email: email,
        password: password,
      );
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnecte l'utilisateur
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour le profil utilisateur
  Future<bool> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? phone,
    String? avatarUrl,
    String? currentActivity,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.updateProfile(
        userId: _currentUser!.id,
        name: name,
        username: username,
        bio: bio,
        phone: phone,
        avatarUrl: avatarUrl,
        currentActivity: currentActivity,
      );
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change le mot de passe
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.changePassword(
        userId: _currentUser!.id,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
