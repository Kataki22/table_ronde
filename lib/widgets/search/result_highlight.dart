import 'package:flutter/material.dart';

/// Widget réutilisable pour mettre en surbrillance du texte recherché
/// avec animation de pulse (300ms)
/// 
/// Ce widget affiche du texte avec des portions mises en surbrillance
/// selon une requête de recherche. Il gère la recherche insensible à la casse
/// et aux accents (par exemple, "cafe" correspondra à "café").
/// 
/// Peut être utilisé dans n'importe quel contexte : résultats de recherche,
/// messages de chat, listes, etc.
/// 
/// **Validates: Requirements 3.6, 8.3**
class ResultHighlight extends StatefulWidget {
  /// Le texte complet à afficher
  final String text;

  /// La requête de recherche à mettre en surbrillance
  final String query;

  /// Couleur du texte normal (par défaut: noir)
  final Color? textColor;

  /// Couleur de fond du texte mis en surbrillance (par défaut: jaune)
  final Color? highlightColor;

  /// Couleur du texte mis en surbrillance (par défaut: noir)
  final Color? highlightTextColor;

  /// Style de texte de base (optionnel)
  final TextStyle? textStyle;

  /// Nombre maximum de lignes (optionnel)
  final int? maxLines;

  /// Comportement de débordement du texte
  final TextOverflow? overflow;

  /// Alignement du texte
  final TextAlign? textAlign;

  const ResultHighlight({
    super.key,
    required this.text,
    required this.query,
    this.textColor,
    this.highlightColor,
    this.highlightTextColor,
    this.textStyle,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  State<ResultHighlight> createState() => _ResultHighlightState();
}

class _ResultHighlightState extends State<ResultHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configuration de l'animation de pulse (300ms)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Démarrer l'animation si la requête n'est pas vide
    if (widget.query.trim().isNotEmpty) {
      _pulseController.forward();
    }
  }

  @override
  void didUpdateWidget(ResultHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Redémarrer l'animation si la requête change
    if (widget.query != oldWidget.query && widget.query.trim().isNotEmpty) {
      _pulseController.reset();
      _pulseController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si la requête est vide, afficher le texte normalement
    if (widget.query.trim().isEmpty) {
      return Text(
        widget.text,
        style: widget.textStyle?.copyWith(color: widget.textColor) ??
            TextStyle(color: widget.textColor ?? Colors.black),
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
      );
    }

    // Calculer les ranges de highlight avec normalisation des accents
    final highlightRanges = _calculateHighlightRanges(widget.text, widget.query);

    // Si aucun match, afficher le texte normalement
    if (highlightRanges.isEmpty) {
      return Text(
        widget.text,
        style: widget.textStyle?.copyWith(color: widget.textColor) ??
            TextStyle(color: widget.textColor ?? Colors.black),
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
      );
    }

    // Construire les spans avec highlighting animé
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final spans = _buildTextSpans(
          widget.text,
          highlightRanges,
          widget.textColor ?? Colors.black,
          widget.highlightColor ?? Colors.yellow,
          widget.highlightTextColor ?? Colors.black,
        );

        return RichText(
          text: TextSpan(
            style: widget.textStyle ?? const TextStyle(fontSize: 14),
            children: spans,
          ),
          maxLines: widget.maxLines,
          overflow: widget.overflow ?? TextOverflow.clip,
          textAlign: widget.textAlign ?? TextAlign.start,
        );
      },
    );
  }

  /// Calcule les ranges de texte à highlighter
  /// 
  /// Utilise une recherche insensible à la casse et aux accents.
  /// Trouve toutes les occurrences de la requête dans le texte.
  List<_TextRange> _calculateHighlightRanges(String text, String query) {
    final ranges = <_TextRange>[];
    
    // Normaliser le texte et la requête (casse + accents)
    final normalizedText = _normalizeString(text);
    final normalizedQuery = _normalizeString(query.trim());
    
    int startIndex = 0;
    while (startIndex < normalizedText.length) {
      final index = normalizedText.indexOf(normalizedQuery, startIndex);
      if (index == -1) break;
      
      // Utiliser les positions du texte original
      ranges.add(_TextRange(index, index + query.trim().length));
      startIndex = index + query.trim().length;
    }
    
    return ranges;
  }

  /// Normalise une chaîne pour la recherche insensible à la casse et aux accents
  /// 
  /// Convertit en minuscules et remplace les caractères accentués
  /// par leurs équivalents non accentués.
  String _normalizeString(String str) {
    // Convertir en minuscules
    String normalized = str.toLowerCase();
    
    // Remplacer les caractères accentués
    const accents = 'àáâãäåèéêëìíîïòóôõöùúûüýÿñçÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝŸÑÇ';
    const withoutAccents = 'aaaaaaeeeeiiiioooooouuuuyyncaaaaaaeeeeiiiioooooouuuuyync';
    
    for (int i = 0; i < accents.length; i++) {
      normalized = normalized.replaceAll(accents[i], withoutAccents[i]);
    }
    
    return normalized;
  }

  /// Construit les TextSpans avec highlighting animé
  List<TextSpan> _buildTextSpans(
    String text,
    List<_TextRange> ranges,
    Color normalColor,
    Color highlightBgColor,
    Color highlightFgColor,
  ) {
    final spans = <TextSpan>[];
    int currentIndex = 0;

    // Trier les ranges par position de début
    final sortedRanges = List<_TextRange>.from(ranges)
      ..sort((a, b) => a.start.compareTo(b.start));

    for (final range in sortedRanges) {
      // Ajouter le texte avant le highlight
      if (currentIndex < range.start) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, range.start),
          style: TextStyle(color: normalColor),
        ));
      }

      // Ajouter le texte highlighté avec animation de pulse
      spans.add(TextSpan(
        text: text.substring(range.start, range.end),
        style: TextStyle(
          color: highlightFgColor,
          backgroundColor: highlightBgColor.withValues(
            alpha: _pulseAnimation.value,
          ),
          fontWeight: FontWeight.w600,
        ),
      ));

      currentIndex = range.end;
    }

    // Ajouter le texte restant après le dernier highlight
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: TextStyle(color: normalColor),
      ));
    }

    return spans;
  }
}

/// Classe interne pour représenter un range de texte
class _TextRange {
  final int start;
  final int end;

  _TextRange(this.start, this.end);
}
