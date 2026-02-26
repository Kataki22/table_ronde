import 'package:flutter/foundation.dart';
import '../models/profiles/user_profile_model.dart';
import '../models/profiles/user_activity.dart';
import '../models/profiles/user_post.dart';
import '../models/auth/user_model.dart';
import '../services/api_service.dart';

/// Provider pour la gestion des profils utilisateurs
/// Gère l'affichage et l'édition des profils
class ProfileProvider extends ChangeNotifier {
  // State
  Map<String, UserProfileModel> _profiles = {};
  Map<String, DateTime> _profileCacheTimes = {};
  UserProfileModel? _currentUserProfile;
  final Set<String> _blockedUsers = {};
  bool _isLoading = false;
  String? _error;

  // Cache TTL: 5 minutes
  static const Duration _cacheTTL = Duration(minutes: 5);

  /// Initialise le provider
  ProfileProvider();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge tous les profils depuis l'API
  Future<void> loadProfiles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profiles = await ApiService.getProfiles();
      _profiles = {for (var profile in profiles) profile.id: profile};
      
      // Mettre à jour les temps de cache
      final now = DateTime.now();
      for (var profile in profiles) {
        _profileCacheTimes[profile.id] = now;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Synchronise le profil actuel avec l'utilisateur authentifié
  void syncWithAuthUser(UserModel? authUser) {
    if (authUser == null) {
      _currentUserProfile = null;
      notifyListeners();
      return;
    }

    // Créer ou mettre à jour le profil à partir des données d'authentification
    final profile = UserProfileModel(
      id: authUser.id,
      name: authUser.name,
      username: authUser.username ?? '@${authUser.name.toLowerCase().replaceAll(' ', '')}',
      bio: authUser.bio,
      phone: authUser.phone,
      avatarUrl: authUser.avatarUrl,
      createdAt: authUser.createdAt,
      isOnline: authUser.isOnline,
      currentActivity: authUser.currentActivity,
      recentActivities: [],
      posts: [],
    );

    _currentUserProfile = profile;
    _profiles[authUser.id] = profile;
    _profileCacheTimes[authUser.id] = DateTime.now();
    notifyListeners();
  }

  /// Charge un profil spécifique avec cache et TTL
  Future<UserProfileModel?> loadProfile(String userId) async {
    // Vérifier si le profil est en cache et valide
    final cachedProfile = _profiles[userId];
    final cacheTime = _profileCacheTimes[userId];
    
    if (cachedProfile != null && cacheTime != null) {
      final age = DateTime.now().difference(cacheTime);
      if (age < _cacheTTL) {
        return cachedProfile;
      }
    }

    // Charger depuis l'API
    try {
      final profile = await ApiService.getProfile(userId);
      _profiles[userId] = profile;
      _profileCacheTimes[userId] = DateTime.now();
      notifyListeners();
      return profile;
    } catch (e) {
      // Fallback au cache en cas d'erreur
      if (cachedProfile != null) {
        return cachedProfile;
      }
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Force le rechargement d'un profil
  Future<UserProfileModel?> refreshProfile(String userId) async {
    // Invalider le cache
    _profileCacheTimes.remove(userId);
    return loadProfile(userId);
  }

  // Getters

  /// Récupère un profil par son ID
  UserProfileModel? getProfile(String userId) {
    return _profiles[userId];
  }

  /// Récupère un profil par son nom
  /// Retourne le premier profil correspondant ou null si aucun n'est trouvé
  UserProfileModel? getProfileByName(String name) {
    try {
      return _profiles.values.firstWhere(
        (profile) => profile.name == name,
      );
    } catch (e) {
      return null;
    }
  }

  /// Récupère le profil de l'utilisateur actuel
  UserProfileModel? get currentUserProfile => _currentUserProfile;

  /// Récupère les activités récentes d'un utilisateur
  List<UserActivity> getUserActivities(String userId) {
    final profile = _profiles[userId];
    return profile?.recentActivities ?? [];
  }

  /// Récupère les posts d'un utilisateur
  List<UserPost> getUserPosts(String userId) {
    final profile = _profiles[userId];
    return profile?.posts ?? [];
  }

  /// Vérifie si un utilisateur est bloqué
  bool isUserBlocked(String userId) {
    return _blockedUsers.contains(userId);
  }

  /// Récupère la liste des utilisateurs bloqués
  Set<String> get blockedUsers => Set.unmodifiable(_blockedUsers);

  // Actions

  /// Met à jour le profil de l'utilisateur actuel
  /// 
  /// Valide les données avant la mise à jour :
  /// - bio : maximum 500 caractères
  /// - phone : format valide (commence par + ou chiffre)
  /// 
  /// Throws [ArgumentError] si la validation échoue
  Future<void> updateProfile({
    String? bio,
    String? photoUrl,
    String? phone,
  }) async {
    if (_currentUserProfile == null) {
      throw StateError('Aucun utilisateur connecté');
    }

    // Validation de la bio
    if (bio != null && bio.length > 500) {
      throw ArgumentError('La bio est trop longue (maximum 500 caractères)');
    }

    // Validation du téléphone
    if (phone != null && phone.isNotEmpty) {
      if (!_isValidPhoneFormat(phone)) {
        throw ArgumentError('Format de téléphone invalide');
      }
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mettre à jour le profil localement
      final updatedProfile = _currentUserProfile!.copyWith(
        bio: bio,
        avatarUrl: photoUrl,
        phone: phone,
      );

      // Envoyer la mise à jour à l'API
      final savedProfile = await ApiService.updateProfile(
        _currentUserProfile!.id,
        updatedProfile,
      );

      // Mettre à jour le cache
      _currentUserProfile = savedProfile;
      _profiles[savedProfile.id] = savedProfile;
      _profileCacheTimes[savedProfile.id] = DateTime.now();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Valide le format du numéro de téléphone
  /// Accepte les formats : +33 6 12 34 56 78, 0612345678, +1234567890
  bool _isValidPhoneFormat(String phone) {
    // Supprimer les espaces pour la validation
    final cleanPhone = phone.replaceAll(' ', '');
    
    // Doit commencer par + ou un chiffre
    if (!cleanPhone.startsWith('+') && !RegExp(r'^\d').hasMatch(cleanPhone)) {
      return false;
    }

    // Doit contenir au moins 10 chiffres
    final digits = cleanPhone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 10) {
      return false;
    }

    return true;
  }

  /// Bloque un utilisateur
  /// 
  /// L'utilisateur bloqué n'apparaîtra plus dans les recherches
  /// et ses messages seront masqués
  Future<void> blockUser(String userId) async {
    if (userId == _currentUserProfile?.id) {
      throw ArgumentError('Impossible de se bloquer soi-même');
    }

    // Simuler une latence réseau
    await Future.delayed(const Duration(milliseconds: 150));

    _blockedUsers.add(userId);
    notifyListeners();
  }

  /// Débloque un utilisateur
  Future<void> unblockUser(String userId) async {
    // Simuler une latence réseau
    await Future.delayed(const Duration(milliseconds: 150));

    _blockedUsers.remove(userId);
    notifyListeners();
  }

  /// Définit l'utilisateur actuel (pour les tests ou le changement d'utilisateur)
  void setCurrentUser(String userId) {
    _currentUserProfile = _profiles[userId];
    notifyListeners();
  }
}
