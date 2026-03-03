import 'package:flutter/material.dart';
import 'package:flow/core/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flow/services/storage_service.dart';
import 'package:flow/models/quiz_card.dart';
import 'package:flow/features/quiz/quiz_screen.dart';
import 'package:flow/features/create/create_screen.dart';
import 'package:flow/features/library/library_screen.dart';
import 'package:flow/features/corrector/corrector_screen.dart';
import 'package:flow/features/tutor/tutor_screen.dart';
import 'package:flow/services/streak_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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

    final dueCards = await StorageService().getDueCards();
    final streak = await StreakService().getStreak();



    setState(() {
      _dueCards = dueCards;

      _actualStreak = streak;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    _buildHeader(isDark),
                    const SizedBox(height: 20),
                    _buildRevisionSection(),
                    const SizedBox(height: 24),
                    _buildSearchBar(isDark),
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

  Widget _buildHeader(bool isDark) {
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
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
            Row(
              children: [
                if (_actualStreak > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '$_actualStreak',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: isDark 
                        ? AppTheme.primaryColor.withOpacity(0.2) 
                        : const Color(0xFFE3F2FD),
                    child: const Icon(Icons.person_rounded, color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ]
    );
  }



  Widget _buildSearchBar(bool isDark) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(isDark ? 0.1 : 0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'trouve des fiches',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
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
              flex: 3,
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
              flex: 2,
              child: _buildBentoCard(
                'Mes Quiz',
                'Voir mes decks',
                Icons.style_rounded,
                [const Color(0xFF10B981), const Color(0xFF34D399)],
                1,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LibraryScreen(),
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
              flex: 2,
              child: _buildBentoCard(
                'Tuteur IA',
                "Pose tes questions",
                Icons.chat_bubble_rounded,
                [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
                2,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TutorScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _buildBentoCard(
                'Correcteur',
                "Corrige tes épreuves",
                Icons.grading_rounded,
                [const Color(0xFFEC4899), const Color(0xFFF472B6)],
                3,
                big: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CorrectorScreen(),
                  ),
                ),
              ),
            ),
          ],
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
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          height: big ? 180 : 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gradient[0].withOpacity(0.2),
                            gradient[1].withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: gradient[0], size: 28),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            big ? subtitle : 'Ouvrir',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!big)
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.3),
                          ),
                      ],
                    ),
                  ],
                ), // Close Column
              ), // Close Container
        ), // Close InkWell
      ) // Close Material
      .animate()
      .fadeIn(delay: (400 + 100 * index).ms)
      .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildRevisionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
        ),
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
                      'Revision Generale',
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
                    'On y va',
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
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
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
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                  size: 20,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (700 + 100 * index).ms, duration: 400.ms)
        .slideX(begin: 0.2, end: 0, delay: (700 + 100 * index).ms);
  }
}
