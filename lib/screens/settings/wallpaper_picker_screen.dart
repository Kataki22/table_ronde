import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conversation_settings_provider.dart';
import '../../widgets/settings/wallpaper_grid.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_theme_data.dart';

/// Screen pour sélectionner un fond d'écran pour une conversation
///
/// Affiche:
/// - Une grille de fonds d'écran prédéfinis (WallpaperGrid)
/// - Une prévisualisation du fond d'écran sélectionné
/// - Un bouton pour sauvegarder et appliquer le fond d'écran
///
/// Validates: Requirements 4.2
class WallpaperPickerScreen extends StatefulWidget {
  /// ID de la conversation pour laquelle sélectionner un fond d'écran
  final String chatId;

  const WallpaperPickerScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<WallpaperPickerScreen> createState() => _WallpaperPickerScreenState();
}

class _WallpaperPickerScreenState extends State<WallpaperPickerScreen> {
  String? _selectedWallpaper;
  bool _isLoading = false;

  // Liste des fonds d'écran prédéfinis
  static const List<String> _predefinedWallpapers = [
    'https://images.unsplash.com/photo-1557683316-973673baf926',
    'https://images.unsplash.com/photo-1579546929518-9e396f3cc809',
    'https://images.unsplash.com/photo-1557682250-33bd709cbe85',
    'https://images.unsplash.com/photo-1579547945413-497e1b99dac0',
    'https://images.unsplash.com/photo-1557682224-5b8590cd9ec5',
    'https://images.unsplash.com/photo-1579547621113-e4bb2a19bdd6',
    'https://images.unsplash.com/photo-1557682268-e3955ed5d83f',
    'https://images.unsplash.com/photo-1579546929662-711aa81148cf',
    'https://images.unsplash.com/photo-1557682260-96773eb01377',
    'https://images.unsplash.com/photo-1579547621706-1a9c79d5c9f1',
    'https://images.unsplash.com/photo-1557682233-43e671455dfa',
    'https://images.unsplash.com/photo-1579546929518-9e396f3cc809',
  ];

  @override
  void initState() {
    super.initState();
    // Charger le fond d'écran actuel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ConversationSettingsProvider>();
      final settings = provider.getSettings(widget.chatId);
      setState(() {
        _selectedWallpaper = settings.wallpaperUrl;
      });
    });
  }

  Future<void> _saveWallpaper() async {
    if (_selectedWallpaper == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner un fond d\'écran'),
          backgroundColor: context.themeColors.colorDanger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ConversationSettingsProvider>();
      await provider.setWallpaper(widget.chatId, _selectedWallpaper!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Fond d\'écran appliqué avec succès'),
            backgroundColor: context.themeColors.colorSuccess,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: context.themeColors.colorDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: colors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Fond d\'écran',
          style: AppTheme.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveWallpaper,
              child: Text(
                'Appliquer',
                style: AppTheme.bodyLarge.copyWith(
                  color: colors.colorPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Prévisualisation
          _buildPreviewSection(colors),
          const SizedBox(height: 24),

          // Section titre
          Text(
            'Choisir un fond d\'écran',
            style: AppTheme.headingSmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez un fond d\'écran pour personnaliser cette conversation',
            style: AppTheme.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Grille de fonds d'écran
          WallpaperGrid(
            wallpapers: _predefinedWallpapers,
            selectedWallpaper: _selectedWallpaper,
            onWallpaperSelected: (wallpaper) {
              setState(() {
                _selectedWallpaper = wallpaper;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(AppThemeData colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prévisualisation',
          style: AppTheme.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: colors.borderMedium,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            // AnimatedSwitcher pour animation de fade (400ms) lors du changement de fond d'écran
            // Validates: Requirements 8.3
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: _selectedWallpaper != null
                  ? Stack(
                      key: ValueKey(_selectedWallpaper),
                      fit: StackFit.expand,
                      children: [
                        // Image du fond d'écran
                        Image.network(
                          _selectedWallpaper!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colors.bgSecondary,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: colors.textSecondary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Impossible de charger l\'image',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: colors.bgSecondary,
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

                        // Overlay avec exemple de message
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.colorPrimary,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                            child: Text(
                              'Message exemple',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      key: const ValueKey('no-wallpaper'),
                      color: colors.bgSecondary,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wallpaper,
                              size: 48,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aucun fond d\'écran sélectionné',
                              style: AppTheme.bodySmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
