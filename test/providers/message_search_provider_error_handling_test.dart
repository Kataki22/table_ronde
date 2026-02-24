import 'package:flutter_test/flutter_test.dart';
import 'package:tableronde_app/providers/message_search_provider.dart';
import 'package:tableronde_app/models/chat_model.dart';

void main() {
  group('MessageSearchProvider - Error Handling', () {
    late MessageSearchProvider provider;
    late List<MessageModel> mockMessages;

    setUp(() {
      provider = MessageSearchProvider();
      
      // Créer des messages de test
      mockMessages = [
        MessageModel(
          id: '1',
          text: 'Bonjour tout le monde',
          isSentByMe: true,
          timestamp: DateTime.now(),
          isRead: true,
          type: MessageType.text,
        ),
        MessageModel(
          id: '2',
          text: 'Comment allez-vous?',
          isSentByMe: false,
          timestamp: DateTime.now(),
          isRead: true,
          type: MessageType.text,
        ),
        MessageModel(
          id: '3',
          text: 'Très bien merci!',
          isSentByMe: true,
          timestamp: DateTime.now(),
          isRead: true,
          type: MessageType.text,
        ),
      ];
    });

    test('should handle empty query', () {
      // Recherche avec query vide
      provider.search('', 'chat1', mockMessages);

      // Vérifier que la query est vide
      expect(provider.query, isEmpty);
      
      // Vérifier qu'aucun résultat n'est retourné
      expect(provider.results, isEmpty);
      expect(provider.resultCount, 0);
      expect(provider.currentResultIndex, -1);
    });

    test('should handle query with only whitespace', () {
      // Recherche avec query contenant seulement des espaces
      provider.search('   ', 'chat1', mockMessages);

      // Vérifier que la query est vide après trim
      expect(provider.query, isEmpty);
      
      // Vérifier qu'aucun résultat n'est retourné
      expect(provider.results, isEmpty);
      expect(provider.resultCount, 0);
    });

    test('should not search with query too short (< 2 chars)', () {
      // Recherche avec 1 caractère
      provider.search('a', 'chat1', mockMessages);

      // Vérifier que la query est enregistrée
      expect(provider.query, 'a');
      
      // Vérifier que isQueryValid retourne false
      expect(provider.isQueryValid, false);
      
      // Vérifier qu'aucun résultat n'est retourné
      expect(provider.results, isEmpty);
      expect(provider.resultCount, 0);
    });

    test('should search with query of exactly 2 chars', () {
      // Recherche avec 2 caractères
      provider.search('Bo', 'chat1', mockMessages);

      // Vérifier que la query est enregistrée
      expect(provider.query, 'Bo');
      
      // Vérifier que isQueryValid retourne true
      expect(provider.isQueryValid, true);
      
      // Vérifier qu'un résultat est trouvé
      expect(provider.results, isNotEmpty);
      expect(provider.resultCount, 1);
    });

    test('should indicate no results when search finds nothing', () {
      // Recherche qui ne trouve rien
      provider.search('xyz123', 'chat1', mockMessages);

      // Vérifier que la query est valide
      expect(provider.isQueryValid, true);
      
      // Vérifier que hasNoResults retourne true
      expect(provider.hasNoResults, true);
      
      // Vérifier qu'aucun résultat n'est retourné
      expect(provider.results, isEmpty);
      expect(provider.resultCount, 0);
    });

    test('should indicate results found when search succeeds', () {
      // Recherche qui trouve des résultats
      provider.search('bien', 'chat1', mockMessages);

      // Vérifier que la query est valide
      expect(provider.isQueryValid, true);
      
      // Vérifier que hasNoResults retourne false
      expect(provider.hasNoResults, false);
      
      // Vérifier que des résultats sont retournés
      expect(provider.results, isNotEmpty);
      expect(provider.resultCount, greaterThan(0));
    });

    test('should handle case-insensitive search', () {
      // Recherche case-insensitive
      provider.search('BONJOUR', 'chat1', mockMessages);

      // Vérifier qu'un résultat est trouvé
      expect(provider.results, isNotEmpty);
      expect(provider.resultCount, 1);
      expect(provider.results.first.message.text, 'Bonjour tout le monde');
    });

    test('should handle accented characters', () {
      // Ajouter un message avec accents
      final messagesWithAccents = [
        ...mockMessages,
        MessageModel(
          id: '4',
          text: 'Café français',
          isSentByMe: true,
          timestamp: DateTime.now(),
          isRead: true,
          type: MessageType.text,
        ),
      ];

      // Recherche avec accents
      provider.search('café', 'chat1', messagesWithAccents);

      // Vérifier qu'un résultat est trouvé
      expect(provider.results, isNotEmpty);
      expect(provider.resultCount, 1);
    });

    test('minQueryLength constant should be 2', () {
      // Vérifier que la constante est bien définie à 2
      expect(MessageSearchProvider.minQueryLength, 2);
    });
  });
}
