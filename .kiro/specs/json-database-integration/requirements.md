# Document d'Exigences : json-database-integration

## Introduction

Cette fonctionnalité vise à remplacer toutes les données fictives (mock data) hardcodées dans l'application Flutter TableRonde par des appels API vers une base de données JSON (db.json) via json-server. L'objectif est de créer un environnement de développement et de test plus réaliste qui simule une véritable API REST, permettant de tester l'application avec des données persistantes et modifiables, de simuler un environnement backend réaliste, et de préparer l'intégration avec une vraie API backend.

## Glossaire

- **ApiService**: Service centralisé pour toutes les requêtes HTTP vers json-server
- **Provider**: Composant de gestion d'état utilisant le pattern ChangeNotifier de Flutter
- **json-server**: Serveur REST simulé basé sur un fichier JSON
- **db.json**: Fichier JSON contenant toutes les données de l'application
- **Mock_Data**: Données fictives hardcodées dans les fichiers Dart
- **Optimistic_Update**: Technique de mise à jour de l'UI avant confirmation du serveur
- **Cache**: Stockage temporaire de données pour améliorer les performances
- **TTL**: Time To Live, durée de validité des données en cache
- **Rate_Limiting**: Limitation du nombre de requêtes par unité de temps
- **CSRF**: Cross-Site Request Forgery, type d'attaque web
- **Pagination**: Division des résultats en pages pour améliorer les performances

## Exigences

### Exigence 1: Extension du Service API

**User Story:** En tant que développeur, je veux un service API centralisé avec toutes les méthodes CRUD, afin de pouvoir effectuer toutes les opérations sur les ressources de l'application.

#### Critères d'Acceptation

1. THE ApiService SHALL fournir des méthodes GET, POST, PUT, DELETE pour les posts
2. THE ApiService SHALL fournir des méthodes GET, POST, PUT, DELETE pour les groupes
3. THE ApiService SHALL fournir des méthodes GET, POST, DELETE pour les messages
4. THE ApiService SHALL fournir des méthodes GET, PUT pour les profils utilisateurs
5. THE ApiService SHALL fournir des méthodes GET, POST, PUT, DELETE pour les notifications
6. THE ApiService SHALL fournir des méthodes GET, POST pour les médias
7. THE ApiService SHALL fournir des méthodes GET, POST, DELETE pour les réactions
8. WHEN une requête HTTP échoue, THE ApiService SHALL lancer une exception avec un message descriptif
9. THE ApiService SHALL sérialiser les objets Dart en JSON avant l'envoi
10. THE ApiService SHALL désérialiser les réponses JSON en objets Dart typés

### Exigence 2: Migration du FeedProvider

**User Story:** En tant qu'utilisateur, je veux voir les posts chargés depuis l'API, afin d'avoir des données persistantes et modifiables.

#### Critères d'Acceptation

1. WHEN loadPosts est appelé, THE FeedProvider SHALL récupérer les posts depuis ApiService
2. WHILE les posts sont en cours de chargement, THE FeedProvider SHALL définir isLoading à true
3. WHEN les posts sont chargés avec succès, THE FeedProvider SHALL définir isLoading à false et error à null
4. IF le chargement échoue, THEN THE FeedProvider SHALL définir isLoading à false et error au message d'erreur
5. WHEN l'état change, THE FeedProvider SHALL appeler notifyListeners
6. WHEN createPost est appelé, THE FeedProvider SHALL ajouter le post localement puis l'envoyer à l'API
7. WHEN updatePost est appelé, THE FeedProvider SHALL mettre à jour le post dans la liste et sur l'API
8. WHEN deletePost est appelé, THE FeedProvider SHALL supprimer le post de la liste et de l'API
9. THE FeedProvider SHALL trier les posts par timestamp décroissant
10. WHEN refreshPosts est appelé, THE FeedProvider SHALL recharger tous les posts depuis l'API

### Exigence 3: Migration du GroupChatProvider

**User Story:** En tant qu'utilisateur, je veux voir les groupes et messages chargés depuis l'API, afin d'avoir des conversations persistantes.

#### Critères d'Acceptation

1. WHEN loadGroups est appelé, THE GroupChatProvider SHALL récupérer les groupes depuis ApiService
2. WHEN loadMessages est appelé avec un groupId, THE GroupChatProvider SHALL récupérer les messages de ce groupe
3. THE GroupChatProvider SHALL stocker les messages dans une Map indexée par groupId
4. WHEN sendMessage est appelé, THE GroupChatProvider SHALL ajouter le message localement immédiatement
5. WHEN sendMessage réussit, THE GroupChatProvider SHALL remplacer le message temporaire par le message confirmé
6. IF sendMessage échoue, THEN THE GroupChatProvider SHALL supprimer le message temporaire
7. WHEN un message est envoyé, THE GroupChatProvider SHALL mettre à jour lastMessage et lastMessageTime du groupe
8. THE GroupChatProvider SHALL gérer les états isLoading et error pour les groupes et messages
9. WHEN createGroup est appelé, THE GroupChatProvider SHALL créer le groupe via l'API et l'ajouter à la liste
10. WHEN updateGroup est appelé, THE GroupChatProvider SHALL mettre à jour le groupe via l'API

### Exigence 4: Migration du ProfileProvider

**User Story:** En tant qu'utilisateur, je veux voir les profils chargés depuis l'API avec mise en cache, afin d'avoir des temps de chargement optimisés.

#### Critères d'Acceptation

1. WHEN loadProfile est appelé avec un userId, THE ProfileProvider SHALL vérifier d'abord le cache
2. WHEN le cache contient le profil et qu'il a moins de 5 minutes, THE ProfileProvider SHALL retourner le profil en cache
3. WHEN le cache est expiré ou inexistant, THE ProfileProvider SHALL charger le profil depuis l'API
4. WHEN un profil est chargé depuis l'API, THE ProfileProvider SHALL le mettre en cache avec un timestamp
5. WHEN updateProfile est appelé, THE ProfileProvider SHALL mettre à jour le profil via l'API et dans le cache
6. THE ProfileProvider SHALL stocker les profils dans une Map indexée par userId
7. WHEN loadProfiles est appelé, THE ProfileProvider SHALL charger tous les profils depuis l'API
8. IF le chargement échoue et qu'un cache existe, THEN THE ProfileProvider SHALL retourner le profil en cache
9. THE ProfileProvider SHALL gérer les états isLoading et error
10. WHEN refreshProfile est appelé, THE ProfileProvider SHALL forcer le rechargement depuis l'API

### Exigence 5: Création du NotificationProvider

**User Story:** En tant qu'utilisateur, je veux voir mes notifications chargées depuis l'API, afin de rester informé des activités.

#### Critères d'Acceptation

1. WHEN loadNotifications est appelé avec un userId, THE NotificationProvider SHALL récupérer les notifications depuis ApiService
2. THE NotificationProvider SHALL trier les notifications par timestamp décroissant
3. THE NotificationProvider SHALL calculer le nombre de notifications non lues
4. WHEN markAsRead est appelé, THE NotificationProvider SHALL marquer la notification comme lue via l'API
5. WHEN une notification est marquée comme lue, THE NotificationProvider SHALL décrémenter unreadCount
6. THE NotificationProvider SHALL garantir que unreadCount ne soit jamais négatif
7. WHEN deleteNotification est appelé, THE NotificationProvider SHALL supprimer la notification via l'API et de la liste
8. WHEN clearAllNotifications est appelé, THE NotificationProvider SHALL supprimer toutes les notifications
9. THE NotificationProvider SHALL gérer les états isLoading et error
10. THE NotificationProvider SHALL exposer une propriété unreadCount pour les badges

### Exigence 6: Migration du MediaGalleryProvider

**User Story:** En tant qu'utilisateur, je veux voir les médias partagés chargés depuis l'API, afin d'accéder à la galerie de chaque conversation.

#### Critères d'Acceptation

1. WHEN loadMediaForChat est appelé avec un chatId, THE MediaGalleryProvider SHALL récupérer les médias depuis ApiService
2. THE MediaGalleryProvider SHALL stocker les médias dans une Map indexée par chatId
3. WHEN uploadMedia est appelé, THE MediaGalleryProvider SHALL envoyer le média via l'API
4. WHEN un média est uploadé, THE MediaGalleryProvider SHALL l'ajouter à la liste des médias du chat
5. WHEN deleteMedia est appelé, THE MediaGalleryProvider SHALL supprimer le média via l'API et de la liste
6. THE MediaGalleryProvider SHALL permettre de filtrer les médias par type
7. THE MediaGalleryProvider SHALL gérer les états isLoading et error
8. THE MediaGalleryProvider SHALL supporter les types photo, video, document, voice, link
9. WHEN getMediaForChat est appelé, THE MediaGalleryProvider SHALL retourner les médias du chat spécifié
10. THE MediaGalleryProvider SHALL trier les médias par timestamp décroissant

### Exigence 7: Validation des Modèles de Données

**User Story:** En tant que développeur, je veux que toutes les données soient validées, afin de garantir l'intégrité des données.

#### Critères d'Acceptation

1. WHEN un PostModel est créé, THE System SHALL valider que id est unique et non vide
2. WHEN un PostModel est créé, THE System SHALL valider que authorId correspond à un utilisateur existant
3. WHEN un PostModel de type text est créé, THE System SHALL valider que content n'est pas vide
4. WHEN un PostModel est créé, THE System SHALL valider que les compteurs sont supérieurs ou égaux à zéro
5. WHEN un GroupChatModel est créé, THE System SHALL valider que name n'est pas vide
6. WHEN un GroupChatModel est créé, THE System SHALL valider qu'il contient au moins 2 membres
7. WHEN un GroupChatModel est créé, THE System SHALL valider qu'au moins un membre a le rôle admin
8. WHEN un UserProfileModel est créé, THE System SHALL valider que username commence par '@'
9. WHEN un NotificationModel est créé, THE System SHALL valider que type est l'un des types valides
10. WHEN un MediaItem est créé, THE System SHALL valider que url n'est pas vide

### Exigence 8: Gestion des Erreurs Réseau

**User Story:** En tant qu'utilisateur, je veux être informé clairement des erreurs de connexion, afin de comprendre ce qui ne fonctionne pas.

#### Critères d'Acceptation

1. IF json-server est indisponible, THEN THE System SHALL afficher "Impossible de se connecter au serveur"
2. IF json-server est indisponible et qu'un cache existe, THEN THE System SHALL utiliser les données en cache
3. IF les données JSON sont invalides, THEN THE System SHALL logger l'erreur et ignorer l'élément invalide
4. IF une ressource n'est pas trouvée (404), THEN THE System SHALL afficher "Ressource non trouvée"
5. IF une ressource existe déjà (409), THEN THE System SHALL afficher "Cette ressource existe déjà"
6. IF la connexion est perdue pendant une opération, THEN THE System SHALL sauvegarder l'opération dans une file d'attente
7. WHEN la connexion revient, THE System SHALL réessayer automatiquement les opérations en attente
8. IF un timeout se produit, THEN THE System SHALL afficher "Délai d'attente dépassé"
9. IF une erreur 401 se produit, THEN THE System SHALL afficher "Non authentifié. Veuillez vous reconnecter"
10. WHEN une erreur se produit, THE System SHALL proposer un bouton "Réessayer"

### Exigence 9: Optimisation des Performances

**User Story:** En tant qu'utilisateur, je veux que l'application charge rapidement, afin d'avoir une expérience fluide.

#### Critères d'Acceptation

1. WHEN getPosts est appelé, THE System SHALL supporter la pagination avec paramètres page et limit
2. THE System SHALL limiter le chargement initial à 20 posts par page
3. WHEN un profil est demandé, THE System SHALL utiliser le cache si les données ont moins de 5 minutes
4. WHEN une recherche est effectuée, THE System SHALL appliquer un debounce de 500ms
5. WHEN des images sont affichées, THE System SHALL utiliser le lazy loading
6. WHEN plusieurs ressources sont nécessaires, THE System SHALL les charger en parallèle avec Future.wait
7. THE System SHALL mettre en cache les images avec CachedNetworkImage
8. THE System SHALL trier les posts par timestamp côté serveur avec _sort et _order
9. WHEN loadInitialData est appelé, THE System SHALL charger posts, groupes et notifications en parallèle
10. THE System SHALL charger un écran en moins de 2 secondes

### Exigence 10: Sécurité des Données

**User Story:** En tant qu'utilisateur, je veux que mes données soient protégées, afin de garantir la sécurité de mes informations.

#### Critères d'Acceptation

1. WHEN un post est créé, THE System SHALL valider que le contenu ne dépasse pas 5000 caractères
2. WHEN du contenu est soumis, THE System SHALL supprimer les balises script et iframe
3. WHEN une requête API est effectuée, THE System SHALL inclure un token d'authentification Bearer
4. WHEN une requête de modification est effectuée, THE System SHALL inclure un token CSRF
5. THE System SHALL limiter les requêtes à 100 par minute par endpoint
6. WHEN la limite de requêtes est atteinte, THE System SHALL afficher "Trop de requêtes"
7. THE System SHALL valider les entrées côté client avant l'envoi au serveur
8. WHEN un utilisateur modifie un profil, THE System SHALL vérifier qu'il a les permissions nécessaires
9. THE System SHALL utiliser HTTPS pour toutes les communications en production
10. THE System SHALL logger toutes les erreurs de sécurité pour audit

### Exigence 11: Adaptation des Écrans

**User Story:** En tant qu'utilisateur, je veux voir des indicateurs de chargement et pouvoir rafraîchir les données, afin de savoir l'état de l'application.

#### Critères d'Acceptation

1. WHEN un écran est chargé, THE System SHALL afficher un CircularProgressIndicator pendant le chargement initial
2. WHEN une erreur se produit, THE System SHALL afficher une icône d'erreur et le message d'erreur
3. WHEN une erreur se produit, THE System SHALL afficher un bouton "Réessayer"
4. WHEN l'utilisateur tire vers le bas, THE System SHALL rafraîchir les données avec RefreshIndicator
5. WHEN les données sont chargées, THE System SHALL afficher le contenu dans une ListView
6. WHEN isLoading est true et que des données existent, THE System SHALL afficher les données avec un indicateur de rafraîchissement
7. WHEN isLoading est true et qu'aucune donnée n'existe, THE System SHALL afficher uniquement l'indicateur de chargement
8. WHEN error est non null et qu'aucune donnée n'existe, THE System SHALL afficher l'écran d'erreur
9. WHEN error est non null et que des données existent, THE System SHALL afficher les données avec un message d'erreur en snackbar
10. THE System SHALL charger les données dans initState avec addPostFrameCallback

### Exigence 12: Configuration de l'Environnement

**User Story:** En tant que développeur, je veux pouvoir configurer facilement l'environnement, afin de démarrer rapidement le développement.

#### Critères d'Acceptation

1. THE System SHALL utiliser http://10.0.2.2:3000 comme baseUrl pour Android Emulator
2. THE System SHALL utiliser http://localhost:3000 comme baseUrl pour iOS Simulator
3. THE System SHALL permettre de configurer une IP personnalisée pour les appareils physiques
4. THE System SHALL documenter comment installer json-server globalement
5. THE System SHALL documenter comment démarrer json-server avec --watch db.json
6. THE System SHALL supporter un mode avec délai simulé pour tester les états de chargement
7. WHEN l'application Android est configurée, THE System SHALL activer usesCleartextTraffic dans AndroidManifest.xml
8. THE System SHALL fournir des commandes curl pour tester l'API
9. THE System SHALL documenter les dépendances Flutter requises dans pubspec.yaml
10. THE System SHALL fournir un guide de démarrage pour les nouveaux développeurs

### Exigence 13: Migration Progressive

**User Story:** En tant que chef de projet, je veux une migration progressive en 6 phases, afin de minimiser les risques et faciliter les tests.

#### Critères d'Acceptation

1. WHEN la Phase 1 est complète, THE System SHALL avoir db.json avec toutes les données et ApiService étendu
2. WHEN la Phase 2 est complète, THE System SHALL avoir tous les providers migrés vers l'API
3. WHEN la Phase 3 est complète, THE System SHALL avoir tous les écrans adaptés avec gestion d'erreur
4. WHEN la Phase 4 est complète, THE System SHALL avoir tous les flux utilisateur testés
5. WHEN la Phase 5 est complète, THE System SHALL avoir supprimé tous les fichiers mock
6. THE System SHALL migrer FeedProvider en premier car c'est le plus simple
7. THE System SHALL migrer ProfileProvider en deuxième car il est une dépendance
8. THE System SHALL migrer GroupChatProvider en troisième car il est plus complexe
9. THE System SHALL migrer NotificationProvider en quatrième car c'est un nouveau provider
10. THE System SHALL migrer MediaGalleryProvider en dernier car il dépend des autres

### Exigence 14: Tests et Qualité

**User Story:** En tant que développeur, je veux une suite de tests complète, afin de garantir la qualité du code.

#### Critères d'Acceptation

1. THE System SHALL avoir des tests unitaires pour chaque méthode d'ApiService
2. THE System SHALL avoir des tests unitaires pour chaque provider
3. THE System SHALL avoir des tests d'intégration pour chaque flux utilisateur
4. THE System SHALL avoir des tests de propriété pour l'unicité des IDs
5. THE System SHALL avoir des tests de propriété pour la cohérence des données
6. THE System SHALL avoir des tests de propriété pour la synchronisation notifyListeners
7. THE System SHALL utiliser mockito pour mocker les dépendances dans les tests
8. THE System SHALL utiliser http_mock_adapter pour mocker les requêtes HTTP
9. THE System SHALL avoir un taux de couverture de code supérieur à 80%
10. THE System SHALL exécuter tous les tests avant chaque commit

### Exigence 15: Documentation et Maintenance

**User Story:** En tant que développeur, je veux une documentation complète, afin de comprendre et maintenir le code facilement.

#### Critères d'Acceptation

1. THE System SHALL documenter tous les endpoints API disponibles
2. THE System SHALL documenter la structure de db.json
3. THE System SHALL documenter comment démarrer json-server
4. THE System SHALL documenter les différentes configurations de baseUrl
5. THE System SHALL documenter les patterns de gestion d'erreur
6. THE System SHALL documenter les stratégies de cache
7. THE System SHALL documenter les optimisations de performance
8. THE System SHALL documenter les considérations de sécurité
9. THE System SHALL fournir des exemples d'utilisation pour chaque provider
10. THE System SHALL maintenir un changelog des modifications
