import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tableronde_app/providers/message_search_provider.dart';
import 'package:tableronde_app/screens/search/search_overlay.dart';
import 'package:tableronde_app/models/chat_model.dart';

void main() {
  group('SearchOverlay - Error Handling', () {
    late MessageSearchProvider provider;
    late List<MessageModel> mockMessages;

    setUp(() {
      provider = MessageSearchProvider();
      
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
      ];
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<MessageSearchProvider>.value(
          value: provider,
          child: Scaffold(
            body: SearchOverlay(
              onResultTap: (index) {},
            ),
          ),
        ),
      );
    }

    testWidgets('should show nothing when query is empty', (tester) async {
      // Ne pas effectuer de recherche (query vide)
      await tester.pumpWidget(createTestWidget());

      // Vérifier que l'overlay n'est pas affiché
      expect(find.byType(SearchOverlay), findsOneWidget);
      expect(find.text('Rechercher dans la conversation'), findsNothing);
    });

    testWidgets('should show min query state when query is too short', (tester) async {
      // Effectuer une recherche avec query trop courte
      provider.search('a', 'chat1', mockMessages);
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Vérifier que le message de query trop courte est affiché
      expect(find.text('Rechercher dans la conversation'), findsOneWidget);
      expect(find.text('Saisissez au moins 2 caractères\npour lancer la recherche'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should show empty state when no results found', (tester) async {
      // Effectuer une recherche qui ne trouve rien
      provider.search('xyz123', 'chat1', mockMessages);
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Vérifier que le message "aucun résultat" est affiché
      expect(find.text('Aucun résultat trouvé'), findsOneWidget);
      expect(find.text('pour "xyz123"'), findsOneWidget);
      expect(find.text('Essayez avec d\'autres mots-clés ou\nmodifiez les filtres de recherche'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('should show results when search succeeds', (tester) async {
      // Effectuer une recherche qui trouve des résultats
      provider.search('bonjour', 'chat1', mockMessages);
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Vérifier que les résultats sont affichés
      expect(find.text('Aucun résultat trouvé'), findsNothing);
      expect(find.text('Rechercher dans la conversation'), findsNothing);
      
      // Vérifier que la navigation bar est affichée
      expect(find.text('Résultat 1 sur 1'), findsOneWidget);
    });

    testWidgets('should transition from min query to results', (tester) async {
      // Commencer avec query trop courte
      provider.search('b', 'chat1', mockMessages);
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Vérifier l'état initial
      expect(find.text('Rechercher dans la conversation'), findsOneWidget);

      // Mettre à jour avec une query valide
      provider.search('bonjour', 'chat1', mockMessages);
      await tester.pump();

      // Vérifier que les résultats sont maintenant affichés
      expect(find.text('Rechercher dans la conversation'), findsNothing);
      expect(find.text('Résultat 1 sur 1'), findsOneWidget);
    });

    testWidgets('should transition from results to empty state', (tester) async {
      // Commencer avec des résultats
      provider.search('bonjour', 'chat1', mockMessages);
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Vérifier l'état initial
      expect(find.text('Résultat 1 sur 1'), findsOneWidget);

      // Mettre à jour avec une query qui ne trouve rien
      provider.search('xyz123', 'chat1', mockMessages);
      await tester.pump();

      // Vérifier que l'état vide est affiché
      expect(find.text('Résultat 1 sur 1'), findsNothing);
      expect(find.text('Aucun résultat trouvé'), findsOneWidget);
    });
  });
}
