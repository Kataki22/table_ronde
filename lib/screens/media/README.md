# Media Gallery Module

Ce module implémente la galerie de médias partagés pour les conversations.

## Fichiers

### `media_gallery_bottom_sheet.dart`
Bottom sheet principal affichant la galerie de médias organisée en onglets.

**Fonctionnalités:**
- TabBar avec 5 onglets (Photos, Vidéos, Documents, Liens, Vocaux)
- Compteur de médias par onglet
- Affichage en grille pour photos/vidéos (MediaGrid)
- Affichage en liste pour documents/liens/vocaux (MediaListTile)
- Gestion du tap pour prévisualisation ou téléchargement
- Simulation de téléchargement avec feedback utilisateur
- État vide personnalisé par type de média

**Validates:** Requirements 5.1, 5.2, 5.3, 5.4, 5.6

### `media_gallery_example.dart`
Fichier d'exemple montrant comment utiliser le bottom sheet.

**Contient:**
- Widget d'exemple avec bouton pour ouvrir la galerie
- Fonction helper `showMediaGallery()` réutilisable
- Documentation d'utilisation

### `media_viewer_screen.dart`
Écran plein écran pour visualiser des photos et vidéos avec navigation.

**Fonctionnalités:**
- Affichage plein écran avec FullScreenViewer
- Swipe horizontal pour naviguer entre médias
- Zoom pinch-to-zoom pour les images
- Contrôles vidéo pour les vidéos
- Informations du média (expéditeur, date, taille)
- Boutons d'action (télécharger, partager, fermer)
- Indicateur de page (1 / 3)
- Toggle des contrôles au tap

**Validates:** Requirements 5.5

## Utilisation

### Dans un écran de chat

```dart
import 'package:provider/provider.dart';
import 'package:table_ronde/screens/media/media_gallery_bottom_sheet.dart';
import 'package:table_ronde/providers/media_gallery_provider.dart';

// Dans votre AppBar ou ailleurs
IconButton(
  icon: const Icon(Icons.photo_library),
  onPressed: () {
    // S'assurer que le provider est initialisé
    final provider = context.read<MediaGalleryProvider>();
    if (!provider.isInitialized) {
      provider.initialize();
    }

    // Ouvrir le bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaGalleryBottomSheet(
        chatId: currentChatId, // ID de la conversation actuelle
      ),
    );
  },
)
```

### Avec la fonction helper

```dart
import 'package:table_ronde/screens/media/media_gallery_example.dart';

// Simplement appeler la fonction
showMediaGallery(context, chatId);
```

## Architecture

### Dépendances
- `MediaGalleryProvider`: Gère l'état et les données des médias
- `MediaGrid`: Widget pour afficher photos/vidéos en grille
- `MediaListTile`: Widget pour afficher documents/liens/vocaux en liste
- `FullScreenViewer`: Widget pour afficher médias en plein écran avec zoom
- `MediaItem`: Modèle de données pour un média
- `MediaType`: Enum des types de médias

### Flux de données

```
MediaGalleryBottomSheet
    ↓
Consumer<MediaGalleryProvider>
    ↓
getMediaForChat(chatId, type)
    ↓
[MediaGrid] ou [ListView + MediaListTile]
    ↓
onTap → _handleMediaTap()
    ↓
Photos/Vidéos: openMediaViewer() → MediaViewerScreen.navigate()
    ↓
MediaViewerScreen → FullScreenViewer
    ↓
Swipe, Zoom, Contrôles
Autres: _handleDownload() → downloadMedia()
```

## Comportements

### Onglets
- **Photos**: Affiche toutes les photos en grille 3x3
- **Vidéos**: Affiche toutes les vidéos en grille avec indicateur de durée
- **Documents**: Affiche tous les documents en liste avec icône, nom, taille
- **Liens**: Affiche tous les liens en liste avec domaine extrait
- **Vocaux**: Affiche tous les messages vocaux en liste avec durée

### Interactions
- **Tap sur photo/vidéo**: Ouvre MediaViewerScreen en plein écran
- **Tap sur document/lien/vocal**: Lance le téléchargement
- **Bouton télécharger**: Lance le téléchargement avec feedback
- **Swipe dans MediaViewerScreen**: Navigue entre les médias de la galerie
- **Pinch-to-zoom**: Zoom sur les images (0.5x à 4x)
- **Tap sur l'écran**: Toggle l'affichage des contrôles

### Téléchargement
- Simulation de téléchargement avec délai basé sur la taille du fichier
- Taux d'échec de 10% pour tester la gestion d'erreur
- Feedback utilisateur via SnackBar
- Option de réessayer en cas d'échec
- Prévention des téléchargements multiples du même fichier

### États vides
Chaque onglet affiche un message personnalisé quand aucun média n'est disponible:
- Photos: "Aucune photo partagée" avec icône photo_library
- Vidéos: "Aucune vidéo partagée" avec icône video_library
- Documents: "Aucun document partagé" avec icône description
- Liens: "Aucun lien partagé" avec icône link
- Vocaux: "Aucun message vocal" avec icône mic

## Tests

### Tests unitaires
Les tests pour MediaViewerScreen sont disponibles dans `test/screens/media/media_viewer_screen_test.dart`.

**Tests couverts:**
1. Affichage du FullScreenViewer avec le média initial
2. Affichage des boutons de contrôle (fermer, télécharger)
3. Affichage de l'indicateur de page pour plusieurs médias
4. Navigation par swipe entre les médias
5. Fermeture de l'écran avec le bouton close
6. Affichage des contrôles vidéo pour les vidéos
7. Toggle de la visibilité des contrôles au tap

### Tests à effectuer pour MediaGalleryBottomSheet
1. Affichage correct des 5 onglets
2. Compteurs de médias corrects par onglet
3. Affichage en grille pour photos/vidéos
4. Affichage en liste pour documents/liens/vocaux
5. Tap sur média ouvre MediaViewerScreen ou télécharge
6. Téléchargement avec feedback succès/échec
7. États vides pour chaque type
8. Synchronisation du tab sélectionné avec le provider

### Tests de propriétés
- **Property 15**: Media Gallery Organization by Type
- **Property 16**: Media Display Format by Type
- **Property 17**: Media Item Download Availability

## TODO

### Améliorations futures
- Recherche dans les médias
- Filtrage par date
- Sélection multiple pour téléchargement groupé
- Partage de médias (actuellement placeholder)
- Suppression de médias
- Lecture vidéo réelle (actuellement thumbnail avec bouton play)
- Menu d'options dans MediaViewerScreen (actuellement placeholder)
