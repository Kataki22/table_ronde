import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/models/media/media_models.dart';

void main() {
  group('MediaItem', () {
    test('should create a MediaItem with all required fields', () {
      final timestamp = DateTime.now();
      final mediaItem = MediaItem(
        id: '1',
        type: MediaType.photo,
        url: 'https://example.com/photo.jpg',
        timestamp: timestamp,
        senderId: 'user1',
        senderName: 'John Doe',
      );

      expect(mediaItem.id, '1');
      expect(mediaItem.type, MediaType.photo);
      expect(mediaItem.url, 'https://example.com/photo.jpg');
      expect(mediaItem.timestamp, timestamp);
      expect(mediaItem.senderId, 'user1');
      expect(mediaItem.senderName, 'John Doe');
    });

    test('should create a MediaItem with optional fields', () {
      final mediaItem = MediaItem(
        id: '2',
        type: MediaType.video,
        url: 'https://example.com/video.mp4',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        fileName: 'video.mp4',
        fileSize: 1024000,
        duration: 125,
        timestamp: DateTime.now(),
        senderId: 'user2',
        senderName: 'Jane Smith',
      );

      expect(mediaItem.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(mediaItem.fileName, 'video.mp4');
      expect(mediaItem.fileSize, 1024000);
      expect(mediaItem.duration, 125);
    });

    group('formattedSize', () {
      test('should return empty string when fileSize is null', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.link,
          url: 'https://example.com',
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedSize, '');
      });

      test('should format bytes correctly', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.document,
          url: 'https://example.com/doc.pdf',
          fileSize: 512,
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedSize, '512 B');
      });

      test('should format kilobytes correctly', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.document,
          url: 'https://example.com/doc.pdf',
          fileSize: 1536, // 1.5 KB
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedSize, '1.5 KB');
      });

      test('should format megabytes correctly', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.video,
          url: 'https://example.com/video.mp4',
          fileSize: 5242880, // 5 MB
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedSize, '5.0 MB');
      });

      test('should format gigabytes correctly', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.video,
          url: 'https://example.com/video.mp4',
          fileSize: 2147483648, // 2 GB
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedSize, '2.0 GB');
      });

      test('should handle edge case of 1 byte', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.document,
          url: 'https://example.com/doc.pdf',
          fileSize: 1,
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedSize, '1 B');
      });

      test('should handle edge case of exactly 1 KB', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.document,
          url: 'https://example.com/doc.pdf',
          fileSize: 1024,
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedSize, '1.0 KB');
      });

      test('should handle edge case of exactly 1 MB', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.video,
          url: 'https://example.com/video.mp4',
          fileSize: 1048576,
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedSize, '1.0 MB');
      });
    });

    group('formattedDuration', () {
      test('should return empty string when duration is null', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.photo,
          url: 'https://example.com/photo.jpg',
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedDuration, '');
      });

      test('should format seconds only (less than 1 minute)', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.voice,
          url: 'https://example.com/voice.m4a',
          duration: 45,
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedDuration, '0:45');
      });

      test('should format minutes and seconds', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.voice,
          url: 'https://example.com/voice.m4a',
          duration: 125, // 2:05
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedDuration, '2:05');
      });

      test('should format hours, minutes and seconds', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.video,
          url: 'https://example.com/video.mp4',
          duration: 3725, // 1:02:05
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedDuration, '1:02:05');
      });

      test('should pad single digit seconds with zero', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.voice,
          url: 'https://example.com/voice.m4a',
          duration: 5,
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedDuration, '0:05');
      });

      test('should pad single digit minutes with zero in hours format', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.video,
          url: 'https://example.com/video.mp4',
          duration: 3605, // 1:00:05
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedDuration, '1:00:05');
      });

      test('should handle edge case of 0 seconds', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.voice,
          url: 'https://example.com/voice.m4a',
          duration: 0,
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedDuration, '0:00');
      });

      test('should handle edge case of exactly 1 hour', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.video,
          url: 'https://example.com/video.mp4',
          duration: 3600,
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedDuration, '1:00:00');
      });

      test('should handle edge case of exactly 1 minute', () {
        final mediaItem = MediaItem(
          id: '1',
          type: MediaType.voice,
          url: 'https://example.com/voice.m4a',
          duration: 60,
          timestamp: DateTime.now(),
          senderId: 'user1',
          senderName: 'User',
        );

        expect(mediaItem.formattedDuration, '1:00');
      });
    });
  });

  group('MediaType', () {
    test('should have all expected media types', () {
      expect(MediaType.values.length, 5);
      expect(MediaType.values, contains(MediaType.photo));
      expect(MediaType.values, contains(MediaType.video));
      expect(MediaType.values, contains(MediaType.document));
      expect(MediaType.values, contains(MediaType.link));
      expect(MediaType.values, contains(MediaType.voice));
    });
  });
}
