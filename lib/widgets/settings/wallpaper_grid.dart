import 'package:flutter/material.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';

/// Widget affichant une grille de fonds d'écran prédéfinis
///
/// Permet à l'utilisateur de sélectionner un fond d'écran pour une conversation.
/// Affiche une grille de miniatures avec un indicateur visuel pour le fond d'écran
/// actuellement sélectionné.
///
/// Validates: Requirements 4.2
class WallpaperGrid extends StatelessWidget {
  /// Liste des URLs de fonds d'écran disponibles
  final List<String> wallpapers;

  /// URL du fond d'écran actuellement sélectionné (null = aucun/défaut)
  final String? selectedWallpaper;

  /// Callback appelé lorsqu'un fond d'écran est sélectionné
  final ValueChanged<String> onWallpaperSelected;

  /// Nombre de colonnes dans la grille (par défaut 3)
  final int crossAxisCount;

  /// Espacement entre les éléments de la grille
  final double spacing;

  const WallpaperGrid({
    super.key,
    required this.wallpapers,
    this.selectedWallpaper,
    required this.onWallpaperSelected,
    this.crossAxisCount = 3,
    this.spacing = AppTheme.spacingSmall,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.75, // Ratio portrait pour les fonds d'écran
      ),
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        final wallpaperUrl = wallpapers[index];
        final isSelected = wallpaperUrl == selectedWallpaper;

        return _WallpaperTile(
          wallpaperUrl: wallpaperUrl,
          isSelected: isSelected,
          onTap: () => onWallpaperSelected(wallpaperUrl),
          borderColor: colors.colorPrimary,
        );
      },
    );
  }
}

/// Tuile individuelle pour un fond d'écran dans la grille
class _WallpaperTile extends StatefulWidget {
  final String wallpaperUrl;
  final bool isSelected;
  final VoidCallback onTap;
  final Color borderColor;

  const _WallpaperTile({
    required this.wallpaperUrl,
    required this.isSelected,
    required this.onTap,
    required this.borderColor,
  });

  @override
  State<_WallpaperTile> createState() => _WallpaperTileState();
}

class _WallpaperTileState extends State<_WallpaperTile>
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedContainer(
            duration: AppTheme.fastAnimation,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: widget.isSelected ? widget.borderColor : Colors.transparent,
                width: 3,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image du fond d'écran
                  Image.network(
                    widget.wallpaperUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Afficher un placeholder en cas d'erreur de chargement
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),

                  // Ripple effect overlay
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      splashColor: Colors.white.withValues(alpha: 0.3),
                      highlightColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),

                  // Indicateur de sélection
                  if (widget.isSelected)
                    Positioned(
                      top: AppTheme.spacingSmall,
                      right: AppTheme.spacingSmall,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: widget.borderColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
