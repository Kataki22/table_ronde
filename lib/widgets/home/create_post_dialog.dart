import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_extensions.dart';

class CreatePostDialog extends StatefulWidget {
  final Function(String, File?) onPostCreated;

  const CreatePostDialog({
    super.key,
    required this.onPostCreated,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final _contentController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.themeColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: context.themeColors.bgSurfaceDark, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Créer un post',
                    style: AppTheme.headingSmall
                        .copyWith(color: context.themeColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: context.themeColors.textSecondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              context.themeColors.colorPrimary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'V',
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.themeColors.colorPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vous',
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.themeColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '@vous',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.themeColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Text input
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    style: AppTheme.bodyMedium
                        .copyWith(color: context.themeColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Quoi de neuf ? 🚀',
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: context.themeColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.themeColors.bgSurfaceDark,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.themeColors.colorPrimary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: context.themeColors.bgPrimary,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Image preview if selected
                  if (_selectedImage != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildIconButton(
                            Icons.image_outlined,
                            () => _selectImage(),
                          ),
                          const SizedBox(width: 12),
                          _buildIconButton(
                            Icons.emoji_emotions_outlined,
                            () {},
                          ),
                          const SizedBox(width: 12),
                          _buildIconButton(
                            Icons.location_on_outlined,
                            () {},
                          ),
                        ],
                      ),
                      _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2563EB),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _postContent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    context.themeColors.colorPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Publier',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.themeColors.bgSurfaceDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: context.themeColors.colorPrimary,
          size: 20,
        ),
      ),
    );
  }

  void _selectImage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.themeColors.bgSurface,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Sélectionner une image',
              style: AppTheme.headingSmall
                  .copyWith(color: context.themeColors.textPrimary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.image, color: Color(0xFF2563EB)),
            title: Text(
              'Galerie',
              style: AppTheme.bodyMedium
                  .copyWith(color: context.themeColors.textPrimary),
            ),
            onTap: () {
              _pickImage(ImageSource.gallery);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
            title: Text(
              'Caméra',
              style: AppTheme.bodyMedium
                  .copyWith(color: context.themeColors.textPrimary),
            ),
            onTap: () {
              _pickImage(ImageSource.camera);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _postContent() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez entrer du contenu',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: context.themeColors.colorDanger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate posting delay
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onPostCreated(_contentController.text, _selectedImage);
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
