# Bugfix Requirements Document

## Introduction

Les écrans d'authentification (`login_screen.dart` et `signup_screen.dart`) ne sont pas connectés au `AuthProvider` et effectuent une navigation directe sans vérifier les credentials auprès du backend (db.json via json-server). Cela permet à n'importe quel utilisateur de se connecter sans authentification réelle, créant une faille de sécurité majeure et empêchant l'utilisation des données utilisateur réelles stockées dans db.json.

Le `AuthService` et le `AuthProvider` sont déjà implémentés et fonctionnels, mais les écrans UI ne les utilisent pas. Ce bug affecte la sécurité de l'application et empêche la gestion correcte des sessions utilisateur.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN l'utilisateur remplit le formulaire de connexion avec n'importe quel email et mot de passe THEN le système navigue directement vers `/home` sans vérifier les credentials dans db.json

1.2 WHEN l'utilisateur remplit le formulaire d'inscription avec n'importe quelles données THEN le système navigue directement vers `/otp` sans créer l'utilisateur dans db.json

1.3 WHEN l'utilisateur clique sur "Se connecter" avec des credentials invalides THEN le système accepte la connexion et navigue vers `/home` au lieu d'afficher une erreur

1.4 WHEN l'utilisateur s'inscrit avec un email déjà existant THEN le système accepte l'inscription au lieu de rejeter avec un message d'erreur

1.5 WHEN l'utilisateur se connecte ou s'inscrit THEN le système ne sauvegarde pas la session utilisateur et ne met pas à jour le statut `isOnline` dans db.json

### Expected Behavior (Correct)

2.1 WHEN l'utilisateur remplit le formulaire de connexion avec email et mot de passe THEN le système SHALL appeler `AuthProvider.login()` qui vérifie les credentials dans db.json avant de naviguer vers `/home`

2.2 WHEN l'utilisateur remplit le formulaire d'inscription avec ses données THEN le système SHALL appeler `AuthProvider.register()` qui crée l'utilisateur dans db.json avant de naviguer vers `/otp`

2.3 WHEN l'utilisateur clique sur "Se connecter" avec des credentials invalides THEN le système SHALL afficher un message d'erreur provenant de `AuthProvider.error` et rester sur l'écran de connexion

2.4 WHEN l'utilisateur s'inscrit avec un email déjà existant THEN le système SHALL afficher un message d'erreur "Cet email est déjà utilisé" et rester sur l'écran d'inscription

2.5 WHEN l'utilisateur se connecte ou s'inscrit avec succès THEN le système SHALL sauvegarder la session utilisateur via SharedPreferences et mettre à jour le statut `isOnline` à `true` dans db.json

2.6 WHEN l'utilisateur est en cours d'authentification THEN le système SHALL afficher un indicateur de chargement et désactiver le bouton de soumission

### Unchanged Behavior (Regression Prevention)

3.1 WHEN l'utilisateur clique sur "Mot de passe oublié ?" THEN le système SHALL CONTINUE TO exécuter le comportement actuel (vide pour l'instant)

3.2 WHEN l'utilisateur clique sur "Continuer avec Google" THEN le système SHALL CONTINUE TO exécuter le comportement actuel (vide pour l'instant)

3.3 WHEN l'utilisateur clique sur "Créer un compte" depuis l'écran de connexion THEN le système SHALL CONTINUE TO naviguer vers `/signup`

3.4 WHEN l'utilisateur clique sur "Se connecter" depuis l'écran d'inscription THEN le système SHALL CONTINUE TO naviguer vers l'écran de connexion

3.5 WHEN l'utilisateur clique sur le bouton retour THEN le système SHALL CONTINUE TO exécuter `Navigator.pop(context)`

3.6 WHEN l'utilisateur soumet un formulaire avec des champs vides THEN le système SHALL CONTINUE TO afficher le message de validation "Ce champ est requis"

3.7 WHEN l'utilisateur tape dans les champs de formulaire THEN le système SHALL CONTINUE TO afficher le texte avec le style et les couleurs actuels

3.8 WHEN l'écran est affiché THEN le système SHALL CONTINUE TO afficher le logo "TR", les titres, et tous les éléments UI existants avec leur style actuel
