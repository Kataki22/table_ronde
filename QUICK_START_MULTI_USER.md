# 🚀 Guide de Démarrage Rapide - Tests Multi-Utilisateurs

## 📋 Prérequis

- Flutter installé
- json-server installé (`npm install -g json-server`)
- Au moins 2 appareils/émulateurs pour tester

## ⚡ Démarrage en 5 minutes

### Étape 1 : Démarrer le serveur JSON

```bash
# Dans le dossier du projet
json-server --watch db.json --port 3000 --host 0.0.0.0
```

Le serveur démarre sur `http://localhost:3000`

### Étape 2 : Configurer l'URL du serveur

Ouvrir `lib/services/api_service.dart` et `lib/services/auth_service.dart` :

**Pour tests locaux (émulateur):**
```dart
static const String baseUrl = 'http://localhost:3000';
```

**Pour appareil physique:**
```dart
// Remplacer X.X.X.X par votre IP locale
static const String baseUrl = 'http://X.X.X.X:3000';
```

**Pour Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

### Étape 3 : Lancer l'application

```bash
flutter run
```

## 🧪 Scénario de test rapide

### Test 1 : Connexion multi-appareils (2 minutes)

**Appareil 1:**
1. Lancer l'app
2. Se connecter avec :
   - Email: `alistair@tableronde.com`
   - Mot de passe: `alistair123`
3. Rôle: 👑 Administrateur

**Appareil 2:**
1. Lancer l'app
2. Se connecter avec :
   - Email: `t4zor@tableronde.com`
   - Mot de passe: `t4zor123`
3. Rôle: 🛡️ Modérateur

### Test 2 : Démarrer une conversation (1 minute)

**Appareil 1 (AlistairJr):**
1. Aller dans l'onglet "Chats"
2. Cliquer sur l'icône 👥 "Tous les membres" en haut à droite
3. Cliquer sur "T4zor" dans la liste
4. Envoyer un message : "Salut T4zor !"

**Appareil 2 (T4zor):**
1. Vérifier la réception du message
2. Répondre : "Salut AlistairJr !"

**Appareil 1:**
1. Vérifier la réception de la réponse

✅ **Succès !** La messagerie multi-utilisateurs fonctionne !

### Test 3 : Tester les rôles (2 minutes)

**Appareil 1 (Admin):**
1. Aller sur le profil (icône en bas à droite)
2. Observer le badge 👑 Administrateur
3. Vérifier les options disponibles

**Appareil 2 (Modérateur):**
1. Aller sur le profil
2. Observer le badge 🛡️ Modérateur
3. Comparer les options avec l'admin

**Appareil 3 (optionnel - Membre):**
1. Se connecter avec `lucas@tableronde.com` / `lucas123`
2. Observer le badge 👤 Membre
3. Comparer les options disponibles

## 📱 Comptes de test disponibles

| Email | Mot de passe | Rôle | Icône |
|-------|--------------|------|-------|
| alistair@tableronde.com | alistair123 | Administrateur | 👑 |
| t4zor@tableronde.com | t4zor123 | Modérateur | 🛡️ |
| sophie@tableronde.com | sophie123 | Modérateur | 🛡️ |
| tkporky@tableronde.com | tkporky123 | Membre | 👤 |
| lucas@tableronde.com | lucas123 | Membre | 👤 |
| test@tableronde.com | test123 | Membre | 👤 |

## 🔍 Fonctionnalités à tester

### Messagerie universelle

- [ ] Rechercher un utilisateur par nom
- [ ] Rechercher un utilisateur par username
- [ ] Filtrer par statut (En ligne)
- [ ] Filtrer par rôle (Admin, Modérateur, Membre)
- [ ] Démarrer une conversation avec un nouveau membre
- [ ] Envoyer un message
- [ ] Recevoir un message
- [ ] Voir le statut en ligne

### Authentification

- [ ] Se connecter
- [ ] Se déconnecter
- [ ] Changer de compte
- [ ] Vérifier la persistance de session (fermer/rouvrir l'app)
- [ ] Vérifier la mise à jour du statut en ligne

### Rôles et permissions

- [ ] Voir le badge de rôle sur le profil
- [ ] Comparer les options disponibles selon le rôle
- [ ] Tester les permissions de modération (si implémentées)

## 🐛 Dépannage

### Le serveur ne démarre pas

```bash
# Vérifier que le port 3000 n'est pas déjà utilisé
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Utiliser un autre port si nécessaire
json-server --watch db.json --port 3001 --host 0.0.0.0
```

### L'app ne se connecte pas au serveur

1. Vérifier que le serveur est bien démarré
2. Vérifier l'URL dans `api_service.dart` et `auth_service.dart`
3. Pour appareil physique, vérifier que l'appareil et l'ordinateur sont sur le même réseau WiFi
4. Désactiver le pare-feu temporairement pour tester

### Trouver votre IP locale

**Windows:**
```bash
ipconfig
# Chercher "Adresse IPv4"
```

**macOS:**
```bash
ifconfig | grep "inet "
# ou
ipconfig getifaddr en0
```

**Linux:**
```bash
ip addr show
# ou
hostname -I
```

### Les messages ne s'affichent pas

1. Vérifier que les deux appareils sont connectés au même serveur
2. Actualiser l'écran de chat (tirer vers le bas)
3. Vérifier les logs du serveur JSON
4. Redémarrer le serveur JSON

### Erreur "Connection refused"

- **Android Emulator** : Utiliser `http://10.0.2.2:3000`
- **iOS Simulator** : Utiliser `http://localhost:3000`
- **Appareil physique** : Utiliser l'IP locale `http://192.168.X.X:3000`

## 📊 Vérifier que tout fonctionne

### Checklist rapide

✅ Le serveur JSON est démarré
✅ L'URL du serveur est correctement configurée
✅ L'app se lance sans erreur
✅ La connexion fonctionne
✅ Le profil affiche les bonnes informations
✅ La liste des membres s'affiche
✅ Les messages s'envoient et se reçoivent
✅ Le statut en ligne se met à jour
✅ Les rôles s'affichent correctement

## 🎯 Scénarios de test avancés

### Scénario 1 : Conversation de groupe

1. **Appareil 1** : Créer un groupe avec plusieurs membres
2. **Appareil 2** : Vérifier la réception de l'invitation
3. **Tous** : Envoyer des messages dans le groupe
4. **Tous** : Vérifier la réception des messages

### Scénario 2 : Changement de statut

1. **Appareil 1** : Se connecter
2. **Appareil 2** : Vérifier que l'utilisateur apparaît en ligne
3. **Appareil 1** : Se déconnecter
4. **Appareil 2** : Actualiser et vérifier que l'utilisateur apparaît hors ligne

### Scénario 3 : Recherche et filtres

1. Aller dans "Tous les membres"
2. Tester la recherche avec différents termes
3. Tester tous les filtres
4. Vérifier que les résultats sont corrects

## 📝 Notes importantes

- Les mots de passe sont stockés en clair dans db.json (OK pour les tests, PAS pour la production)
- Le serveur JSON ne gère pas les WebSockets, donc pas de mise à jour en temps réel automatique
- Pour voir les nouveaux messages, il faut actualiser l'écran
- Les permissions sont vérifiées côté client uniquement (ajouter la vérification serveur pour la production)

## 🆘 Besoin d'aide ?

Consultez la documentation complète : `ROLES_AND_MULTI_USER_SYSTEM.md`

---

**Bon test ! 🚀**
