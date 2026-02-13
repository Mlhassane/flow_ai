import 'package:flow/core/theme.dart';
import 'package:flow/models/quiz_card.dart';
import 'package:flow/services/storage_service.dart';
import 'package:flow/services/spaced_repetition_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  final List<QuizCard> quizCards;

  const QuizScreen({super.key, required this.quizCards});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _correctCount = 0;
  int _easyCount = 0;
  int _revoirCount = 0;
  bool _isFinished = false;

  void _handleAction(ReviewQuality quality) {
    setState(() {
      if (quality == ReviewQuality.good) _correctCount++;
      if (quality == ReviewQuality.easy) _easyCount++;
      if (quality == ReviewQuality.forgot || quality == ReviewQuality.hard)
        _revoirCount++;

      if (_currentIndex < widget.quizCards.length - 1) {
        _currentIndex++;
        _isFlipped = false;
      } else {
        _isFinished = true;
      }
    });
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildResultView();
    }

    final currentCard = widget.quizCards[_currentIndex];
    final progress = (_currentIndex + 1) / widget.quizCards.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
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
        title: Text(
          'Révision Intelligente',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child:
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.black.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
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
            const SizedBox(height: 20),

            // Card Container
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            final rotateAnim = Tween(
                              begin: pi,
                              end: 0.0,
                            ).animate(animation);
                            return AnimatedBuilder(
                              animation: rotateAnim,
                              child: child,
                              builder: (context, child) {
                                final isUnder =
                                    (ValueKey(_isFlipped) != child!.key);
                                var tilt =
                                    ((animation.value - 0.5).abs() - 0.5) *
                                    0.003;
                                tilt *= isUnder ? -1.0 : 1.0;
                                final value = isUnder
                                    ? min(rotateAnim.value, pi / 2)
                                    : rotateAnim.value;
                                return Transform(
                                  transform: Matrix4.rotationY(value)
                                    ..setEntry(3, 0, tilt),
                                  alignment: Alignment.center,
                                  child: child,
                                );
                              },
                            );
                          },
                      layoutBuilder: (widget, list) =>
                          Stack(children: [widget!, ...list]),
                      switchInCurve: Curves.easeInBack,
                      switchOutCurve: Curves.easeInBack.flipped,
                      child: _isFlipped
                          ? _buildBackCard(currentCard)
                          : _buildFrontCard(currentCard),
                    ),
                  ),
                ),
              ),
            ),

            // Progress counter
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '${_currentIndex + 1}/${widget.quizCards.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
            ),

            // Controls / Spaced Repetition Ratings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: _isFlipped
                  ? _buildReviewControls(currentCard)
                  : _buildNavigationControls(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Row(
      children: [
        IconButton(
          onPressed: _currentIndex > 0 ? _prevCard : null,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _currentIndex > 0 ? Colors.black54 : Colors.grey.shade200,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _flipCard,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              children: [
                Icon(Icons.flip_to_back_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Voir la réponse',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _handleAction(ReviewQuality.good),
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewControls(QuizCard card) {
    return Row(
      children: [
        Expanded(
          child: _buildReviewButton(
            'Plus tard',
            Colors.red.withOpacity(0.1),
            Colors.red,
            ReviewQuality.hard,
            card,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildReviewButton(
            'Bien',
            Colors.green.withOpacity(0.1),
            Colors.green,
            ReviewQuality.good,
            card,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildReviewButton(
            'Facile',
            Colors.blue.withOpacity(0.1),
            Colors.blue,
            ReviewQuality.easy,
            card,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildReviewButton(
    String label,
    Color bgColor,
    Color textColor,
    ReviewQuality quality,
    QuizCard card,
  ) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () async {
          final updatedCard = SpacedRepetitionService.calculateNextReview(
            card,
            quality,
          );
          await StorageService().updateCard(updatedCard);
          _handleAction(quality);
        },
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

  Widget _buildFrontCard(QuizCard card) {
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      height: 520,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08,
            ),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'QUESTION',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Toucher pour retourner',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(QuizCard card) {
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      height: 520,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F172A)
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : const Color(0xFF1E293B))
                    .withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'RÉPONSE',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card.answer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                if (card.explanation.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(width: 40, height: 1, color: Colors.white24),
                  const SizedBox(height: 32),
                  Text(
                    card.explanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    int total = widget.quizCards.length;
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
                'Révision Terminée !',
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
                'Tu as révisé $total cartes',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 40),
              _buildResultRow(
                label: 'À retravailler',
                count: _revoirCount,
                color: Colors.red.shade400,
                icon: Icons.refresh_rounded,
              ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),
              const SizedBox(height: 12),
              _buildResultRow(
                label: 'Acquis',
                count: _correctCount,
                color: Colors.green.shade400,
                icon: Icons.check_circle_rounded,
              ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.2),
              const SizedBox(height: 12),
              _buildResultRow(
                label: 'Maîtrisé',
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
                    'Continuer',
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
}
