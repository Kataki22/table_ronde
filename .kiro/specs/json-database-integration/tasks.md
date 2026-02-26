# Plan d'Implémentation : json-database-integration

## Vue d'ensemble

Ce plan implémente la migration progressive de l'application TableRonde des données mock vers une API REST simulée avec json-server. La migration suit 6 phases sur 6 semaines, en commençant par la préparation de l'infrastructure, puis la migration des providers, l'adaptation des écrans, les tests d'intégration, l'optimisation, et enfin les tests de propriétés.

## Tâches

- [x] 1. Phase 1 : Préparation de l'infrastructure API
  - [x] 1.1 Auditer et compléter db.json
    - Comparer db.json avec tous les fichiers mock
    - Ajouter les données manquantes dans db.json
    - Valider la structure JSON
    - _Exigences: 13.1, 15.2_

  - [x] 1.2 Étendre ApiService avec méthodes CRUD complètes
    - Implémenter toutes les méthodes pour posts, groupes, messages, profils, notifications, médias, réactions
    - Ajouter gestion d'erreur HTTP avec messages descriptifs
    - Implémenter sérialisation/désérialisation JSON
    - _Exigences: 1.1-1.10_

  - [ ]* 1.3 Créer tests unitaires pour ApiService
    - Tester chaque méthode avec mockito et http_mock_adapter
    - Tester les cas d'erreur (404, 409, timeout, etc.)
    - _Exigences: 14.1_

  - [x] 1.4 Documenter les endpoints API
    - Créer documentation des endpoints disponibles
    - Documenter la structure de db.json
    - Ajouter exemples de requêtes curl
    - _Exigences: 15.1, 15.2, 15.8_

- [x] 2. Checkpoint - Vérifier l'infrastructure
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. Phase 2 : Migration des Providers vers API
  - [x] 3.1 Migrer FeedProvider vers API
    - Remplacer données mock par appels ApiService.getPosts()
    - Implémenter loadPosts() avec gestion isLoading et error
    - Implémenter createPost() avec optimistic update
    - Implémenter updatePost() et deletePost()
    - Implémenter refreshPosts()
    - Ajouter tri par timestamp décroissant
    - Appeler notifyListeners() après chaque changement d'état
    - _Exigences: 2.1-2.10, 13.6_

  - [ ]* 3.2 Écrire tests unitaires pour FeedProvider
    - Tester loadPosts avec succès et échec
    - Tester createPost, updatePost, deletePost
    - Vérifier que notifyListeners est appelé
    - _Exigences: 14.2_

  - [x] 3.3 Migrer ProfileProvider vers API
    - Implémenter loadProfile() avec cache et TTL de 5 minutes
    - Implémenter loadProfiles() pour charger tous les profils
    - Implémenter updateProfile() avec mise à jour du cache
    - Implémenter refreshProfile() qui force le rechargement
    - Ajouter fallback vers cache en cas d'erreur
    - Gérer états isLoading et error
    - _Exigences: 4.1-4.10, 13.7_

  - [ ]* 3.4 Écrire tests unitaires pour ProfileProvider
    - Tester stratégie cache-first
    - Tester expiration du cache après 5 minutes
    - Tester fallback vers cache en cas d'erreur
    - _Exigences: 14.2_

  - [x] 3.5 Migrer GroupChatProvider vers API
    - Implémenter loadGroups() depuis ApiService
    - Implémenter loadMessages(groupId) avec stockage dans Map
    - Implémenter sendMessage() avec optimistic update
    - Gérer remplacement du message temporaire après confirmation
    - Gérer rollback en cas d'échec d'envoi
    - Mettre à jour lastMessage et lastMessageTime du groupe
    - Implémenter createGroup() et updateGroup()
    - _Exigences: 3.1-3.10, 13.8_

  - [ ]* 3.6 Écrire tests unitaires pour GroupChatProvider
    - Tester optimistic update pour messages
    - Tester rollback en cas d'échec
    - Tester mise à jour des métadonnées du groupe
    - _Exigences: 14.2_

  - [x] 3.7 Créer NotificationProvider avec API
    - Créer nouveau provider NotificationProvider
    - Implémenter loadNotifications(userId) avec tri par timestamp
    - Calculer unreadCount (nombre de notifications non lues)
    - Implémenter markAsRead() avec décrémentation de unreadCount
    - Garantir que unreadCount ne soit jamais négatif
    - Implémenter deleteNotification() et clearAllNotifications()
    - Gérer états isLoading et error
    - _Exigences: 5.1-5.10, 13.9_

  - [ ]* 3.8 Écrire tests unitaires pour NotificationProvider
    - Tester calcul de unreadCount
    - Tester que unreadCount ne devient jamais négatif
    - Tester markAsRead et deleteNotification
    - _Exigences: 14.2_

  - [x] 3.9 Migrer MediaGalleryProvider vers API
    - Implémenter loadMediaForChat(chatId) depuis ApiService
    - Stocker médias dans Map indexée par chatId
    - Implémenter uploadMedia() avec ajout à la liste
    - Implémenter deleteMedia()
    - Ajouter filtrage par type de média
    - Implémenter getMediaForChat() avec tri par timestamp
    - Gérer états isLoading et error
    - _Exigences: 6.1-6.10, 13.10_

  - [ ]* 3.10 Écrire tests unitaires pour MediaGalleryProvider
    - Tester loadMediaForChat et filtrage par type
    - Tester uploadMedia et deleteMedia
    - _Exigences: 14.2_

- [x] 4. Checkpoint - Vérifier les providers
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Phase 3 : Adaptation des Écrans pour API
  - [x] 5.1 Adapter FeedScreen pour gérer états de chargement
    - Ajouter chargement des posts dans initState avec addPostFrameCallback
    - Afficher CircularProgressIndicator pendant isLoading et liste vide
    - Afficher message d'erreur avec bouton "Réessayer" si erreur et liste vide
    - Implémenter RefreshIndicator pour pull-to-refresh
    - Afficher données avec indicateur si isLoading et données existantes
    - Afficher snackbar si erreur et données existantes
    - _Exigences: 11.1-11.10_

  - [x] 5.2 Adapter ChatScreen pour gérer états de chargement
    - Ajouter chargement des groupes dans initState
    - Afficher CircularProgressIndicator pendant chargement initial
    - Gérer affichage d'erreur avec bouton "Réessayer"
    - Implémenter RefreshIndicator pour rafraîchir les groupes
    - _Exigences: 11.1-11.10_

  - [x] 5.3 Adapter GroupChatScreen pour gérer états de chargement
    - Charger messages du groupe dans initState
    - Afficher indicateur de chargement pour messages
    - Gérer erreur d'envoi de message avec feedback visuel
    - Afficher indicateur temporaire pour messages en cours d'envoi
    - _Exigences: 11.1-11.10_

  - [x] 5.4 Adapter ProfileScreen pour gérer états de chargement
    - Charger profil dans initState
    - Afficher CircularProgressIndicator pendant chargement
    - Gérer erreur de chargement avec bouton "Réessayer"
    - Implémenter RefreshIndicator
    - _Exigences: 11.1-11.10_

  - [x] 5.5 Créer NotificationsScreen avec gestion d'états
    - Créer nouveau écran NotificationsScreen
    - Charger notifications dans initState
    - Afficher liste de notifications avec indicateurs de lecture
    - Gérer marquage comme lu au tap
    - Afficher badge avec unreadCount
    - Gérer états de chargement et d'erreur
    - _Exigences: 11.1-11.10_

  - [x] 5.6 Adapter MediaGalleryScreen pour gérer états de chargement
    - Charger médias du chat dans initState
    - Afficher CircularProgressIndicator pendant chargement
    - Gérer erreur avec bouton "Réessayer"
    - Implémenter filtrage par type de média
    - _Exigences: 11.1-11.10_

- [x] 6. Checkpoint - Vérifier les écrans
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Phase 4 : Tests d'Intégration End-to-End
  - [ ]* 7.1 Tester flux de connexion
    - Tester inscription d'un nouvel utilisateur
    - Tester connexion avec utilisateur existant
    - Tester déconnexion
    - Vérifier persistance des données dans db.json
    - _Exigences: 14.3_

  - [ ]* 7.2 Tester flux du feed
    - Tester chargement des posts
    - Tester création d'un nouveau post
    - Tester ajout de réaction à un post
    - Tester ajout de commentaire
    - Tester partage d'un post
    - Vérifier que les données sont persistées
    - _Exigences: 14.3_

  - [ ]* 7.3 Tester flux de chat
    - Tester chargement des
- [ ] 7. Phase 4 : Tests d'Intégration End-to-End
  - [ ]* 7.1 Tester flux de connexion
    - Tester inscription, connexion, déconnexion
    - Vérifier persistance des données dans db.json
    - _Exigences: 14.3_

  - [ ]* 7.2 Tester flux du feed
    - Tester chargement, création, réaction, commentaire, partage de posts
    - Vérifier que les données sont persistées
    - _Exigences: 14.3_

  - [ ]* 7.3 Tester flux de chat
    - Tester chargement des groupes, ouverture, envoi et réception de messages
    - Vérifier optimistic update et rollback
    - _Exigences: 14.3_

  - [ ]* 7.4 Tester flux de profil
    - Tester consultation et modification de profil
    - Tester consultation des posts d'un utilisateur
    - Vérifier cache et expiration
    - _Exigences: 14.3_

  - [ ]* 7.5 Tester flux de notifications
    - Tester chargement des notifications
    - Tester marquage comme lu
    - Tester navigation depuis une notification
    - Vérifier unreadCount
    - _Exigences: 14.3_

- [x] 8. Checkpoint - Vérifier les flux end-to-end
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Phase 5 : Optimisation et Nettoyage
  - [x] 9.1 Implémenter cache avec expiration pour ProfileProvider
    - Créer classe CachedData avec timestamp et TTL
    - Modifier getProfile pour utiliser le cache
    - Configurer TTL à 5 minutes
    - _Exigences: 9.3, 4.2_

  - [x] 9.2 Ajouter pagination pour getPosts
    - Modifier ApiService.getPosts pour accepter page et limit
    - Utiliser paramètres _page, _limit, _sort, _order de json-server
    - Limiter chargement initial à 20 posts
    - Implémenter chargement de pages supplémentaires
    - _Exigences: 9.1, 9.2, 9.8_

  - [x] 9.3 Implémenter debouncing pour recherche
    - Créer fonction de recherche avec Timer
    - Configurer debounce à 500ms
    - Annuler timer précédent à chaque nouvelle saisie
    - _Exigences: 9.4_

  - [x] 9.4 Optimiser chargement des images
    - Remplacer Image.network par CachedNetworkImage
    - Ajouter placeholder et errorWidget
    - Configurer fadeInDuration
    - _Exigences: 9.5, 9.7_

  - [x] 9.5 Implémenter chargement parallèle initial
    - Créer fonction loadInitialData dans un provider global
    - Utiliser Future.wait pour charger posts, groupes, notifications en parallèle
    - Appeler au démarrage de l'application
    - _Exigences: 9.6, 9.9_

  - [x] 9.6 Supprimer fichiers mock inutilisés
    - Supprimer lib/data/mock_posts_data.dart
    - Supprimer lib/data/mock_groups_data.dart
    - Supprimer lib/data/mock_profiles_data.dart
    - Supprimer lib/data/mock_media_data.dart
    - Supprimer lib/data/mock_notifications_data.dart
    - Supprimer lib/data/mock_reactions_data.dart
    - Supprimer lib/data/sample_chats_data.dart
    - Vérifier qu'aucune référence ne subsiste
    - _Exigences: 13.5_

  - [x] 9.7 Mettre à jour documentation
    - Documenter configuration de baseUrl pour Android/iOS/physique
    - Documenter commandes pour démarrer json-server
    - Créer guide de démarrage pour nouveaux développeurs
    - Documenter patterns de gestion d'erreur
    - Documenter stratégies de cache et optimisations
    - _Exigences: 15.3, 15.4, 15.5, 15.6, 15.7, 15.10_

- [x] 10. Checkpoint - Vérifier optimisations
  - Ensure all tests pass, ask the user if questions arise.

- [x] 11. Phase 6 : Tests de Propriétés de Correction
  - [ ]* 11.1 Tester propriétés de sérialisation
    - **Propriété 1: Round-trip de Sérialisation**
    - **Valide: Exigences 1.9, 1.10**
    - Tester que sérialiser puis désérialiser produit objet équivalent pour tous les modèles

  - [ ]* 11.2 Tester propriétés de gestion d'erreur
    - **Propriété 2: Gestion d'Erreur HTTP**
    - **Valide: Exigence 1.8**
    - Tester que toute requête HTTP qui échoue lance une exception avec message descriptif

  - [ ]* 11.3 Tester propriétés de chargement depuis API
    - **Propriété 3: Chargement depuis API**
    - **Valide: Exigences 2.1, 3.1, 4.7, 5.1, 6.1**
    - Tester que tous les appels de chargement utilisent ApiService

  - [ ]* 11.4 Tester propriétés d'état des providers
    - **Propriété 4: État de Chargement**
    - **Propriété 5: État après Succès**
    - **Propriété 6: État après Échec**
    - **Valide: Exigences 2.2, 2.3, 2.4**
    - Tester isLoading et error pour tous les providers

  - [ ]* 11.5 Tester propriété de synchronisation UI
    - **Propriété 7: Synchronisation État-UI**
    - **Valide: Exigence 2.5**
    - Tester que notifyListeners est appelé après chaque modification

  - [ ]* 11.6 Tester propriétés d'optimistic update
    - **Propriété 8: Optimistic Update pour Posts**
    - **Propriété 14: Optimistic Update pour Messages**
    - **Propriété 15: Remplacement après Confirmation**
    - **Propriété 16: Rollback sur Échec**
    - **Valide: Exigences 2.6, 3.4, 3.5, 3.6**
    - Tester optimistic update, confirmation et rollback

  - [ ]* 11.7 Tester propriétés de synchronisation CRUD
    - **Propriété 9: Synchronisation Update**
    - **Propriété 10: Synchronisation Delete**
    - **Valide: Exigences 2.7, 2.8, 3.10, 4.5, 5.7, 6.5**
    - Tester que update et delete sont synchronisés local/API

  - [ ]* 11.8 Tester propriétés de tri et refresh
    - **Propriété 11: Tri des Posts**
    - **Propriété 12: Refresh Force Reload**
    - **Propriété 23: Tri des Notifications**
    - **Propriété 32: Tri des Médias**
    - **Valide: Exigences 2.9, 2.10, 4.10, 5.2, 6.10**
    - Tester tri par timestamp et refresh

  - [ ]* 11.9 Tester propriétés de messages par groupe
    - **Propriété 13: Messages par Groupe**
    - **Propriété 17: Cohérence Métadonnées Groupe**
    - **Valide: Exigences 3.2, 3.7**
    - Tester que messages appartiennent au bon groupe et métadonnées sont à jour

  - [ ]* 11.10 Tester propriétés de cache
    - **Propriété 18: Stratégie Cache-First**
    - **Propriété 19: Validité du Cache**
    - **Propriété 20: Fallback vers API**
    - **Propriété 21: Mise à Jour du Cache**
    - **Propriété 22: Résilience avec Cache**
    - **Valide: Exigences 4.1, 4.2, 4.3, 4.4, 4.8, 8.2, 9.3**
    - Tester stratégie de cache avec TTL et fallback

  - [ ]* 11.11 Tester propriétés de notifications
    - **Propriété 24: Compteur de Notifications**
    - **Propriété 25: Synchronisation Mark as Read**
    - **Propriété 26: Décrémentation du Compteur**
    - **Propriété 27: Compteur Non Négatif**
    - **Propriété 28: Suppression en Masse**
    - **Valide: Exigences 5.3, 5.4, 5.5, 5.6, 5.8**
    - Tester unreadCount et opérations sur notifications

  - [ ]* 11.12 Tester propriétés de médias
    - **Propriété 29: Upload et Ajout de Média**
    - **Propriété 30: Filtrage par Type**
    - **Propriété 31: Médias par Chat**
    - **Valide: Exigences 6.4, 6.6, 6.9**
    - Tester upload, filtrage et association aux chats

  - [ ]* 11.13 Tester propriétés de validation des données
    - **Propriété 33: Unicité des Identifiants**
    - **Propriété 34: Intégrité Référentielle**
    - **Propriété 35: Validation Contenu Post**
    - **Propriété 36: Compteurs Non Négatifs**
    - **Propriété 37: Validation Nom Groupe**
    - **Propriété 38: Nombre Minimum de Membres**
    - **Propriété 39: Présence d'Admin**
    - **Propriété 40: Format Username**
    - **Propriété 41: Type de Notification Valide**
    - **Propriété 42: URL Média Non Vide**
    - **Valide: Exigences 7.1-7.10**
    - Tester toutes les règles de validation des modèles

  - [ ]* 11.14 Tester propriétés de résilience
    - **Propriété 43: Résilience aux Données Invalides**
    - **Propriété 44: File d'Attente d'Opérations**
    - **Propriété 45: Reprise Automatique**
    - **Propriété 46: Bouton Réessayer**
    - **Valide: Exigences 8.3, 8.6, 8.7, 8.10, 11.3**
    - Tester gestion des erreurs et récupération

  - [ ]* 11.15 Tester propriétés d'optimisation
    - **Propriété 47: Pagination Fonctionnelle**
    - **Propriété 48: Debouncing de Recherche**
    - **Propriété 49: Chargement Parallèle**
    - **Propriété 50: Tri Côté Serveur**
    - **Valide: Exigences 9.1, 9.4, 9.6, 9.8, 9.9**
    - Tester pagination, debounce et chargement parallèle

  - [ ]* 11.16 Tester propriétés de sécurité
    - **Propriété 51: Limite de Caractères**
    - **Propriété 52: Sanitization du Contenu**
    - **Propriété 53: Token d'Authentification**
    - **Propriété 54: Token CSRF**
    - **Propriété 55: Rate Limiting**
    - **Propriété 56: Vérification des Permissions**
    - **Propriété 57: Logging des Erreurs de Sécurité**
    - **Valide: Exigences 10.1-10.10**
    - Tester validation, sanitization, tokens et rate limiting

  - [ ]* 11.17 Tester propriétés d'affichage UI
    - **Propriété 58: Indicateur de Chargement Initial**
    - **Propriété 59: Affichage d'Erreur**
    - **Propriété 60: Pull-to-Refresh**
    - **Propriété 61: Affichage du Contenu**
    - **Propriété 62: Chargement avec Données Existantes**
    - **Propriété 63: Erreur avec Données Existantes**
    - **Valide: Exigences 11.1-11.9**
    - Tester tous les états d'affichage des écrans

- [x] 12. Checkpoint final - Validation complète
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Les tâches marquées avec `*` sont optionnelles et peuvent être sautées pour un MVP plus rapide
- Chaque tâche référence les exigences spécifiques pour la traçabilité
- Les checkpoints permettent une validation incrémentale
- Les tests de propriétés valident les 63 propriétés de correction définies dans le design
- La migration suit un ordre logique : infrastructure → providers → écrans → tests → optimisation
- Les tests unitaires et d'intégration sont optionnels mais fortement recommandés
- Le plan suit strictement les 6 phases décrites dans le document de conception
