import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:tableronde_app/utils/text_parser.dart';
import '../../models/search/text_range.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/safe_context_mixin.dart';

/// Widget pour afficher du texte avec surlignage des correspondances de recherche
/// 
/// Fonctionnalités :
/// - Surlignage de multiples ranges de texte
/// - Styles personnalisables pour le surlignage
/// - Support des hashtags et mentions cliquables
/// - Animation du surlignage
/// - Gestion des overlaps de ranges
class HighlightedText extends StatefulWidget {
  /// Texte à afficher
  final String text;
  
  /// Ranges de texte à surligner
  final List<TextRange> highlightRanges;
  
  /// Style de base du texte
  final TextStyle? baseStyle;
  
  /// Couleur de surlignage
  final Color? highlightColor;
  
  /// Style du texte surligné
  final TextStyle? highlightStyle;
  
  /// Callback pour les hashtags cliquables
  final Function(String hashtag)? onHashtagTap;
  
  /// Callback pour les mentions cliquables
  final Function(String mention)? onMentionTap;
  
  /// Si true, anime le surlignage
  final bool animateHighlight;
  
  /// Nombre maximum de lignes
  final int? maxLines;
  
  /// Comportement de débordement
  final TextOverflow? overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlightRanges,
    this.baseStyle,
    this.highlightColor,
    this.highlightStyle,
    this.onHashtagTap,
    this.onMentionTap,
    this.animateHighlight = false,
    this.maxLines,
    this.overflow,
  });

  @override
  State<HighlightedText> createState() => _HighlightedTextState();
}

class _HighlightedTextState extends State<HighlightedText>
    with SingleTickerProviderStateMixin, SafeContextMixin {
  // Animation
  late AnimationController _animationController;
  late Animation<double> _highlightAnimation;
  
  // Liste des recognizers pour les disposer correctement
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    
    // Animation pour le surlignage
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _highlightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.animateHighlight && widget.highlightRanges.isNotEmpty) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(HighlightedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Redémarrer l'animation si les ranges ont changé
    if (widget.animateHighlight && 
        widget.highlightRanges != oldWidget.highlightRanges &&
        widget.highlightRanges.isNotEmpty) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    // Disposer tous les recognizers
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.highlightRanges.isEmpty) {
      return _buildPlainText();
    }
    
    if (widget.animateHighlight) {
      return AnimatedBuilder(
        animation: _highlightAnimation,
        builder: (context, child) => _buildHighlightedText(),
      );
    }
    
    return _buildHighlightedText();
  }

  /// Construit le texte sans surlignage
  Widget _buildPlainText() {
    return TextParser.buildRichText(
      widget.text,
      baseStyle: widget.baseStyle ?? AppTheme.bodyMedium.copyWith(
        color: context.themeColors.textPrimary,
      ),
      onHashtagTap: widget.onHashtagTap,
      onMentionTap: widget.onMentionTap,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }

  /// Construit le texte avec surlignage
  Widget _buildHighlightedText() {
    // Nettoyer les anciens recognizers
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    
    // Fusionner les ranges qui se chevauchent
    final mergedRanges = TextRange.mergeOverlapping(widget.highlightRanges);
    
    // Créer les spans de texte
    final spans = <TextSpan>[];
    int currentIndex = 0;
    
    for (final range in mergedRanges) {
      // Ajouter le texte avant le range
      if (currentIndex < range.start) {
        final beforeText = widget.text.substring(currentIndex, range.start);
        spans.addAll(_createTextSpans(beforeText, false));
      }
      
      // Ajouter le texte surligné
      if (range.start < widget.text.length && range.end <= widget.text.length) {
        final highlightedText = widget.text.substring(range.start, range.end);
        spans.addAll(_createTextSpans(highlightedText, true));
      }
      
      currentIndex = range.end;
    }
    
    // Ajouter le texte restant
    if (currentIndex < widget.text.length) {
      final remainingText = widget.text.substring(currentIndex);
      spans.addAll(_createTextSpans(remainingText, false));
    }
    
    return RichText(
      text: TextSpan(children: spans),
      maxLines: widget.maxLines,
      overflow: widget.overflow ?? TextOverflow.clip,
    );
  }

  /// Crée les spans de texte avec gestion des hashtags/mentions
  List<TextSpan> _createTextSpans(String text, bool isHighlighted) {
    final spans = <TextSpan>[];
    
    // Extraire hashtags et mentions
    final hashtags = RegExp(r'#\w+').allMatches(text);
    final mentions = RegExp(r'@\w+').allMatches(text);
    
    // Créer une liste de tous les éléments spéciaux
    final specialElements = <MapEntry<int, String>>[];
    
    for (final match in hashtags) {
      specialElements.add(MapEntry(match.start, 'hashtag:${match.group(0)}'));
    }
    
    for (final match in mentions) {
      specialElements.add(MapEntry(match.start, 'mention:${match.group(0)}'));
    }
    
    // Trier par position
    specialElements.sort((a, b) => a.key.compareTo(b.key));
    
    if (specialElements.isEmpty) {
      // Pas d'éléments spéciaux, créer un span simple
      spans.add(_createTextSpan(text, isHighlighted, null));
    } else {
      // Traiter les éléments spéciaux
      int currentIndex = 0;
      
      for (final element in specialElements) {
        final position = element.key;
        final elementInfo = element.value.split(':');
        final elementType = elementInfo[0];
        final elementText = elementInfo[1];
        
        // Ajouter le texte avant l'élément spécial
        if (currentIndex < position) {
          final beforeText = text.substring(currentIndex, position);
          spans.add(_createTextSpan(beforeText, isHighlighted, null));
        }
        
        // Ajouter l'élément spécial
        spans.add(_createTextSpan(elementText, isHighlighted, elementType));
        
        currentIndex = position + elementText.length;
      }
      
      // Ajouter le texte restant
      if (currentIndex < text.length) {
        final remainingText = text.substring(currentIndex);
        spans.add(_createTextSpan(remainingText, isHighlighted, null));
      }
    }
    
    return spans;
  }

  /// Crée un span de texte individuel
  TextSpan _createTextSpan(String text, bool isHighlighted, String? specialType) {
    // Style de base
    TextStyle style = widget.baseStyle ?? AppTheme.bodyMedium.copyWith(
      color: context.themeColors.textPrimary,
    );
    
    // Appliquer le surlignage
    if (isHighlighted) {
      final highlightOpacity = widget.animateHighlight 
          ? _highlightAnimation.value 
          : 1.0;
      
      style = style.copyWith(
        backgroundColor: (widget.highlightColor ?? 
            context.themeColors.colorPrimary.withValues(alpha: 0.3))
            .withValues(alpha: highlightOpacity * 0.3),
        fontWeight: FontWeight.w600,
      );
      
      if (widget.highlightStyle != null) {
        style = style.merge(widget.highlightStyle);
      }
    }
    
    // Appliquer les styles spéciaux
    TapGestureRecognizer? recognizer;
    
    switch (specialType) {
      case 'hashtag':
        style = style.copyWith(
          color: const Color(0xFF1DA1F2),
          fontWeight: FontWeight.w600,
        );
        if (widget.onHashtagTap != null) {
          final hashtag = text.substring(1); // Enlever le #
          recognizer = TapGestureRecognizer()
            ..onTap = safeTapCallback(() {
              widget.onHashtagTap!(hashtag);
            });
          _recognizers.add(recognizer);
        }
        break;
        
      case 'mention':
        style = style.copyWith(
          color: const Color(0xFF9C27B0),
          fontWeight: FontWeight.w600,
        );
        if (widget.onMentionTap != null) {
          final mention = text.substring(1); // Enlever le @
          recognizer = TapGestureRecognizer()
            ..onTap = safeTapCallback(() {
              widget.onMentionTap!(mention);
            });
          _recognizers.add(recognizer);
        }
        break;
    }
    
    return TextSpan(
      text: text,
      style: style,
      recognizer: recognizer,
    );
  }
}

