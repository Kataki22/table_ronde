import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/media/media_type.dart';
import '../../models/media/media_item.dart';
import '../../providers/media_gallery_provider.dart';
import '../../widgets/media/media_grid.dart';
import '../../widgets/media/media_list_tile.dart';
import '../../utils/responsive_layout.dart';
import 'media_viewer_screen.dart';

/// Bottom sheet affichant la galerie de médias partagés dans une conversation
/// 
/// Organise les médias en 5 onglets : Photos, Vidéos, Documents, Liens, Vocaux
/// Utilise MediaGrid pour photos/vidéos et MediaListTile pour les autres types
/// 
/// Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.6
class MediaGalleryBottomSheet extends StatefulWidget {
  /// ID de la conversation dont on affiche les médias
  final String chatId;

  const MediaGalleryBottomSheet({
    super.key,
    required this.chatId,
  });

  @override
  State<MediaGalleryBottomSheet> createState() => _MediaGalleryBottomSheetState();
}

class _MediaGalleryBottomSheetState extends State<MediaGalleryBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mapping des onglets vers les types de médias
  final List<MediaType> _tabTypes = [
    MediaType.photo,
    MediaType.video,
    MediaType.document,
    MediaType.link,
    MediaType.voice,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Synchroniser le tab sélectionné avec le provider
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final provider = context.read<MediaGalleryProvider>();
        provider.selectTab(_tabTypes[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.shouldUseDesktopLayout(context);
    
    // On desktop, show as a dialog instead of bottom sheet
    if (isDesktop) {
      return Dialog(
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _buildContent(context),
        ),
      );
    }

    // On mobile, show as bottom sheet
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: _buildContent(context),
    );
  }

  /// Builds the main content (shared between mobile and desktop)
  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Handle pour glisser le bottom sheet (mobile only)
        if (!ResponsiveLayout.shouldUseDesktopLayout(context))
          _buildHandle(),
        
        // En-tête avec titre
        _buildHeader(context),
        
        // TabBar avec les 5 onglets
        _buildTabBar(context),
        
        // Contenu des onglets
        Expanded(
          child: _buildTabBarView(context),
        ),
      ],
    );
  }

  /// Construit le handle de glissement
  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Construit l'en-tête avec le titre
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Médias partagés',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Fermer',
          ),
        ],
      ),
    );
  }

  /// Construit la barre d'onglets
  Widget _buildTabBar(BuildContext context) {
    return Consumer<MediaGalleryProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            tabs: [
              _buildTab(
                'Photos',
                provider.getMediaCount(widget.chatId, MediaType.photo),
              ),
              _buildTab(
                'Vidéos',
                provider.getMediaCount(widget.chatId, MediaType.video),
              ),
              _buildTab(
                'Documents',
                provider.getMediaCount(widget.chatId, MediaType.document),
              ),
              _buildTab(
                'Liens',
                provider.getMediaCount(widget.chatId, MediaType.link),
              ),
              _buildTab(
                'Vocaux',
                provider.getMediaCount(widget.chatId, MediaType.voice),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construit un onglet avec son compteur
  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construit le contenu des onglets
  Widget _buildTabBarView(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildMediaTab(context, MediaType.photo),
        _buildMediaTab(context, MediaType.video),
        _buildMediaTab(context, MediaType.document),
        _buildMediaTab(context, MediaType.link),
        _buildMediaTab(context, MediaType.voice),
      ],
    );
  }

  /// Construit le contenu d'un onglet selon le type de média
  Widget _buildMediaTab(BuildContext context, MediaType type) {
    return Consumer<MediaGalleryProvider>(
      builder: (context, provider, child) {
        final mediaItems = provider.getMediaForChat(widget.chatId, type);

        if (mediaItems.isEmpty) {
          return _buildEmptyState(type);
        }

        // Utiliser MediaGrid pour photos et vidéos
        if (type == MediaType.photo || type == MediaType.video) {
          return MediaGrid(
            items: mediaItems,
            onItemTap: (item, index) => _handleMediaTap(context, item, mediaItems),
          );
        }

        // Utiliser une liste pour documents, liens et vocaux
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: mediaItems.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey[300],
          ),
          itemBuilder: (context, index) {
            final item = mediaItems[index];
            return MediaListTile(
              item: item,
              onTap: () => _handleMediaTap(context, item, mediaItems),
              onDownload: () => _handleDownload(context, item),
            );
          },
        );
      },
    );
  }

  /// Construit l'état vide pour un type de média
  Widget _buildEmptyState(MediaType type) {
    final String message;
    final IconData icon;

    switch (type) {
      case MediaType.photo:
        message = 'Aucune photo partagée';
        icon = Icons.photo_library_outlined;
        break;
      case MediaType.video:
        message = 'Aucune vidéo partagée';
        icon = Icons.video_library_outlined;
        break;
      case MediaType.document:
        message = 'Aucun document partagé';
        icon = Icons.description_outlined;
        break;
      case MediaType.link:
        message = 'Aucun lien partagé';
        icon = Icons.link_outlined;
        break;
      case MediaType.voice:
        message = 'Aucun message vocal';
        icon = Icons.mic_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Gère le tap sur un média
  void _handleMediaTap(
    BuildContext context,
    MediaItem item,
    List<MediaItem> gallery,
  ) {
    final provider = context.read<MediaGalleryProvider>();

    // Pour les photos et vidéos, ouvrir la prévisualisation plein écran
    if (item.type == MediaType.photo || item.type == MediaType.video) {
      provider.openMediaViewer(item, gallery);
      
      // Trouver l'index du média dans la galerie
      final index = gallery.indexOf(item);
      
      // Naviguer vers MediaViewerScreen
      MediaViewerScreen.navigate(
        context,
        initialItem: item,
        gallery: gallery,
        initialIndex: index,
      );
    } else {
      // Pour les autres types, proposer de télécharger
      _handleDownload(context, item);
    }
  }

  /// Gère le téléchargement d'un média
  Future<void> _handleDownload(BuildContext context, MediaItem item) async {
    final provider = context.read<MediaGalleryProvider>();

    // Vérifier si déjà en cours de téléchargement
    if (provider.isDownloading(item.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Téléchargement déjà en cours'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Afficher un message de début de téléchargement
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement de ${_getMediaName(item)}...'),
        duration: const Duration(seconds: 2),
      ),
    );

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
            onPressed: () => _handleDownload(context, item),
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
    
    switch (item.type) {
      case MediaType.photo:
        return 'la photo';
      case MediaType.video:
        return 'la vidéo';
      case MediaType.document:
        return 'le document';
      case MediaType.link:
        return 'le lien';
      case MediaType.voice:
        return 'le message vocal';
    }
  }
}
