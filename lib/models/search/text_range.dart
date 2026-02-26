/// Modèle représentant une plage de texte pour le surlignage
/// 
/// Utilisé pour marquer les portions de texte qui correspondent
/// à une recherche, permettant de les surligner dans l'interface.
class TextRange {
  /// Position de début de la plage (inclusive)
  final int start;
  
  /// Position de fin de la plage (exclusive)
  final int end;
  
  /// Type de correspondance (optionnel)
  /// Peut être utilisé pour différents styles de surlignage
  final String? type;
  
  /// Texte correspondant (optionnel, pour debug/cache)
  final String? matchedText;

  const TextRange({
    required this.start,
    required this.end,
    this.type,
    this.matchedText,
  }) : assert(start >= 0 && end >= start, 'Invalid range: start=$start, end=$end');

  /// Crée une copie avec les champs modifiés
  TextRange copyWith({
    int? start,
    int? end,
    String? type,
    String? matchedText,
  }) {
    return TextRange(
      start: start ?? this.start,
      end: end ?? this.end,
      type: type ?? this.type,
      matchedText: matchedText ?? this.matchedText,
    );
  }

  /// Longueur de la plage
  int get length => end - start;
  
  /// Vérifie si la plage est valide
  bool get isValid => start >= 0 && end >= start;
  
  /// Vérifie si la plage est vide
  bool get isEmpty => start == end;
  
  /// Vérifie si cette plage contient la position donnée
  bool contains(int position) {
    return position >= start && position < end;
  }
  
  /// Vérifie si cette plage chevauche avec une autre
  bool overlaps(TextRange other) {
    return start < other.end && end > other.start;
  }
  
  /// Vérifie si cette plage est adjacente à une autre
  bool isAdjacentTo(TextRange other) {
    return end == other.start || start == other.end;
  }
  
  /// Fusionne cette plage avec une autre si elles se chevauchent ou sont adjacentes
  TextRange? mergeWith(TextRange other) {
    if (overlaps(other) || isAdjacentTo(other)) {
      return TextRange(
        start: start < other.start ? start : other.start,
        end: end > other.end ? end : other.end,
        type: type ?? other.type,
      );
    }
    return null;
  }
  
  /// Extrait le texte correspondant depuis une chaîne source
  String extractFrom(String source) {
    if (start >= source.length || end > source.length) {
      return '';
    }
    return source.substring(start, end);
  }

  /// Crée un TextRange depuis JSON
  factory TextRange.fromJson(Map<String, dynamic> json) {
    return TextRange(
      start: json['start'] as int,
      end: json['end'] as int,
      type: json['type'] as String?,
      matchedText: json['matchedText'] as String?,
    );
  }

  /// Convertit ce TextRange en JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      if (type != null) 'type': type,
      if (matchedText != null) 'matchedText': matchedText,
    };
  }

  /// Crée une liste de TextRange fusionnées depuis une liste non triée
  static List<TextRange> mergeOverlapping(List<TextRange> ranges) {
    if (ranges.isEmpty) return [];
    
    // Trier par position de début
    final sorted = List<TextRange>.from(ranges)
      ..sort((a, b) => a.start.compareTo(b.start));
    
    final merged = <TextRange>[sorted.first];
    
    for (int i = 1; i < sorted.length; i++) {
      final current = sorted[i];
      final last = merged.last;
      
      final mergedRange = last.mergeWith(current);
      if (mergedRange != null) {
        merged[merged.length - 1] = mergedRange;
      } else {
        merged.add(current);
      }
    }
    
    return merged;
  }
  
  /// Crée des TextRange depuis une liste de correspondances regex
  static List<TextRange> fromMatches(
    String source,
    Pattern pattern, {
    String? type,
  }) {
    final ranges = <TextRange>[];
    final matches = pattern.allMatches(source);
    
    for (final match in matches) {
      ranges.add(TextRange(
        start: match.start,
        end: match.end,
        type: type,
        matchedText: match.group(0),
      ));
    }
    
    return ranges;
  }
  
  /// Crée des TextRange pour toutes les occurrences d'un terme
  static List<TextRange> fromSearchTerm(
    String source,
    String searchTerm, {
    bool caseSensitive = false,
    String? type,
  }) {
    if (searchTerm.isEmpty) return [];
    
    final ranges = <TextRange>[];
    final sourceToSearch = caseSensitive ? source : source.toLowerCase();
    final termToSearch = caseSensitive ? searchTerm : searchTerm.toLowerCase();
    
    int startIndex = 0;
    while (true) {
      final index = sourceToSearch.indexOf(termToSearch, startIndex);
      if (index == -1) break;
      
      ranges.add(TextRange(
        start: index,
        end: index + searchTerm.length,
        type: type,
        matchedText: source.substring(index, index + searchTerm.length),
      ));
      
      startIndex = index + 1;
    }
    
    return ranges;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextRange &&
        other.start == start &&
        other.end == end &&
        other.type == type;
  }

  @override
  int get hashCode {
    return start.hashCode ^ end.hashCode ^ type.hashCode;
  }

  @override
  String toString() {
    return 'TextRange(start: $start, end: $end, length: $length${type != null ? ', type: $type' : ''}${matchedText != null ? ', text: "$matchedText"' : ''})';
  }
}