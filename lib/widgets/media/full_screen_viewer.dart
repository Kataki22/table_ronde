import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/media/media_item.dart';
import '../../models/media/media_type.dart';

/// Widget affichant un média en plein écran avec zoom et navigation
/// 
/// Permet de visualiser des photos et vidéos en plein écran avec :
/// - Zoom pinch-to-zoom pour les images
/// - Swipe horizontal pour naviguer entre médias
/// - Contrôles pour les vidéos
/// - Informations du média (nom, date, expéditeur)
class FullScreenViewer extends StatefulWidget {
  /// Le média actuellement affiché
  final MediaItem initialItem;
  
  /// Liste complète des médias pour la navigation
  final List<MediaItem> gallery;
  
  /// Index du média initial dans la galerie
  final int initialIndex;
  
  /// Callback appelé lors du téléchargement
  final Function(MediaItem)? onDownload;

  const FullScreenViewer({
    super.key,
    required this.initialItem,
    required this.gallery,
    required this.initialIndex,
    this.onDownload,
  });

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;
  final TransformationController _transformationController = 
      TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 1.0,
    );
    
    // Masquer la barre de statut pour une expérience plein écran
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    
    // Restaurer la barre de statut
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  MediaItem get _currentItem => widget.gallery[_currentIndex];

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      // Réinitialiser le zoom lors du changement de page
      _transformationController.value = Matrix4.identity();
    });
  }

  void _handleDownload() {
    if (widget.onDownload != null) {
      widget.onDownload!(_currentItem);
      
      // Afficher un feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Téléchargement de ${_getMediaName()} en cours...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getMediaName() {
    if (_currentItem.fileName != null) {
      return _currentItem.fileName!;
    }
    return _currentItem.type == MediaType.video ? 'vidéo' : 'image';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Contenu principal avec PageView pour swipe
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.gallery.length,
              physics: const BouncingScrollPhysics(),
              pageSnapping: true,
              itemBuilder: (context, index) {
                final item = widget.gallery[index];
                
                // Animation de transition entre pages (250ms)
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      // Limiter l'effet aux pages adjacentes
                      value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                    }
                    
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildMediaContent(item),
                );
              },
            ),
            
            // Contrôles supérieurs (barre d'app)
            if (_showControls) _buildTopBar(),
            
            // Contrôles inférieurs (informations et actions)
            if (_showControls) _buildBottomBar(),
            
            // Indicateur de page si plusieurs médias
            if (widget.gallery.length > 1 && _showControls)
              _buildPageIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(MediaItem item) {
    if (item.type == MediaType.video) {
      return _buildVideoPlayer(item);
    } else {
      return _buildImageViewer(item);
    }
  }

  Widget _buildImageViewer(MediaItem item) {
    return Center(
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.asset(
          item.url,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Impossible de charger l\'image',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(MediaItem item) {
    // Pour l'instant, afficher une miniature avec un bouton play
    // Dans une implémentation complète, utiliser video_player package
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail de la vidéo
          Image.asset(
            item.thumbnailUrl ?? item.url,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: Icon(
                  Icons.videocam,
                  size: 64,
                  color: Colors.grey[600],
                ),
              );
            },
          ),
          
          // Bouton play
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.black87,
              size: 48,
            ),
          ),
          
          // Durée en bas à droite
          if (item.duration != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.formattedDuration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Bouton retour
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Fermer',
                ),
                
                const Spacer(),
                
                // Bouton télécharger
                if (widget.onDownload != null)
                  IconButton(
                    icon: const Icon(Icons.download),
                    color: Colors.white,
                    onPressed: _handleDownload,
                    tooltip: 'Télécharger',
                  ),
                
                // Bouton partager
                IconButton(
                  icon: const Icon(Icons.share),
                  color: Colors.white,
                  onPressed: () {
                    // TODO: Implémenter le partage
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité de partage à venir'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Partager',
                ),
                
                // Bouton plus d'options
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: Colors.white,
                  onPressed: () {
                    // TODO: Afficher menu d'options
                  },
                  tooltip: 'Plus d\'options',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nom de l'expéditeur
                Text(
                  _currentItem.senderName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Date et taille
                Row(
                  children: [
                    Text(
                      _formatDate(_currentItem.timestamp),
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                      ),
                    ),
                    if (_currentItem.fileSize != null) ...[
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      Text(
                        _currentItem.formattedSize,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentIndex + 1} / ${widget.gallery.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
      return days[date.weekday - 1];
    } else if (difference.inDays < 365) {
      final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 
                      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
      return '${date.day} ${months[date.month - 1]}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
