import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tableronde_app/providers/auth_provider.dart';
import 'package:tableronde_app/providers/theme_provider.dart';
import 'package:tableronde_app/screens/login_screen.dart';
import 'package:tableronde_app/screens/signup_screen.dart';

/// Tests de préservation pour l'intégration AuthProvider
/// 
/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8**
/// 
/// **Property 2: Preservation** - Comportement UI et navigation préservés
/// 
/// Ces tests vérifient que tous les comportements qui NE sont PAS la soumission
/// du formulaire principal restent inchangés après le fix.
/// 
/// **IMPORTANT**: Ces tests DOIVENT PASSER sur le code NON CORRIGÉ
void main() {
  group('Auth Preservation - UI and Navigation Behavior', () {
    late MockNavigatorObserver navigatorObserver;
    late ThemeProvider themeProvider;
    late MockAuthProvider mockAuthProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      navigatorObserver = MockNavigatorObserver();
      themeProvider = ThemeProvider();
      mockAuthProvider = MockAuthProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    group('Login Screen Preservation', () {
      testWidgets(
        'Clicking "Créer un compte" link navigates to /signup',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: MaterialApp(
                home: const LoginScreen(),
                navigatorObservers: [navigatorObserver],
                routes: {
                  '/signup': (context) => const Scaffold(body: Text('Signup Screen')),
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Scroll to make the link visible
          await tester.dragUntilVisible(
            find.text('Créer un compte'),
            find.byType(SingleChildScrollView),
            const Offset(0, -50),
          );
          await tester.pumpAndSettle();

          // Find and tap the "Créer un compte" link
          final createAccountLink = find.text('Créer un compte');
          expect(createAccountLink, findsOneWidget);
          
          await tester.tap(createAccountLink);
          await tester.pumpAndSettle();

          // The initial route '/' is pushed, then '/signup' replaces it
          expect(
            find.text('Signup Screen'),
            findsOneWidget,
            reason: 'Should navigate to /signup when "Créer un compte" is clicked',
          );
        },
      );

      testWidgets(
        'Clicking back button calls Navigator.pop()',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: MaterialApp(
                home: const LoginScreen(),
                navigatorObservers: [navigatorObserver],
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Find and tap the back button
          final backButton = find.byIcon(Icons.arrow_back);
          expect(backButton, findsOneWidget);
          
          await tester.tap(backButton);
          await tester.pumpAndSettle();

          expect(
            navigatorObserver.poppedRoutes,
            isNotEmpty,
            reason: 'Navigator.pop() should be called when back button is clicked',
          );
        },
      );

      testWidgets(
        'Submitting with empty fields displays "Ce champ est requis"',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: MaterialApp(
                home: const LoginScreen(),
                navigatorObservers: [navigatorObserver],
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Scroll to make the button visible
          await tester.dragUntilVisible(
            find.text('Se connecter'),
            find.byType(SingleChildScrollView),
            const Offset(0, -50),
          );
          await tester.pumpAndSettle();

          // Tap the login button without entering any text
          await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
          await tester.pumpAndSettle();

          // Verify validation message appears
          expect(
            find.text('Ce champ est requis'),
            findsWidgets,
            reason: 'Validation message should appear for empty fields',
          );

          // Verify no navigation occurred (only initial route)
          expect(
            navigatorObserver.pushedRoutes.length,
            equals(1), // Only the initial '/' route
            reason: 'Should not navigate when validation fails',
          );
        },
      );

      testWidgets(
        'Clicking "Mot de passe oublié ?" does nothing',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: MaterialApp(
                home: const LoginScreen(),
                navigatorObservers: [navigatorObserver],
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Find and tap the "Mot de passe oublié ?" link
          final forgotPasswordLink = find.text('Mot de passe oublié ?');
          expect(forgotPasswordLink, findsOneWidget);
          
          await tester.tap(forgotPasswordLink);
          await tester.pumpAndSettle();

          // Verify no additional navigation occurred (only initial route)
          expect(
            navigatorObserver.pushedRoutes.length,
            equals(1), // Only the initial '/' route
            reason: 'Should not navigate when "Mot de passe oublié ?" is clicked',
          );
        },
      );

      testWidgets(
        'Clicking "Continuer avec Google" does nothing',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: MaterialApp(
                home: const LoginScreen(),
                navigatorObservers: [navigatorObserver],
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Scroll to make the button visible
          await tester.dragUntilVisible(
            find.text('Continuer avec Google'),
            find.byType(SingleChildScrollView),
            const Offset(0, -50),
          );
          await tester.pumpAndSettle();

          // Find and tap the "Continuer avec Google" button
          final googleButton = find.text('Continuer avec Google');
          expect(googleButton, findsOneWidget);
          
          await tester.tap(googleButton);
          await tester.pumpAndSettle();

          // Verify no additional navigation occurred (only initial route)
          expect(
            navigatorObserver.pushedRoutes.length,
            equals(1), // Only the initial '/' route
            reason: 'Should not navigate when "Continuer avec Google" is clicked',
          );
        },
      );

      testWidgets(
        'All UI elements display correctly with proper styles',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: const MaterialApp(
                home: LoginScreen(),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify logo "TR" is displayed
          expect(find.text('TR'), findsOneWidget);

          // Verify title is displayed
          expect(find.text('Bon retour !'), findsOneWidget);

          // Verify subtitle is displayed
          expect(find.text('Connectez-vous pour continuer'), findsOneWidget);

          // Verify form labels are displayed
          expect(find.text('EMAIL'), findsOneWidget);
          expect(find.text('MOT DE PASSE'), findsOneWidget);

          // Verify buttons are displayed
          expect(find.text('Se connecter'), findsOneWidget);
          expect(find.text('Continuer avec Google'), findsOneWidget);

          // Verify links are displayed
          expect(find.text('Mot de passe oublié ?'), findsOneWidget);
          expect(find.text('Créer un compte'), findsOneWidget);

          // Verify text fields are displayed
          final textFields = find.byType(TextFormField);
          expect(textFields, findsNWidgets(2));
        },
      );
    });

    group('Signup Screen Preservation', () {
      testWidgets(
        'Clicking "Se connecter" link navigates back to login',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: MaterialApp(
                home: const SignupScreen(),
                navigatorObservers: [navigatorObserver],
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Scroll to make the link visible
          await tester.dragUntilVisible(
            find.text('Se connecter'),
            find.byType(SingleChildScrollView),
            const Offset(0, -50),
          );
          await tester.pumpAndSettle();

          // Find and tap the "Se connecter" link
          final loginLink = find.text('Se connecter');
          expect(loginLink, findsOneWidget);
          
          await tester.tap(loginLink);
          await tester.pumpAndSettle();

          expect(
            navigatorObserver.poppedRoutes,
            isNotEmpty,
            reason: 'Should navigate back when "Se connecter" is clicked',
          );
        },
      );

      testWidgets(
        'Clicking back button calls Navigator.pop()',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: MaterialApp(
                home: const SignupScreen(),
                navigatorObservers: [navigatorObserver],
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Find and tap the back button
          final backButton = find.byIcon(Icons.arrow_back);
          expect(backButton, findsOneWidget);
          
          await tester.tap(backButton);
          await tester.pumpAndSettle();

          expect(
            navigatorObserver.poppedRoutes,
            isNotEmpty,
            reason: 'Navigator.pop() should be called when back button is clicked',
          );
        },
      );

      testWidgets(
        'Submitting with empty fields displays "Ce champ est requis"',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: MaterialApp(
                home: const SignupScreen(),
                navigatorObservers: [navigatorObserver],
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Scroll to make the button visible
          await tester.dragUntilVisible(
            find.text('S\'inscrire'),
            find.byType(SingleChildScrollView),
            const Offset(0, -50),
          );
          await tester.pumpAndSettle();

          // Tap the signup button without entering any text
          await tester.tap(find.widgetWithText(ElevatedButton, 'S\'inscrire'));
          await tester.pumpAndSettle();

          // Verify validation message appears
          expect(
            find.text('Ce champ est requis'),
            findsWidgets,
            reason: 'Validation message should appear for empty fields',
          );

          // Verify no navigation occurred (only initial route)
          expect(
            navigatorObserver.pushedRoutes.length,
            equals(1), // Only the initial '/' route
            reason: 'Should not navigate when validation fails',
          );
        },
      );

      testWidgets(
        'Clicking "Continuer avec Google" does nothing',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: MaterialApp(
                home: const SignupScreen(),
                navigatorObservers: [navigatorObserver],
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Scroll to make the button visible
          await tester.dragUntilVisible(
            find.text('Continuer avec Google'),
            find.byType(SingleChildScrollView),
            const Offset(0, -50),
          );
          await tester.pumpAndSettle();

          // Find and tap the "Continuer avec Google" button
          final googleButton = find.text('Continuer avec Google');
          expect(googleButton, findsOneWidget);
          
          await tester.tap(googleButton);
          await tester.pumpAndSettle();

          // Verify no additional navigation occurred (only initial route)
          expect(
            navigatorObserver.pushedRoutes.length,
            equals(1), // Only the initial '/' route
            reason: 'Should not navigate when "Continuer avec Google" is clicked',
          );
        },
      );

      testWidgets(
        'All UI elements display correctly with proper styles',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
                ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ],
              child: const MaterialApp(
                home: SignupScreen(),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify logo "TR" is displayed
          expect(find.text('TR'), findsOneWidget);

          // Verify title is displayed
          expect(find.text('Bienvenue !'), findsOneWidget);

          // Verify subtitle is displayed
          expect(find.text('Nous sommes ravis de vous voir'), findsOneWidget);

          // Verify form labels are displayed
          expect(find.text('NOM D\'UTILISATEUR'), findsOneWidget);
          expect(find.text('EMAIL'), findsOneWidget);
          expect(find.text('MOT DE PASSE'), findsOneWidget);

          // Verify buttons are displayed
          expect(find.text('S\'inscrire'), findsOneWidget);
          expect(find.text('Continuer avec Google'), findsOneWidget);

          // Verify links are displayed
          expect(find.text('Se connecter'), findsOneWidget);

          // Verify text fields are displayed
          final textFields = find.byType(TextFormField);
          expect(textFields, findsNWidgets(3));
        },
      );
    });
  });
}

class MockNavigatorObserver extends NavigatorObserver {
  final List<String> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      pushedRoutes.add(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
  }
}

/// Mock AuthProvider for preservation tests
/// This mock does nothing - it just provides the required provider context
class MockAuthProvider extends AuthProvider {
  MockAuthProvider() : super();
  
  // Override to prevent actual authentication calls
  @override
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return false; // Never actually login in preservation tests
  }
  
  @override
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? username,
  }) async {
    return false; // Never actually register in preservation tests
  }
}
