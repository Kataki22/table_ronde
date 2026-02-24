import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/providers/group_chat_provider.dart';

void main() {
  group('GroupChatProvider - Validation Tests', () {
    late GroupChatProvider provider;

    setUp(() {
      provider = GroupChatProvider();
    });

    group('Group Name Validation', () {
      test('should throw error when group name is empty', () async {
        expect(
          () => provider.createGroup(
            name: '',
            memberIds: ['user_2'],
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Le nom du groupe est requis',
          )),
        );
      });

      test('should throw error when group name is only whitespace', () async {
        expect(
          () => provider.createGroup(
            name: '   ',
            memberIds: ['user_2'],
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Le nom du groupe est requis',
          )),
        );
      });

      test('should throw error when group name exceeds 50 characters', () async {
        final longName = 'a' * 51;
        expect(
          () => provider.createGroup(
            name: longName,
            memberIds: ['user_2'],
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Le nom du groupe est trop long (maximum 50 caractères)',
          )),
        );
      });

      test('should accept group name with exactly 50 characters', () async {
        final maxName = 'a' * 50;
        final group = await provider.createGroup(
          name: maxName,
          memberIds: ['user_2'],
        );
        expect(group.name, equals(maxName));
      });

      test('should trim whitespace from group name', () async {
        final group = await provider.createGroup(
          name: '  Test Group  ',
          memberIds: ['user_2'],
        );
        expect(group.name, equals('Test Group'));
      });
    });

    group('Member Selection Validation', () {
      test('should throw error when no members are selected', () async {
        expect(
          () => provider.createGroup(
            name: 'Test Group',
            memberIds: [],
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Sélectionnez au moins un membre',
          )),
        );
      });

      test('should accept group with one member', () async {
        final group = await provider.createGroup(
          name: 'Test Group',
          memberIds: ['user_2'],
        );
        expect(group.members.length, greaterThanOrEqualTo(1));
      });

      test('should accept group with multiple members', () async {
        final group = await provider.createGroup(
          name: 'Test Group',
          memberIds: ['user_2', 'user_3', 'user_4'],
        );
        expect(group.members.length, greaterThanOrEqualTo(3));
      });

      test('should deduplicate member IDs', () async {
        final group = await provider.createGroup(
          name: 'Test Group',
          memberIds: ['user_2', 'user_2', 'user_3'],
        );
        // Should have unique members only
        final uniqueIds = group.members.map((m) => m.userId).toSet();
        expect(uniqueIds.length, equals(group.members.length));
      });
    });

    group('Successful Group Creation', () {
      test('should create group with valid data', () async {
        final group = await provider.createGroup(
          name: 'Flutter Team',
          description: 'Team for Flutter development',
          memberIds: ['user_2', 'user_3'],
        );

        expect(group.name, equals('Flutter Team'));
        expect(group.description, equals('Team for Flutter development'));
        expect(group.members.length, greaterThanOrEqualTo(2));
      });

      test('should create group without description', () async {
        final group = await provider.createGroup(
          name: 'Test Group',
          memberIds: ['user_2'],
        );

        expect(group.name, equals('Test Group'));
        expect(group.description, isNull);
      });

      test('should add group to provider list', () async {
        final initialCount = provider.groups.length;
        
        await provider.createGroup(
          name: 'New Group',
          memberIds: ['user_2'],
        );

        expect(provider.groups.length, equals(initialCount + 1));
      });

      test('should set current user as admin', () async {
        final group = await provider.createGroup(
          name: 'Test Group',
          memberIds: ['user_2'],
        );

        final currentUserMember = group.members.firstWhere(
          (m) => m.userId == provider.currentUserId,
        );
        expect(currentUserMember.permission.name, equals('admin'));
      });
    });
  });
}
