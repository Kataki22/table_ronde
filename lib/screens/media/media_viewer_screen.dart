import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/media/media_item.dart';
import '../../providers/media_gallery_provider.dart';
import '../../widgets/media/full_screen_viewer.dart';

/// Écran affichant un média en plein écran avec navigation dans la galerie
/// 
/// Utilise le widget FullScreenViewer pour afficher des photos et vidéos
/// en plein écran avec zoom, swipe pour naviguer, et contrôles.
/// 
/// Cet écran est ouvert depuis MediaGalleryBottomSheet lorsqu'on tape
/// sur une photo ou vidéo.
/// 
/// Validates: Requirements 5.5
class MediaViewerScreen extends StatelessWidget {
  /// Le média initial à afficher
  final MediaItem initialItem;
  
  /// Liste complète des médias pour la navigation
  final List<MediaItem> gallery;
  
  /// Index du média initial dans la galerie
  final int initialIndex;

  const MediaViewerScreen({
    super.key,
    required this.initialItem,
    required this.gallery,
    required this.initialIndex,
  });

  /// Route name pour la navigation
  static const String routeName = '/media-viewer';

  /// Méthode helper pour naviguer vers cet écran avec animation zoom in
  static Future<void> navigate(
    BuildContext context, {
    required MediaItem initialItem,
    required List<MediaItem> gallery,
    required int initialIndex,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MediaViewerScreen(
          initialItem: initialItem,
          gallery: gallery,
          initialIndex: initialIndex,
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Animation de zoom in depuis le centre
          const begin = 0.8;
          const end = 1.0;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: Curves.easeOutCubic),
          );
          final scaleAnimation = animation.drive(tween);
          
          // Animation de fade in
          final fadeAnimation = animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeOut),
            ),
          );
          
          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MediaGalleryProvider>();

    return FullScreenViewer(
      initialItem: initialItem,
      gallery: gallery,
      initialIndex: initialIndex,
      onDownload: (item) => _handleDownload(context, provider, item),
    );
  }

  /// Gère le téléchargement d'un média
  Future<void> _handleDownload(
    BuildContext context,
    MediaGalleryProvider provider,
    MediaItem item,
  ) async {
    // Vérifier si déjà en cours de téléchargement
    if (provider.isDownloading(item.id)) {
      return;
    }

    // Lancer le téléchargement simulé
    final success = await provider.downloadMedia(item);

    if (!context.mounted) return;

    // Afficher le résultat
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getMediaName(item)} téléchargé avec succès'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec du téléchargement de ${_getMediaName(item)}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Réessayer',
            textColor: Colors.white,
            onPressed: () => _handleDownload(context, provider, item),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Retourne le nom du média pour l'affichage
  String _getMediaName(MediaItem item) {
    if (item.fileName != null) {
      return item.fileName!;
    }
    return item.type.toString().split('.').last;
  }
}
