import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/models/chat_model.dart';
import 'package:tableronde_app/models/groups/group_member_model.dart';
import 'package:tableronde_app/models/groups/group_permission.dart';
import 'package:tableronde_app/widgets/groups/group_chat_bubble.dart';
import 'package:tableronde_app/utils/app_theme.dart';

void main() {
  group('GroupChatBubble Widget Tests', () {
    late GroupMemberModel testSender;
    late MessageModel testMessage;

    setUp(() {
      testSender = GroupMemberModel(
        userId: 'user123',
        name: 'John Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
        permission: GroupPermission.member,
        joinedAt: DateTime.now(),
      );

      testMessage = MessageModel(
        id: 'msg123',
        text: 'Hello, this is a test message!',
        isSentByMe: false,
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.text,
      );
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('displays sender name for received messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: testMessage,
            sender: testSender,
            showAvatar: true,
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays message text', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: testMessage,
            sender: testSender,
            showAvatar: true,
          ),
        ),
      );

      expect(find.text('Hello, this is a test message!'), findsOneWidget);
    });

    testWidgets('shows avatar when showAvatar is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: testMessage,
            sender: testSender,
            showAvatar: true,
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('hides avatar when showAvatar is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: testMessage,
            sender: testSender,
            showAvatar: false,
          ),
        ),
      );

      // Should still find CircleAvatar but it will be replaced with SizedBox
      expect(find.byType(CircleAvatar), findsNothing);
    });

    testWidgets('does not show sender name for sent messages', (WidgetTester tester) async {
      final sentMessage = MessageModel(
        id: 'msg456',
        text: 'My message',
        isSentByMe: true,
        timestamp: DateTime.now(),
        isRead: true,
        type: MessageType.text,
      );

      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: sentMessage,
            sender: testSender,
            showAvatar: true,
          ),
        ),
      );

      // Sender name should not be displayed for sent messages
      expect(find.text('John Doe'), findsNothing);
    });

    testWidgets('calls onTap when message is tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: testMessage,
            sender: testSender,
            showAvatar: true,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('calls onLongPress when message is long pressed', (WidgetTester tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: testMessage,
            sender: testSender,
            showAvatar: true,
            onLongPress: () {
              longPressed = true;
            },
          ),
        ),
      );

      await tester.longPress(find.byType(GestureDetector).first);
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('displays read status for sent messages', (WidgetTester tester) async {
      final sentMessage = MessageModel(
        id: 'msg789',
        text: 'Read message',
        isSentByMe: true,
        timestamp: DateTime.now(),
        isRead: true,
        type: MessageType.text,
      );

      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: sentMessage,
            sender: testSender,
            showAvatar: true,
          ),
        ),
      );

      // Should show double check mark for read messages
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('displays unread status for sent messages', (WidgetTester tester) async {
      final sentMessage = MessageModel(
        id: 'msg790',
        text: 'Unread message',
        isSentByMe: true,
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.text,
      );

      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: sentMessage,
            sender: testSender,
            showAvatar: true,
          ),
        ),
      );

      // Should show single check mark for unread messages
      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets('displays edited indicator for edited messages', (WidgetTester tester) async {
      final editedMessage = MessageModel(
        id: 'msg791',
        text: 'Edited message',
        isSentByMe: false,
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.text,
        isEdited: true,
      );

      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: editedMessage,
            sender: testSender,
            showAvatar: true,
          ),
        ),
      );

      expect(find.text('modifié'), findsOneWidget);
    });

    testWidgets('displays document message correctly', (WidgetTester tester) async {
      final documentMessage = MessageModel(
        id: 'msg792',
        text: '',
        isSentByMe: false,
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.document,
        attachmentName: 'test_document.pdf',
      );

      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: documentMessage,
            sender: testSender,
            showAvatar: true,
          ),
        ),
      );

      expect(find.text('test_document.pdf'), findsOneWidget);
      expect(find.byIcon(Icons.insert_drive_file), findsOneWidget);
    });

    testWidgets('displays voice message correctly', (WidgetTester tester) async {
      final voiceMessage = MessageModel(
        id: 'msg793',
        text: '',
        isSentByMe: false,
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.voice,
        voiceDuration: 125, // 2:05
      );

      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: voiceMessage,
            sender: testSender,
            showAvatar: true,
          ),
        ),
      );

      expect(find.text('02:05'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('displays sender initial when no avatar URL', (WidgetTester tester) async {
      final senderNoAvatar = GroupMemberModel(
        userId: 'user456',
        name: 'Jane Smith',
        avatarUrl: null,
        permission: GroupPermission.member,
        joinedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          GroupChatBubble(
            message: testMessage,
            sender: senderNoAvatar,
            showAvatar: true,
          ),
        ),
      );

      expect(find.text('J'), findsOneWidget);
    });
  });
}
