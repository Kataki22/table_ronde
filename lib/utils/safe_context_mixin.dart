import 'dart:async';
import 'package:flutter/material.dart';

/// Mixin pour sécuriser l'accès au contexte dans les widgets avec état
/// 
/// Évite les erreurs "Tried to listen to a value exposed with provider, 
/// from outside of the widget tree" en vérifiant que le widget est monté
/// avant d'accéder au contexte.
mixin SafeContextMixin<T extends StatefulWidget> on State<T> {
  /// Exécute une fonction avec le contexte seulement si le widget est monté
  /// 
  /// Utilisation :
  /// ```dart
  /// safeContext((context) {
  ///   context.read<MyProvider>().doSomething();
  /// });
  /// ```
  void safeContext(void Function(BuildContext context) callback) {
    if (mounted) {
      try {
        callback(context);
      } catch (e) {
        debugPrint('Error in safe context callback: $e');
      }
    }
  }

  /// Version asynchrone de safeContext
  /// 
  /// Utilisation :
  /// ```dart
  /// await safeContextAsync((context) async {
  ///   await context.read<MyProvider>().doSomethingAsync();
  /// });
  /// ```
  Future<void> safeContextAsync(Future<void> Function(BuildContext context) callback) async {
    if (mounted) {
      try {
        await callback(context);
      } catch (e) {
        debugPrint('Error in safe async context callback: $e');
      }
    }
  }

  /// Exécute une fonction avec le contexte et retourne un résultat
  /// 
  /// Utilisation :
  /// ```dart
  /// final result = safeContextWithResult<String>((context) {
  ///   return context.read<MyProvider>().getSomething();
  /// });
  /// ```
  T? safeContextWithResult<T>(T Function(BuildContext context) callback) {
    if (mounted) {
      try {
        return callback(context);
      } catch (e) {
        debugPrint('Error in safe context callback with result: $e');
      }
    }
    return null;
  }

  /// Version asynchrone de safeContextWithResult
  Future<T?> safeContextWithResultAsync<T>(Future<T> Function(BuildContext context) callback) async {
    if (mounted) {
      try {
        return await callback(context);
      } catch (e) {
        debugPrint('Error in safe async context callback with result: $e');
      }
    }
    return null;
  }

  /// Crée un callback sécurisé pour les TapGestureRecognizer
  /// 
  /// Utilisation :
  /// ```dart
  /// TapGestureRecognizer()
  ///   ..onTap = safeTapCallback(() {
  ///     context.read<MyProvider>().doSomething();
  ///   });
  /// ```
  VoidCallback safeTapCallback(VoidCallback callback) {
    return () {
      if (mounted) {
        try {
          callback();
        } catch (e) {
          debugPrint('Error in safe tap callback: $e');
        }
      }
    };
  }

  /// Crée un callback sécurisé avec contexte pour les TapGestureRecognizer
  /// 
  /// Utilisation :
  /// ```dart
  /// TapGestureRecognizer()
  ///   ..onTap = safeTapCallbackWithContext((context) {
  ///     context.read<MyProvider>().doSomething();
  ///   });
  /// ```
  VoidCallback safeTapCallbackWithContext(void Function(BuildContext context) callback) {
    return () {
      safeContext(callback);
    };
  }

  /// Crée un Timer sécurisé qui vérifie mounted avant d'exécuter
  /// 
  /// Utilisation :
  /// ```dart
  /// safeTimer(Duration(seconds: 1), () {
  ///   context.read<MyProvider>().doSomething();
  /// });
  /// ```
  Timer safeTimer(Duration duration, void Function(BuildContext context) callback) {
    return Timer(duration, () {
      safeContext(callback);
    });
  }

  /// Crée un Timer périodique sécurisé
  Timer safePeriodic(Duration duration, void Function(BuildContext context) callback) {
    return Timer.periodic(duration, (_) {
      safeContext(callback);
    });
  }
}