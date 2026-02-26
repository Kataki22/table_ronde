# Plan d'Implémentation - Intégration AuthProvider

- [x] 1. Écrire le test d'exploration de la condition de bug
  - **Property 1: Fault Condition** - Méthodes d'authentification non appelées avant navigation
  - **CRITIQUE**: Ce test DOIT ÉCHOUER sur le code non corrigé - l'échec confirme que le bug existe
  - **NE PAS tenter de corriger le test ou le code quand il échoue**
  - **NOTE**: Ce test encode le comportement attendu - il validera le fix quand il passera après l'implémentation
  - **OBJECTIF**: Exposer des contre-exemples qui démontrent l'existence du bug
  - **Approche PBT ciblée**: Pour ce bug déterministe, cibler les cas concrets d'échec pour assurer la reproductibilité
  - Tester que lors de la soumission du formulaire de connexion avec credentials invalides (ex: "fake@test.com", "wrong"), le système appelle `AuthProvider.login()` et n'effectue PAS la navigation vers `/home` si la méthode retourne `false`
  - Tester que lors de la soumission du formulaire d'inscription avec email existant (ex: "user1@example.com"), le système appelle `AuthProvider.register()` et n'effectue PAS la navigation vers `/otp` si la méthode retourne `false`
  - Tester que lors de la soumission avec credentials valides, le système appelle la méthode AuthProvider appropriée et navigue seulement si elle retourne `true`
  - Les assertions du test doivent correspondre aux Expected Behavior Properties du design
  - Exécuter le test sur le code NON CORRIGÉ
  - **RÉSULTAT ATTENDU**: Le test ÉCHOUE (c'est correct - cela prouve que le bug existe)
  - Documenter les contre-exemples trouvés pour comprendre la cause racine
  - Marquer la tâche comme complète quand le test est écrit, exécuté, et l'échec documenté
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

- [x] 2. Écrire les tests de propriété de préservation (AVANT d'implémenter le fix)
  - **Property 2: Preservation** - Comportement UI et navigation préservés
  - **IMPORTANT**: Suivre la méthodologie observation-first
  - Observer le comportement sur le code NON CORRIGÉ pour les entrées non-bugguées
  - Écrire des tests basés sur les propriétés capturant les patterns de comportement observés des Preservation Requirements
  - Les tests basés sur les propriétés génèrent de nombreux cas de test pour des garanties plus fortes
  - Observer: Cliquer sur "Créer un compte" depuis l'écran de connexion navigue vers `/signup`
  - Observer: Cliquer sur "Se connecter" depuis l'écran d'inscription navigue vers l'écran de connexion
  - Observer: Soumettre avec des champs vides affiche "Ce champ est requis"
  - Observer: Cliquer sur le bouton retour appelle `Navigator.pop(context)`
  - Observer: Les boutons "Mot de passe oublié ?" et "Continuer avec Google" ne font rien
  - Observer: Tous les éléments UI (logo "TR", titres, styles) s'affichent correctement
  - Écrire des tests basés sur les propriétés pour toutes les interactions qui NE sont PAS la soumission du formulaire principal
  - Exécuter les tests sur le code NON CORRIGÉ
  - **RÉSULTAT ATTENDU**: Les tests PASSENT (cela confirme le comportement de base à préserver)
  - Marquer la tâche comme complète quand les tests sont écrits, exécutés, et passent sur le code non corrigé
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8_

- [x] 3. Fix pour l'intégration AuthProvider dans les écrans d'authentification

  - [x] 3.1 Intégrer AuthProvider dans login_screen.dart
    - Ajouter les imports: `import 'package:provider/provider.dart';` et `import '../providers/auth_provider.dart';`
    - Envelopper le contenu du `build()` avec `Consumer<AuthProvider>` pour écouter les changements d'état
    - Modifier le callback `onPressed` du bouton "Se connecter":
      - Remplacer la navigation directe par un appel async à `authProvider.login(_emailController.text, _passwordController.text)`
      - Attendre le résultat avec `await`
      - Naviguer vers `/home` seulement si le résultat est `true`
      - Afficher un SnackBar avec `authProvider.error` si le résultat est `false`
    - Ajouter un indicateur de chargement: désactiver le bouton et afficher un CircularProgressIndicator quand `authProvider.isLoading` est `true`
    - Ajouter un widget Text au-dessus du bouton pour afficher `authProvider.error` en rouge si présent
    - _Bug_Condition: isBugCondition(input) où input.formType = 'login' AND input.formIsValid = true AND input.buttonPressed = true AND NOT authProviderMethodCalled('login') AND navigationOccurs(input)_
    - _Expected_Behavior: Pour toute soumission de formulaire de connexion avec données valides, appeler AuthProvider.login(), attendre le résultat async, et naviguer vers /home seulement si retourne true, sinon afficher authProvider.error_
    - _Preservation: Préserver la validation de formulaire, navigation avec bouton retour et liens, styles UI, boutons "Mot de passe oublié ?" et "Continuer avec Google", gestion des TextEditingController_
    - _Requirements: 2.1, 2.3, 2.5, 2.6, 3.1, 3.2, 3.3, 3.5, 3.6, 3.7, 3.8_

  - [x] 3.2 Intégrer AuthProvider dans signup_screen.dart
    - Ajouter les imports: `import 'package:provider/provider.dart';` et `import '../providers/auth_provider.dart';`
    - Envelopper le contenu du `build()` avec `Consumer<AuthProvider>` pour écouter les changements d'état
    - Modifier le callback `onPressed` du bouton "S'inscrire":
      - Remplacer la navigation directe par un appel async à `authProvider.register(email: _emailController.text, password: _passwordController.text, name: _usernameController.text)`
      - Attendre le résultat avec `await`
      - Naviguer vers `/otp` seulement si le résultat est `true`
      - Afficher un SnackBar avec `authProvider.error` si le résultat est `false`
    - Ajouter un indicateur de chargement: désactiver le bouton et afficher un CircularProgressIndicator quand `authProvider.isLoading` est `true`
    - Ajouter un widget Text au-dessus du bouton pour afficher `authProvider.error` en rouge si présent
    - _Bug_Condition: isBugCondition(input) où input.formType = 'signup' AND input.formIsValid = true AND input.buttonPressed = true AND NOT authProviderMethodCalled('signup') AND navigationOccurs(input)_
    - _Expected_Behavior: Pour toute soumission de formulaire d'inscription avec données valides, appeler AuthProvider.register(), attendre le résultat async, et naviguer vers /otp seulement si retourne true, sinon afficher authProvider.error_
    - _Preservation: Préserver la validation de formulaire, navigation avec bouton retour et lien "Se connecter", styles UI, bouton "Continuer avec Google", gestion des TextEditingController_
    - _Requirements: 2.2, 2.4, 2.5, 2.6, 3.1, 3.2, 3.4, 3.5, 3.6, 3.7, 3.8_

  - [x] 3.3 Vérifier que le test d'exploration de la condition de bug passe maintenant
    - **Property 1: Expected Behavior** - Méthodes d'authentification appelées avant navigation
    - **IMPORTANT**: Ré-exécuter le MÊME test de la tâche 1 - NE PAS écrire un nouveau test
    - Le test de la tâche 1 encode le comportement attendu
    - Quand ce test passe, il confirme que le comportement attendu est satisfait
    - Exécuter le test d'exploration de la condition de bug de l'étape 1
    - **RÉSULTAT ATTENDU**: Le test PASSE (confirme que le bug est corrigé)
    - _Requirements: Expected Behavior Properties du design (2.1, 2.2, 2.3, 2.4, 2.5, 2.6)_

  - [x] 3.4 Vérifier que les tests de préservation passent toujours
    - **Property 2: Preservation** - Comportement UI et navigation préservés
    - **IMPORTANT**: Ré-exécuter les MÊMES tests de la tâche 2 - NE PAS écrire de nouveaux tests
    - Exécuter les tests de propriété de préservation de l'étape 2
    - **RÉSULTAT ATTENDU**: Les tests PASSENT (confirme qu'il n'y a pas de régressions)
    - Confirmer que tous les tests passent toujours après le fix (pas de régressions)

- [x] 4. Checkpoint - S'assurer que tous les tests passent
  - S'assurer que tous les tests passent, poser des questions à l'utilisateur si nécessaire
