import 'package:flutter/material.dart';
import 'package:flow/core/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flow/models/quiz_deck.dart';
import 'package:flow/services/storage_service.dart';
import 'package:flow/features/quiz/mcq_quiz_screen.dart';
import 'package:flow/features/library/reading_screen.dart';
import 'package:flow/features/flashcard_review_screen.dart';
import 'package:flow/features/create/create_screen.dart';
import 'package:flow/services/streak_service.dart';
import 'package:flow/widgets/cauri_icon.dart';
import 'package:flutter/services.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<QuizDeck> _decks = [];
  bool _isLoading = true;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadDecks();
    _initStreak();
  }

  Future<void> _initStreak() async {
    final service = StreakService();
    await service.updateStreak();
    final streak = await service.getStreak();
    setState(() => _streak = streak);
  }

  Future<void> _loadDecks() async {
    setState(() => _isLoading = true);
    final decks = await StorageService().getDecks();
    setState(() {
      _decks = decks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Subtle Dynamic Background
          Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.8, -0.6),
                        radius: 1.2,
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: 10,
                end: -10,
                duration: 6.seconds,
                curve: Curves.easeInOut,
              ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.black.withOpacity(0.1),
                          ),
                        )
                      : _buildDeckGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bibliothèque',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildStreakBadge(),
                  const SizedBox(width: 8),
                  Text(
                    '${_decks.length} packs',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
          Row(
            children: [
              _buildRoundButton(
                icon: Icons.refresh_rounded,
                onTap: _loadDecks,
                delay: 400,
              ),
              const SizedBox(width: 12),
              _buildRoundButton(
                icon: Icons.add_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateScreen(),
                    ),
                  ).then((_) => _loadDecks());
                },
                isPrimary: true,
                delay: 600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color contentColor = isDark ? Colors.white : const Color(0xFF92400E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : const Color(0xFFFDE68A),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CauriIcon(size: 18, color: contentColor),
          const SizedBox(width: 6),
          Text(
            '$_streak',
            style: TextStyle(
              color: contentColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
    int delay = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child:
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPrimary
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.3
                        : 0.05,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isPrimary
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ).animate().scale(
            delay: delay.ms,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildDeckGrid() {
    if (_decks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun deck pour le moment',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Pour naviguer vers l'onglet de création, on peut utiliser
                // DefaultTabController ou simplement informer l'utilisateur.
                // Ici on va simuler un clic sur l'onglet central.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Appuie sur le bouton "+" en bas pour créer !',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Créer mon premier quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _decks.length,
      itemBuilder: (context, index) {
        return _buildDeckCard(_decks[index], index);
      },
    );
  }

  Widget _buildDeckCard(QuizDeck deck, int index) {
    return GestureDetector(
      onTap: () => _showDeckOptions(deck),
      onLongPress: () => _showDeleteDialog(deck),
      child:
          Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.3
                            : 0.02,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.collections_bookmark_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      deck.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Barre de progression
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${deck.cards.length} cartes',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(deck.masteryProgress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: deck.masteryProgress,
                            backgroundColor: AppTheme.primaryColor.withOpacity(
                              0.05,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: (100 * index).ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
    );
  }

  void _showDeckOptions(QuizDeck deck) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              deck.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            _buildOptionItem(
              icon: Icons.style_rounded,
              label: 'Réviser (Fiches)',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardReviewScreen(deck: deck),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionItem(
              icon: Icons.quiz_rounded,
              label: 'S\'entraîner (QCM)',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MCQQuizScreen(deck: deck),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionItem(
              icon: Icons.menu_book_rounded,
              label: 'Lire le cours',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingScreen(deck: deck),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
          ),
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(QuizDeck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce deck ?'),
        content: Text('Voulez-vous vraiment supprimer "${deck.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService().deleteDeck(deck.id);
              Navigator.pop(context);
              _loadDecks();
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
