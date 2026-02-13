class User {
  final String id;
  final String name;
  final String level;
  final String avatarUrl;
  final int coins;
  final int streak;
  final int totalFlashcards;
  final int totalQuizzes;
  final List<String> badges;
  final Map<String, int> subjectProgress;

  User({
    required this.id,
    required this.name,
    required this.level,
    required this.avatarUrl,
    required this.coins,
    required this.streak,
    required this.totalFlashcards,
    required this.totalQuizzes,
    required this.badges,
    required this.subjectProgress,
  });

  static User mock() {
    return User(
      id: '1',
      name: 'Alexandre',
      level: 'Première',
      avatarUrl: 'https://i.pravatar.cc/150?u=me',
      coins: 992500,
      streak: 3,
      totalFlashcards: 247,
      totalQuizzes: 89,
      badges: ['early_bird', 'quiz_master', 'streak_3', 'social_butterfly'],
      subjectProgress: {
        'Français': 75,
        'Mathématiques': 60,
        'SES': 85,
        'Histoire': 45,
        'Anglais': 70,
      },
    );
  }
}
