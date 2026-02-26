import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/feed_provider.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/text_parser.dart';
import '../../models/feed/post_type.dart';

/// Widget avancé pour créer un nouveau post
/// 
/// Fonctionnalités :
/// - Sélection d'images multiples
/// - Détection automatique des hashtags/mentions
/// - Aperçu en temps réel
/// - Compteur de caractères
/// - Boutons d'action (photo, GIF, localisation, etc.)
/// - Validation du contenu
/// 
/// **Validates: Requirements 1.1, 1.2, 2.1**
class CreatePostWidget extends StatefulWidget {
  /// Callback appelé après la création réussie du post
  final VoidCallback? onPostCreated;
  
  /// Si true, affiche le widget en mode compact (pour modal)
  final bool isCompact;
  
  /// Contenu initial (pour édition ou réponse)
  final String? initialContent;
  
  /// Placeholder personnalisé
  final String? placeholder;

  const CreatePostWidget({
    super.key,
    this.onPostCreated,
    this.isCompact = false,
    this.initialContent,
    this.placeholder,
  });

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  // État
  List<File> _selectedImages = [];
  String? _selectedLocation;
  bool _isPosting = false;
  bool _showPreview = false;
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  
  // Limites
  static const int maxCharacters = 500;
  static const int maxImages = 4;
  
  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    // Initialiser le contenu si fourni
    if (widget.initialContent != null) {
      _textController.text = widget.initialContent!;
    }
    
    // Animation pour l'expansion du widget
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Écouter les changements de focus
    _focusNode.addListener(_onFocusChanged);
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _textController.removeListener(_onTextChanged);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !widget.isCompact) {
      _animationController.forward();
    } else if (!_focusNode.hasFocus && _textController.text.isEmpty && !widget.isCompact) {
      _animationController.reverse();
    }
  }

  void _onTextChanged() {
    setState(() {
      // Forcer la reconstruction pour mettre à jour le compteur
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.isCompact ? EdgeInsets.zero : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.themeColors.bgSecondary,
        borderRadius: BorderRadius.circular(widget.isCompact ? 0 : 12),
        border: widget.isCompact ? null : Border.all(
          color: context.themeColors.borderSubtle,
          width: 1,
        ),
        boxShadow: widget.isCompact ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec avatar utilisateur
          _buildHeader(),
          
          // Zone de texte principale
          _buildTextInput(),
          
          // Aperçu des hashtags/mentions
          if (_showPreview) _buildContentPreview(),
          
          // Images sélectionnées
          if (_selectedImages.isNotEmpty) _buildSelectedImages(),
          
          // Localisation sélectionnée
          if (_selectedLocation != null) _buildSelectedLocation(),
          
          // Animation pour les options étendues
          if (!widget.isCompact)
            AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: child,
                );
              },
              child: _buildExpandedOptions(),
            ),
          
          // Barre d'actions
          _buildActionBar(),
        ],
      ),
    );
  }

  /// Construit l'en-tête avec l'avatar de l'utilisateur
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar utilisateur
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.themeColors.colorPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'A', // Première lettre du nom utilisateur
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Texte d'invitation
          Expanded(
            child: Text(
              widget.placeholder ?? 'Quoi de neuf, AlistairJr ?',
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textSecondary,
              ),
            ),
          ),
          
          // Bouton aperçu
          if (_textController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                _showPreview ? Icons.visibility_off : Icons.visibility,
                color: context.themeColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _showPreview = !_showPreview;
                });
              },
              tooltip: _showPreview ? 'Masquer l\'aperçu' : 'Aperçu',
            ),
        ],
      ),
    );
  }

  /// Construit la zone de saisie de texte
  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        maxLines: widget.isCompact ? 3 : null,
        minLines: widget.isCompact ? 3 : 1,
        maxLength: maxCharacters,
        decoration: InputDecoration(
          hintText: 'Écrivez votre message...',
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: context.themeColors.textSecondary,
          ),
          border: InputBorder.none,
          counterText: '', // Masquer le compteur par défaut
        ),
        style: AppTheme.bodyMedium.copyWith(
          color: context.themeColors.textPrimary,
        ),
        onChanged: (text) {
          // Auto-détection des hashtags et mentions pour l'aperçu
          if (text.isNotEmpty && (text.contains('#') || text.contains('@'))) {
            setState(() {
              _showPreview = true;
            });
          }
        },
      ),
    );
  }

  /// Construit l'aperçu du contenu avec hashtags/mentions stylés
  Widget _buildContentPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.themeColors.bgTertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.themeColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                size: 16,
                color: context.themeColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Aperçu',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Contenu avec hashtags/mentions stylés
          TextParser.buildRichText(
            _textController.text,
            baseStyle: AppTheme.bodyMedium.copyWith(
              color: context.themeColors.textPrimary,
            ),
            hashtagStyle: AppTheme.bodyMedium.copyWith(
              color: context.themeColors.colorPrimary,
              fontWeight: FontWeight.w600,
            ),
            mentionStyle: AppTheme.bodyMedium.copyWith(
              color: Colors.purple,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Statistiques du contenu
          const SizedBox(height: 8),
          _buildContentStats(),
        ],
      ),
    );
  }

  /// Construit les statistiques du contenu
  Widget _buildContentStats() {
    final hashtags = TextParser.extractHashtags(_textController.text);
    final mentions = TextParser.extractMentions(_textController.text);
    final wordCount = TextParser.countWords(_textController.text);
    
    return Wrap(
      spacing: 16,
      children: [
        if (hashtags.isNotEmpty)
          _buildStat(Icons.tag, '${hashtags.length} hashtag${hashtags.length > 1 ? 's' : ''}'),
        if (mentions.isNotEmpty)
          _buildStat(Icons.alternate_email, '${mentions.length} mention${mentions.length > 1 ? 's' : ''}'),
        _buildStat(Icons.text_fields, '$wordCount mot${wordCount > 1 ? 's' : ''}'),
      ],
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: context.themeColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTheme.bodySmall.copyWith(
            color: context.themeColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Construit la grille des images sélectionnées
  Widget _buildSelectedImages() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library,
                size: 16,
                color: context.themeColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''} sélectionnée${_selectedImages.length > 1 ? 's' : ''}',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Grille d'images
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _selectedImages.length == 1 ? 1 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: _selectedImages.length == 1 ? 16/9 : 1,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return _buildImagePreview(_selectedImages[index], index);
            },
          ),
        ],
      ),
    );
  }

  /// Construit l'aperçu d'une image avec bouton de suppression
  Widget _buildImagePreview(File image, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        
        // Bouton de suppression
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImages.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construit l'affichage de la localisation sélectionnée
  Widget _buildSelectedLocation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.themeColors.bgTertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.themeColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: context.themeColors.colorPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedLocation!,
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedLocation = null;
              });
            },
            child: Icon(
              Icons.close,
              color: context.themeColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit les options étendues (visible quand le champ est focalisé)
  Widget _buildExpandedOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suggestions de hashtags populaires
          if (_textController.text.contains('#'))
            _buildHashtagSuggestions(),
          
          // Suggestions de mentions
          if (_textController.text.contains('@'))
            _buildMentionSuggestions(),
          
          const SizedBox(height: 8),
          
          // Conseils d'écriture
          _buildWritingTips(),
        ],
      ),
    );
  }

  /// Construit les suggestions de hashtags
  Widget _buildHashtagSuggestions() {
    final popularHashtags = ['Flutter', 'Dev', 'Programming', 'Mobile', 'UI', 'UX'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hashtags populaires',
          style: AppTheme.bodySmall.copyWith(
            color: context.themeColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: popularHashtags.map((hashtag) {
            return GestureDetector(
              onTap: () {
                final currentText = _textController.text;
                final newText = '$currentText #$hashtag ';
                _textController.text = newText;
                _textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: newText.length),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.themeColors.colorPrimary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '#$hashtag',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.colorPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Construit les suggestions de mentions
  Widget _buildMentionSuggestions() {
    final recentUsers = ['t4zor', 'tkporky', 'sophiemartin', 'lucasdubois'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Utilisateurs récents',
          style: AppTheme.bodySmall.copyWith(
            color: context.themeColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: recentUsers.map((user) {
            return GestureDetector(
              onTap: () {
                final currentText = _textController.text;
                final newText = '$currentText @$user ';
                _textController.text = newText;
                _textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: newText.length),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '@$user',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Construit les conseils d'écriture
  Widget _buildWritingTips() {
    final tips = [
      'Utilisez des hashtags pour augmenter la visibilité',
      'Mentionnez des utilisateurs avec @ pour les notifier',
      'Ajoutez des images pour plus d\'engagement',
    ];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.themeColors.colorPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.themeColors.colorPrimary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: context.themeColors.colorPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                'Conseils',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.colorPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: AppTheme.bodySmall.copyWith(
                      color: context.themeColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  /// Construit la barre d'actions en bas
  Widget _buildActionBar() {
    final characterCount = _textController.text.length;
    final isOverLimit = characterCount > maxCharacters;
    final canPost = _textController.text.trim().isNotEmpty && !isOverLimit && !_isPosting;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.themeColors.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Boutons d'actions média
          _buildActionButton(
            icon: Icons.photo_camera,
            tooltip: 'Ajouter des photos',
            onPressed: _selectedImages.length < maxImages ? _pickImages : null,
          ),
          
          _buildActionButton(
            icon: Icons.gif_box,
            tooltip: 'Ajouter un GIF',
            onPressed: _pickGif,
          ),
          
          _buildActionButton(
            icon: Icons.location_on,
            tooltip: 'Ajouter une localisation',
            onPressed: _selectedLocation == null ? _pickLocation : null,
          ),
          
          _buildActionButton(
            icon: Icons.poll,
            tooltip: 'Créer un sondage',
            onPressed: _createPoll,
          ),
          
          const Spacer(),
          
          // Compteur de caractères
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOverLimit 
                  ? Colors.red.withOpacity(0.1)
                  : context.themeColors.bgTertiary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOverLimit 
                    ? Colors.red.withOpacity(0.3)
                    : context.themeColors.borderSubtle,
              ),
            ),
            child: Text(
              '$characterCount/$maxCharacters',
              style: AppTheme.bodySmall.copyWith(
                color: isOverLimit 
                    ? Colors.red 
                    : context.themeColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Bouton publier
          ElevatedButton(
            onPressed: canPost ? _publishPost : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.themeColors.colorPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _isPosting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Publier',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Construit un bouton d'action
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip,
        color: onPressed != null 
            ? context.themeColors.textSecondary 
            : context.themeColors.textSecondary.withOpacity(0.5),
      ),
    );
  }

  /// Sélectionne des images depuis la galerie
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          // Ajouter les nouvelles images sans dépasser la limite
          final remainingSlots = maxImages - _selectedImages.length;
          final imagesToAdd = images.take(remainingSlots);
          
          for (final image in imagesToAdd) {
            _selectedImages.add(File(image.path));
          }
        });
        
        if (images.length > (maxImages - _selectedImages.length)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum $maxImages images autorisées'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection des images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Sélectionne un GIF (simulé)
  void _pickGif() {
    // TODO: Implémenter la sélection de GIF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sélection de GIF - À implémenter'),
      ),
    );
  }

  /// Sélectionne une localisation (simulé)
  void _pickLocation() {
    // Simuler la sélection d'une localisation
    final locations = [
      'Paris, France',
      'Lyon, France',
      'Marseille, France',
      'Toulouse, France',
      'Nice, France',
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une localisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: locations.map((location) {
            return ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(location),
              onTap: () {
                setState(() {
                  _selectedLocation = location;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  /// Crée un sondage (simulé)
  void _createPoll() {
    // TODO: Implémenter la création de sondage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Création de sondage - À implémenter'),
      ),
    );
  }

  /// Publie le post
  Future<void> _publishPost() async {
    if (!mounted) return;
    
    setState(() {
      _isPosting = true;
    });

    try {
      // Capturer le provider avant toute opération asynchrone
      final feedProvider = context.read<FeedProvider>();
      
      // Convertir les images en URLs (simulé)
      List<String>? imageUrls;
      if (_selectedImages.isNotEmpty) {
        imageUrls = _selectedImages.map((file) => file.path).toList();
      }
      
      // Créer le post
      await feedProvider.createPost(
        content: _textController.text.trim(),
        imageUrls: imageUrls,
        location: _selectedLocation,
      );
      
      // Vérifier que le widget est toujours monté avant d'utiliser le contexte
      if (!mounted) return;
      
      // Réinitialiser le formulaire
      setState(() {
        _selectedImages.clear();
        _selectedLocation = null;
        _showPreview = false;
        _isPosting = false;
      });
      
      _textController.clear();
      _focusNode.unfocus();
      
      if (!widget.isCompact) {
        _animationController.reverse();
      }
      
      // Callback de succès
      widget.onPostCreated?.call();
      
      // Notification de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post publié avec succès !'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la publication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }
}