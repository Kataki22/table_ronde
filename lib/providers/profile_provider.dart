import 'package:flutter/foundation.dart';
import '../models/profiles/user_profile_model.dart';
import '../models/profiles/user_activity.dart';
import '../models/profiles/user_post.dart';
import '../data/mock_profiles_data.dart';

/// Provider pour la gestion des profils utilisateurs
/// Gère l'affichage et l'édition des profils
class ProfileProvider extends ChangeNotifier {
  // State
  Map<String, UserProfileModel> _profiles = {};
  UserProfileModel? _currentUserProfile;
  final Set<String> _blockedUsers = {};

  /// Initialise le provider avec les données mockées
  ProfileProvider() {
    _loadProfiles();
  }

  /// Charge les profils depuis les données mockées
  void _loadProfiles() {
    _profiles = Map.from(MockProfilesData.profiles);
    // Définir le profil de l'utilisateur actuel (user_1 par défaut)
    _currentUserProfile = _profiles['user_1'];
    notifyListeners();
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

    // Simuler une latence réseau
    await Future.delayed(const Duration(milliseconds: 200));

    // Simuler un échec occasionnel (5% de chance)
    if (DateTime.now().millisecond % 20 == 0) {
      throw Exception('Impossible de sauvegarder les paramètres');
    }

    // Mettre à jour le profil
    _currentUserProfile = _currentUserProfile!.copyWith(
      bio: bio,
      avatarUrl: photoUrl,
      phone: phone,
    );

    // Mettre à jour dans la map des profils
    _profiles[_currentUserProfile!.id] = _currentUserProfile!;

    notifyListeners();
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

  /// Recharge tous les profils depuis les données mockées
  void reloadProfiles() {
    _loadProfiles();
  }
}
