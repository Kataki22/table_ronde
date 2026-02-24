import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tableronde_app/models/media/media_item.dart';
import 'package:tableronde_app/models/media/media_type.dart';
import 'package:tableronde_app/providers/media_gallery_provider.dart';
import 'package:tableronde_app/screens/media/media_viewer_screen.dart';

void main() {
  group('MediaViewerScreen', () {
    late MediaGalleryProvider mockProvider;
    late List<MediaItem> testGallery;

    setUp(() {
      mockProvider = MediaGalleryProvider();
      mockProvider.initialize();

      // Créer une galerie de test avec quelques médias
      testGallery = [
        MediaItem(
          id: 'photo_1',
          type: MediaType.photo,
          url: 'assets/images/placeholder.png',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          senderId: 'user_1',
          senderName: 'Alice Dupont',
          fileSize: 1024 * 500, // 500 KB
        ),
        MediaItem(
          id: 'photo_2',
          type: MediaType.photo,
          url: 'assets/images/placeholder.png',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          senderId: 'user_2',
          senderName: 'Bob Martin',
          fileSize: 1024 * 750, // 750 KB
        ),
        MediaItem(
          id: 'video_1',
          type: MediaType.video,
          url: 'assets/images/placeholder.png',
          thumbnailUrl: 'assets/images/placeholder.png',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          senderId: 'user_3',
          senderName: 'Charlie Dubois',
          fileSize: 1024 * 1024 * 5, // 5 MB
          duration: 125, // 2:05
        ),
      ];
    });

    Widget createTestWidget(MediaItem initialItem, int initialIndex) {
      return ChangeNotifierProvider<MediaGalleryProvider>.value(
        value: mockProvider,
        child: MaterialApp(
          home: MediaViewerScreen(
            initialItem: initialItem,
            gallery: testGallery,
            initialIndex: initialIndex,
          ),
        ),
      );
    }

    testWidgets('should display FullScreenViewer with initial media',
        (WidgetTester tester) async {
      // Arrange
      final initialItem = testGallery[0];

      // Act
      await tester.pumpWidget(createTestWidget(initialItem, 0));
      await tester.pumpAndSettle();

      // Assert
      // Vérifier que le FullScreenViewer est affiché
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Vérifier que le nom de l'expéditeur est affiché
      expect(find.text('Alice Dupont'), findsOneWidget);
    });

    testWidgets('should display close button', (WidgetTester tester) async {
      // Arrange
      final initialItem = testGallery[0];

      // Act
      await tester.pumpWidget(createTestWidget(initialItem, 0));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should display download button', (WidgetTester tester) async {
      // Arrange
      final initialItem = testGallery[0];

      // Act
      await tester.pumpWidget(createTestWidget(initialItem, 0));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('should display page indicator when multiple items',
        (WidgetTester tester) async {
      // Arrange
      final initialItem = testGallery[0];

      // Act
      await tester.pumpWidget(createTestWidget(initialItem, 0));
      await tester.pumpAndSettle();

      // Assert
      // Vérifier que l'indicateur de page est affiché (1 / 3)
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('should allow swiping between media items',
        (WidgetTester tester) async {
      // Arrange
      final initialItem = testGallery[0];

      // Act
      await tester.pumpWidget(createTestWidget(initialItem, 0));
      await tester.pumpAndSettle();

      // Vérifier l'état initial
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('Alice Dupont'), findsOneWidget);

      // Swiper vers la gauche (aller au média suivant)
      // Note: On swipe vers la gauche pour aller à droite dans le PageView
      await tester.fling(
        find.byType(PageView),
        const Offset(-300, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // Assert
      // Vérifier que l'indicateur a changé
      expect(find.text('2 / 3'), findsOneWidget);
      // Vérifier que le nom de l'expéditeur a changé
      expect(find.text('Bob Martin'), findsOneWidget);
    });

    testWidgets('should close screen when close button is tapped',
        (WidgetTester tester) async {
      // Arrange
      final initialItem = testGallery[0];

      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<MediaGalleryProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    MediaViewerScreen.navigate(
                      context,
                      initialItem: initialItem,
                      gallery: testGallery,
                      initialIndex: 0,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      // Ouvrir le viewer
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Vérifier que le viewer est ouvert
      expect(find.text('Alice Dupont'), findsOneWidget);

      // Taper sur le bouton fermer
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Assert
      // Vérifier que le viewer est fermé
      expect(find.text('Alice Dupont'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('should display video controls for video items',
        (WidgetTester tester) async {
      // Arrange
      final videoItem = testGallery[2]; // Le troisième item est une vidéo

      // Act
      await tester.pumpWidget(createTestWidget(videoItem, 2));
      await tester.pumpAndSettle();

      // Assert
      // Vérifier que le bouton play est affiché pour les vidéos
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      
      // Vérifier que la durée est affichée
      expect(find.text('2:05'), findsOneWidget);
    });

    testWidgets('should toggle controls visibility on tap',
        (WidgetTester tester) async {
      // Arrange
      final initialItem = testGallery[0];

      // Act
      await tester.pumpWidget(createTestWidget(initialItem, 0));
      await tester.pumpAndSettle();

      // Vérifier que les contrôles sont visibles initialement
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Alice Dupont'), findsOneWidget);

      // Taper sur l'écran pour masquer les contrôles
      await tester.tap(find.byType(PageView));
      await tester.pumpAndSettle();

      // Assert
      // Les contrôles devraient être masqués
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.text('Alice Dupont'), findsNothing);

      // Taper à nouveau pour afficher les contrôles
      await tester.tap(find.byType(PageView));
      await tester.pumpAndSettle();

      // Les contrôles devraient être visibles à nouveau
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Alice Dupont'), findsOneWidget);
    });
  });
}
