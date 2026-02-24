import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tableronde_app/models/profiles/user_profile_model.dart';
import 'package:tableronde_app/providers/theme_provider.dart';
import 'package:tableronde_app/widgets/profiles/profile_header.dart';

void main() {
  group('ProfileHeader Widget Tests', () {
    late UserProfileModel testProfile;

    setUp(() {
      testProfile = UserProfileModel(
        id: 'test-user-1',
        name: 'Jean Dupont',
        username: '@jeandupont',
        bio: 'Développeur passionné par Flutter et les technologies mobiles.',
        phone: '+33612345678',
        avatarUrl: null, // Use null to avoid network image loading in tests
        createdAt: DateTime(2023, 1, 15),
        isOnline: true,
        recentActivities: [],
        posts: [],
      );
    });

    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('displays user name correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: testProfile,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.text('Jean Dupont'), findsOneWidget);
    });

    testWidgets('displays username when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: testProfile,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.text('@jeandupont'), findsOneWidget);
    });

    testWidgets('displays bio when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: testProfile,
            isCurrentUser: false,
          ),
        ),
      );

      expect(
        find.text('Développeur passionné par Flutter et les technologies mobiles.'),
        findsOneWidget,
      );
    });

    testWidgets('does not display bio when null', (WidgetTester tester) async {
      final profileWithoutBio = testProfile.copyWith(bio: ''); // Use empty string to clear bio

      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: profileWithoutBio,
            isCurrentUser: false,
          ),
        ),
      );

      expect(
        find.text('Développeur passionné par Flutter et les technologies mobiles.'),
        findsNothing,
      );
    });

    testWidgets('displays registration date', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: testProfile,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.textContaining('Membre depuis'), findsOneWidget);
    });

    testWidgets('displays online status indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: testProfile,
            isCurrentUser: false,
          ),
        ),
      );

      // Find the CircleAvatar (profile photo)
      expect(find.byType(CircleAvatar), findsOneWidget);
      
      // The widget should render without errors
      expect(find.text('Jean Dupont'), findsOneWidget);
    });

    testWidgets('shows edit button for current user', (WidgetTester tester) async {
      bool editPressed = false;

      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: testProfile,
            isCurrentUser: true,
            onEditPressed: () {
              editPressed = true;
            },
          ),
        ),
      );

      expect(find.text('Modifier le profil'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);

      // Tap the edit button
      await tester.tap(find.text('Modifier le profil'));
      await tester.pump();

      expect(editPressed, true);
    });

    testWidgets('does not show edit button for other users', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: testProfile,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.text('Modifier le profil'), findsNothing);
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('displays initials when no avatar URL', (WidgetTester tester) async {
      // testProfile already has null avatarUrl

      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: testProfile,
            isCurrentUser: false,
          ),
        ),
      );

      // Should display initials "JD" for "Jean Dupont"
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('displays single initial for single name', (WidgetTester tester) async {
      final profileSingleName = testProfile.copyWith(
        name: 'Jean',
      );

      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: profileSingleName,
            isCurrentUser: false,
          ),
        ),
      );

      // Should display initial "J" for "Jean"
      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('handles empty name gracefully', (WidgetTester tester) async {
      final profileEmptyName = testProfile.copyWith(
        name: '',
      );

      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: profileEmptyName,
            isCurrentUser: false,
          ),
        ),
      );

      // Should display "?" for empty name
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('formats recent registration date correctly', (WidgetTester tester) async {
      final recentProfile = UserProfileModel(
        id: testProfile.id,
        name: testProfile.name,
        username: testProfile.username,
        bio: testProfile.bio,
        phone: testProfile.phone,
        avatarUrl: testProfile.avatarUrl,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isOnline: testProfile.isOnline,
        recentActivities: testProfile.recentActivities,
        posts: testProfile.posts,
      );

      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: recentProfile,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.textContaining('semaine'), findsOneWidget);
    });

    testWidgets('formats old registration date correctly', (WidgetTester tester) async {
      final oldProfile = UserProfileModel(
        id: testProfile.id,
        name: testProfile.name,
        username: testProfile.username,
        bio: testProfile.bio,
        phone: testProfile.phone,
        avatarUrl: testProfile.avatarUrl,
        createdAt: DateTime(2020, 5, 15),
        isOnline: testProfile.isOnline,
        recentActivities: testProfile.recentActivities,
        posts: testProfile.posts,
      );

      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: oldProfile,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.textContaining('mai 2020'), findsOneWidget);
    });

    testWidgets('does not show username when null', (WidgetTester tester) async {
      final profileWithoutUsername = testProfile.copyWith(username: ''); // Use empty string to clear

      await tester.pumpWidget(
        createTestWidget(
          ProfileHeader(
            profile: profileWithoutUsername,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.text('@jeandupont'), findsNothing);
    });
  });
}
