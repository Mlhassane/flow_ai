import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flow/models/quiz_deck.dart';
import 'package:flow/core/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MCQQuizScreen extends StatefulWidget {
  final QuizDeck deck;
  const MCQQuizScreen({super.key, required this.deck});

  @override
  State<MCQQuizScreen> createState() => _MCQQuizScreenState();
}

class _MCQQuizScreenState extends State<MCQQuizScreen> {
  int _currentIndex = 0;
  bool _showResult = false;
  int? _selectedOption;
  late List<String> _currentOptions;
  late int _correctIndex;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _generateOptions();
  }

  void _generateOptions() {
    final correctCard = widget.deck.cards[_currentIndex];
    final otherAnswers = widget.deck.cards
        .where((c) => c.id != correctCard.id)
        .map((c) => c.answer)
        .toList();

    // Pick 2 distractors if available, otherwise use defaults
    otherAnswers.shuffle();
    final distractors = otherAnswers.take(2).toList();
    while (distractors.length < 2) {
      distractors.add("Réponse alternative ${distractors.length + 1}");
    }

    _currentOptions = [correctCard.answer, ...distractors];
    _currentOptions.shuffle();
    _correctIndex = _currentOptions.indexOf(correctCard.answer);
  }

  void _handleOptionTap(int index) {
    if (_selectedOption != null) return;
    setState(() {
      _selectedOption = index;
      if (index == _correctIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_currentIndex < widget.deck.cards.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedOption = null;
          _generateOptions();
        });
      } else {
        setState(() {
          _showResult = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return QuizResultScreen(
        deck: widget.deck,
        score: _score,
        total: widget.deck.cards.length,
      );
    }

    double progress = (_currentIndex + 1) / widget.deck.cards.length;

    final card = widget.deck.cards[_currentIndex];

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
                fontSize: 14,
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
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.circle,
                  size: 3,
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Révision',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 8,
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
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.black.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
            minHeight: 4,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Question Card
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(32),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_currentIndex + 1}/${widget.deck.cards.length}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      card.question,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Options
            Expanded(
              child: ListView.separated(
                itemCount: _currentOptions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isSelected = _selectedOption == index;
                  final isCorrect = _correctIndex == index;

                  Color bgColor = Theme.of(context).colorScheme.surface;
                  Color borderColor = Theme.of(
                    context,
                  ).dividerColor.withOpacity(0.1);
                  Color textColor = Theme.of(context).colorScheme.onSurface;
                  Color labelColor = Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4);

                  if (_selectedOption != null) {
                    if (isCorrect) {
                      bgColor = Colors.green.withOpacity(0.1);
                      borderColor = Colors.green.withOpacity(0.3);
                      textColor = Colors.green;
                      labelColor = Colors.green;
                    } else if (isSelected) {
                      bgColor = Colors.red.withOpacity(0.1);
                      borderColor = Colors.red.withOpacity(0.3);
                      textColor = Colors.red;
                      labelColor = Colors.red;
                    }
                  }

                  return GestureDetector(
                    onTap: () => _handleOptionTap(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  color: labelColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _currentOptions[index],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bien joué ! Continue ton effort...',
              style: const TextStyle(color: Colors.black26, fontSize: 13),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final QuizDeck deck;
  final int score;
  final int total;
  const QuizResultScreen({
    super.key,
    required this.deck,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        title: Column(
          children: [
            Text(
              deck.title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Révision',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.circle,
                  size: 3,
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Quiz',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CustomPaint(
                    painter: ResultCirclePainter(percentage: score / total),
                  ),
                ),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          Theme.of(context).brightness == Brightness.dark
                              ? 0.4
                              : 0.1,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        score.toString(),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'sur $total',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
          ],
        ),
      ),
    );
  }
}

class ResultCirclePainter extends CustomPainter {
  final double percentage;
  ResultCirclePainter({this.percentage = 0.8});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 50.0;

    final paintBg = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, paintBg);

    // Dynamic segment
    final paintFill = Paint()
      ..color = percentage >= 0.5
          ? const Color(0xFFA5D6A7)
          : const Color(0xFFFFCC80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      2 * pi * percentage,
      false,
      paintFill,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
