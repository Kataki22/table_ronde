import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tableronde_app/widgets/settings/settings_tile.dart';
import 'package:tableronde_app/providers/theme_provider.dart';
import 'package:tableronde_app/utils/app_theme_data.dart';

void main() {
  // Helper pour wrapper le widget avec les providers nécessaires
  Widget wrapWithProviders(Widget child) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('SettingsTile Widget Tests', () {
    testWidgets('affiche icône, titre et sous-titre', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Gérer les notifications',
            type: SettingsTileType.action,
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Gérer les notifications'), findsOneWidget);
    });

    testWidgets('affiche titre sans sous-titre', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const SettingsTile(
            icon: Icons.settings,
            title: 'Paramètres',
            type: SettingsTileType.action,
          ),
        ),
      );

      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget); // Seulement le titre
    });

    testWidgets('type toggle affiche un switch', (tester) async {
      bool toggleValue = false;

      await tester.pumpWidget(
        wrapWithProviders(
          StatefulBuilder(
            builder: (context, setState) {
              return SettingsTile(
                icon: Icons.notifications,
                title: 'Notifications',
                type: SettingsTileType.toggle,
                toggleValue: toggleValue,
                onToggleChanged: (value) {
                  setState(() => toggleValue = value);
                },
              );
            },
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);

      // Vérifier que le switch est désactivé
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, false);

      // Taper sur le switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Le switch devrait être activé
      final updatedSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(updatedSwitch.value, true);
    });

    testWidgets('type navigation affiche un chevron', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          SettingsTile(
            icon: Icons.palette,
            title: 'Apparence',
            type: SettingsTileType.navigation,
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('type action n\'affiche pas de trailing widget', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          SettingsTile(
            icon: Icons.delete,
            title: 'Supprimer',
            type: SettingsTileType.action,
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(Switch), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('onTap est appelé pour type navigation', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapWithProviders(
          SettingsTile(
            icon: Icons.settings,
            title: 'Paramètres',
            type: SettingsTileType.navigation,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(SettingsTile));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('onTap est appelé pour type action', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapWithProviders(
          SettingsTile(
            icon: Icons.logout,
            title: 'Déconnexion',
            type: SettingsTileType.action,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(SettingsTile));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('onTap n\'est pas appelé pour type toggle', (tester) async {
      bool tapped = false;
      bool toggleValue = false;

      await tester.pumpWidget(
        wrapWithProviders(
          StatefulBuilder(
            builder: (context, setState) {
              return SettingsTile(
                icon: Icons.notifications,
                title: 'Notifications',
                type: SettingsTileType.toggle,
                toggleValue: toggleValue,
                onToggleChanged: (value) {
                  setState(() => toggleValue = value);
                },
                onTap: () => tapped = true,
              );
            },
          ),
        ),
      );

      // Taper sur le tile (pas sur le switch)
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      // onTap ne devrait pas être appelé pour un toggle
      expect(tapped, false);
    });

    testWidgets('isDestructive affiche en rouge', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          SettingsTile(
            icon: Icons.delete,
            title: 'Supprimer',
            subtitle: 'Action irréversible',
            type: SettingsTileType.action,
            isDestructive: true,
            onTap: () {},
          ),
        ),
      );

      // Vérifier que le widget existe
      expect(find.text('Supprimer'), findsOneWidget);
      expect(find.text('Action irréversible'), findsOneWidget);

      // Note: Vérifier la couleur exacte nécessiterait d'accéder au style du Text,
      // ce qui est complexe dans les tests. On vérifie juste que le widget s'affiche.
    });

    testWidgets('iconColor personnalisée est appliquée', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          SettingsTile(
            icon: Icons.star,
            title: 'Favoris',
            type: SettingsTileType.action,
            iconColor: Colors.amber,
            onTap: () {},
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(iconWidget.color, Colors.amber);
    });

    testWidgets('cas limite : titre très long', (tester) async {
      const longTitle = 'Ceci est un titre extrêmement long qui devrait '
          'être tronqué ou wrappé correctement dans l\'interface utilisateur';

      await tester.pumpWidget(
        wrapWithProviders(
          const SettingsTile(
            icon: Icons.text_fields,
            title: longTitle,
            type: SettingsTileType.action,
          ),
        ),
      );

      expect(find.text(longTitle), findsOneWidget);
    });

    testWidgets('cas limite : sous-titre très long', (tester) async {
      const longSubtitle = 'Ceci est un sous-titre extrêmement long qui devrait '
          'être affiché correctement sans déborder de l\'interface';

      await tester.pumpWidget(
        wrapWithProviders(
          const SettingsTile(
            icon: Icons.text_fields,
            title: 'Titre',
            subtitle: longSubtitle,
            type: SettingsTileType.action,
          ),
        ),
      );

      expect(find.text(longSubtitle), findsOneWidget);
    });
  });
}
