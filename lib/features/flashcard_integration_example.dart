import 'package:flutter/material.dart';
import 'package:flow/models/flashcard.dart';
import 'package:flow/widgets/flashcard_card.dart';

/// Exemple d'intégration du widget FlashcardCard avec le modèle Flashcard existant
class FlashcardIntegrationExample extends StatefulWidget {
  const FlashcardIntegrationExample({super.key});

  @override
  State<FlashcardIntegrationExample> createState() =>
      _FlashcardIntegrationExampleState();
}

class _FlashcardIntegrationExampleState
    extends State<FlashcardIntegrationExample> {
  int currentIndex = 0;
  final List<Flashcard> flashcards = Flashcard.mockList();

  // Réponses correspondant aux flashcards
  final Map<String, String> answers = {
    '1':
        'Le krack de 1929 fait suite à la première Guerre mondiale et une période de surproduction et de forte spéculation. Les causes principales incluent:\n\n• Surproduction industrielle et agricole\n• Spéculation boursière excessive\n• Crédit facile et surendettement\n• Déséquilibres économiques internationaux',
    '2':
        'Les principales figures de style en français sont:\n\n• Métaphore: comparaison implicite\n• Comparaison: rapprochement explicite avec "comme"\n• Personnification: attributs humains à l\'inanimé\n• Hyperbole: exagération\n• Euphémisme: atténuation\n• Antithèse: opposition de deux idées',
    '3':
        'Le théorème de Pythagore énonce que dans un triangle rectangle, le carré de l\'hypoténuse est égal à la somme des carrés des deux autres côtés.\n\nFormule: a² + b² = c²\n\noù c est l\'hypoténuse (côté opposé à l\'angle droit) et a et b sont les deux autres côtés.',
    '4':
        'La Révolution française (1789-1799) est une période majeure de l\'histoire de France marquée par:\n\n• La fin de la monarchie absolue\n• La Déclaration des Droits de l\'Homme et du Citoyen\n• La prise de la Bastille (14 juillet 1789)\n• L\'exécution de Louis XVI\n• L\'établissement de la République',
    '5':
        'Present Perfect vs Past Simple:\n\n**Present Perfect** (have/has + participe passé):\n• Action passée liée au présent\n• "I have lived here for 5 years"\n\n**Past Simple** (verbe au prétérit):\n• Action passée terminée\n• "I lived there in 2010"',
  };

  void _nextCard() {
    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFlashcard = flashcards[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentFlashcard.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Flashcard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: FlashcardCard(
                  flashcard: currentFlashcard,
                  answer: answers[currentFlashcard.id],
                  currentIndex: currentIndex,
                  totalCards: flashcards.length,
                  onFlip: () {
                    debugPrint('Carte ${currentFlashcard.id} retournée');
                  },
                ),
              ),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    Icons.favorite_rounded,
                    currentFlashcard.likes.toString(),
                    Colors.red.shade400,
                  ),
                  _buildStatItem(
                    Icons.chat_bubble_rounded,
                    currentFlashcard.comments.toString(),
                    Colors.blue.shade400,
                  ),
                  _buildStatItem(
                    Icons.bookmark_rounded,
                    currentFlashcard.bookmarks.toString(),
                    Colors.orange.shade400,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  _buildNavButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: currentIndex > 0 ? _previousCard : null,
                  ),

                  // Card counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '${currentIndex + 1} / ${flashcards.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),

                  // Next button
                  _buildNavButton(
                    icon: Icons.arrow_forward_rounded,
                    onPressed: currentIndex < flashcards.length - 1
                        ? _nextCard
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Difficile',
                      color: const Color(0xFFEF4444), // red-500
                      icon: Icons.close_rounded,
                      onPressed: () {
                        debugPrint('Carte marquée comme difficile');
                        _nextCard();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Moyen',
                      color: const Color(0xFFF59E0B), // amber-500
                      icon: Icons.remove_rounded,
                      onPressed: () {
                        debugPrint('Carte marquée comme moyenne');
                        _nextCard();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Facile',
                      color: const Color(0xFF10B981), // green-500
                      icon: Icons.check_rounded,
                      onPressed: () {
                        debugPrint('Carte marquée comme facile');
                        _nextCard();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            count,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null ? Colors.white : Colors.grey.shade100,
        shape: BoxShape.circle,
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed != null
              ? const Color(0xFF111827)
              : Colors.grey.shade400,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
