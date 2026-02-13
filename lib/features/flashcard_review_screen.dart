import 'package:flutter/material.dart';
import 'package:flow/widgets/flashcard_widget.dart';
import 'package:flow/models/quiz_deck.dart';
import 'package:flow/services/storage_service.dart';
import 'package:flow/core/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FlashcardReviewScreen extends StatefulWidget {
  final QuizDeck deck;
  const FlashcardReviewScreen({super.key, required this.deck});

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen> {
  int currentIndex = 0;
  int _correctCount = 0;
  int _easyCount = 0;
  int _revoirCount = 0;
  bool _isFinished = false;

  Future<void> _handleAction(String type) async {
    int quality = 3;
    if (type == 'revoir') quality = 1;
    if (type == 'easy') quality = 5;

    // Retour haptique
    HapticFeedback.lightImpact();

    // Mise à jour de la carte avec l'algorithme SM-2
    final currentCard = widget.deck.cards[currentIndex];
    final updatedCard = currentCard.updateReview(quality);

    // Sauvegarde immédiate
    await StorageService().updateCard(updatedCard);

    setState(() {
      if (type == 'correct') _correctCount++;
      if (type == 'easy') _easyCount++;
      if (type == 'revoir') _revoirCount++;

      if (currentIndex < widget.deck.cards.length - 1) {
        currentIndex++;
      } else {
        _isFinished = true;
        HapticFeedback.vibrate(); // Vibration finale
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildResultView();
    }

    double progress = (currentIndex + 1) / widget.deck.cards.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              widget.deck.title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Première',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.circle,
                  size: 4,
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'SES',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child:
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.black.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                minHeight: 4,
              ).animate().fadeIn().scaleX(
                begin: 0,
                alignment: Alignment.centerLeft,
              ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Card container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: FlashcardWidget(
                  question: widget.deck.cards[currentIndex].question,
                  answer: widget.deck.cards[currentIndex].answer,
                  subject: 'Révision',
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: Text(
                  '${currentIndex + 1}/${widget.deck.cards.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'À revoir',
                      color: Colors.red.withOpacity(0.1),
                      textColor: Colors.red,
                      onPressed: () => _handleAction('revoir'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Correct',
                      color: Colors.green.withOpacity(0.1),
                      textColor: Colors.green,
                      onPressed: () => _handleAction('correct'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Facile',
                      color: Colors.blue.withOpacity(0.1),
                      textColor: Colors.blue,
                      onPressed: () => _handleAction('easy'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    int total = widget.deck.cards.length;
    double scoreValue = ((_correctCount + _easyCount) / total) * 100;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 32),
              Text(
                'Session Terminée !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Score : ${scoreValue.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryColor,
                ),
              ).animate().fadeIn(delay: 400.ms).scale(),
              const SizedBox(height: 8),
              Text(
                'Tu as révisé $total fiches',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 48),
              _buildResultRow(
                label: 'À revoir',
                count: _revoirCount,
                color: Colors.red.shade400,
                icon: Icons.refresh_rounded,
              ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),
              const SizedBox(height: 16),
              _buildResultRow(
                label: 'Correct',
                count: _correctCount,
                color: Colors.green.shade400,
                icon: Icons.check_circle_rounded,
              ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.2),
              const SizedBox(height: 16),
              _buildResultRow(
                label: 'Facile',
                count: _easyCount,
                color: Colors.blue.shade400,
                icon: Icons.star_rounded,
              ).animate().fadeIn(delay: 1200.ms).slideX(begin: -0.2),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Retour à la bibliothèque',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
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
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
