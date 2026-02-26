import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/search/search_result.dart';
import '../models/search/text_range.dart';

/// Provider pour la recherche dans les messages
/// Gère la recherche en temps réel et le filtrage
class MessageSearchProvider extends ChangeNotifier {
  // État privé
  String _query = '';
  List<SearchResult> _results = [];
  Set<MessageType> _activeFilters = {};
  int _currentResultIndex = -1;
  String _currentChatId = '';

  // Getters publics
  String get query => _query;
  List<SearchResult> get results => List.unmodifiable(_results);
  int get resultCount => _results.length;
  int get currentResultIndex => _currentResultIndex;
  Set<MessageType> get activeFilters => Set.unmodifiable(_activeFilters);
  
  /// Vérifie si la requête est valide (longueur suffisante)
  bool get isQueryValid => _query.length >= minQueryLength;
  
  /// Vérifie si la recherche a été effectuée et n'a trouvé aucun résultat
  bool get hasNoResults => _query.length >= minQueryLength && _results.isEmpty;

  /// Longueur minimale de la requête pour déclencher une recherche
  static const int minQueryLength = 2;

  /// Recherche dans les messages d'une conversation
  /// 
  /// Effectue une recherche case-insensitive dans tous les messages
  /// de la conversation spécifiée. Applique les filtres actifs si présents.
  /// 
  /// **Gestion d'erreurs:**
  /// - Query vide: Efface les résultats et affiche placeholder
  /// - Query trop courte (<2 chars): N'effectue pas la recherche
  /// - Aucun résultat: Affiche message approprié
  /// 
  /// [query] - Le texte à rechercher
  /// [chatId] - L'ID de la conversation dans laquelle rechercher
  /// [messages] - La liste des messages à parcourir
  void search(String query, String chatId, List<MessageModel> messages) {
    _query = query.trim();
    _currentChatId = chatId;
    _results.clear();
    _currentResultIndex = -1;

    // Si la requête est vide, on ne fait rien
    if (_query.isEmpty) {
      notifyListeners();
      return;
    }

    // Si la requête est trop courte, on ne lance pas la recherche
    // L'UI affichera un message demandant plus de caractères
    if (_query.length < minQueryLength) {
      notifyListeners();
      return;
    }

    // Normaliser la requête pour la recherche case-insensitive
    final normalizedQuery = _query.toLowerCase();

    // Parcourir tous les messages
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];

      // Appliquer les filtres de type si actifs
      if (_activeFilters.isNotEmpty && !_activeFilters.contains(message.type)) {
        continue;
      }

      // Rechercher dans le texte du message (case-insensitive)
      final normalizedText = message.text.toLowerCase();
      
      if (normalizedText.contains(normalizedQuery)) {
        // Calculer les ranges de highlight
        final highlightRanges = _calculateHighlightRanges(
          message.text,
          _query,
        );

        // Ajouter le résultat
        _results.add(SearchResult(
          message: message,
          chatId: chatId,
          matchIndex: i,
          highlightRanges: highlightRanges,
        ));
      }
    }

    // Si on a des résultats, positionner sur le premier
    if (_results.isNotEmpty) {
      _currentResultIndex = 0;
    }

    notifyListeners();
  }

  /// Calcule les ranges de texte à highlighter dans un message
  /// 
  /// Trouve toutes les occurrences de la requête dans le texte
  /// et retourne les positions pour le highlighting.
  List<TextRange> _calculateHighlightRanges(String text, String query) {
    final ranges = <TextRange>[];
    final normalizedText = text.toLowerCase();
    final normalizedQuery = query.toLowerCase();
    
    int startIndex = 0;
    while (true) {
      final index = normalizedText.indexOf(normalizedQuery, startIndex);
      if (index == -1) break;
      
      ranges.add(TextRange(
        start: index,
        end: index + query.length,
      ));
      startIndex = index + query.length;
    }
    
    return ranges;
  }

  /// Applique un filtre par type de message
  /// 
  /// Ajoute le type spécifié aux filtres actifs et relance
  /// la recherche si une requête est en cours.
  void applyFilter(MessageType type) {
    if (_activeFilters.add(type)) {
      // Si on a une recherche en cours, la relancer avec le nouveau filtre
      if (_query.isNotEmpty && _currentChatId.isNotEmpty) {
        // Note: On ne peut pas relancer la recherche ici car on n'a pas
        // accès aux messages. Le widget appelant doit relancer search()
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  /// Retire un filtre par type de message
  /// 
  /// Supprime le type spécifié des filtres actifs et relance
  /// la recherche si une requête est en cours.
  void removeFilter(MessageType type) {
    if (_activeFilters.remove(type)) {
      // Si on a une recherche en cours, la relancer sans ce filtre
      if (_query.isNotEmpty && _currentChatId.isNotEmpty) {
        // Note: On ne peut pas relancer la recherche ici car on n'a pas
        // accès aux messages. Le widget appelant doit relancer search()
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  /// Efface tous les filtres actifs
  void clearFilters() {
    if (_activeFilters.isNotEmpty) {
      _activeFilters.clear();
      notifyListeners();
    }
  }

  /// Navigue vers le résultat suivant
  /// 
  /// Avec wrapping : si on est au dernier résultat, revient au premier.
  void navigateToNext() {
    if (_results.isEmpty) return;

    _currentResultIndex = (_currentResultIndex + 1) % _results.length;
    notifyListeners();
  }

  /// Navigue vers le résultat précédent
  /// 
  /// Avec wrapping : si on est au premier résultat, va au dernier.
  void navigateToPrevious() {
    if (_results.isEmpty) return;

    _currentResultIndex = (_currentResultIndex - 1 + _results.length) % _results.length;
    notifyListeners();
  }

  /// Efface la recherche et réinitialise l'état
  void clear() {
    _query = '';
    _results.clear();
    _currentResultIndex = -1;
    _currentChatId = '';
    _activeFilters.clear();
    notifyListeners();
  }

  /// Obtient le résultat actuellement sélectionné
  SearchResult? get currentResult {
    if (_currentResultIndex >= 0 && _currentResultIndex < _results.length) {
      return _results[_currentResultIndex];
    }
    return null;
  }
}
