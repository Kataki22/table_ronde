import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';

/// Screen for editing the current user's profile
/// 
/// Allows editing:
/// - Profile photo (URL input for mock data)
/// - Bio (max 500 characters)
/// - Phone number (with validation)
/// 
/// **Validates: Requirements 2.7**
class ProfileEditScreen extends StatefulWidget {
  /// The ID of the user whose profile to edit
  final String userId;

  const ProfileEditScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _photoUrlController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  /// Loads the current profile data into the form
  void _loadCurrentProfile() {
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.getProfile(widget.userId);
    
    if (profile != null) {
      _bioController.text = profile.bio ?? '';
      _phoneController.text = profile.phone ?? '';
      _photoUrlController.text = profile.avatarUrl ?? '';
    }

    // Listen for changes
    _bioController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _photoUrlController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          return;
        }
        
        final shouldPop = await _showDiscardChangesDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.themeColors.bgPrimary,
        appBar: AppBar(
          title: const Text('Modifier le profil'),
          backgroundColor: context.themeColors.bgSecondary,
          elevation: 0,
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Enregistrer',
                        style: TextStyle(
                          color: context.themeColors.colorPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Profile photo section
              _buildPhotoSection(),
              const SizedBox(height: 32),

              // Bio field
              _buildBioField(),
              const SizedBox(height: 24),

              // Phone field
              _buildPhoneField(),
              const SizedBox(height: 32),

              // Save button (mobile-friendly)
              if (_hasChanges)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.themeColors.colorPrimary,
                      foregroundColor: context.themeColors.textInverse,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Enregistrer les modifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the profile photo section
  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo de profil',
          style: AppTheme.bodyLarge.copyWith(
            color: context.themeColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Current photo preview
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                final profile = profileProvider.getProfile(widget.userId);
                final photoUrl = _photoUrlController.text.isNotEmpty
                    ? _photoUrlController.text
                    : profile?.avatarUrl;

                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.themeColors.borderMedium,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    backgroundColor: context.themeColors.bgSurfaceDark,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: context.themeColors.textSecondary,
                          )
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            
            // Photo URL input
            Expanded(
              child: TextFormField(
                controller: _photoUrlController,
                decoration: InputDecoration(
                  labelText: 'URL de la photo',
                  hintText: 'https://example.com/photo.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: context.themeColors.bgSecondary,
                ),
                keyboardType: TextInputType.url,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Entrez l\'URL d\'une image pour votre photo de profil',
          style: AppTheme.bodySmall.copyWith(
            color: context.themeColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds the bio text field
  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: AppTheme.bodyLarge.copyWith(
            color: context.themeColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _bioController,
          builder: (context, value, child) {
            return TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                hintText: 'Parlez-nous de vous...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: context.themeColors.bgSecondary,
                counterText: '${value.text.length}/500',
                counterStyle: TextStyle(
                  color: value.text.length > 500
                      ? context.themeColors.colorDanger
                      : context.themeColors.textSecondary,
                ),
              ),
              maxLines: 4,
              maxLength: 500,
              validator: (value) {
                if (value != null && value.length > 500) {
                  return 'La bio est trop longue (maximum 500 caractères)';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            );
          },
        ),
      ],
    );
  }

  /// Builds the phone number field
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Téléphone',
          style: AppTheme.bodyLarge.copyWith(
            color: context.themeColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: '+33 6 12 34 56 78',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: context.themeColors.bgSecondary,
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: context.themeColors.textSecondary,
            ),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              // Basic phone validation
              final cleanPhone = value.replaceAll(' ', '');
              
              // Must start with + or a digit
              if (!cleanPhone.startsWith('+') && !RegExp(r'^\d').hasMatch(cleanPhone)) {
                return 'Format de téléphone invalide';
              }
              
              // Must contain at least 10 digits
              final digits = cleanPhone.replaceAll(RegExp(r'[^\d]'), '');
              if (digits.length < 10) {
                return 'Le numéro doit contenir au moins 10 chiffres';
              }
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 8),
        Text(
          'Format: +33 6 12 34 56 78 ou 0612345678',
          style: AppTheme.bodySmall.copyWith(
            color: context.themeColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Saves the profile changes
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider = context.read<ProfileProvider>();
      
      await profileProvider.updateProfile(
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        photoUrl: _photoUrlController.text.isEmpty ? null : _photoUrlController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      );

      if (mounted) {
        setState(() {
          _hasChanges = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil mis à jour avec succès'),
            backgroundColor: context.themeColors.colorSuccess,
            duration: const Duration(seconds: 2),
          ),
        );

        // Return to profile screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: context.themeColors.colorDanger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Shows a dialog to confirm discarding changes
  Future<bool> _showDiscardChangesDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonner les modifications ?'),
        content: const Text(
          'Vous avez des modifications non enregistrées. '
          'Voulez-vous vraiment quitter sans enregistrer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuer l\'édition'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.themeColors.colorDanger,
            ),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
