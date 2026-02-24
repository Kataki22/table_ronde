import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/providers/profile_provider.dart';

void main() {
  group('ProfileProvider', () {
    late ProfileProvider provider;

    setUp(() {
      provider = ProfileProvider();
    });

    test('should initialize with mock profiles', () {
      expect(provider.currentUserProfile, isNotNull);
      expect(provider.currentUserProfile?.id, equals('user_1'));
      expect(provider.getProfile('user_1'), isNotNull);
    });

    test('should get profile by ID', () {
      final profile = provider.getProfile('user_2');
      expect(profile, isNotNull);
      expect(profile?.name, equals('T4zor'));
    });

    test('should get user activities', () {
      final activities = provider.getUserActivities('user_1');
      expect(activities, isNotEmpty);
    });

    test('should get user posts', () {
      final posts = provider.getUserPosts('user_1');
      expect(posts, isNotEmpty);
    });

    test('should update profile with valid data', () async {
      final newBio = 'Updated bio';
      final newPhone = '+33 6 12 34 56 78';

      await provider.updateProfile(
        bio: newBio,
        phone: newPhone,
      );

      expect(provider.currentUserProfile?.bio, equals(newBio));
      expect(provider.currentUserProfile?.phone, equals(newPhone));
    });

    test('should throw error when bio exceeds 500 characters', () async {
      final longBio = 'a' * 501;

      expect(
        () => provider.updateProfile(bio: longBio),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for invalid phone format', () async {
      expect(
        () => provider.updateProfile(phone: 'invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should accept valid phone formats', () async {
      // Test various valid formats
      await provider.updateProfile(phone: '+33 6 12 34 56 78');
      expect(provider.currentUserProfile?.phone, equals('+33 6 12 34 56 78'));

      await provider.updateProfile(phone: '0612345678');
      expect(provider.currentUserProfile?.phone, equals('0612345678'));

      await provider.updateProfile(phone: '+1234567890');
      expect(provider.currentUserProfile?.phone, equals('+1234567890'));
    });

    test('should block user', () async {
      await provider.blockUser('user_2');
      expect(provider.isUserBlocked('user_2'), isTrue);
      expect(provider.blockedUsers.contains('user_2'), isTrue);
    });

    test('should unblock user', () async {
      await provider.blockUser('user_2');
      expect(provider.isUserBlocked('user_2'), isTrue);

      await provider.unblockUser('user_2');
      expect(provider.isUserBlocked('user_2'), isFalse);
    });

    test('should not allow blocking self', () async {
      expect(
        () => provider.blockUser('user_1'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should set current user', () {
      provider.setCurrentUser('user_2');
      expect(provider.currentUserProfile?.id, equals('user_2'));
      expect(provider.currentUserProfile?.name, equals('T4zor'));
    });

    test('should reload profiles', () {
      provider.reloadProfiles();
      expect(provider.currentUserProfile, isNotNull);
      expect(provider.getProfile('user_1'), isNotNull);
    });
  });
}
