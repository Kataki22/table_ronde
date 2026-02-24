import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/providers/profile_provider.dart';

/// Tests de validation pour ProfileProvider
/// 
/// Vérifie que les validations de bio et téléphone fonctionnent correctement
/// **Validates: Requirements 2.7**
void main() {
  group('ProfileProvider Validation Tests', () {
    late ProfileProvider provider;

    setUp(() {
      provider = ProfileProvider();
    });

    /// Helper function to retry operations that might fail due to simulated network errors
    Future<void> retryOperation(Future<void> Function() operation, {int maxRetries = 3}) async {
      for (int i = 0; i < maxRetries; i++) {
        try {
          await operation();
          return;
        } catch (e) {
          if (e.toString().contains('Impossible de sauvegarder les paramètres') && i < maxRetries - 1) {
            // Retry on simulated network failure
            await Future.delayed(const Duration(milliseconds: 50));
            continue;
          }
          rethrow;
        }
      }
    }

    group('Bio Validation', () {
      test('should accept bio with 500 characters or less', () async {
        final validBio = 'A' * 500;
        
        await retryOperation(() => provider.updateProfile(bio: validBio));
      });

      test('should reject bio with more than 500 characters', () async {
        final invalidBio = 'A' * 501;
        
        await expectLater(
          provider.updateProfile(bio: invalidBio),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('La bio est trop longue'),
          )),
        );
      });

      test('should accept empty bio', () async {
        await retryOperation(() => provider.updateProfile(bio: ''));
      });

      test('should accept null bio', () async {
        await retryOperation(() => provider.updateProfile(bio: null));
      });
    });

    group('Phone Validation', () {
      test('should accept valid international phone format', () async {
        await retryOperation(() => provider.updateProfile(phone: '+33 6 12 34 56 78'));
      });

      test('should accept valid local phone format', () async {
        await retryOperation(() => provider.updateProfile(phone: '0612345678'));
      });

      test('should accept phone with spaces', () async {
        await retryOperation(() => provider.updateProfile(phone: '06 12 34 56 78'));
      });

      test('should reject phone with less than 10 digits', () async {
        await expectLater(
          provider.updateProfile(phone: '123456789'),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Format de téléphone invalide'),
          )),
        );
      });

      test('should reject phone with invalid characters', () async {
        await expectLater(
          provider.updateProfile(phone: 'abc1234567890'),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Format de téléphone invalide'),
          )),
        );
      });

      test('should accept empty phone', () async {
        await retryOperation(() => provider.updateProfile(phone: ''));
      });

      test('should accept null phone', () async {
        await retryOperation(() => provider.updateProfile(phone: null));
      });
    });

    group('Combined Validation', () {
      test('should accept valid bio and phone together', () async {
        await retryOperation(() => provider.updateProfile(
          bio: 'This is a valid bio',
          phone: '+33 6 12 34 56 78',
        ));
      });

      test('should reject if bio is invalid even if phone is valid', () async {
        final invalidBio = 'A' * 501;
        
        await expectLater(
          provider.updateProfile(
            bio: invalidBio,
            phone: '+33 6 12 34 56 78',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject if phone is invalid even if bio is valid', () async {
        await expectLater(
          provider.updateProfile(
            bio: 'Valid bio',
            phone: '123',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Profile Update', () {
      test('should update profile with valid data', () async {
        final initialProfile = provider.currentUserProfile;
        
        await retryOperation(() => provider.updateProfile(
          bio: 'New bio',
          phone: '+33 6 12 34 56 78',
          photoUrl: 'https://example.com/photo.jpg',
        ));

        final updatedProfile = provider.currentUserProfile;
        
        expect(updatedProfile?.bio, equals('New bio'));
        expect(updatedProfile?.phone, equals('+33 6 12 34 56 78'));
        expect(updatedProfile?.avatarUrl, equals('https://example.com/photo.jpg'));
        expect(updatedProfile?.id, equals(initialProfile?.id));
      });

      test('should preserve unchanged fields', () async {
        final initialProfile = provider.currentUserProfile;
        
        await retryOperation(() => provider.updateProfile(bio: 'New bio'));

        final updatedProfile = provider.currentUserProfile;
        
        expect(updatedProfile?.bio, equals('New bio'));
        expect(updatedProfile?.name, equals(initialProfile?.name));
        expect(updatedProfile?.id, equals(initialProfile?.id));
      });
    });
  });
}
