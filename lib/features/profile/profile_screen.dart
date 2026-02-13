import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flow/core/theme.dart';
import 'package:flow/models/user.dart';
import 'package:flow/services/theme_service.dart';
import 'package:flow/services/streak_service.dart';
import 'package:flow/widgets/cauri_icon.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _actualStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await StreakService().getStreak();
    setState(() {
      _actualStreak = streak;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = User.mock();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                begin: 15,
                end: -15,
                duration: 7.seconds,
                curve: Curves.easeInOut,
              ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(context, user, isDark),
                  const SizedBox(height: 40),
                  _buildStatsGrid(context, user, isDark),
                  const SizedBox(height: 40),
                  _buildBadgesSection(context, user, isDark),
                  const SizedBox(height: 40),
                  _buildProgressSection(context, user, isDark),
                  const SizedBox(height: 40),
                  _buildSettingsSection(context, isDark),
                  const SizedBox(height: 120), // Bottom nav space
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User user, bool isDark) {
    return Column(
      children: [
        Center(
          child: Hero(
            tag: 'profile_avatar',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Theme.of(context).colorScheme.surface,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        ),
        const SizedBox(height: 20),
        Text(
          user.name,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.8,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.level,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuickStat(
              context,
              'Pièces',
              (user.coins / 1000).toStringAsFixed(1) + 'k',
              Icons.stars_rounded,
              Colors.amber,
              isDark,
            ),
            Container(
              height: 30,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            _buildQuickStat(
              context,
              'Série',
              _isLoading ? '...' : '$_actualStreak',
              null, // Use Cauri
              isDark ? Colors.white : const Color(0xFF92400E),
              isDark,
              useCauri: true,
            ),
          ],
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String value,
    IconData? icon,
    Color color,
    bool isDark, {
    bool useCauri = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (useCauri)
              CauriIcon(size: 20, color: color)
            else
              Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, User user, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Flashcards',
            user.totalFlashcards.toString(),
            Icons.style_rounded,
            AppTheme.primaryColor,
            0,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Quiz Faits',
            user.totalQuizzes.toString(),
            Icons.quiz_rounded,
            Colors.green,
            1,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    int index,
    bool isDark,
  ) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (400 + 100 * index).ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildBadgesSection(BuildContext context, User user, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mes badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Tout voir',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 20),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: user.badges.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              return _buildBadge(context, user.badges[index], index, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String badgeId,
    int index,
    bool isDark,
  ) {
    final badgeData = _getBadgeData(badgeId);

    return Container(
          width: 90,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (badgeId == 'streak_3')
                const CauriIcon(size: 28)
              else
                Icon(badgeData['icon'], color: badgeData['color'], size: 28),
              const SizedBox(height: 10),
              Text(
                badgeData['name'],
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (700 + 100 * index).ms)
        .scale(delay: (700 + 100 * index).ms, curve: Curves.easeOutBack);
  }

  Map<String, dynamic> _getBadgeData(String badgeId) {
    final badges = {
      'early_bird': {
        'name': 'Lève-tôt',
        'icon': Icons.wb_sunny_rounded,
        'color': Colors.orange,
      },
      'quiz_master': {
        'name': 'Maître Quiz',
        'icon': Icons.emoji_events_rounded,
        'color': Colors.amber,
      },
      'streak_3': {
        'name': 'Série 3',
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.red,
      },
      'social_butterfly': {
        'name': 'Social',
        'icon': Icons.people_rounded,
        'color': Colors.blue,
      },
    };
    return badges[badgeId] ?? badges['quiz_master']!;
  }

  Widget _buildProgressSection(BuildContext context, User user, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suivi par matière',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 800.ms),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: user.subjectProgress.entries.map((entry) {
              final index = user.subjectProgress.keys.toList().indexOf(
                entry.key,
              );
              return _buildProgressBar(context, entry.key, entry.value, index);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String subject,
    int progress,
    int index,
  ) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$progress%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (900 + 100 * index).ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildSettingsSection(BuildContext context, bool isDark) {
    final themeService = Provider.of<ThemeService>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Préférences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 1100.ms),
        const SizedBox(height: 20),
        _buildSettingTile(
          context,
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          'Mode sombre',
          0,
          trailing: Switch(
            value: themeService.isDarkMode,
            onChanged: (_) => themeService.toggleTheme(),
            activeColor: AppTheme.primaryColor,
          ),
        ),
        _buildSettingTile(
          context,
          Icons.notifications_none_rounded,
          'Notifications',
          1,
        ),
        _buildSettingTile(context, Icons.security_rounded, 'Sécurité', 2),
        _buildSettingTile(
          context,
          Icons.logout_rounded,
          'Déconnexion',
          3,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    IconData icon,
    String title,
    int index, {
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            leading: Icon(
              icon,
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : AppTheme.primaryColor,
              size: 22,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            trailing:
                trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.2),
                  size: 20,
                ),
            onTap: trailing == null ? () {} : null,
          ),
        )
        .animate()
        .fadeIn(delay: (1200 + 100 * index).ms)
        .slideY(begin: 0.1, end: 0);
  }
}
