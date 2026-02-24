import 'package:flutter/material.dart';
import 'result_highlight.dart';

/// Exemple d'utilisation du widget ResultHighlight
/// 
/// Démontre différents cas d'usage :
/// - Recherche simple
/// - Recherche insensible à la casse
/// - Recherche insensible aux accents
/// - Personnalisation des couleurs
/// - Utilisation dans différents contextes
class ResultHighlightExample extends StatefulWidget {
  const ResultHighlightExample({super.key});

  @override
  State<ResultHighlightExample> createState() => _ResultHighlightExampleState();
}

class _ResultHighlightExampleState extends State<ResultHighlightExample> {
  String _searchQuery = 'cafe';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResultHighlight - Exemples'),
        backgroundColor: const Color(0xFF5865F2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ de recherche
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                hintText: 'Entrez un terme de recherche...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Section 1: Recherche insensible à la casse
            _buildSection(
              'Recherche insensible à la casse',
              'Le texte "CAFÉ" correspond à la recherche "cafe"',
              [
                _ExampleCard(
                  title: 'Texte avec majuscules',
                  child: ResultHighlight(
                    text: 'J\'aime boire un bon CAFÉ le matin',
                    query: _searchQuery,
                    textColor: Colors.black87,
                    highlightColor: Colors.yellow.shade300,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 2: Recherche insensible aux accents
            _buildSection(
              'Recherche insensible aux accents',
              'Le texte "café" correspond à la recherche "cafe"',
              [
                _ExampleCard(
                  title: 'Texte avec accents',
                  child: ResultHighlight(
                    text: 'Le café français est délicieux',
                    query: _searchQuery,
                    textColor: Colors.black87,
                    highlightColor: Colors.yellow.shade300,
                  ),
                ),
                _ExampleCard(
                  title: 'Multiples occurrences',
                  child: ResultHighlight(
                    text: 'Café, café, café ! J\'adore le café.',
                    query: _searchQuery,
                    textColor: Colors.black87,
                    highlightColor: Colors.yellow.shade300,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 3: Personnalisation des couleurs
            _buildSection(
              'Personnalisation des couleurs',
              'Différents styles de highlighting',
              [
                _ExampleCard(
                  title: 'Style Discord (bleu)',
                  backgroundColor: const Color(0xFF2C2F33),
                  child: ResultHighlight(
                    text: 'Rejoignez notre serveur Discord pour discuter de café',
                    query: _searchQuery,
                    textColor: Colors.white,
                    highlightColor: const Color(0xFF5865F2),
                    highlightTextColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
                _ExampleCard(
                  title: 'Style Telegram (vert)',
                  child: ResultHighlight(
                    text: 'Envoyez un message sur Telegram pour commander du café',
                    query: _searchQuery,
                    textColor: Colors.black87,
                    highlightColor: Colors.green.shade200,
                    highlightTextColor: Colors.green.shade900,
                  ),
                ),
                _ExampleCard(
                  title: 'Style personnalisé (orange)',
                  child: ResultHighlight(
                    text: 'Le café est prêt ! Venez le chercher.',
                    query: _searchQuery,
                    textColor: Colors.black87,
                    highlightColor: Colors.orange.shade300,
                    highlightTextColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 4: Cas d'usage réels
            _buildSection(
              'Cas d\'usage réels',
              'Exemples dans différents contextes',
              [
                _ExampleCard(
                  title: 'Message de chat',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF5865F2),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Marie',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ResultHighlight(
                              text: 'On se retrouve au café à 15h ?',
                              query: _searchQuery,
                              textColor: Colors.black87,
                              highlightColor: Colors.yellow.shade300,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _ExampleCard(
                  title: 'Résultat de recherche',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jean',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '14:30',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ResultHighlight(
                        text: 'Le café du coin fait les meilleurs expressos de la ville',
                        query: _searchQuery,
                        textColor: Colors.black87,
                        highlightColor: const Color(0xFF5865F2),
                        highlightTextColor: Colors.white,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _ExampleCard(
                  title: 'Liste de documents',
                  child: Row(
                    children: [
                      Icon(Icons.description, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ResultHighlight(
                          text: 'Recette_cafe_latte.pdf',
                          query: _searchQuery,
                          textColor: Colors.black87,
                          highlightColor: Colors.blue.shade200,
                          highlightTextColor: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 5: Cas limites
            _buildSection(
              'Cas limites',
              'Gestion des cas particuliers',
              [
                _ExampleCard(
                  title: 'Requête vide',
                  child: ResultHighlight(
                    text: 'Texte sans highlighting car la requête est vide',
                    query: '',
                    textColor: Colors.black87,
                  ),
                ),
                _ExampleCard(
                  title: 'Aucune correspondance',
                  child: ResultHighlight(
                    text: 'Ce texte ne contient pas le mot recherché',
                    query: 'xyz123',
                    textColor: Colors.black87,
                    highlightColor: Colors.yellow.shade300,
                  ),
                ),
                _ExampleCard(
                  title: 'Texte long avec maxLines',
                  child: ResultHighlight(
                    text: 'Le café est une boisson énergisante préparée à partir '
                        'des graines torréfiées de diverses espèces de caféiers. '
                        'Le café est l\'une des boissons les plus consommées au monde.',
                    query: _searchQuery,
                    textColor: Colors.black87,
                    highlightColor: Colors.yellow.shade300,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, List<Widget> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        ...examples,
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? backgroundColor;

  const _ExampleCard({
    required this.title,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: backgroundColor != null ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
