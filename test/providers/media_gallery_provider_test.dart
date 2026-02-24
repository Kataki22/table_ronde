import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/models/media/media_item.dart';
import 'package:tableronde_app/models/media/media_type.dart';
import 'package:tableronde_app/providers/media_gallery_provider.dart';

void main() {
  group('MediaGalleryProvider', () {
    late MediaGalleryProvider provider;

    setUp(() {
      provider = MediaGalleryProvider();
    });

    test('should initialize successfully', () async {
      expect(provider.isInitialized, false);
      
      await provider.initialize();
      
      expect(provider.isInitialized, true);
    });

    test('should have default selected tab as photo', () {
      expect(provider.selectedTab, MediaType.photo);
    });

    test('should change selected tab', () {
      provider.selectTab(MediaType.video);
      expect(provider.selectedTab, MediaType.video);
      
      provider.selectTab(MediaType.document);
      expect(provider.selectedTab, MediaType.document);
    });

    test('should load media from mock data after initialization', () async {
      await provider.initialize();
      
      // Check that group_1 has media
      final group1Photos = provider.getPhotos('group_1');
      expect(group1Photos.isNotEmpty, true);
      
      final group1Videos = provider.getVideos('group_1');
      expect(group1Videos.isNotEmpty, true);
      
      final group1Documents = provider.getDocuments('group_1');
      expect(group1Documents.isNotEmpty, true);
    });

    test('should filter media by type correctly', () async {
      await provider.initialize();
      
      final photos = provider.getPhotos('group_1');
      expect(photos.every((item) => item.type == MediaType.photo), true);
      
      final videos = provider.getVideos('group_1');
      expect(videos.every((item) => item.type == MediaType.video), true);
      
      final documents = provider.getDocuments('group_1');
      expect(documents.every((item) => item.type == MediaType.document), true);
      
      final links = provider.getLinks('group_1');
      expect(links.every((item) => item.type == MediaType.link), true);
      
      final voiceMessages = provider.getVoiceMessages('group_1');
      expect(voiceMessages.every((item) => item.type == MediaType.voice), true);
    });

    test('should return empty list for chat with no media', () async {
      await provider.initialize();
      
      final photos = provider.getPhotos('nonexistent_chat');
      expect(photos, isEmpty);
    });

    test('should sort media by timestamp (most recent first)', () async {
      await provider.initialize();
      
      final photos = provider.getPhotos('group_1');
      if (photos.length > 1) {
        for (int i = 0; i < photos.length - 1; i++) {
          expect(
            photos[i].timestamp.isAfter(photos[i + 1].timestamp) ||
                photos[i].timestamp.isAtSameMomentAs(photos[i + 1].timestamp),
            true,
          );
        }
      }
    });

    test('should open media viewer with gallery', () async {
      await provider.initialize();
      
      final photos = provider.getPhotos('group_1');
      expect(photos.isNotEmpty, true);
      
      final firstPhoto = photos.first;
      provider.openMediaViewer(firstPhoto, photos);
      
      expect(provider.currentMediaItem, firstPhoto);
      expect(provider.currentGallery.length, photos.length);
      expect(provider.currentMediaIndex, 1);
      expect(provider.galleryItemCount, photos.length);
    });

    test('should navigate to next media in viewer', () async {
      await provider.initialize();
      
      final photos = provider.getPhotos('group_1');
      expect(photos.length >= 2, true);
      
      provider.openMediaViewer(photos.first, photos);
      expect(provider.currentMediaIndex, 1);
      
      provider.navigateToNextMedia();
      expect(provider.currentMediaItem, photos[1]);
      expect(provider.currentMediaIndex, 2);
    });

    test('should navigate to previous media in viewer', () async {
      await provider.initialize();
      
      final photos = provider.getPhotos('group_1');
      expect(photos.length >= 2, true);
      
      provider.openMediaViewer(photos[1], photos);
      expect(provider.currentMediaIndex, 2);
      
      provider.navigateToPreviousMedia();
      expect(provider.currentMediaItem, photos[0]);
      expect(provider.currentMediaIndex, 1);
    });

    test('should wrap around when navigating at boundaries', () async {
      await provider.initialize();
      
      final photos = provider.getPhotos('group_1');
      expect(photos.isNotEmpty, true);
      
      // Test wrap to beginning
      provider.openMediaViewer(photos.last, photos);
      provider.navigateToNextMedia();
      expect(provider.currentMediaItem, photos.first);
      
      // Test wrap to end
      provider.openMediaViewer(photos.first, photos);
      provider.navigateToPreviousMedia();
      expect(provider.currentMediaItem, photos.last);
    });

    test('should close media viewer', () async {
      await provider.initialize();
      
      final photos = provider.getPhotos('group_1');
      provider.openMediaViewer(photos.first, photos);
      
      expect(provider.currentMediaItem, isNotNull);
      expect(provider.currentGallery.isNotEmpty, true);
      
      provider.closeMediaViewer();
      
      expect(provider.currentMediaItem, isNull);
      expect(provider.currentGallery, isEmpty);
    });

    test('should track downloading state', () async {
      await provider.initialize();
      
      final photos = provider.getPhotos('group_1');
      final photo = photos.first;
      
      expect(provider.isDownloading(photo.id), false);
      
      // Start download (don't await to check state)
      final downloadFuture = provider.downloadMedia(photo);
      
      // Should be downloading now
      expect(provider.isDownloading(photo.id), true);
      
      // Wait for download to complete
      await downloadFuture;
      
      // Should no longer be downloading
      expect(provider.isDownloading(photo.id), false);
    });

    test('should prevent duplicate downloads', () async {
      await provider.initialize();
      
      final photos = provider.getPhotos('group_1');
      final photo = photos.first;
      
      // Start first download
      final download1 = provider.downloadMedia(photo);
      
      // Try to start second download
      final download2 = provider.downloadMedia(photo);
      
      // Second download should return false immediately
      expect(await download2, false);
      
      // Wait for first download to complete
      await download1;
    });

    test('should get media count by type', () async {
      await provider.initialize();
      
      final photoCount = provider.getMediaCount('group_1', MediaType.photo);
      final videoCount = provider.getMediaCount('group_1', MediaType.video);
      
      expect(photoCount, greaterThan(0));
      expect(videoCount, greaterThan(0));
    });

    test('should get total media count', () async {
      await provider.initialize();
      
      final totalCount = provider.getTotalMediaCount('group_1');
      expect(totalCount, greaterThan(0));
    });

    test('should check if chat has media', () async {
      await provider.initialize();
      
      expect(provider.hasMedia('group_1'), true);
      expect(provider.hasMedia('nonexistent_chat'), false);
    });

    test('should clear all data', () async {
      await provider.initialize();
      
      expect(provider.isInitialized, true);
      expect(provider.hasMedia('group_1'), true);
      
      provider.clear();
      
      expect(provider.isInitialized, false);
      expect(provider.hasMedia('group_1'), false);
      expect(provider.selectedTab, MediaType.photo);
      expect(provider.currentMediaItem, isNull);
    });
  });
}
