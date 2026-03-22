class User {
  final String id;
  final String firstName;
  final String lastName;
  final String level;
  final String country; // ML, BF, NE
  final String examType; // DEF, BEPC, BAC
  final String series; // A, D, C, etc.
  final String avatarUrl;
  final int coins;
  final int streak;
  final int totalFlashcards;
  final int totalQuizzes;
  final List<String> badges;
  final Map<String, int> subjectProgress;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.level,
    required this.country,
    required this.examType,
    required this.series,
    required this.avatarUrl,
    required this.coins,
    required this.streak,
    required this.totalFlashcards,
    required this.totalQuizzes,
    required this.badges,
    required this.subjectProgress,
  });

  String get fullName => "$firstName $lastName";

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'level': level,
      'country': country,
      'examType': examType,
      'series': series,
      'avatarUrl': avatarUrl,
      'coins': coins,
      'streak': streak,
      'totalFlashcards': totalFlashcards,
      'totalQuizzes': totalQuizzes,
      'badges': badges,
      'subjectProgress': subjectProgress,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      level: json['level'],
      country: json['country'] ?? 'ML',
      examType: json['examType'] ?? 'BAC',
      series: json['series'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      coins: json['coins'] ?? 0,
      streak: json['streak'] ?? 0,
      totalFlashcards: json['totalFlashcards'] ?? 0,
      totalQuizzes: json['totalQuizzes'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      subjectProgress: Map<String, int>.from(json['subjectProgress'] ?? {}),
    );
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? level,
    String? country,
    String? examType,
    String? series,
    String? avatarUrl,
    int? coins,
    int? streak,
    int? totalFlashcards,
    int? totalQuizzes,
    List<String>? badges,
    Map<String, int>? subjectProgress,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      level: level ?? this.level,
      country: country ?? this.country,
      examType: examType ?? this.examType,
      series: series ?? this.series,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      totalFlashcards: totalFlashcards ?? this.totalFlashcards,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      badges: badges ?? this.badges,
      subjectProgress: subjectProgress ?? this.subjectProgress,
    );
  }

  static User mock() {
    return User(
      id: '1',
      firstName: 'Alexandre',
      lastName: '',
      level: 'Terminale',
      country: 'ML',
      examType: 'BAC',
      series: 'TSE',
      avatarUrl: '',
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
