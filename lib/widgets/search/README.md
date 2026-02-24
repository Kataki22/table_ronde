# Search Widgets

Ce module contient les widgets personnalisés pour la fonctionnalité de recherche dans les messages.

## Widgets

### ChatSearchBar

Widget de barre de recherche personnalisée intégrable dans un AppBar.

**Fonctionnalités:**
- Animation fluide d'ouverture/fermeture (expand/collapse)
- Saisie en temps réel avec callback
- Affichage du compteur de résultats (ex: "3 de 15")
- Bouton clear pour effacer la recherche
- Bouton close pour fermer la barre de recherche
- Focus automatique lors de l'ouverture
- Design responsive et moderne

**Utilisation:**

```dart
// Dans votre AppBar
AppBar(
  title: _isSearchOpen
      ? ChatSearchBar(
          isOpen: _isSearchOpen,
          onSearchChanged: (query) {
            // Effectuer la recherche
            context.read<MessageSearchProvider>().search(
              query,
              chatId,
              messages,
            );
          },
          onClose: () {
            // Fermer la recherche
            setState(() => _isSearchOpen = false);
            context.read<MessageSearchProvider>().clear();
          },
        )
      : Text('Chat'),
  actions: [
    if (!_isSearchOpen)
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () => setState(() => _isSearchOpen = true),
      ),
  ],
)
```

**Paramètres:**

- `isOpen` (bool): Si true, la barre est ouverte et animée
- `onSearchChanged` (Function(String)?): Callback appelé lors de la saisie
- `onClose` (VoidCallback?): Callback appelé lors de la fermeture
- `animationDuration` (Duration): Durée de l'animation (défaut: 250ms)

**Requirements validés:** 3.1, 3.2, 3.4

## Intégration avec MessageSearchProvider

Le ChatSearchBar est conçu pour fonctionner avec le `MessageSearchProvider`:

```dart
// 1. Effectuer une recherche
final searchProvider = context.read<MessageSearchProvider>();
searchProvider.search(query, chatId, messages);

// 2. Accéder aux résultats
final results = searchProvider.results;
final resultCount = searchProvider.resultCount;
final currentIndex = searchProvider.currentResultIndex;

// 3. Naviguer entre les résultats
searchProvider.navigateToNext();
searchProvider.navigateToPrevious();

// 4. Effacer la recherche
searchProvider.clear();
```

## Exemple complet

Voir `chat_search_bar_example.dart` pour un exemple complet d'intégration.

## Design Pattern

Le widget suit le design pattern Discord/Telegram:
- Barre de recherche arrondie avec fond subtil
- Animation smooth d'expansion/collapse
- Compteur de résultats intégré
- Boutons d'action minimalistes
- Focus automatique pour une UX optimale

## Animation

L'animation d'ouverture/fermeture utilise:
- `AnimationController` avec `SingleTickerProviderStateMixin`
- `CurvedAnimation` avec `Curves.easeInOut`
- Durée par défaut: 250ms (configurable)
- Animation de largeur (0% → 70% de l'écran)

## Accessibilité

- Semantic labels sur tous les boutons
- Contraste des couleurs respectant WCAG AA
- Support du clavier (focus, tab navigation)
- Feedback visuel sur les interactions

## Tests

Pour tester le widget:

```dart
testWidgets('ChatSearchBar displays result counter', (tester) async {
  // Setup
  final searchProvider = MessageSearchProvider();
  
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: searchProvider,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: ChatSearchBar(
              isOpen: true,
              onSearchChanged: (query) {
                searchProvider.search(query, 'test', mockMessages);
              },
            ),
          ),
        ),
      ),
    ),
  );
  
  // Test
  await tester.enterText(find.byType(TextField), 'test');
  await tester.pump();
  
  // Verify
  expect(find.text('1/3'), findsOneWidget);
});
```

### FilterChips

Widget de chips de filtrage pour filtrer les résultats de recherche par type de message.

**Fonctionnalités:**
- Affiche un chip pour chaque type de message (texte, image, vidéo, document, vocal, sticker, GIF)
- Support de la sélection multiple (plusieurs filtres actifs simultanément)
- Distinction visuelle claire entre états actif/inactif
- Icônes et labels pour chaque type
- Scrollable horizontalement si nécessaire
- Intégration avec MessageSearchProvider

**Utilisation:**

```dart
// Simple - le widget se connecte automatiquement au provider
const FilterChips()

// Dans un contexte de recherche complet
Column(
  children: [
    // Barre de recherche
    ChatSearchBar(
      isOpen: true,
      onSearchChanged: (query) {
        context.read<MessageSearchProvider>().search(
          query,
          chatId,
          messages,
        );
      },
    ),
    
    // Chips de filtrage
    const FilterChips(),
    
    // Résultats
    Expanded(
      child: SearchResultsList(),
    ),
  ],
)
```

**Comportement:**
- Cliquer sur un chip inactif l'active et applique le filtre
- Cliquer sur un chip actif le désactive et retire le filtre
- Plusieurs chips peuvent être actifs simultanément
- Les filtres s'appliquent immédiatement aux résultats de recherche
- Le provider notifie automatiquement les widgets écouteurs

**Design:**
- Chips arrondis avec bordure
- État actif: fond coloré (primary), texte blanc, bordure épaisse
- État inactif: fond surface, texte normal, bordure fine
- Élévation sur l'état actif pour effet de profondeur
- Icônes adaptées à chaque type de message
- Padding et espacement optimisés pour mobile

**Requirements validés:** 3.3

## Prochaines étapes

Les prochains widgets du module Search à implémenter:
- `SearchResultsList` (task 8.3): Liste des résultats avec navigation
- `ResultHighlight` (task 8.4): Highlighting du texte recherché


### SearchResultsList

Widget de liste des résultats de recherche avec highlighting et navigation.

**Fonctionnalités:**
- Affiche une liste scrollable des résultats de recherche
- Highlighting du texte recherché dans chaque résultat
- Barre de navigation avec boutons précédent/suivant
- Indicateur de position (Résultat X sur Y)
- Indication visuelle du résultat actuellement sélectionné
- Affichage de l'expéditeur et du timestamp pour chaque résultat
- Gestion du tap pour naviguer vers le message dans le chat
- Message d'état si aucun résultat trouvé

**Utilisation:**

```dart
// Simple - avec callback de navigation
SearchResultsList(
  onResultTap: (result) {
    // Naviguer vers le message dans le chat
    _scrollToMessage(result.matchIndex);
    
    // Optionnel: fermer la recherche
    setState(() => _isSearchOpen = false);
    context.read<MessageSearchProvider>().clear();
  },
)

// Dans un contexte de recherche complet
Column(
  children: [
    // Barre de recherche
    ChatSearchBar(
      isOpen: true,
      onSearchChanged: _handleSearchChanged,
      onClose: _handleSearchClose,
    ),
    
    // Chips de filtrage
    const FilterChips(),
    
    // Liste des résultats
    Expanded(
      child: SearchResultsList(
        onResultTap: _handleResultTap,
      ),
    ),
  ],
)
```

**Navigation vers un résultat:**

```dart
void _handleResultTap(SearchResult result) {
  // Option 1: Avec un ScrollController standard
  final itemHeight = 80.0; // Hauteur approximative d'un message
  _scrollController.animateTo(
    result.matchIndex * itemHeight,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
  
  // Option 2: Avec ItemScrollController (scrollable_positioned_list)
  _itemScrollController.scrollTo(
    index: result.matchIndex,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
  
  // Option 3: Avec jumpTo pour navigation instantanée
  _scrollController.jumpTo(result.matchIndex * itemHeight);
}
```

**Composants internes:**

1. **_NavigationBar**: Barre de navigation en haut de la liste
   - Affiche "Résultat X sur Y"
   - Boutons précédent (flèche haut) et suivant (flèche bas)
   - Appelle `navigateToPrevious()` et `navigateToNext()` du provider

2. **_SearchResultTile**: Tuile représentant un résultat individuel
   - Affiche l'expéditeur ("Vous" ou "Contact")
   - Affiche le timestamp (HH:mm si aujourd'hui, DD/MM/YYYY sinon)
   - Affiche le contenu du message avec highlighting
   - Bordure gauche colorée si sélectionné
   - Fond semi-transparent si sélectionné

3. **_HighlightedText**: Widget de highlighting du texte
   - Construit un RichText avec TextSpans
   - Applique le highlighting sur les ranges spécifiés
   - Utilise `colorBrand` du thème pour la couleur de surbrillance
   - Limite à 2 lignes avec ellipsis

**Comportement:**
- Le résultat actuellement sélectionné (currentResultIndex) est mis en évidence
- Les boutons de navigation permettent de parcourir tous les résultats
- La navigation wrap automatiquement (dernier → premier, premier → dernier)
- Taper sur un résultat appelle le callback `onResultTap`
- Si aucun résultat, affiche un message avec icône et texte explicatif

**Design:**
- Barre de navigation avec fond `bgSecondary` et bordure inférieure
- Résultat sélectionné: bordure gauche `colorPrimary` (3px) + fond semi-transparent
- Highlighting: fond `colorBrand` avec texte blanc et gras
- Timestamps formatés selon le contexte (aujourd'hui vs autre jour)
- Espacement et padding optimisés pour la lisibilité

**Requirements validés:** 3.5, 3.6

**Exemple complet:**

Voir `search_results_list_example.dart` pour un exemple complet d'intégration avec ChatSearchBar et FilterChips.

## Architecture complète du module Search

```
MessageSearchProvider (State Management)
    ↓
    ├── ChatSearchBar (Input + Counter)
    │   └── Gère la saisie et affiche le compteur
    │
    ├── FilterChips (Filters)
    │   └── Applique/retire des filtres par type
    │
    └── SearchResultsList (Results Display)
        ├── _NavigationBar (Prev/Next buttons)
        │   └── Contrôle la navigation entre résultats
        │
        └── _SearchResultTile (Individual result)
            ├── Affiche expéditeur + timestamp
            └── _HighlightedText (Text highlighting)
                └── Highlighting du texte recherché
```

## Propriétés testées (Property-Based Testing)

- **Property 9**: Search Results Accuracy (Requirements 3.2)
  - Tous les résultats contiennent la requête
  - Tous les messages contenant la requête sont dans les résultats

- **Property 10**: Search Filter Correctness (Requirements 3.3)
  - Tous les résultats correspondent aux filtres actifs
  - Aucun résultat de type non filtré n'est inclus

- **Property 11**: Search Result Navigation Bounds (Requirements 3.5)
  - Navigation next depuis le dernier résultat wrap au premier
  - Navigation previous depuis le premier résultat wrap au dernier

- **Property 12**: Search Result Highlighting (Requirements 3.6)
  - Le texte recherché est visuellement mis en surbrillance
  - Les highlight ranges correspondent aux occurrences de la requête

## Notes de design

- Le highlighting utilise `colorBrand` du thème pour une cohérence visuelle
- Les résultats sont limités à 2 lignes avec ellipsis pour éviter les tuiles trop grandes
- La navigation wrap automatiquement pour une UX fluide
- Le résultat sélectionné a une bordure gauche colorée et un fond semi-transparent
- Les timestamps affichent l'heure pour aujourd'hui, la date complète sinon
- Le message "Aucun résultat trouvé" inclut la requête pour plus de clarté

## Workflow complet de recherche

1. **Ouverture**: L'utilisateur clique sur l'icône de recherche
2. **Animation**: La ChatSearchBar s'anime et prend le focus
3. **Saisie**: L'utilisateur tape sa requête
4. **Recherche**: Le provider recherche dans les messages
5. **Filtrage** (optionnel): L'utilisateur active des filtres via FilterChips
6. **Affichage**: SearchResultsList affiche les résultats avec highlighting
7. **Navigation**: L'utilisateur parcourt les résultats avec les boutons
8. **Sélection**: L'utilisateur tape sur un résultat
9. **Navigation**: L'app scroll vers le message dans le chat
10. **Fermeture**: La recherche se ferme et l'état est réinitialisé


### ResultHighlight

Widget réutilisable pour mettre en surbrillance du texte recherché avec support de la recherche insensible à la casse et aux accents.

**Fonctionnalités:**
- Recherche insensible à la casse (CAFÉ = café = Café)
- Recherche insensible aux accents (café = cafe = cafè)
- Highlighting de toutes les occurrences de la requête
- Personnalisation complète des couleurs (texte, fond, texte surligné)
- Support de maxLines et overflow pour les textes longs
- Support de textAlign pour l'alignement
- Réutilisable dans n'importe quel contexte (pas limité à la recherche)

**Utilisation:**

```dart
// Utilisation simple
ResultHighlight(
  text: 'Le café français est délicieux',
  query: 'cafe', // Trouvera "café" malgré l'absence d'accent
  textColor: Colors.black87,
  highlightColor: Colors.yellow.shade300,
)

// Utilisation avancée avec personnalisation
ResultHighlight(
  text: 'Rejoignez notre serveur Discord pour discuter de café',
  query: 'cafe',
  textColor: Colors.white,
  highlightColor: const Color(0xFF5865F2),
  highlightTextColor: Colors.white,
  textStyle: const TextStyle(fontSize: 14),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  textAlign: TextAlign.start,
)

// Dans un message de chat
Row(
  children: [
    CircleAvatar(child: Icon(Icons.person)),
    SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Marie', style: TextStyle(fontWeight: FontWeight.bold)),
          ResultHighlight(
            text: 'On se retrouve au café à 15h ?',
            query: searchQuery,
            textColor: Colors.black87,
            highlightColor: Colors.yellow.shade300,
          ),
        ],
      ),
    ),
  ],
)

// Dans une liste de documents
Row(
  children: [
    Icon(Icons.description, color: Colors.blue.shade700),
    SizedBox(width: 12),
    Expanded(
      child: ResultHighlight(
        text: 'Recette_cafe_latte.pdf',
        query: searchQuery,
        textColor: Colors.black87,
        highlightColor: Colors.blue.shade200,
        highlightTextColor: Colors.blue.shade900,
      ),
    ),
  ],
)
```

**Paramètres:**

- `text` (String, requis): Le texte complet à afficher
- `query` (String, requis): La requête de recherche à mettre en surbrillance
- `textColor` (Color?): Couleur du texte normal (défaut: noir)
- `highlightColor` (Color?): Couleur de fond du texte surligné (défaut: jaune)
- `highlightTextColor` (Color?): Couleur du texte surligné (défaut: noir)
- `textStyle` (TextStyle?): Style de texte de base
- `maxLines` (int?): Nombre maximum de lignes
- `overflow` (TextOverflow?): Comportement de débordement
- `textAlign` (TextAlign?): Alignement du texte

**Normalisation des accents:**

Le widget normalise automatiquement les caractères accentués pour la recherche:
- `à á â ã ä å` → `a`
- `è é ê ë` → `e`
- `ì í î ï` → `i`
- `ò ó ô õ ö` → `o`
- `ù ú û ü` → `u`
- `ý ÿ` → `y`
- `ñ` → `n`
- `ç` → `c`

Cela permet à une recherche "cafe" de trouver "café", "cafè", "cafê", etc.

**Cas d'usage:**

1. **Résultats de recherche dans les messages**: Highlighting du texte recherché dans les messages de chat
2. **Liste de documents**: Highlighting des noms de fichiers correspondant à la recherche
3. **Profils utilisateurs**: Highlighting des noms ou bios correspondant à une recherche
4. **Galerie de médias**: Highlighting des descriptions ou noms de médias
5. **Notifications**: Highlighting du contenu des notifications
6. **Tout contexte nécessitant du highlighting**: Le widget est générique et réutilisable partout

**Comportement:**

- Si la requête est vide, le texte est affiché normalement sans highlighting
- Si aucune correspondance n'est trouvée, le texte est affiché normalement
- Toutes les occurrences de la requête sont mises en surbrillance
- Le highlighting respecte la casse du texte original (seule la recherche est insensible)
- Les ranges de highlighting sont calculés sur le texte normalisé mais appliqués sur le texte original

**Design:**

- Par défaut: fond jaune avec texte noir et gras pour le highlighting
- Personnalisable: toutes les couleurs peuvent être modifiées
- Le texte surligné utilise `fontWeight: FontWeight.w600` pour plus de visibilité
- Compatible avec tous les thèmes (Discord, Telegram, personnalisé)

**Différence avec _HighlightedText:**

`ResultHighlight` est une version améliorée et réutilisable de `_HighlightedText` (widget interne de SearchResultsList):
- **Réutilisable**: Peut être utilisé n'importe où dans l'app
- **Normalisation des accents**: Gère les caractères accentués
- **Plus de personnalisation**: Plus d'options de style
- **API publique**: Conçu pour être utilisé par d'autres widgets

**Requirements validés:** 3.6

**Exemple complet:**

Voir `result_highlight_example.dart` pour des exemples complets démontrant:
- Recherche insensible à la casse
- Recherche insensible aux accents
- Personnalisation des couleurs (styles Discord, Telegram, personnalisé)
- Cas d'usage réels (messages, documents, profils)
- Cas limites (requête vide, aucune correspondance, texte long)

## Comparaison des widgets de highlighting

| Caractéristique | _HighlightedText | ResultHighlight |
|----------------|------------------|-----------------|
| Visibilité | Privé (interne à SearchResultsList) | Public (réutilisable) |
| Normalisation accents | Non | Oui |
| Personnalisation | Limitée | Complète |
| Cas d'usage | Résultats de recherche uniquement | Tout contexte |
| API | Interne | Publique et documentée |

**Recommandation**: Utiliser `ResultHighlight` pour tous les nouveaux cas d'usage de highlighting. `_HighlightedText` reste utilisé en interne par SearchResultsList pour des raisons de compatibilité.
