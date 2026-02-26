# Intégration AuthProvider - Bugfix Design

## Overview

Ce bugfix corrige une faille de sécurité critique où les écrans d'authentification (`login_screen.dart` et `signup_screen.dart`) effectuent une navigation directe sans vérifier les credentials auprès du backend. L'approche consiste à connecter les écrans UI au `AuthProvider` existant en utilisant le pattern Provider de Flutter, permettant ainsi la validation des credentials via `AuthService`, la gestion des états de chargement et d'erreur, et la sauvegarde correcte des sessions utilisateur.

## Glossary

- **Bug_Condition (C)**: La condition qui déclenche le bug - lorsque l'utilisateur soumet un formulaire d'authentification (connexion ou inscription) et que le système navigue directement sans appeler AuthProvider
- **Property (P)**: Le comportement désiré - les formulaires doivent appeler AuthProvider qui vérifie les credentials dans db.json avant toute navigation
- **Preservation**: Les comportements UI existants (navigation entre écrans, validation de formulaire, styles) qui doivent rester inchangés
- **AuthProvider**: Le provider Flutter dans `lib/providers/auth_provider.dart` qui gère l'état d'authentification avec méthodes `login()`, `register()`, propriétés `isLoading`, `error`, `currentUser`
- **AuthService**: Le service dans `lib/services/auth_service.dart` qui communique avec json-server pour valider credentials et gérer sessions
- **Provider.of<AuthProvider>**: La méthode Flutter pour accéder au AuthProvider depuis le widget tree
- **context.read<AuthProvider>()**: Alternative moderne pour accéder au provider sans écouter les changements
- **Consumer<AuthProvider>**: Widget Flutter qui reconstruit automatiquement quand AuthProvider notifie des changements

## Bug Details

### Fault Condition

Le bug se manifeste lorsqu'un utilisateur soumet un formulaire d'authentification (connexion ou inscription). Les fonctions `onPressed` des boutons "Se connecter" et "S'inscrire" appellent directement `Navigator.pushNamed()` après validation du formulaire, sans jamais invoquer `AuthProvider.login()` ou `AuthProvider.register()`. Cela permet à n'importe quel utilisateur de contourner l'authentification réelle.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type FormSubmissionEvent
  OUTPUT: boolean
  
  RETURN (input.formType IN ['login', 'signup'])
         AND input.formIsValid == true
         AND input.buttonPressed == true
         AND NOT authProviderMethodCalled(input.formType)
         AND navigationOccurs(input)
END FUNCTION
```

### Examples

- **Connexion avec credentials invalides**: L'utilisateur entre `email: "fake@test.com"` et `password: "wrong"` (qui n'existent pas dans db.json), clique sur "Se connecter", et le système navigue vers `/home` au lieu de rejeter la connexion
- **Inscription avec email existant**: L'utilisateur entre `email: "user1@example.com"` (qui existe déjà dans db.json), clique sur "S'inscrire", et le système navigue vers `/otp` au lieu d'afficher "Cet email est déjà utilisé"
- **Connexion avec credentials valides**: L'utilisateur entre `email: "user1@example.com"` et `password: "password123"` (qui existent dans db.json), clique sur "Se connecter", et le système navigue vers `/home` MAIS sans sauvegarder la session ni mettre à jour `isOnline` dans db.json
- **Edge case - Champs vides**: L'utilisateur clique sur "Se connecter" avec des champs vides - le système affiche correctement "Ce champ est requis" (comportement préservé, pas un bug)

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- La validation de formulaire avec `_formKey.currentState!.validate()` doit continuer à fonctionner et afficher "Ce champ est requis" pour les champs vides
- La navigation entre écrans (bouton retour, liens "Créer un compte" / "Se connecter") doit continuer à fonctionner exactement comme avant
- Tous les styles UI, couleurs, layouts, et éléments visuels (logo "TR", titres, champs de formulaire) doivent rester identiques
- Les boutons "Mot de passe oublié ?" et "Continuer avec Google" doivent continuer à ne rien faire (comportement actuel)
- Les TextEditingController et leur gestion (dispose) doivent rester inchangés

**Scope:**
Toutes les interactions qui NE sont PAS la soumission du formulaire principal (boutons "Se connecter" et "S'inscrire") doivent être complètement inaffectées par ce fix. Cela inclut:
- Navigation avec bouton retour ou liens texte
- Validation de formulaire pour champs vides
- Affichage et style des éléments UI
- Gestion des controllers et lifecycle des widgets

## Hypothesized Root Cause

Basé sur l'analyse du code, les causes probables sont:

1. **Absence d'intégration Provider**: Les écrans `login_screen.dart` et `signup_screen.dart` n'importent pas `package:provider/provider.dart` et n'utilisent jamais `Provider.of<AuthProvider>` ou `Consumer<AuthProvider>` pour accéder au AuthProvider

2. **Navigation directe dans onPressed**: Les callbacks `onPressed` des boutons contiennent directement `Navigator.pushNamed(context, '/home')` ou `Navigator.pushNamed(context, '/otp')` sans appeler les méthodes async `AuthProvider.login()` ou `AuthProvider.register()`

3. **Pas de gestion d'état async**: Les écrans ne gèrent pas les états `isLoading` et `error` du AuthProvider, donc même si on appelait les méthodes, l'utilisateur ne verrait pas d'indicateur de chargement ni de messages d'erreur

4. **Pas de vérification de succès**: Les écrans ne vérifient pas la valeur de retour `bool` des méthodes `login()` et `register()` pour décider si la navigation doit avoir lieu

## Correctness Properties

Property 1: Fault Condition - Authentication Methods Called Before Navigation

_For any_ form submission where the user clicks "Se connecter" or "S'inscrire" with valid form data, the fixed screens SHALL call the appropriate AuthProvider method (`login()` or `register()`), wait for the async result, and only navigate to the next screen if the method returns `true`, otherwise display the error message from `AuthProvider.error`.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6**

Property 2: Preservation - UI and Navigation Behavior

_For any_ user interaction that is NOT the main form submission (back button, navigation links, empty field validation, UI display), the fixed screens SHALL produce exactly the same behavior as the original screens, preserving all existing navigation, validation, and visual presentation.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8**

## Fix Implementation

### Changes Required

En supposant que notre analyse de cause racine est correcte:

**File**: `lib/screens/login_screen.dart`

**Function**: `_LoginScreenState` class

**Specific Changes**:
1. **Import Provider**: Ajouter `import 'package:provider/provider.dart';` et `import '../providers/auth_provider.dart';` en haut du fichier

2. **Wrap with Consumer**: Envelopper le contenu du `build()` avec `Consumer<AuthProvider>` pour écouter les changements d'état et accéder à `authProvider.isLoading` et `authProvider.error`

3. **Modifier onPressed du bouton "Se connecter"**: 
   - Remplacer la navigation directe par un appel async à `authProvider.login()`
   - Attendre le résultat avec `await`
   - Naviguer vers `/home` seulement si le résultat est `true`
   - Afficher un SnackBar avec `authProvider.error` si le résultat est `false`

4. **Ajouter indicateur de chargement**: Désactiver le bouton et afficher un CircularProgressIndicator quand `authProvider.isLoading` est `true`

5. **Afficher les erreurs**: Ajouter un widget Text au-dessus du bouton pour afficher `authProvider.error` en rouge si présent

**File**: `lib/screens/signup_screen.dart`

**Function**: `_SignupScreenState` class

**Specific Changes**:
1. **Import Provider**: Ajouter `import 'package:provider/provider.dart';` et `import '../providers/auth_provider.dart';` en haut du fichier

2. **Wrap with Consumer**: Envelopper le contenu du `build()` avec `Consumer<AuthProvider>` pour écouter les changements d'état

3. **Modifier onPressed du bouton "S'inscrire"**: 
   - Remplacer la navigation directe par un appel async à `authProvider.register()`
   - Passer les paramètres: `email`, `password`, `name` (depuis _usernameController), et optionnellement `username`
   - Attendre le résultat avec `await`
   - Naviguer vers `/otp` seulement si le résultat est `true`
   - Afficher un SnackBar avec `authProvider.error` si le résultat est `false`

4. **Ajouter indicateur de chargement**: Désactiver le bouton et afficher un CircularProgressIndicator quand `authProvider.isLoading` est `true`

5. **Afficher les erreurs**: Ajouter un widget Text au-dessus du bouton pour afficher `authProvider.error` en rouge si présent

## Testing Strategy

### Validation Approach

La stratégie de test suit une approche en deux phases: d'abord, exposer des contre-exemples qui démontrent le bug sur le code non corrigé, puis vérifier que le fix fonctionne correctement et préserve le comportement existant.

### Exploratory Fault Condition Checking

**Goal**: Exposer des contre-exemples qui démontrent le bug AVANT d'implémenter le fix. Confirmer ou réfuter l'analyse de cause racine. Si on réfute, on devra ré-hypothétiser.

**Test Plan**: Écrire des tests d'intégration qui simulent la soumission de formulaires avec différents credentials et vérifient si AuthProvider est appelé et si la navigation est conditionnelle. Exécuter ces tests sur le code NON CORRIGÉ pour observer les échecs et comprendre la cause racine.

**Test Cases**:
1. **Test connexion credentials invalides**: Simuler la saisie de `email: "fake@test.com"`, `password: "wrong"`, cliquer sur "Se connecter" (échouera sur code non corrigé - navigation vers /home sans vérification)
2. **Test inscription email existant**: Simuler la saisie de `email: "user1@example.com"` (existe dans db.json), cliquer sur "S'inscrire" (échouera sur code non corrigé - navigation vers /otp sans vérification)
3. **Test connexion credentials valides**: Simuler la saisie de `email: "user1@example.com"`, `password: "password123"`, cliquer sur "Se connecter" (échouera sur code non corrigé - navigation sans sauvegarder session)
4. **Test vérification AuthProvider non appelé**: Utiliser un mock de AuthProvider et vérifier que `login()` ou `register()` n'est jamais appelé (échouera sur code non corrigé)

**Expected Counterexamples**:
- La navigation vers `/home` ou `/otp` se produit immédiatement sans appeler AuthProvider
- Causes possibles: pas d'import Provider, pas d'appel aux méthodes async, navigation directe dans onPressed

### Fix Checking

**Goal**: Vérifier que pour toutes les entrées où la condition de bug est vraie, la fonction corrigée produit le comportement attendu.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition(input) DO
  result := handleFormSubmission_fixed(input)
  ASSERT authProviderMethodCalled(input.formType)
  ASSERT IF authProviderReturnsTrue THEN navigationOccurs
  ASSERT IF authProviderReturnsFalse THEN errorDisplayed AND NOT navigationOccurs
END FOR
```

### Preservation Checking

**Goal**: Vérifier que pour toutes les entrées où la condition de bug N'est PAS vraie, la fonction corrigée produit le même résultat que la fonction originale.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  ASSERT handleInteraction_original(input) = handleInteraction_fixed(input)
END FOR
```

**Testing Approach**: Les tests basés sur les propriétés (Property-Based Testing) sont recommandés pour la vérification de préservation car:
- Ils génèrent automatiquement de nombreux cas de test à travers le domaine d'entrée
- Ils détectent les cas limites que les tests unitaires manuels pourraient manquer
- Ils fournissent de fortes garanties que le comportement est inchangé pour toutes les entrées non bugguées

**Test Plan**: Observer le comportement sur le code NON CORRIGÉ d'abord pour les interactions non-authentification, puis écrire des tests basés sur les propriétés capturant ce comportement.

**Test Cases**:
1. **Préservation navigation liens**: Observer que cliquer sur "Créer un compte" navigue vers `/signup` sur code non corrigé, puis écrire test pour vérifier que cela continue après fix
2. **Préservation validation formulaire**: Observer que soumettre avec champs vides affiche "Ce champ est requis" sur code non corrigé, puis écrire test pour vérifier que cela continue après fix
3. **Préservation bouton retour**: Observer que cliquer sur le bouton retour appelle `Navigator.pop()` sur code non corrigé, puis écrire test pour vérifier que cela continue après fix
4. **Préservation styles UI**: Observer que tous les éléments UI s'affichent avec les bonnes couleurs et styles sur code non corrigé, puis écrire test pour vérifier que cela continue après fix

### Unit Tests

- Tester que `AuthProvider.login()` est appelé avec les bons paramètres quand le formulaire de connexion est soumis
- Tester que `AuthProvider.register()` est appelé avec les bons paramètres quand le formulaire d'inscription est soumis
- Tester que la navigation vers `/home` se produit seulement si `login()` retourne `true`
- Tester que la navigation vers `/otp` se produit seulement si `register()` retourne `true`
- Tester que les messages d'erreur sont affichés quand `AuthProvider.error` est non-null
- Tester que l'indicateur de chargement est affiché quand `AuthProvider.isLoading` est `true`
- Tester que le bouton est désactivé pendant le chargement
- Tester que la validation de formulaire continue à fonctionner pour les champs vides

### Property-Based Tests

- Générer des credentials aléatoires (valides et invalides) et vérifier que le système appelle toujours AuthProvider avant de naviguer
- Générer des états aléatoires de AuthProvider (isLoading, error) et vérifier que l'UI réagit correctement
- Tester que toutes les interactions non-authentification (navigation, validation) continuent à fonctionner à travers de nombreux scénarios

### Integration Tests

- Tester le flux complet de connexion avec credentials valides: saisie → soumission → appel AuthProvider → navigation vers /home
- Tester le flux complet d'inscription avec nouvelles données: saisie → soumission → appel AuthProvider → navigation vers /otp
- Tester le flux d'erreur: saisie credentials invalides → soumission → appel AuthProvider → affichage erreur → reste sur écran
- Tester que la session est sauvegardée après connexion/inscription réussie (vérifier SharedPreferences)
- Tester que le statut `isOnline` est mis à jour dans db.json après connexion/inscription réussie
