import 'package:flutter/material.dart';
import '../../models/media/media_item.dart';
import '../../models/media/media_type.dart';
import '../../utils/accessibility_helpers.dart';

/// Widget affichant une tuile de liste pour documents, liens et messages vocaux
/// 
/// Utilisé dans la galerie de médias pour afficher les médias non-visuels
/// sous forme de liste avec icône, nom, taille, date et bouton de téléchargement.
class MediaListTile extends StatefulWidget {
  /// Le média à afficher
  final MediaItem item;
  
  /// Callback appelé lors du tap sur la tuile
  final VoidCallback onTap;
  
  /// Callback appelé lors du tap sur le bouton de téléchargement
  final VoidCallback onDownload;

  const MediaListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDownload,
  });

  @override
  State<MediaListTile> createState() => _MediaListTileState();
}

class _MediaListTileState extends State<MediaListTile>
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
      end: 0.98,
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
    final typeLabel = _getTypeLabel();
    final displayName = _getDisplayName();
    final secondaryInfo = _getSecondaryInfo();
    
    return Semantics(
      label: AccessibilityHelpers.mediaItemLabel(
        type: typeLabel,
        fileName: displayName,
        duration: widget.item.type == MediaType.voice && widget.item.duration != null
            ? widget.item.formattedDuration
            : null,
        size: widget.item.fileSize != null ? widget.item.formattedSize : null,
      ),
      hint: AccessibilityHelpers.tapToOpen,
      button: true,
      enabled: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            splashColor: Colors.grey.withValues(alpha: 0.2),
            highlightColor: Colors.grey.withValues(alpha: 0.1),
            hoverColor: _isHovered 
                ? Colors.grey.withValues(alpha: 0.05)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // Icône selon le type de média
                  _buildLeadingIcon(),
                  
                  const SizedBox(width: 12),
                  
                  // Informations du média
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom du fichier ou URL
                        Text(
                          _getDisplayName(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Informations secondaires (taille, durée, date)
                        Text(
                          _getSecondaryInfo(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        // Nom de l'expéditeur
                        const SizedBox(height: 2),
                        Text(
                          widget.item.senderName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Bouton de téléchargement
                  _DownloadButton(onPressed: widget.onDownload),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  /// Gets the type label for accessibility
  String _getTypeLabel() {
    switch (widget.item.type) {
      case MediaType.document:
        return AccessibilityHelpers.document;
      case MediaType.link:
        return AccessibilityHelpers.link;
      case MediaType.voice:
        return AccessibilityHelpers.voiceMessage;
      default:
        return 'Fichier';
    }
  }

  /// Construit l'icône de gauche selon le type de média
  Widget _buildLeadingIcon() {
    IconData iconData;
    Color iconColor;

    switch (widget.item.type) {
      case MediaType.document:
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case MediaType.link:
        iconData = Icons.link;
        iconColor = Colors.green;
        break;
      case MediaType.voice:
        iconData = Icons.mic;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  /// Retourne le nom à afficher (nom de fichier ou URL)
  String _getDisplayName() {
    if (widget.item.type == MediaType.document && widget.item.fileName != null) {
      return widget.item.fileName!;
    } else if (widget.item.type == MediaType.link) {
      // Extraire le domaine de l'URL
      try {
        final uri = Uri.parse(widget.item.url);
        return uri.host.isNotEmpty ? uri.host : widget.item.url;
      } catch (e) {
        return widget.item.url;
      }
    } else if (widget.item.type == MediaType.voice) {
      return 'Message vocal';
    }
    return 'Fichier';
  }

  /// Retourne les informations secondaires (taille, durée, date)
  String _getSecondaryInfo() {
    final parts = <String>[];

    // Ajouter la taille du fichier
    if (widget.item.fileSize != null && widget.item.fileSize! > 0) {
      parts.add(widget.item.formattedSize);
    }

    // Ajouter la durée pour les messages vocaux
    if (widget.item.type == MediaType.voice && widget.item.duration != null) {
      parts.add(widget.item.formattedDuration);
    }

    // Ajouter la date
    final dateStr = _formatDate(widget.item.timestamp);
    parts.add(dateStr);

    return parts.join(' • ');
  }

  /// Formate la date de manière lisible
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Aujourd'hui - afficher l'heure
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      // Hier
      return 'Hier';
    } else if (difference.inDays < 7) {
      // Cette semaine - afficher le jour
      final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
      return days[date.weekday - 1];
    } else if (difference.inDays < 365) {
      // Cette année - afficher jour et mois
      final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 
                      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
      return '${date.day} ${months[date.month - 1]}';
    } else {
      // Année précédente - afficher date complète
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Download button with scale animation
class _DownloadButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _DownloadButton({required this.onPressed});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Télécharger',
      hint: AccessibilityHelpers.tapToDownload,
      button: true,
      enabled: true,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            _controller.forward().then((_) => _controller.reverse());
            widget.onPressed();
          },
          tooltip: 'Télécharger',
          color: Theme.of(context).primaryColor,
          splashRadius: 24,
        ),
      ),
    );
  }
}
