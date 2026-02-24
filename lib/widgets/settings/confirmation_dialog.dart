import 'package:flutter/material.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';

/// Widget de dialogue de confirmation réutilisable
///
/// Affiche un dialogue modal avec un titre, un message et des boutons d'action.
/// Supporte les actions destructives (affichées en rouge) et les actions normales.
/// Utilisé pour confirmer des actions importantes comme la suppression, le blocage, etc.
///
/// Validates: Requirements 1.7, 4.7, 4.9
class ConfirmationDialog extends StatelessWidget {
  /// Titre du dialogue
  final String title;

  /// Message descriptif du dialogue
  final String message;

  /// Texte du bouton de confirmation
  final String confirmText;

  /// Texte du bouton d'annulation (par défaut "Annuler")
  final String cancelText;

  /// Indique si l'action est destructive (affiche le bouton en rouge)
  final bool isDestructive;

  /// Callback appelé lors de la confirmation
  final VoidCallback onConfirm;

  /// Callback optionnel appelé lors de l'annulation
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText = 'Annuler',
    this.isDestructive = false,
    required this.onConfirm,
    this.onCancel,
  });

  /// Méthode helper pour afficher le dialogue
  ///
  /// Retourne un Future<bool?> qui est true si l'utilisateur confirme,
  /// false s'il annule, et null s'il ferme le dialogue autrement.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    String cancelText = 'Annuler',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return AlertDialog(
      backgroundColor: colors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      title: Text(
        title,
        style: AppTheme.headingSmall.copyWith(
          color: colors.textPrimary,
        ),
      ),
      content: Text(
        message,
        style: AppTheme.bodyMedium.copyWith(
          color: colors.textSecondary,
        ),
      ),
      actions: [
        // Bouton d'annulation
        TextButton(
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            } else {
              Navigator.of(context).pop(false);
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: colors.textSecondary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLarge,
              vertical: AppTheme.spacingSmall,
            ),
          ),
          child: Text(
            cancelText,
            style: AppTheme.bodyLarge.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Bouton de confirmation
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? colors.colorDanger : colors.colorPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLarge,
              vertical: AppTheme.spacingSmall,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
          child: Text(
            confirmText,
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
