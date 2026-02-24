import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../services/sticker_manager.dart';
import '../../utils/theme_extensions.dart';

/// Widget for creating new custom stickers
class StickerCreator extends StatefulWidget {
  const StickerCreator({super.key});

  @override
  State<StickerCreator> createState() => _StickerCreatorState();
}

class _StickerCreatorState extends State<StickerCreator> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.themeColors.bgSurfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.themeColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Créer un sticker',
                style: TextStyle(
                  color: context.themeColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildOption(
                    icon: Icons.photo_library,
                    label: 'Choisir depuis la galerie',
                    color: Colors.blueAccent,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    icon: Icons.camera_alt,
                    label: 'Prendre une photo',
                    color: Colors.greenAccent,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isProcessing ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.themeColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.themeColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() => _isProcessing = true);

      // Close the picker sheet
      if (mounted) Navigator.pop(context);

      // Open the editor
      final editedImage = await _openImageEditor(File(image.path));

      if (editedImage != null && mounted) {
        // Show dialog to name the sticker
        final stickerName = await _showNameDialog();

        if (stickerName != null && stickerName.isNotEmpty && mounted) {
          // Save the sticker
          final sticker = await StickerManager().addSticker(
            imageFile: editedImage,
            name: stickerName,
          );

          // Return the created sticker
          if (mounted) {
            Navigator.pop(context, sticker);
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<File?> _openImageEditor(File imageFile) async {
    if (!mounted) return null;

    final editedImage = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditor.file(
          imageFile,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {
              Navigator.pop(context, bytes);
            },
          ),
          configs: ProImageEditorConfigs(
            designMode: ImageEditorDesignMode.material,
            i18n: const I18n(
              cancel: 'Annuler',
              done: 'Terminé',
              remove: 'Supprimer',
              undo: 'Annuler',
              redo: 'Refaire',
              various: I18nVarious(
                loadingDialogMsg: 'Veuillez patienter...',
                closeEditorWarningTitle: 'Fermer l\'éditeur?',
                closeEditorWarningMessage:
                    'Êtes-vous sûr de vouloir fermer l\'éditeur? Vos modifications seront perdues.',
                closeEditorWarningConfirmBtn: 'Fermer',
                closeEditorWarningCancelBtn: 'Annuler',
              ),
            ),
          ),
        ),
      ),
    );

    if (editedImage == null) return null;

    // Save the edited image to a temporary file
    final tempDir = await Directory.systemTemp.createTemp('sticker_');
    final tempFile = File('${tempDir.path}/edited_sticker.png');
    await tempFile.writeAsBytes(editedImage);

    return tempFile;
  }

  Future<String?> _showNameDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.themeColors.bgSurface,
        title: Text(
          'Nommer votre sticker',
          style: TextStyle(color: context.themeColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: context.themeColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Nom du sticker',
            hintStyle: TextStyle(color: context.themeColors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.themeColors.textDisabled),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.themeColors.colorPrimary),
            ),
          ),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: context.themeColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              'Créer',
              style: TextStyle(color: context.themeColors.colorPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
