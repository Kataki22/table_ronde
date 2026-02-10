import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  static const String keyName = 'user_name';
  static const String keyUsername = 'user_username';
  static const String keyEmail = 'user_email';
  static const String keyBio = 'user_bio';
  static const String keyAvatarUrl = 'user_avatar_url';
  static const String keyIsLoggedIn = 'is_logged_in';

  Future<void> saveUser({
    String? name,
    String? username,
    String? email,
    String? bio,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(keyName, name);
    if (username != null) await prefs.setString(keyUsername, username);
    if (email != null) await prefs.setString(keyEmail, email);
    if (bio != null) await prefs.setString(keyBio, bio);
    if (avatarUrl != null) await prefs.setString(keyAvatarUrl, avatarUrl);
    await prefs.setBool(keyIsLoggedIn, true);
  }

  Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(keyName),
      'username': prefs.getString(keyUsername),
      'email': prefs.getString(keyEmail),
      'bio': prefs.getString(keyBio),
      'avatarUrl': prefs.getString(keyAvatarUrl),
    };
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
