/// Exemple d'utilisation des widgets de galerie média
/// 
/// Ce fichier montre comment utiliser MediaGrid, MediaListTile et FullScreenViewer
/// ensemble pour créer une galerie de médias complète.

import 'package:flutter/material.dart';
import '../../models/media/media_item.dart';
import '../../models/media/media_type.dart';
import '../../data/mock_media_data.dart';
import 'media_widgets.dart';

/// Exemple de page utilisant les widgets de galerie média
class MediaGalleryExample extends StatefulWidget {
  final String chatId;

  const MediaGalleryExample({
    super.key,
    required this.chatId,
  });

  @override
  State<MediaGalleryExample> createState() => _MediaGalleryExampleState();
}

class _MediaGalleryExampleState extends State<MediaGalleryExample>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<MediaType> _tabs = [
    MediaType.photo,
    MediaType.video,
    MediaType.document,
    MediaType.link,
    MediaType.voice,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<MediaItem> _getMediaForType(MediaType type) {
    final allMedia = MockMediaData.mediaByChat[widget.chatId] ?? [];
    return allMedia.where((item) => item.type == type).toList();
  }

  String _getTabLabel(MediaType type) {
    switch (type) {
      case MediaType.photo:
        return 'Photos';
      case MediaType.video:
        return 'Vidéos';
      case MediaType.document:
        return 'Documents';
      case MediaType.link:
        return 'Liens';
      case MediaType.voice:
        return 'Vocaux';
    }
  }

  IconData _getTabIcon(MediaType type) {
    switch (type) {
      case MediaType.photo:
        return Icons.photo;
      case MediaType.video:
        return Icons.videocam;
      case MediaType.document:
        return Icons.description;
      case MediaType.link:
        return Icons.link;
      case MediaType.voice:
        return Icons.mic;
    }
  }

  void _openFullScreenViewer(MediaItem item, List<MediaItem> gallery) {
    final index = gallery.indexOf(item);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenViewer(
          initialItem: item,
          gallery: gallery,
          initialIndex: index,
          onDownload: _handleDownload,
        ),
      ),
    );
  }

  void _handleDownload(MediaItem item) {
    // Simuler le téléchargement
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement de ${item.fileName ?? "média"} simulé'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie de médias'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((type) {
            return Tab(
              icon: Icon(_getTabIcon(type)),
              text: _getTabLabel(type),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((type) {
          final items = _getMediaForType(type);
          
          // Utiliser MediaGrid pour photos et vidéos
          if (type == MediaType.photo || type == MediaType.video) {
            return MediaGrid(
              items: items,
              onItemTap: (item, index) {
                _openFullScreenViewer(item, items);
              },
              crossAxisCount: 3,
            );
          }
          
          // Utiliser MediaListTile pour documents, liens et vocaux
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return MediaListTile(
                item: item,
                onTap: () {
                  if (type == MediaType.link) {
                    // Ouvrir le lien dans un navigateur
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ouverture de ${item.url}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    // Pour documents et vocaux, ouvrir en plein écran
                    _openFullScreenViewer(item, items);
                  }
                },
                onDownload: () => _handleDownload(item),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
