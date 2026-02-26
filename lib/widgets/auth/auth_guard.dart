import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';

/// Widget qui protège l'accès aux écrans nécessitant une authentification
class AuthGuard extends StatelessWidget {
  final Widget child;
  final bool requireAuth;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireAuth = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Si l'authentification n'est pas requise, afficher directement le contenu
        if (!requireAuth) {
          return child;
        }

        // Si en cours de chargement
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si non authentifié, afficher l'écran de connexion
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Si authentifié, afficher le contenu
        return child;
      },
    );
  }
}

/// Widget pour afficher les informations de l'utilisateur connecté
class CurrentUserWidget extends StatelessWidget {
  final Widget Function(BuildContext context, dynamic user) builder;

  const CurrentUserWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.currentUser == null) {
          return const SizedBox.shrink();
        }
        return builder(context, authProvider.currentUser);
      },
    );
  }
}
