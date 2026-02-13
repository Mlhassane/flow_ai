import 'package:flutter/material.dart';
import 'package:flow/core/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flow/services/storage_service.dart';
import 'package:flow/models/quiz_card.dart';
import 'package:flow/features/quiz/quiz_screen.dart';
import 'package:flow/features/create/create_screen.dart';
import 'package:flow/features/tutor/tutor_screen.dart';
import 'package:flow/features/profile/profile_screen.dart';
import 'package:flow/features/library/library_screen.dart';
import 'package:flow/features/corrector/corrector_screen.dart';
import 'package:flow/services/streak_service.dart';
import 'package:flow/widgets/cauri_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalCards = 0;
  int _masteryScore = 0;
  int _actualStreak = 0;
  List<QuizCard> _dueCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final decks = await StorageService().getDecks();
    final dueCards = await StorageService().getDueCards();
    final streak = await StreakService().getStreak();

    int total = 0;
    int masteredCount = 0;

    for (var deck in decks) {
      total += deck.cards.length;
      for (var card in deck.cards) {
        if (card.repetitions >= 2) masteredCount++;
      }
    }

    setState(() {
      _dueCards = dueCards;
      _totalCards = total;
      _masteryScore = total > 0 ? ((masteredCount / total) * 100).toInt() : 0;
      _actualStreak = streak;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Subtle Dynamic Background
          Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.8, -0.6),
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
                begin: -20,
                end: 20,
                duration: 5.seconds,
                curve: Curves.easeInOut,
              ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 32),
                    const Text(
                      'Mes outils',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildToolsGrid(),
                    const SizedBox(height: 32),
                    _buildRevisionSection(),
                    const SizedBox(height: 32),
                    const Text(
                      'Mes groupes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGroupsList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salut tonton ! 👋',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Prêt pour un quiz ?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Stats Card (Sober & Minimalist)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.02,
                ),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Circular Mastery Chart (Sober)
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Stack(
                      children: [
                        Center(
                              child: SizedBox(
                                height: 70,
                                width: 70,
                                child: CircularProgressIndicator(
                                  value: _masteryScore / 100,
                                  strokeWidth: 6,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onSurface,
                                  ),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.05, 1.05),
                              duration: 2.seconds,
                            ),
                        Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: _masteryScore.toDouble(),
                            ),
                            duration: const Duration(seconds: 2),
                            builder: (context, value, child) {
                              return Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Info Level
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Niveau ${_masteryScore ~/ 10 + 1}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _masteryScore > 80 ? 'ELITE' : 'PRO',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true),
                                )
                                .shimmer(
                                  duration: 3.seconds,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surface.withOpacity(0.5),
                                ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mémorisation Globale',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // XP Bar (Sober)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_masteryScore % 10) / 10,
                            minHeight: 6,
                            backgroundColor: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.black.withOpacity(0.05)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '$_actualStreak',
                    'Série',
                    null,
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF92400E),
                    useCauri: true,
                  ),
                  _buildStatItem(
                    '$_totalCards',
                    'Cartes',
                    Icons.style_outlined,
                    Colors.black54,
                  ),
                  _buildStatItem(
                    'Top 5%',
                    'Rank',
                    Icons.emoji_events_outlined,
                    Colors.amber,
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData? icon,
    Color color, {
    bool useCauri = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (useCauri)
              const CauriIcon(size: 16)
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: Offset(1.1, 1.1),
                    duration: 2.seconds,
                  )
            else
              Icon(icon, color: color, size: 16)
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 1.seconds,
                  ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 55,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03,
                ),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade400),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'trouve des fiches',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildToolsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildBentoCard(
                'Crée ton Quiz',
                'Prends une photo',
                Icons.auto_awesome_rounded,
                [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                0,
                big: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoCard(
                'Stats',
                'Ton progrès',
                Icons.bar_chart_rounded,
                [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
                1,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                'Fiches',
                'Flashcards IA',
                Icons.style_rounded,
                [const Color(0xFF10B981), const Color(0xFF3B82F6)],
                2,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LibraryScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildBentoCard(
                'Tuteur IA',
                'Pose tes questions',
                Icons.psychology_rounded,
                [const Color(0xFFEC4899), const Color(0xFF8B5CF6)],
                3,
                big: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TutorScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildBentoCard(
          'Correcteur d\'Épreuve',
          'Scan et corrige tes examens avec pédagogie',
          Icons.fact_check_rounded,
          [const Color(0xFF3B82F6), const Color(0xFF2DD4BF)],
          4,
          big: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CorrectorScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard(
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradient,
    int index, {
    bool big = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child:
          Container(
                height: 160,
                padding: const EdgeInsets.all(24),
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
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gradient[0].withOpacity(0.1),
                            gradient[1].withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: gradient[0], size: 24),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      big ? subtitle : 'Ouvrir',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: (400 + 100 * index).ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildRevisionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.04,
            ),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session IA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _isLoading
                          ? 'Chargement...'
                          : '${_dueCards.length} questions prêtes',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_dueCards.isNotEmpty)
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(quizCards: _dueCards),
                      ),
                    );
                    _loadStats();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go !',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 32,
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildGroupsList() {
    final groups = [
      {
        'subject': 'Français',
        'level': 'Première',
        'subtitle': 'Rejoint par Céleste et 12 autres',
      },
      {
        'subject': 'Mathématiques',
        'level': 'Première',
        'subtitle': 'Rejoint par Thomas et 24 autres',
      },
      {
        'subject': 'SES',
        'level': 'Première',
        'subtitle': 'Rejoint par Marie et 8 autres',
      },
    ];

    return Column(
      children: groups.asMap().entries.map((entry) {
        final index = entry.key;
        final group = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index < groups.length - 1 ? 12 : 0),
          child: _buildGroupTile(
            group['subject']!,
            group['level']!,
            group['subtitle']!,
            index,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupTile(
    String subject,
    String level,
    String subtitle,
    int index,
  ) {
    return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.02,
                ),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.book, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          subject,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          level,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chat_bubble_outline,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                size: 20,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (700 + 100 * index).ms, duration: 400.ms)
        .slideX(begin: 0.2, end: 0, delay: (700 + 100 * index).ms);
  }
}
