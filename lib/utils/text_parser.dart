import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Utilitaire pour parser le texte et extraire hashtags, mentions, liens
class TextParser {
  /// Expression régulière pour les hashtags (#mot)
  static final RegExp _hashtagRegex = RegExp(r'#[a-zA-Z0-9_À-ÿ]+');
  
  /// Expression régulière pour les mentions (@utilisateur)
  static final RegExp _mentionRegex = RegExp(r'@[a-zA-Z0-9_]+');
  
  /// Expression régulière pour les URLs
  static final RegExp _urlRegex = RegExp(
    r'https?://(?:[-\w.])+(?:\:[0-9]+)?(?:/(?:[\w/_.])*(?:\?(?:[\w&=%.])*)?(?:\#(?:[\w.])*)?)?',
    caseSensitive: false,
  );

  /// Extrait tous les hashtags d'un texte
  static List<String> extractHashtags(String text) {
    final matches = _hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(0)!.substring(1)).toList(); // Enlever le #
  }

  /// Extrait toutes les mentions d'un texte
  static List<String> extractMentions(String text) {
    final matches = _mentionRegex.allMatches(text);
    return matches.map((match) => match.group(0)!.substring(1)).toList(); // Enlever le @
  }

  /// Extrait toutes les URLs d'un texte
  static List<String> extractUrls(String text) {
    final matches = _urlRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  /// Construit un widget de texte riche avec hashtags, mentions et liens cliquables
  static Widget buildRichText(
    String text, {
    TextStyle? baseStyle,
    TextStyle? hashtagStyle,
    TextStyle? mentionStyle,
    TextStyle? linkStyle,
    Function(String)? onHashtagTap,
    Function(String)? onMentionTap,
    Function(String)? onLinkTap,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    // Trouver tous les éléments spéciaux (hashtags, mentions, liens)
    final List<_SpecialElement> elements = [];
    
    // Ajouter les hashtags
    for (final match in _hashtagRegex.allMatches(text)) {
      elements.add(_SpecialElement(
        start: match.start,
        end: match.end,
        text: match.group(0)!,
        type: _ElementType.hashtag,
      ));
    }
    
    // Ajouter les mentions
    for (final match in _mentionRegex.allMatches(text)) {
      elements.add(_SpecialElement(
        start: match.start,
        end: match.end,
        text: match.group(0)!,
        type: _ElementType.mention,
      ));
    }
    
    // Ajouter les liens
    for (final match in _urlRegex.allMatches(text)) {
      elements.add(_SpecialElement(
        start: match.start,
        end: match.end,
        text: match.group(0)!,
        type: _ElementType.link,
      ));
    }

    // Trier par position dans le texte
    elements.sort((a, b) => a.start.compareTo(b.start));

    // Construire les spans
    for (final element in elements) {
      // Ajouter le texte normal avant l'élément spécial
      if (lastIndex < element.start) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, element.start),
          style: baseStyle,
        ));
      }

      // Ajouter l'élément spécial
      switch (element.type) {
        case _ElementType.hashtag:
          TapGestureRecognizer? hashtagRecognizer;
          if (onHashtagTap != null) {
            hashtagRecognizer = TapGestureRecognizer()
              ..onTap = () {
                try {
                  onHashtagTap(element.text.substring(1));
                } catch (e) {
                  debugPrint('Error in hashtag tap: $e');
                }
              };
          }
          spans.add(TextSpan(
            text: element.text,
            style: hashtagStyle ?? _defaultHashtagStyle,
            recognizer: hashtagRecognizer,
          ));
          break;
        case _ElementType.mention:
          TapGestureRecognizer? mentionRecognizer;
          if (onMentionTap != null) {
            mentionRecognizer = TapGestureRecognizer()
              ..onTap = () {
                try {
                  onMentionTap(element.text.substring(1));
                } catch (e) {
                  debugPrint('Error in mention tap: $e');
                }
              };
          }
          spans.add(TextSpan(
            text: element.text,
            style: mentionStyle ?? _defaultMentionStyle,
            recognizer: mentionRecognizer,
          ));
          break;
        case _ElementType.link:
          TapGestureRecognizer? linkRecognizer;
          if (onLinkTap != null) {
            linkRecognizer = TapGestureRecognizer()
              ..onTap = () {
                try {
                  onLinkTap(element.text);
                } catch (e) {
                  debugPrint('Error in link tap: $e');
                }
              };
          }
          spans.add(TextSpan(
            text: element.text,
            style: linkStyle ?? _defaultLinkStyle,
            recognizer: linkRecognizer,
          ));
          break;
      }

      lastIndex = element.end;
    }

    // Ajouter le texte restant
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  /// Style par défaut pour les hashtags
  static const TextStyle _defaultHashtagStyle = TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.w600,
  );

  /// Style par défaut pour les mentions
  static const TextStyle _defaultMentionStyle = TextStyle(
    color: Colors.purple,
    fontWeight: FontWeight.w600,
  );

  /// Style par défaut pour les liens
  static const TextStyle _defaultLinkStyle = TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  /// Compte le nombre de mots dans un texte
  static int countWords(String text) {
    return text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  /// Compte le nombre de caractères (sans espaces)
  static int countCharacters(String text) {
    return text.replaceAll(' ', '').length;
  }

  /// Tronque un texte à une longueur donnée avec ellipsis
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Nettoie un texte en supprimant les espaces multiples et les retours à la ligne excessifs
  static String cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ') // Remplacer espaces multiples par un seul
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Max 2 retours à la ligne consécutifs
        .trim();
  }

  /// Vérifie si un texte contient des hashtags
  static bool hasHashtags(String text) {
    return _hashtagRegex.hasMatch(text);
  }

  /// Vérifie si un texte contient des mentions
  static bool hasMentions(String text) {
    return _mentionRegex.hasMatch(text);
  }

  /// Vérifie si un texte contient des liens
  static bool hasLinks(String text) {
    return _urlRegex.hasMatch(text);
  }

  /// Remplace les hashtags par des liens cliquables (pour HTML)
  static String hashtagsToLinks(String text, String baseUrl) {
    return text.replaceAllMapped(_hashtagRegex, (match) {
      final hashtag = match.group(0)!.substring(1);
      return '<a href="$baseUrl/hashtag/$hashtag">${match.group(0)}</a>';
    });
  }

  /// Remplace les mentions par des liens cliquables (pour HTML)
  static String mentionsToLinks(String text, String baseUrl) {
    return text.replaceAllMapped(_mentionRegex, (match) {
      final mention = match.group(0)!.substring(1);
      return '<a href="$baseUrl/user/$mention">${match.group(0)}</a>';
    });
  }
}

/// Classe interne pour représenter un élément spécial dans le texte
class _SpecialElement {
  final int start;
  final int end;
  final String text;
  final _ElementType type;

  _SpecialElement({
    required this.start,
    required this.end,
    required this.text,
    required this.type,
  });
}

/// Types d'éléments spéciaux
enum _ElementType {
  hashtag,
  mention,
  link,
}