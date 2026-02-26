import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tableronde_app/providers/auth_provider.dart';
import 'package:tableronde_app/providers/theme_provider.dart';
import 'package:tableronde_app/screens/login_screen.dart';
import 'package:tableronde_app/screens/signup_screen.dart';

/// Test d'exploration de la condition de bug pour l'intégration AuthProvider
/// 
/// **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6**
/// 
/// **CRITIQUE**: Ce test DOIT ÉCHOUER sur le code non corrigé - l'échec confirme que le bug existe
/// 
/// **Property 1: Fault Condition** - Méthodes d'authentification non appelées avant navigation
void main() {
  group('Auth Bug Exploration - Fault Condition', () {
    late MockNavigatorObserver navigatorObserver;
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      navigatorObserver = MockNavigatorObserver();
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    testWidgets(
      'Login with invalid credentials should call AuthProvider.login() and NOT navigate to /home',
      (WidgetTester tester) async {
        bool loginCalled = false;
        String? loginEmail;
        String? loginPassword;

        final testAuthProvider = TestAuthProvider(
          onLogin: (email, password) {
            loginCalled = true;
            loginEmail = email;
            loginPassword = password;
            return Future.value(false);
          },
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
              ChangeNotifierProvider<AuthProvider>.value(value: testAuthProvider),
            ],
            child: MaterialApp(
              home: const LoginScreen(),
              navigatorObservers: [navigatorObserver],
              routes: {
                '/home': (context) => const Scaffold(body: Text('Home Screen')),
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find text fields by type and index
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(2)); // Email and password fields
        
        await tester.enterText(textFields.at(0), 'fake@test.com'); // Email field
        await tester.enterText(textFields.at(1), 'wrong'); // Password field
        
        // Scroll to make the button visible
        await tester.ensureVisible(find.text('Se connecter'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Se connecter'));
        await tester.pumpAndSettle();

        expect(
          loginCalled,
          isTrue,
          reason: 'AuthProvider.login() should be called when login button is pressed',
        );
        expect(loginEmail, equals('fake@test.com'));
        expect(loginPassword, equals('wrong'));
        expect(
          navigatorObserver.pushedRoutes.contains('/home'),
          isFalse,
          reason: 'Should NOT navigate to /home when login returns false',
        );
        expect(
          testAuthProvider.error,
          isNotNull,
          reason: 'Error message should be set when login fails',
        );
      },
    );

    testWidgets(
      'Signup with existing email should call AuthProvider.register() and NOT navigate to /otp',
      (WidgetTester tester) async {
        bool registerCalled = false;
        String? registerEmail;
        String? registerPassword;
        String? registerName;

        final testAuthProvider = TestAuthProvider(
          onRegister: (email, password, name, username) {
            registerCalled = true;
            registerEmail = email;
            registerPassword = password;
            registerName = name;
            return Future.value(false);
          },
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
              ChangeNotifierProvider<AuthProvider>.value(value: testAuthProvider),
            ],
            child: MaterialApp(
              home: const SignupScreen(),
              navigatorObservers: [navigatorObserver],
              routes: {
                '/otp': (context) => const Scaffold(body: Text('OTP Screen')),
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find text fields by type and index
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(3)); // Username, email and password fields
        
        await tester.enterText(textFields.at(0), 'testuser'); // Username field
        await tester.enterText(textFields.at(1), 'user1@example.com'); // Email field
        await tester.enterText(textFields.at(2), 'password123'); // Password field
        
        // Scroll to make the button visible
        await tester.ensureVisible(find.text('S\'inscrire'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('S\'inscrire'));
        await tester.pumpAndSettle();

        expect(
          registerCalled,
          isTrue,
          reason: 'AuthProvider.register() should be called when signup button is pressed',
        );
        expect(registerEmail, equals('user1@example.com'));
        expect(registerPassword, equals('password123'));
        expect(registerName, equals('testuser'));
        expect(
          navigatorObserver.pushedRoutes.contains('/otp'),
          isFalse,
          reason: 'Should NOT navigate to /otp when register returns false',
        );
        expect(
          testAuthProvider.error,
          isNotNull,
          reason: 'Error message should be set when registration fails',
        );
      },
    );

    testWidgets(
      'Login with valid credentials should call AuthProvider.login() and navigate to /home only if it returns true',
      (WidgetTester tester) async {
        bool loginCalled = false;

        final testAuthProvider = TestAuthProvider(
          onLogin: (email, password) {
            loginCalled = true;
            return Future.value(true);
          },
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
              ChangeNotifierProvider<AuthProvider>.value(value: testAuthProvider),
            ],
            child: MaterialApp(
              home: const LoginScreen(),
              navigatorObservers: [navigatorObserver],
              routes: {
                '/home': (context) => const Scaffold(body: Text('Home Screen')),
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find text fields by type and index
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(2)); // Email and password fields
        
        await tester.enterText(textFields.at(0), 'user1@example.com'); // Email field
        await tester.enterText(textFields.at(1), 'password123'); // Password field
        
        // Scroll to make the button visible
        await tester.ensureVisible(find.text('Se connecter'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Se connecter'));
        await tester.pumpAndSettle();

        expect(
          loginCalled,
          isTrue,
          reason: 'AuthProvider.login() should be called when login button is pressed',
        );
        expect(
          navigatorObserver.pushedRoutes.contains('/home'),
          isTrue,
          reason: 'Should navigate to /home when login returns true',
        );
        expect(
          testAuthProvider.error,
          isNull,
          reason: 'No error message should be set when login succeeds',
        );
      },
    );

    testWidgets(
      'Signup with new email should call AuthProvider.register() and navigate to /otp only if it returns true',
      (WidgetTester tester) async {
        bool registerCalled = false;

        final testAuthProvider = TestAuthProvider(
          onRegister: (email, password, name, username) {
            registerCalled = true;
            return Future.value(true);
          },
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
              ChangeNotifierProvider<AuthProvider>.value(value: testAuthProvider),
            ],
            child: MaterialApp(
              home: const SignupScreen(),
              navigatorObservers: [navigatorObserver],
              routes: {
                '/otp': (context) => const Scaffold(body: Text('OTP Screen')),
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find text fields by type and index
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(3)); // Username, email and password fields
        
        await tester.enterText(textFields.at(0), 'newuser'); // Username field
        await tester.enterText(textFields.at(1), 'newuser@example.com'); // Email field
        await tester.enterText(textFields.at(2), 'newpassword123'); // Password field
        
        // Scroll to make the button visible
        await tester.ensureVisible(find.text('S\'inscrire'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('S\'inscrire'));
        await tester.pumpAndSettle();

        expect(
          registerCalled,
          isTrue,
          reason: 'AuthProvider.register() should be called when signup button is pressed',
        );
        expect(
          navigatorObserver.pushedRoutes.contains('/otp'),
          isTrue,
          reason: 'Should navigate to /otp when register returns true',
        );
        expect(
          testAuthProvider.error,
          isNull,
          reason: 'No error message should be set when registration succeeds',
        );
      },
    );
  });
}

class MockNavigatorObserver extends NavigatorObserver {
  final List<String> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      pushedRoutes.add(route.settings.name!);
    }
  }
}

class TestAuthProvider extends AuthProvider {
  final Future<bool> Function(String email, String password)? onLogin;
  final Future<bool> Function(
    String email,
    String password,
    String name,
    String? username,
  )? onRegister;

  TestAuthProvider({
    this.onLogin,
    this.onRegister,
  });

  @override
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (onLogin != null) {
      final result = await onLogin!(email, password);
      if (!result) {
        _error = 'Identifiants invalides';
      }
      _isLoading = false;
      notifyListeners();
      return result;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (onRegister != null) {
      final result = await onRegister!(email, password, name, username);
      if (!result) {
        _error = 'Cet email est déjà utilisé';
      }
      _isLoading = false;
      notifyListeners();
      return result;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Expose private fields for testing
  bool _isLoading = false;
  String? _error;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;
}
