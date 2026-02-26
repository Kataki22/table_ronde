# 🧪 Scénarios de Test Complets

## 📋 Vue d'ensemble

Ce document contient tous les scénarios de test pour valider le système de rôles et la messagerie multi-utilisateurs.

## 🎯 Prérequis

- Serveur JSON démarré : `json-server --watch db.json --port 3000 --host 0.0.0.0`
- Au moins 2 appareils/émulateurs disponibles
- Application compilée sans erreur

## 📱 Scénarios de test

### Scénario 1 : Connexion et profil (5 minutes)

#### Objectif
Vérifier que chaque utilisateur voit son propre profil avec le bon rôle.

#### Étapes

**Appareil 1 :**
1. Lancer l'application
2. Se connecter avec :
   - Email : `alistair@tableronde.com`
   - Mot de passe : `alistair123`
3. Aller sur l'onglet "Profil" (icône en bas à droite)
4. ✅ Vérifier : Nom = "AlistairJr"
5. ✅ Vérifier : Badge = 👑 Administrateur
6. ✅ Vérifier : Bouton de déconnexion visible

**Appareil 2 :**
1. Lancer l'application
2. Se connecter avec :
   - Email : `t4zor@tableronde.com`
   - Mot de passe : `t4zor123`
3. Aller sur l'onglet "Profil"
4. ✅ Vérifier : Nom = "T4zor"
5. ✅ Vérifier : Badge = 🛡️ Modérateur
6. ✅ Vérifier : Bouton de déconnexion visible

**Résultat attendu :**
- Chaque appareil affiche le profil de l'utilisateur connecté
- Les badges de rôle sont corrects
- Les informations sont différentes sur chaque appareil

---

### Scénario 2 : Messagerie de base (10 minutes)

#### Objectif
Vérifier que les messages sont correctement envoyés et reçus entre deux utilisateurs.

#### Étapes

**Appareil 1 (AlistairJr) :**
1. Aller dans l'onglet "Chats"
2. Cliquer sur l'icône 👥 "Tous les membres" en haut à droite
3. Dans la liste, cliquer sur "T4zor"
4. ✅ Vérifier : Écran de chat ouvert avec "T4zor" en titre
5. Taper le message : "Salut T4zor, comment ça va ?"
6. Envoyer le message
7. ✅ Vérifier : Le message apparaît à DROITE (bulle bleue)
8. ✅ Vérifier : Le message affiche l'heure d'envoi

**Appareil 2 (T4zor) :**
1. Aller dans l'onglet "Chats"
2. ✅ Vérifier : Une conversation avec "AlistairJr" apparaît
3. ✅ Vérifier : Badge de messages non lus visible
4. Ouvrir la conversation avec "AlistairJr"
5. ✅ Vérifier : Le message "Salut T4zor, comment ça va ?" apparaît à GAUCHE (bulle grise)
6. ✅ Vérifier : Le nom "AlistairJr" s'affiche au-dessus du message
7. Taper la réponse : "Salut AlistairJr, ça va bien merci !"
8. Envoyer le message
9. ✅ Vérifier : Le message apparaît à DROITE (bulle bleue)

**Appareil 1 (AlistairJr) :**
1. Actualiser l'écran (tirer vers le bas) ou attendre quelques secondes
2. ✅ Vérifier : La réponse de T4zor apparaît à GAUCHE (bulle grise)
3. ✅ Vérifier : Le nom "T4zor" s'affiche au-dessus du message

**Résultat attendu :**
- Les messages envoyés apparaissent à droite
- Les messages reçus apparaissent à gauche
- Les noms des expéditeurs sont corrects
- Les conversations sont synchronisées via le serveur

---

### Scénario 3 : Isolation des conversations (15 minutes)

#### Objectif
Vérifier que les conversations sont isolées et que chaque utilisateur ne voit que ses propres conversations.

#### Étapes

**Appareil 1 (AlistairJr) :**
1. Aller dans "Chats" → 👥 "Tous les membres"
2. Démarrer une conversation avec "Tk-Porky"
3. Envoyer : "Salut Tk-Porky, projet en cours ?"
4. ✅ Vérifier : Message à droite
5. Retourner à la liste des chats
6. ✅ Vérifier : Deux conversations visibles (T4zor et Tk-Porky)

**Appareil 2 (T4zor) :**
1. Aller dans "Chats"
2. ✅ Vérifier : Une seule conversation visible (AlistairJr)
3. ✅ Vérifier : PAS de conversation avec Tk-Porky
4. Ouvrir la conversation avec AlistairJr
5. ✅ Vérifier : Uniquement les messages entre AlistairJr et T4zor
6. ✅ Vérifier : PAS de message "projet en cours"

**Appareil 3 (Tk-Porky) - Optionnel :**
1. Se connecter avec `tkporky@tableronde.com` / `tkporky123`
2. Aller dans "Chats"
3. ✅ Vérifier : Une conversation avec AlistairJr
4. ✅ Vérifier : Le message "projet en cours" est visible
5. ✅ Vérifier : PAS de messages entre AlistairJr et T4zor

**Résultat attendu :**
- Chaque conversation est isolée
- Les utilisateurs ne voient que leurs propres conversations
- Les messages ne "fuient" pas entre les conversations

---

### Scénario 4 : Recherche et filtres (10 minutes)

#### Objectif
Vérifier que la recherche et les filtres fonctionnent correctement.

#### Étapes

**Appareil 1 (n'importe quel utilisateur) :**
1. Aller dans "Chats" → 👥 "Tous les membres"
2. ✅ Vérifier : Liste de tous les utilisateurs (sauf soi-même)

**Test de recherche :**
3. Dans la barre de recherche, taper "alistair"
4. ✅ Vérifier : Seul "AlistairJr" apparaît
5. Effacer la recherche
6. Taper "@t4zor"
7. ✅ Vérifier : Seul "T4zor" apparaît

**Test des filtres :**
8. Cliquer sur le filtre "En ligne"
9. ✅ Vérifier : Seuls les utilisateurs en ligne apparaissent
10. Cliquer sur le filtre "👑 Admins"
11. ✅ Vérifier : Seul "AlistairJr" apparaît
12. Cliquer sur le filtre "🛡️ Modérateurs"
13. ✅ Vérifier : "T4zor" et "Sophie Martin" apparaissent
14. Cliquer sur le filtre "👤 Membres"
15. ✅ Vérifier : "Tk-Porky", "Lucas Dubois", etc. apparaissent

**Résultat attendu :**
- La recherche fonctionne par nom et username
- Les filtres affichent les bons utilisateurs
- Les badges de rôle sont visibles

---

### Scénario 5 : Déconnexion et changement de compte (5 minutes)

#### Objectif
Vérifier que la déconnexion fonctionne et qu'on peut changer de compte.

#### Étapes

**Appareil 1 :**
1. Être connecté avec n'importe quel compte
2. Aller sur le profil
3. Cliquer sur le bouton de déconnexion (icône logout)
4. ✅ Vérifier : Dialogue de confirmation s'affiche
5. Confirmer la déconnexion
6. ✅ Vérifier : Redirection vers l'écran de connexion
7. Se connecter avec un autre compte
8. ✅ Vérifier : Le nouveau profil s'affiche
9. ✅ Vérifier : Les conversations sont différentes

**Résultat attendu :**
- La déconnexion fonctionne
- Le changement de compte est fluide
- Les données sont bien isolées par utilisateur

---

### Scénario 6 : Persistance de session (5 minutes)

#### Objectif
Vérifier que la session persiste après fermeture de l'application.

#### Étapes

**Appareil 1 :**
1. Se connecter avec un compte
2. Fermer complètement l'application (kill)
3. Relancer l'application
4. ✅ Vérifier : L'utilisateur est toujours connecté
5. ✅ Vérifier : Redirection automatique vers l'écran d'accueil
6. ✅ Vérifier : Le profil est correct

**Résultat attendu :**
- La session persiste après fermeture
- Pas besoin de se reconnecter
- Les données sont conservées

---

### Scénario 7 : Statut en ligne (10 minutes)

#### Objectif
Vérifier que le statut en ligne se met à jour correctement.

#### Étapes

**Appareil 1 (AlistairJr) :**
1. Se connecter
2. ✅ Vérifier : Statut = En ligne dans db.json

**Appareil 2 (T4zor) :**
1. Aller dans "Chats" → 👥 "Tous les membres"
2. ✅ Vérifier : Point vert à côté de "AlistairJr"
3. Cliquer sur le filtre "En ligne"
4. ✅ Vérifier : "AlistairJr" apparaît dans la liste

**Appareil 1 (AlistairJr) :**
1. Se déconnecter
2. ✅ Vérifier : Statut = Hors ligne dans db.json

**Appareil 2 (T4zor) :**
1. Actualiser la liste (tirer vers le bas)
2. ✅ Vérifier : Plus de point vert à côté de "AlistairJr"
3. Cliquer sur le filtre "En ligne"
4. ✅ Vérifier : "AlistairJr" n'apparaît plus

**Résultat attendu :**
- Le statut en ligne se met à jour à la connexion
- Le statut hors ligne se met à jour à la déconnexion
- Les autres utilisateurs voient le changement de statut

---

### Scénario 8 : Permissions par rôle (15 minutes)

#### Objectif
Vérifier que les permissions sont correctement appliquées selon le rôle.

#### Étapes

**Test Admin (AlistairJr) :**
1. Se connecter avec `alistair@tableronde.com`
2. ✅ Vérifier : Badge 👑 Administrateur
3. ✅ Vérifier : Toutes les options disponibles
4. Dans le code, vérifier :
   ```dart
   currentUser.isAdmin // true
   currentUser.hasPermission('delete_groups') // true
   currentUser.hasPermission('manage_roles') // true
   ```

**Test Modérateur (T4zor) :**
1. Se connecter avec `t4zor@tableronde.com`
2. ✅ Vérifier : Badge 🛡️ Modérateur
3. ✅ Vérifier : Options de modération disponibles
4. Dans le code, vérifier :
   ```dart
   currentUser.isModerator // true
   currentUser.hasPermission('delete_others_messages') // true
   currentUser.hasPermission('manage_roles') // false
   ```

**Test Membre (Lucas) :**
1. Se connecter avec `lucas@tableronde.com`
2. ✅ Vérifier : Badge 👤 Membre
3. ✅ Vérifier : Options limitées
4. Dans le code, vérifier :
   ```dart
   currentUser.isAdmin // false
   currentUser.isModerator // false
   currentUser.hasPermission('delete_others_messages') // false
   ```

**Résultat attendu :**
- Les permissions sont correctes pour chaque rôle
- Les badges s'affichent correctement
- Les options sont filtrées selon le rôle

---

### Scénario 9 : Messages multiples (10 minutes)

#### Objectif
Vérifier que plusieurs messages s'affichent correctement dans l'ordre.

#### Étapes

**Appareil 1 (AlistairJr) :**
1. Ouvrir une conversation avec T4zor
2. Envoyer 5 messages successifs :
   - "Message 1"
   - "Message 2"
   - "Message 3"
   - "Message 4"
   - "Message 5"
3. ✅ Vérifier : Tous les messages apparaissent à droite
4. ✅ Vérifier : Les messages sont dans l'ordre chronologique

**Appareil 2 (T4zor) :**
1. Ouvrir la conversation avec AlistairJr
2. ✅ Vérifier : Les 5 messages apparaissent à gauche
3. ✅ Vérifier : Les messages sont dans l'ordre
4. Envoyer 3 réponses :
   - "Réponse 1"
   - "Réponse 2"
   - "Réponse 3"
5. ✅ Vérifier : Les réponses apparaissent à droite

**Appareil 1 (AlistairJr) :**
1. Actualiser
2. ✅ Vérifier : Les 3 réponses apparaissent à gauche
3. ✅ Vérifier : L'ordre est correct (messages alternés)

**Résultat attendu :**
- Tous les messages s'affichent
- L'ordre chronologique est respecté
- Les messages alternent correctement (gauche/droite)

---

### Scénario 10 : Vérification de la base de données (5 minutes)

#### Objectif
Vérifier que les données sont correctement stockées dans db.json.

#### Étapes

**Terminal :**
```bash
# Vérifier les utilisateurs
curl http://localhost:3000/users | jq

# Vérifier les utilisateurs en ligne
curl "http://localhost:3000/users?isOnline=true" | jq

# Vérifier tous les messages
curl http://localhost:3000/messages | jq

# Vérifier les messages d'une conversation
curl "http://localhost:3000/messages?chatId=chat_user_1_user_2" | jq
```

**Vérifications :**
1. ✅ Les utilisateurs ont le champ `role`
2. ✅ Les utilisateurs connectés ont `isOnline: true`
3. ✅ Les messages ont un `chatId` correct
4. ✅ Les messages ont un `senderId` correct
5. ✅ Les messages sont filtrés par `chatId`

**Résultat attendu :**
- Les données sont correctement structurées
- Les champs requis sont présents
- Les relations sont correctes

---

## 📊 Tableau récapitulatif

| Scénario | Durée | Priorité | Statut |
|----------|-------|----------|--------|
| 1. Connexion et profil | 5 min | Haute | ⬜ À tester |
| 2. Messagerie de base | 10 min | Haute | ⬜ À tester |
| 3. Isolation des conversations | 15 min | Haute | ⬜ À tester |
| 4. Recherche et filtres | 10 min | Moyenne | ⬜ À tester |
| 5. Déconnexion | 5 min | Haute | ⬜ À tester |
| 6. Persistance de session | 5 min | Moyenne | ⬜ À tester |
| 7. Statut en ligne | 10 min | Moyenne | ⬜ À tester |
| 8. Permissions par rôle | 15 min | Basse | ⬜ À tester |
| 9. Messages multiples | 10 min | Moyenne | ⬜ À tester |
| 10. Vérification BDD | 5 min | Basse | ⬜ À tester |

**Durée totale estimée** : 90 minutes

## 🐛 Problèmes connus et solutions

### Problème : Les messages ne s'actualisent pas automatiquement

**Solution temporaire :**
- Tirer vers le bas pour actualiser
- Fermer et rouvrir la conversation

**Solution permanente (à implémenter) :**
- Ajouter un polling automatique toutes les 5 secondes
- Implémenter WebSocket pour le temps réel

### Problème : Le serveur JSON ne démarre pas

**Solution :**
```bash
# Vérifier le port
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Tuer le processus si nécessaire
kill -9 [PID]  # macOS/Linux

# Utiliser un autre port
json-server --watch db.json --port 3001 --host 0.0.0.0
```

### Problème : L'application ne se connecte pas au serveur

**Solution :**
1. Vérifier que le serveur est démarré
2. Vérifier l'URL dans `api_service.dart` et `auth_service.dart`
3. Pour appareil physique, utiliser l'IP locale
4. Désactiver le pare-feu temporairement

## ✅ Checklist de validation finale

Après avoir exécuté tous les scénarios :

- [ ] Tous les scénarios passent
- [ ] Aucune erreur dans les logs
- [ ] Les données sont correctes dans db.json
- [ ] Les performances sont acceptables
- [ ] L'interface est réactive
- [ ] Les messages d'erreur sont clairs
- [ ] La documentation est à jour

## 📝 Rapport de test

Après les tests, remplir ce rapport :

**Date** : _______________
**Testeur** : _______________
**Version** : 1.0.0

**Résultats :**
- Scénarios réussis : ___ / 10
- Bugs trouvés : ___
- Bugs critiques : ___

**Commentaires :**
_______________________________________
_______________________________________
_______________________________________

---

**Bon test ! 🚀**
