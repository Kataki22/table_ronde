# Plan d'implémentation : Social Chat Enhancements

## Vue d'ensemble

Ce plan implémente six modules fonctionnels pour enrichir l'expérience sociale et de chat dans l'application TableRonde. L'architecture suit le pattern MVC modulaire avec Provider pour la gestion d'état, utilisant des données mockées sans backend réel.

**Modules** : Groupes, Profils, Recherche, Paramètres de conversation, Galerie médias, Notifications

**Stack technique** : Flutter 3.x, Provider, shared_preferences, faker (tests)

**Priorités** : Modèles → Providers → Widgets → Screens → Navigation → Tests

## Tâches

- [x] 1. Configuration initiale et structure de base
  - Créer la structure de dossiers pour les 6 modules
  - Ajouter les dépendances nécessaires (provider, shared_preferences, faker)
  - Créer les fichiers de mock data pour chaque module
  - _Requirements: 7.3_

- [x] 2. Modèles de données et enums
  - [x] 2.1 Créer les modèles pour les groupes
    - Implémenter GroupChatModel avec méthodes helper (isUserAdmin, canUserManageMembers)
    - Implémenter GroupMemberModel
    - Créer l'enum GroupPermission (admin, moderator, member)
    - _Requirements: 1.1, 1.2, 9.1, 9.2_

  - [x] 2.2 Créer les modèles pour les profils utilisateurs
    - Implémenter UserProfileModel avec copyWith
    - Implémenter UserActivity et UserPost
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 2.3 Créer les modèles pour la recherche
    - Implémenter SearchResult avec highlightRanges
    - Implémenter TextRange pour le highlighting
    - _Requirements: 3.2, 3.6_

  - [x] 2.4 Créer les modèles pour les paramètres de conversation
    - Implémenter ConversationSettings avec toJson/fromJson
    - Implémenter copyWith pour l'immutabilité
    - _Requirements: 4.1, 4.2, 10.1_

  - [x] 2.5 Créer les modèles pour la galerie médias
    - Créer l'enum MediaType (photo, video, document, link, voice)
    - Implémenter MediaItem avec méthodes helper (formattedSize, formattedDuration)
    - _Requirements: 5.1, 5.2_

  - [x] 2.6 Créer les modèles pour les notifications
    - Créer l'enum NotificationType (message, mention, like, comment, announcement, activity)
    - Implémenter NotificationModel avec copyWith et méthodes helper (icon, color)
    - _Requirements: 6.1, 6.2_

- [x] 3. Données mockées
  - [x] 3.1 Créer MockGroupsData
    - Générer 10-15 groupes avec membres variés
    - Générer des messages de groupe pour chaque groupe
    - Inclure différents niveaux de permissions
    - _Requirements: 7.3_

  - [x] 3.2 Créer MockProfilesData
    - Générer 20-30 profils utilisateurs complets
    - Générer activités récentes et posts pour chaque profil
    - _Requirements: 7.3_

  - [x] 3.3 Créer MockMediaData
    - Générer médias partagés pour chaque conversation
    - Inclure tous les types de médias (photos, vidéos, documents, liens, vocaux)
    - _Requirements: 7.3_

  - [x] 3.4 Créer MockNotificationsData
    - Générer 30-50 notifications de tous types
    - Inclure notifications lues et non lues
    - _Requirements: 7.3_

- [x] 4. Providers - Gestion d'état
  - [x] 4.1 Implémenter GroupChatProvider
    - Implémenter createGroup avec validation
    - Implémenter addMember, removeMember avec vérification de permissions
    - Implémenter updateMemberPermission (admin uniquement)
    - Implémenter leaveGroup et sendGroupMessage
    - _Requirements: 1.2, 1.6, 9.3, 9.4, 7.1, 7.2_

  - [ ]* 4.2 Écrire les tests de propriétés pour GroupChatProvider
    - **Property 1: Group Creation Round-Trip**
    - **Valide: Requirements 1.2**
    - **Property 2: Group Member List Completeness**
    - **Valide: Requirements 1.4**
    - **Property 5: Permission-Based Access Control**
    - **Valide: Requirements 9.3, 9.4, 9.5, 9.6**

  - [x] 4.3 Implémenter ProfileProvider
    - Implémenter getProfile et currentUserProfile
    - Implémenter updateProfile avec validation
    - Implémenter blockUser et unblockUser
    - Charger activités et posts depuis mock data
    - _Requirements: 2.1, 2.7, 7.1, 7.2_

  - [ ]* 4.4 Écrire les tests de propriétés pour ProfileProvider
    - **Property 8: Profile Edit Round-Trip**
    - **Valide: Requirements 2.7**

  - [x] 4.5 Implémenter MessageSearchProvider
    - Implémenter search avec recherche case-insensitive
    - Implémenter applyFilter et removeFilter pour filtrage par type
    - Implémenter navigateToNext et navigateToPrevious avec wrapping
    - Calculer highlightRanges pour chaque résultat
    - _Requirements: 3.2, 3.3, 3.5, 3.6, 7.1, 7.2_

  - [ ]* 4.6 Écrire les tests de propriétés pour MessageSearchProvider
    - **Property 9: Search Results Accuracy**
    - **Valide: Requirements 3.2**
    - **Property 10: Search Filter Correctness**
    - **Valide: Requirements 3.3**
    - **Property 11: Search Result Navigation Bounds**
    - **Valide: Requirements 3.5**

  - [x] 4.7 Implémenter ConversationSettingsProvider
    - Implémenter setWallpaper, toggleNotifications, setNotificationSound
    - Implémenter pinConversation, archiveConversation
    - Implémenter deleteConversation, blockUser, reportUser
    - Implémenter _saveSettings et _loadSettings avec shared_preferences
    - _Requirements: 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 10.1, 10.5, 7.1, 7.2_

  - [ ]* 4.8 Écrire les tests de propriétés pour ConversationSettingsProvider
    - **Property 13: Conversation Settings Persistence Round-Trip**
    - **Valide: Requirements 4.2, 4.3, 4.4, 4.5, 4.6, 10.1, 10.2, 10.3, 10.4, 10.5**

  - [x] 4.9 Implémenter MediaGalleryProvider
    - Implémenter getMediaForChat avec filtrage par MediaType
    - Implémenter selectTab pour changer d'onglet
    - Implémenter downloadMedia avec simulation de téléchargement
    - Implémenter openMediaViewer pour prévisualisation
    - _Requirements: 5.2, 5.3, 5.6, 5.7, 7.1, 7.2_

  - [ ]* 4.10 Écrire les tests de propriétés pour MediaGalleryProvider
    - **Property 15: Media Gallery Organization by Type**
    - **Valide: Requirements 5.2**

  - [x] 4.11 Implémenter NotificationProvider
    - Implémenter markAsRead, markAsUnread, deleteNotification
    - Implémenter applyFilter et removeFilter pour filtrage par type
    - Calculer unreadCount dynamiquement
    - Implémenter updateNotificationSetting avec persistance
    - Implémenter navigateToContent avec gestion d'erreurs
    - Générer mock notifications au démarrage
    - _Requirements: 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 7.1, 7.2_

  - [ ]* 4.12 Écrire les tests de propriétés pour NotificationProvider
    - **Property 18: Notification Badge Count Accuracy**
    - **Valide: Requirements 6.3**
    - **Property 19: Notification State Toggle**
    - **Valide: Requirements 6.4**
    - **Property 20: Notification Deletion**
    - **Valide: Requirements 6.5**
    - **Property 21: Notification Filter Correctness**
    - **Valide: Requirements 6.6**

- [x] 5. Checkpoint - Vérifier les Providers
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Widgets réutilisables - Module Groupes
  - [x] 6.1 Créer GroupChatBubble
    - Afficher message avec avatar du sender
    - Afficher nom du sender pour les groupes
    - Gérer tap et long press
    - _Requirements: 1.3_

  - [x] 6.2 Créer MemberListTile
    - Afficher avatar, nom et badge de permission
    - Afficher date de jointure
    - Gérer actions contextuelles (retirer, changer permission)
    - _Requirements: 1.4, 1.5, 9.2_

  - [x] 6.3 Créer PermissionBadge
    - Afficher badge visuel selon le niveau (admin, moderator, member)
    - Utiliser couleurs distinctes pour chaque niveau
    - _Requirements: 1.5, 9.2_

  - [ ]* 6.4 Écrire les tests de propriétés pour les widgets de groupe
    - **Property 3: Permission Visual Indicators**
    - **Valide: Requirements 1.5, 9.2**

- [x] 7. Widgets réutilisables - Module Profils
  - [x] 7.1 Créer ProfileHeader
    - Afficher photo de profil, nom, username
    - Afficher bio et date d'inscription
    - Afficher statut en ligne
    - _Requirements: 2.2_

  - [x] 7.2 Créer ActivityCard
    - Afficher icône selon le type d'activité
    - Afficher description et timestamp
    - _Requirements: 2.3_

  - [x] 7.3 Créer PostCard
    - Afficher contenu du post avec images
    - Afficher compteurs de likes et commentaires
    - _Requirements: 2.4_

  - [x] 7.4 Créer ActionButtons
    - Afficher boutons Message, Appel vocal, Appel vidéo, Bloquer
    - Adapter selon le contexte (profil propre vs autre utilisateur)
    - _Requirements: 2.5, 2.6_

  - [ ]* 7.5 Écrire les tests de propriétés pour les widgets de profil
    - **Property 6: Profile Content Completeness**
    - **Valide: Requirements 2.2, 2.3, 2.4**
    - **Property 7: Profile Action Buttons Context**
    - **Valide: Requirements 2.5, 2.6**

- [x] 8. Widgets réutilisables - Module Recherche
  - [x] 8.1 Créer SearchBar personnalisée
    - Intégrer dans AppBar avec animation
    - Gérer saisie en temps réel
    - Afficher compteur de résultats
    - _Requirements: 3.1, 3.2, 3.4_

  - [x] 8.2 Créer FilterChips
    - Afficher chips pour chaque type de contenu
    - Gérer sélection multiple
    - Afficher état actif visuellement
    - _Requirements: 3.3_

  - [x] 8.3 Créer SearchResultsList
    - Afficher liste des résultats avec highlighting
    - Afficher boutons navigation (précédent/suivant)
    - Gérer tap sur résultat pour naviguer
    - _Requirements: 3.5, 3.6_

  - [x] 8.4 Créer ResultHighlight
    - Highlighter le texte recherché dans les messages
    - Gérer accents et casse
    - _Requirements: 3.6_

  - [ ]* 8.5 Écrire les tests de propriétés pour les widgets de recherche
    - **Property 12: Search Result Highlighting**
    - **Valide: Requirements 3.6**

- [x] 9. Widgets réutilisables - Module Paramètres
  - [x] 9.1 Créer SettingsTile
    - Afficher icône, titre et sous-titre
    - Gérer différents types (toggle, navigation, action)
    - _Requirements: 4.1_

  - [x] 9.2 Créer WallpaperGrid
    - Afficher grille de fonds d'écran prédéfinis
    - Indiquer le fond d'écran sélectionné
    - _Requirements: 4.2_

  - [x] 9.3 Créer ConfirmationDialog
    - Afficher titre, message et boutons d'action
    - Gérer actions destructives (rouge) vs normales
    - Réutilisable pour toutes les confirmations
    - _Requirements: 1.7, 4.7, 4.9_

  - [ ]* 9.4 Écrire les tests de propriétés pour les widgets de paramètres
    - **Property 14: Destructive Action Confirmations**
    - **Valide: Requirements 1.7, 4.7, 4.9**

- [x] 10. Widgets réutilisables - Module Galerie Médias
  - [x] 10.1 Créer MediaGrid
    - Afficher grille de miniatures pour photos/vidéos
    - Gérer tap pour ouvrir prévisualisation
    - Afficher indicateur de durée pour vidéos
    - _Requirements: 5.3_

  - [x] 10.2 Créer MediaListTile
    - Afficher tuile pour documents/liens/vocaux
    - Afficher icône, nom, taille et date
    - Afficher bouton de téléchargement
    - _Requirements: 5.4, 5.6_

  - [x] 10.3 Créer FullScreenViewer
    - Afficher média en plein écran avec zoom
    - Gérer swipe pour naviguer entre médias
    - Afficher contrôles pour vidéos
    - _Requirements: 5.5_

  - [ ]* 10.4 Écrire les tests de propriétés pour les widgets de galerie
    - **Property 16: Media Display Format by Type**
    - **Valide: Requirements 5.3, 5.4**
    - **Property 17: Media Item Download Availability**
    - **Valide: Requirements 5.6, 5.7**

- [x] 11. Widgets réutilisables - Module Notifications
  - [x] 11.1 Créer NotificationTile
    - Afficher icône selon le type de notification
    - Afficher titre, corps et timestamp
    - Afficher indicateur de lecture
    - Gérer swipe pour actions (marquer lu, supprimer)
    - _Requirements: 6.2, 6.4, 6.5_

  - [x] 11.2 Créer FilterTabs
    - Afficher onglets pour chaque type de notification
    - Gérer sélection et afficher compteur par type
    - _Requirements: 6.6_

  - [x] 11.3 Créer BadgeCounter
    - Afficher badge avec compteur de notifications non lues
    - Animer l'apparition de nouvelles notifications
    - _Requirements: 6.3_

  - [ ]* 11.4 Écrire les tests de propriétés pour les widgets de notifications
    - **Property 22: Notification Navigation**
    - **Valide: Requirements 6.8**

- [x] 12. Checkpoint - Vérifier les widgets
  - Ensure all tests pass, ask the user if questions arise.

- [x] 13. Screens - Module Groupes
  - [x] 13.1 Créer GroupCreationScreen
    - Formulaire avec champs nom, description, photo
    - Sélecteur de membres avec recherche
    - Validation et création du groupe
    - _Requirements: 1.1, 1.2_

  - [x] 13.2 Créer GroupInfoBottomSheet
    - Afficher détails du groupe (nom, description, photo)
    - Afficher liste des membres avec permissions
    - Afficher boutons d'action (gérer membres, paramètres, quitter)
    - _Requirements: 1.4, 1.5, 1.8_

  - [x] 13.3 Créer GroupMembersScreen
    - Afficher liste complète des membres
    - Afficher options de gestion pour admins
    - Gérer ajout et retrait de membres
    - _Requirements: 1.4, 1.6, 9.3, 9.4_

  - [ ]* 13.4 Écrire les tests unitaires pour les screens de groupe
    - Tester validation du formulaire de création
    - Tester affichage conditionnel des options selon permissions
    - Tester cas limite : groupe avec 1 membre, 100+ membres

- [x] 14. Screens - Module Profils
  - [x] 14.1 Créer ProfileScreen
    - Afficher ProfileHeader avec toutes les informations
    - Afficher sections activités récentes et posts
    - Afficher ActionButtons selon le contexte
    - Gérer navigation vers édition si profil propre
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

  - [x] 14.2 Créer ProfileEditScreen
    - Formulaire d'édition avec champs bio, photo, téléphone
    - Validation des champs
    - Sauvegarde et retour au profil
    - _Requirements: 2.7_

  - [ ]* 14.3 Écrire les tests unitaires pour les screens de profil
    - Tester affichage complet du profil
    - Tester validation du formulaire d'édition
    - Tester cas limite : profil sans posts, profil sans activités

- [x] 15. Screens - Module Recherche
  - [x] 15.1 Intégrer SearchBar dans ChatScreen
    - Ajouter SearchBar dans AppBar avec animation d'apparition
    - Connecter au MessageSearchProvider
    - Afficher FilterChips sous la barre de recherche
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 15.2 Créer SearchResultsOverlay
    - Afficher SearchResultsList par-dessus le chat
    - Gérer navigation entre résultats avec scroll automatique
    - Afficher message si aucun résultat
    - _Requirements: 3.4, 3.5, 3.7_

  - [ ]* 15.3 Écrire les tests unitaires pour la recherche
    - Tester recherche avec résultats
    - Tester recherche sans résultats
    - Tester filtrage par type
    - Tester cas limite : 1 résultat, 1000+ résultats

- [x] 16. Screens - Module Paramètres de conversation
  - [x] 16.1 Créer ConversationSettingsBottomSheet
    - Afficher liste des paramètres avec SettingsTile
    - Gérer toggle notifications, épingler, archiver
    - Gérer navigation vers sélection de fond d'écran
    - Afficher options destructives (bloquer, signaler, supprimer)
    - _Requirements: 4.1, 4.3, 4.5, 4.6, 4.7, 4.8, 4.9_

  - [x] 16.2 Créer WallpaperPickerScreen
    - Afficher WallpaperGrid avec options prédéfinies
    - Prévisualiser le fond d'écran sélectionné
    - Sauvegarder et appliquer le fond d'écran
    - _Requirements: 4.2_

  - [ ]* 16.3 Écrire les tests unitaires pour les paramètres
    - Tester toggle de chaque paramètre
    - Tester affichage des confirmations
    - Tester persistance après redémarrage

- [x] 17. Screens - Module Galerie Médias
  - [x] 17.1 Créer MediaGalleryBottomSheet
    - Afficher TabBar avec 5 onglets (Photos, Vidéos, Documents, Liens, Vocaux)
    - Afficher MediaGrid pour photos/vidéos
    - Afficher liste pour documents/liens/vocaux
    - Gérer tap pour ouvrir prévisualisation ou télécharger
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.6_

  - [x] 17.2 Créer MediaViewerScreen
    - Afficher FullScreenViewer pour photos/vidéos
    - Gérer swipe pour naviguer dans la galerie
    - Afficher contrôles et informations du média
    - _Requirements: 5.5_

  - [ ]* 17.3 Écrire les tests unitaires pour la galerie
    - Tester organisation par type
    - Tester affichage grille vs liste
    - Tester téléchargement simulé
    - Tester cas limite : galerie vide, 1000+ médias

- [x] 18. Screens - Module Notifications
  - [x] 18.1 Créer NotificationCenterScreen
    - Afficher FilterTabs en haut
    - Afficher liste de NotificationTile
    - Gérer tap pour naviguer vers contenu
    - Gérer swipe pour actions (marquer lu, supprimer)
    - Afficher message si aucune notification
    - _Requirements: 6.1, 6.2, 6.4, 6.5, 6.6, 6.8_

  - [x] 18.2 Créer NotificationSettingsScreen
    - Afficher liste des types de notifications
    - Gérer toggle pour activer/désactiver chaque type
    - Sauvegarder les préférences
    - _Requirements: 6.7_

  - [ ]* 18.3 Écrire les tests unitaires pour les notifications
    - Tester affichage des notifications
    - Tester filtrage par type
    - Tester navigation vers contenu
    - Tester cas limite : aucune notification, 1000+ notifications

- [x] 19. Checkpoint - Vérifier les screens
  - Ensure all tests pass, ask the user if questions arise.

- [x] 20. Navigation et intégration
  - [x] 20.1 Intégrer les groupes dans l'app
    - Ajouter FAB pour création de groupe dans ChatListScreen
    - Ajouter navigation vers GroupInfoBottomSheet depuis GroupChatScreen
    - Connecter tous les Providers avec MultiProvider
    - _Requirements: 1.1, 1.8_

  - [x] 20.2 Intégrer les profils dans l'app
    - Ajouter navigation vers ProfileScreen depuis avatars
    - Ajouter navigation vers ProfileEditScreen depuis profil propre
    - Gérer retour après édition
    - _Requirements: 2.1, 2.6, 2.7_

  - [x] 20.3 Intégrer la recherche dans l'app
    - Ajouter icône de recherche dans AppBar de ChatScreen
    - Gérer animation d'ouverture/fermeture de la recherche
    - Gérer navigation vers messages depuis résultats
    - _Requirements: 3.1, 3.5_

  - [x] 20.4 Intégrer les paramètres dans l'app
    - Ajouter bouton paramètres dans ChatScreen AppBar
    - Ouvrir ConversationSettingsBottomSheet
    - Appliquer le fond d'écran sélectionné au chat
    - _Requirements: 4.1, 4.2_

  - [x] 20.5 Intégrer la galerie médias dans l'app
    - Ajouter bouton galerie dans ChatScreen AppBar
    - Ouvrir MediaGalleryBottomSheet
    - Gérer navigation vers MediaViewerScreen
    - _Requirements: 5.1, 5.5_

  - [x] 20.6 Intégrer les notifications dans l'app
    - Ajouter onglet Notifications dans BottomNavigationBar
    - Afficher BadgeCounter sur l'icône
    - Gérer navigation vers contenu depuis notifications
    - _Requirements: 6.1, 6.3, 6.8_

  - [ ]* 20.7 Écrire les tests d'intégration
    - Tester flux complet : créer groupe → envoyer message → voir dans galerie
    - Tester flux : modifier profil → sauvegarder → vérifier persistance
    - Tester flux : rechercher message → naviguer résultats → ouvrir message
    - Tester flux : changer paramètres → redémarrer app → vérifier restauration
    - Tester flux : recevoir notification → cliquer → naviguer vers contenu

- [x] 21. Animations et transitions
  - [x] 21.1 Implémenter animations pour les groupes
    - Animation d'apparition du GroupInfoBottomSheet (slide up, 300ms)
    - Animation de suppression de membre (fade out, 200ms)
    - _Requirements: 8.3_

  - [x] 21.2 Implémenter animations pour les profils
    - Animation de transition vers ProfileScreen (hero animation sur avatar)
    - Animation d'apparition des sections (staggered fade in, 200ms)
    - _Requirements: 8.3_

  - [x] 21.3 Implémenter animations pour la recherche
    - Animation d'ouverture de la SearchBar (expand, 250ms)
    - Animation de highlighting des résultats (pulse, 300ms)
    - _Requirements: 8.3_

  - [x] 21.4 Implémenter animations pour les paramètres
    - Animation d'apparition du BottomSheet (slide up, 300ms)
    - Animation de changement de fond d'écran (fade, 400ms)
    - _Requirements: 8.3_

  - [x] 21.5 Implémenter animations pour la galerie
    - Animation d'ouverture du MediaViewerScreen (zoom in, 300ms)
    - Animation de swipe entre médias (page transition, 250ms)
    - _Requirements: 8.3_

  - [x] 21.6 Implémenter animations pour les notifications
    - Animation d'apparition de nouvelles notifications (slide in, 200ms)
    - Animation de swipe pour actions (slide out, 250ms)
    - Animation du BadgeCounter (scale pulse, 300ms)
    - _Requirements: 8.3_

  - [ ]* 21.7 Écrire les tests de performance pour les animations
    - Vérifier frame rate ≥ 60 FPS pendant les animations
    - Tester sur différentes tailles d'écran

- [x] 22. Design responsive et accessibilité
  - [x] 22.1 Adapter les layouts pour mobile et desktop
    - Implémenter layouts responsive avec MediaQuery
    - Mobile : single-column, bottom sheets
    - Desktop : multi-column, side panels
    - _Requirements: 8.1, 8.2_

  - [x] 22.2 Ajouter feedback visuel interactif
    - Implémenter ripple effects sur tous les boutons
    - Ajouter changements de couleur au hover (desktop)
    - Ajouter animations de scale sur tap
    - _Requirements: 8.5_

  - [x] 22.3 Améliorer l'accessibilité
    - Ajouter Semantics labels sur tous les widgets interactifs
    - Vérifier contraste des couleurs (WCAG AA minimum)
    - Tester navigation au clavier (desktop)
    - _Requirements: 8.4_

  - [ ]* 22.4 Écrire les tests de propriétés pour le responsive
    - **Property 24: Responsive Layout Adaptation**
    - **Valide: Requirements 8.1, 8.2**
    - **Property 25: Interactive Element Feedback**
    - **Valide: Requirements 8.5**

- [x] 23. Gestion d'erreurs et validation
  - [x] 23.1 Implémenter validation pour les groupes
    - Valider nom de groupe (requis, max 50 chars)
    - Valider sélection de membres (min 1)
    - Afficher messages d'erreur appropriés
    - _Requirements: 1.1, 1.2_

  - [x] 23.2 Implémenter validation pour les profils
    - Valider bio (max 500 chars)
    - Valider format de téléphone
    - Afficher erreurs inline dans le formulaire
    - _Requirements: 2.7_

  - [x] 23.3 Implémenter gestion d'erreurs pour la recherche
    - Gérer query vide ou trop courte
    - Afficher message si aucun résultat
    - _Requirements: 3.2, 3.7_

  - [x] 23.4 Implémenter gestion d'erreurs pour les médias
    - Gérer échec de chargement avec placeholder
    - Simuler échec de téléchargement (10% chance)
    - Afficher messages d'erreur avec retry
    - _Requirements: 5.6, 5.7_

  - [x] 23.5 Implémenter gestion d'erreurs pour les notifications
    - Gérer navigation vers contenu inexistant
    - Afficher SnackBar avec message approprié
    - _Requirements: 6.8_

  - [x] 23.6 Implémenter gestion d'erreurs pour les permissions
    - Afficher SnackBar si permission insuffisante
    - Masquer options inaccessibles préventivement
    - _Requirements: 9.6_

  - [ ]* 23.7 Écrire les tests unitaires pour la gestion d'erreurs
    - Tester tous les cas de validation
    - Tester affichage des messages d'erreur
    - Tester recovery après erreur

- [x] 24. Générateurs de tests et property-based testing
  - [x] 24.1 Créer GroupGenerator
    - Implémenter randomGroup avec faker
    - Implémenter randomMember avec permissions variées
    - _Requirements: 7.3_

  - [x] 24.2 Créer ProfileGenerator
    - Implémenter randomProfile avec toutes les sections
    - Implémenter randomActivity et randomPost
    - _Requirements: 7.3_

  - [x] 24.3 Créer MessageGenerator
    - Implémenter randomMessage avec tous les types
    - Implémenter randomConversation
    - _Requirements: 7.3_

  - [x] 24.4 Créer MediaGenerator
    - Implémenter randomMedia avec tous les types
    - Implémenter randomMediaList
    - _Requirements: 7.3_

  - [x] 24.5 Créer NotificationGenerator
    - Implémenter randomNotification avec tous les types
    - Implémenter randomNotificationList
    - _Requirements: 7.3_

  - [ ]* 24.6 Configurer property-based testing
    - Configurer minimum 100 itérations par test
    - Ajouter tags avec format : Feature + Property number
    - Documenter les générateurs

- [x] 25. Checkpoint final - Tests complets
  - Ensure all tests pass, ask the user if questions arise.

- [x] 26. Optimisations et polish
  - [x] 26.1 Optimiser les performances
    - Implémenter lazy loading pour les listes longues
    - Optimiser le rendu des médias avec caching
    - Vérifier absence de rebuilds inutiles
    - _Requirements: 8.6_

  - [x] 26.2 Ajouter loading states
    - Afficher shimmer loading pour les listes
    - Afficher spinners pendant les opérations async
    - Simuler latence réseau (100-500ms)
    - _Requirements: 7.3_

  - [x] 26.3 Améliorer l'UX
    - Ajouter haptic feedback sur actions importantes
    - Ajouter sons subtils pour notifications (optionnel)
    - Polir les transitions entre écrans
    - _Requirements: 8.3, 8.5_

  - [x] 26.4 Vérifier la cohérence du thème
    - Vérifier que tous les composants respectent le thème Discord/Telegram
    - Vérifier cohérence des couleurs et typographie
    - Vérifier cohérence des espacements et paddings
    - _Requirements: 8.4_

  - [ ]* 26.5 Écrire les tests de performance
    - Tester temps de chargement des listes (< 100ms pour 100 items)
    - Tester temps de recherche (< 200ms pour 1000 messages)
    - Tester temps de rendu galerie (< 300ms pour 500 médias)
    - Tester utilisation mémoire (< 200MB)

## Notes

- Les tâches marquées avec `*` sont optionnelles et peuvent être sautées pour un MVP plus rapide
- Chaque tâche référence les requirements spécifiques pour la traçabilité
- Les checkpoints permettent de valider le progrès de manière incrémentale
- Les tests de propriétés valident les propriétés universelles de correction
- Les tests unitaires valident des exemples spécifiques et cas limites
- L'implémentation suit l'ordre : Modèles → Providers → Widgets → Screens → Navigation → Tests
- Toutes les animations doivent maintenir 60 FPS minimum
- La persistance locale utilise shared_preferences pour les préférences utilisateur
- Les données mockées simulent un comportement réaliste avec latence et erreurs occasionnelles
