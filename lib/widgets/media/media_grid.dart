import 'package:flutter/material.dart';
import '../../models/media/media_item.dart';
import '../../models/media/media_type.dart';
import '../../utils/accessibility_helpers.dart';

/// Widget affichant une grille de miniatures pour photos et vidéos
/// 
/// Utilisé dans la galerie de médias pour afficher les photos et vidéos
/// sous forme de grille avec indicateur de durée pour les vidéos.
class MediaGrid extends StatelessWidget {
  /// Liste des médias à afficher
  final List<MediaItem> items;
  
  /// Callback appelé lors du tap sur un média
  /// Reçoit le média et son index dans la liste
  final Function(MediaItem, int) onItemTap;
  
  /// Nombre de colonnes dans la grille (par défaut 3)
  final int crossAxisCount;
  
  const MediaGrid({
    super.key,
    required this.items,
    required this.onItemTap,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun média',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _MediaGridTile(
          item: item,
          onTap: () => onItemTap(item, index),
        );
      },
    );
  }
}

/// Tuile individuelle dans la grille de médias
class _MediaGridTile extends StatefulWidget {
  final MediaItem item;
  final VoidCallback onTap;

  const _MediaGridTile({
    required this.item,
    required this.onTap,
  });

  @override
  State<_MediaGridTile> createState() => _MediaGridTileState();
}

class _MediaGridTileState extends State<_MediaGridTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = widget.item.type == MediaType.video
        ? AccessibilityHelpers.video
        : AccessibilityHelpers.image;
    final durationLabel = widget.item.type == MediaType.video && widget.item.duration != null
        ? widget.item.formattedDuration
        : null;
    
    return Semantics(
      label: AccessibilityHelpers.mediaItemLabel(
        type: typeLabel,
        fileName: widget.item.fileName ?? typeLabel,
        duration: durationLabel,
        size: null,
      ),
      hint: AccessibilityHelpers.tapToOpen,
      button: true,
      enabled: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image de fond (thumbnail pour vidéo, url pour photo)
              _buildMediaImage(),
              
              // Overlay pour les vidéos avec icône play et durée
              if (widget.item.type == MediaType.video) _buildVideoOverlay(),
              
              // Bordure au tap avec ripple effect
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  splashColor: Colors.white.withValues(alpha: 0.3),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  hoverColor: _isHovered 
                      ? Colors.white.withValues(alpha: 0.1)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildMediaImage() {
    final imageUrl = widget.item.type == MediaType.video 
        ? (widget.item.thumbnailUrl ?? widget.item.url)
        : widget.item.url;

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Icon(
            widget.item.type == MediaType.video ? Icons.videocam : Icons.image,
            size: 40,
            color: Colors.grey[600],
          ),
        );
      },
    );
  }

  Widget _buildVideoOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Icône play au centre
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.black87,
                size: 24,
              ),
            ),
          ),
          
          // Durée en bas à droite
          if (widget.item.duration != null)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.item.formattedDuration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
