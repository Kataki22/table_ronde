import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tableronde_app/models/groups/group_member_model.dart';
import 'package:tableronde_app/models/groups/group_permission.dart';
import 'package:tableronde_app/widgets/groups/member_list_tile.dart';
import 'package:tableronde_app/utils/app_theme.dart';
import 'package:tableronde_app/providers/theme_provider.dart';

void main() {
  group('MemberListTile Widget Tests', () {
    late GroupMemberModel testMember;

    setUp(() {
      testMember = GroupMemberModel(
        userId: 'user123',
        name: 'John Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
        permission: GroupPermission.member,
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
      );
    });

    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('displays member name', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(member: testMember),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays member avatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(member: testMember),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays member initial when no avatar URL', (WidgetTester tester) async {
      final memberNoAvatar = GroupMemberModel(
        userId: 'user456',
        name: 'Jane Smith',
        avatarUrl: null,
        permission: GroupPermission.member,
        joinedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(member: memberNoAvatar),
        ),
      );

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('displays admin badge for admin permission', (WidgetTester tester) async {
      final adminMember = testMember.copyWith(permission: GroupPermission.admin);

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(member: adminMember),
        ),
      );

      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('displays moderator badge for moderator permission', (WidgetTester tester) async {
      final modMember = testMember.copyWith(permission: GroupPermission.moderator);

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(member: modMember),
        ),
      );

      expect(find.text('Modo'), findsOneWidget);
    });

    testWidgets('displays member badge for member permission', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(member: testMember),
        ),
      );

      expect(find.text('Membre'), findsOneWidget);
    });

    testWidgets('displays join date', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(member: testMember),
        ),
      );

      // Should display "Membre depuis" text
      expect(find.textContaining('Membre depuis'), findsOneWidget);
    });

    testWidgets('formats recent join date correctly', (WidgetTester tester) async {
      final recentMember = testMember.copyWith(
        joinedAt: DateTime.now().subtract(const Duration(days: 3)),
      );

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(member: recentMember),
        ),
      );

      expect(find.textContaining('il y a 3 jours'), findsOneWidget);
    });

    testWidgets('formats today join date correctly', (WidgetTester tester) async {
      final todayMember = testMember.copyWith(
        joinedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(member: todayMember),
        ),
      );

      expect(find.textContaining("aujourd'hui"), findsOneWidget);
    });

    testWidgets('does not show actions menu when canManage is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: testMember,
            canManage: false,
            isCurrentUserAdmin: false,
          ),
        ),
      );

      expect(find.byType(PopupMenuButton<String>), findsNothing);
    });

    testWidgets('shows actions menu when canManage is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: testMember,
            canManage: true,
          ),
        ),
      );

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('shows actions menu when isCurrentUserAdmin is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: testMember,
            isCurrentUserAdmin: true,
          ),
        ),
      );

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('calls onTap when tile is tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: testMember,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows remove option in menu when canManage is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: testMember,
            canManage: true,
          ),
        ),
      );

      // Open the menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Retirer du groupe'), findsOneWidget);
    });

    testWidgets('shows promote admin option for non-admin when isCurrentUserAdmin is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: testMember,
            isCurrentUserAdmin: true,
          ),
        ),
      );

      // Open the menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Promouvoir admin'), findsOneWidget);
    });

    testWidgets('shows promote moderator option for non-moderator when isCurrentUserAdmin is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: testMember,
            isCurrentUserAdmin: true,
          ),
        ),
      );

      // Open the menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Promouvoir modérateur'), findsOneWidget);
    });

    testWidgets('calls onRemove when remove option is selected', (WidgetTester tester) async {
      bool removed = false;

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: testMember,
            canManage: true,
            onRemove: () {
              removed = true;
            },
          ),
        ),
      );

      // Open the menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap remove option
      await tester.tap(find.text('Retirer du groupe'));
      await tester.pumpAndSettle();

      expect(removed, isTrue);
    });

    testWidgets('calls onChangePermission with admin when promote admin is selected', (WidgetTester tester) async {
      GroupPermission? changedPermission;

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: testMember,
            isCurrentUserAdmin: true,
            onChangePermission: (permission) {
              changedPermission = permission;
            },
          ),
        ),
      );

      // Open the menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap promote admin option
      await tester.tap(find.text('Promouvoir admin'));
      await tester.pumpAndSettle();

      expect(changedPermission, equals(GroupPermission.admin));
    });

    testWidgets('calls onChangePermission with moderator when promote moderator is selected', (WidgetTester tester) async {
      GroupPermission? changedPermission;

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: testMember,
            isCurrentUserAdmin: true,
            onChangePermission: (permission) {
              changedPermission = permission;
            },
          ),
        ),
      );

      // Open the menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap promote moderator option
      await tester.tap(find.text('Promouvoir modérateur'));
      await tester.pumpAndSettle();

      expect(changedPermission, equals(GroupPermission.moderator));
    });

    testWidgets('shows demote option for admin member when isCurrentUserAdmin is true', (WidgetTester tester) async {
      final adminMember = testMember.copyWith(permission: GroupPermission.admin);

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: adminMember,
            isCurrentUserAdmin: true,
          ),
        ),
      );

      // Open the menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Rétrograder membre'), findsOneWidget);
    });

    testWidgets('calls onChangePermission with member when demote is selected', (WidgetTester tester) async {
      GroupPermission? changedPermission;
      final adminMember = testMember.copyWith(permission: GroupPermission.admin);

      await tester.pumpWidget(
        createTestWidget(
          MemberListTile(
            member: adminMember,
            isCurrentUserAdmin: true,
            onChangePermission: (permission) {
              changedPermission = permission;
            },
          ),
        ),
      );

      // Open the menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap demote option
      await tester.tap(find.text('Rétrograder membre'));
      await tester.pumpAndSettle();

      expect(changedPermission, equals(GroupPermission.member));
    });
  });
}
