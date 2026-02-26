# 🎭 Système de Rôles et Multi-Utilisateurs - Documentation

## 📚 Documentation disponible

Ce système comprend plusieurs documents pour vous guider :

### 🚀 Pour commencer rapidement
**[QUICK_START_MULTI_USER.md](QUICK_START_MULTI_USER.md)**
- Guide de démarrage en 5 minutes
- Scénarios de test rapides
- Configuration du serveur
- Dépannage

### 📖 Documentation complète
**[ROLES_AND_MULTI_USER_SYSTEM.md](ROLES_AND_MULTI_USER_SYSTEM.md)**
- Architecture technique détaillée
- Modèles de données
- Services et écrans
- Flux de données
- Tests recommandés

### 🔐 Guide des permissions
**[PERMISSIONS_USAGE_GUIDE.md](PERMISSIONS_USAGE_GUIDE.md)**
- Comment utiliser les permissions dans le code
- Exemples pratiques
- Bonnes pratiques
- Débogage

### 📋 Résumé de l'implémentation
**[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)**
- Liste des fichiers créés/modifiés
- Statistiques du projet
- Fonctionnalités par rôle
- Métriques de qualité

## 🎯 Par où commencer ?

### Je veux tester rapidement
→ Lisez **[QUICK_START_MULTI_USER.md](QUICK_START_MULTI_USER.md)**

### Je veux comprendre l'architecture
→ Lisez **[ROLES_AND_MULTI_USER_SYSTEM.md](ROLES_AND_MULTI_USER_SYSTEM.md)**

### Je veux utiliser les permissions dans mon code
→ Lisez **[PERMISSIONS_USAGE_GUIDE.md](PERMISSIONS_USAGE_GUIDE.md)**

### Je veux voir ce qui a été fait
→ Lisez **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)**

## ⚡ Démarrage ultra-rapide

### 1. Démarrer le serveur
```bash
json-server --watch db.json --port 3000 --host 0.0.0.0
```

### 2. Lancer l'app
```bash
flutter run
```

### 3. Se connecter
```
Email: alistair@tableronde.com
Mot de passe: alistair123
```

### 4. Tester la messagerie
1. Cliquer sur l'onglet "Chats"
2. Cliquer sur l'icône 👥 "Tous les membres"
3. Sélectionner un utilisateur
4. Envoyer un message

## 📱 Comptes de test

| Email | Mot de passe | Rôle |
|-------|--------------|------|
| alistair@tableronde.com | alistair123 | 👑 Admin |
| t4zor@tableronde.com | t4zor123 | 🛡️ Modérateur |
| sophie@tableronde.com | sophie123 | 🛡️ Modérateur |
| tkporky@tableronde.com | tkporky123 | 👤 Membre |
| lucas@tableronde.com | lucas123 | 👤 Membre |
| test@tableronde.com | test123 | 👤 Membre |

## ✨ Fonctionnalités principales

### 🎭 Système de rôles
- 3 rôles : Administrateur, Modérateur, Membre
- 25+ permissions granulaires
- Badges visuels (👑 🛡️ 👤)

### 👥 Authentification multi-comptes
- Connexion/Déconnexion
- 6 comptes de test
- Session persistante
- Statut en ligne synchronisé

### 💬 Messagerie universelle
- Liste de tous les utilisateurs
- Recherche par nom/username
- Filtres (statut, rôle)
- Démarrage de conversation en 1 clic
- Support multi-appareils

## 🔧 Configuration réseau

### Développement local
```dart
static const String baseUrl = 'http://localhost:3000';
```

### Appareil physique
```dart
static const String baseUrl = 'http://[VOTRE_IP]:3000';
```

### Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

## 📊 Structure du projet

```
lib/
├── models/
│   └── auth/
│       ├── user_model.dart          # Modèle utilisateur avec rôle
│       └── user_role.dart           # Rôles et permissions
├── services/
│   ├── auth_service.dart            # Authentification
│   ├── api_service.dart             # API REST
│   └── user_service.dart            # Gestion des utilisateurs
├── screens/
│   ├── users/
│   │   └── all_users_screen.dart    # Liste des utilisateurs
│   └── chat_list_screen.dart        # Liste des chats
└── providers/
    └── auth_provider.dart            # État d'authentification
```

## 🧪 Tests rapides

### Test 1 : Connexion (30 secondes)
1. Lancer l'app
2. Se connecter avec un compte
3. Vérifier le profil

### Test 2 : Messagerie (1 minute)
1. Aller dans "Chats"
2. Cliquer sur 👥
3. Sélectionner un utilisateur
4. Envoyer un message

### Test 3 : Multi-appareils (2 minutes)
1. Appareil 1 : Se connecter avec alistair@tableronde.com
2. Appareil 2 : Se connecter avec t4zor@tableronde.com
3. Appareil 1 : Envoyer un message à T4zor
4. Appareil 2 : Vérifier la réception

## 🆘 Problèmes courants

### Le serveur ne démarre pas
```bash
# Vérifier le port
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows
```

### L'app ne se connecte pas
1. Vérifier que le serveur est démarré
2. Vérifier l'URL dans les services
3. Vérifier le réseau WiFi (même réseau)

### Les messages ne s'affichent pas
1. Actualiser l'écran (tirer vers le bas)
2. Vérifier les logs du serveur
3. Redémarrer le serveur

## 📞 Support

Pour plus d'aide, consultez :
- [QUICK_START_MULTI_USER.md](QUICK_START_MULTI_USER.md) - Section dépannage
- [ROLES_AND_MULTI_USER_SYSTEM.md](ROLES_AND_MULTI_USER_SYSTEM.md) - Documentation complète

## ✅ Checklist de validation

- [ ] Serveur JSON démarré
- [ ] URL configurée correctement
- [ ] App lancée sans erreur
- [ ] Connexion fonctionnelle
- [ ] Liste des utilisateurs affichée
- [ ] Messages envoyés/reçus
- [ ] Statut en ligne mis à jour
- [ ] Rôles affichés correctement

## 🎓 Ressources d'apprentissage

### Débutant
1. Lire [QUICK_START_MULTI_USER.md](QUICK_START_MULTI_USER.md)
2. Tester les scénarios de base
3. Explorer l'interface

### Intermédiaire
1. Lire [ROLES_AND_MULTI_USER_SYSTEM.md](ROLES_AND_MULTI_USER_SYSTEM.md)
2. Comprendre l'architecture
3. Tester les permissions

### Avancé
1. Lire [PERMISSIONS_USAGE_GUIDE.md](PERMISSIONS_USAGE_GUIDE.md)
2. Implémenter de nouvelles fonctionnalités
3. Personnaliser les permissions

## 🚀 Prochaines étapes

Après avoir testé le système de base :

1. **Ajouter des fonctionnalités** : Utilisez les permissions pour contrôler l'accès
2. **Personnaliser les rôles** : Créez de nouveaux rôles si nécessaire
3. **Implémenter la modération** : Utilisez les permissions de modération
4. **Ajouter des statistiques** : Suivez l'utilisation par rôle

## 📝 Notes importantes

- ⚠️ Les mots de passe sont en clair (OK pour les tests)
- ⚠️ Pas de WebSocket (pas de temps réel automatique)
- ⚠️ Permissions vérifiées côté client uniquement
- ✅ Parfait pour les tests et le développement
- ✅ Prêt pour l'intégration d'un vrai backend

---

**Bon développement ! 🎉**

Pour toute question, consultez la documentation complète ou les guides spécifiques.
