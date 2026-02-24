import 'package:flutter/material.dart';
import 'wallpaper_grid.dart';

/// Exemple d'utilisation du WallpaperGrid
///
/// Ce fichier démontre comment utiliser le widget WallpaperGrid
/// pour permettre à l'utilisateur de sélectionner un fond d'écran.
class WallpaperGridExample extends StatefulWidget {
  const WallpaperGridExample({super.key});

  @override
  State<WallpaperGridExample> createState() => _WallpaperGridExampleState();
}

class _WallpaperGridExampleState extends State<WallpaperGridExample> {
  // Liste de fonds d'écran prédéfinis (URLs d'exemple)
  final List<String> _wallpapers = [
    'https://picsum.photos/400/600?random=1',
    'https://picsum.photos/400/600?random=2',
    'https://picsum.photos/400/600?random=3',
    'https://picsum.photos/400/600?random=4',
    'https://picsum.photos/400/600?random=5',
    'https://picsum.photos/400/600?random=6',
    'https://picsum.photos/400/600?random=7',
    'https://picsum.photos/400/600?random=8',
    'https://picsum.photos/400/600?random=9',
  ];

  String? _selectedWallpaper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un fond d\'écran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisissez un fond d\'écran pour cette conversation',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            WallpaperGrid(
              wallpapers: _wallpapers,
              selectedWallpaper: _selectedWallpaper,
              onWallpaperSelected: (wallpaperUrl) {
                setState(() {
                  _selectedWallpaper = wallpaperUrl;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fond d\'écran sélectionné'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            if (_selectedWallpaper != null)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Appliquer le fond d'écran
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fond d\'écran appliqué'),
                      ),
                    );
                  },
                  child: const Text('Appliquer'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
