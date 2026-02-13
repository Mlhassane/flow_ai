class QuizCard {
  final String id;
  final String question;
  final String answer;
  final String explanation;

  // Champs pour la révision espacée
  final DateTime nextReview;
  final int interval; // en jours
  final int repetitions;
  final double easeFactor;

  QuizCard({
    required this.id,
    required this.question,
    required this.answer,
    this.explanation = '',
    DateTime? nextReview,
    this.interval = 0,
    this.repetitions = 0,
    this.easeFactor = 2.5,
  }) : this.nextReview = nextReview ?? DateTime.now();

  QuizCard copyWith({
    String? id,
    String? question,
    String? answer,
    String? explanation,
    DateTime? nextReview,
    int? interval,
    int? repetitions,
    double? easeFactor,
  }) {
    return QuizCard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      nextReview: nextReview ?? this.nextReview,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
    );
  }

  // Convertir en JSON pour sauvegarder
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'explanation': explanation,
      'nextReview': nextReview.toIso8601String(),
      'interval': interval,
      'repetitions': repetitions,
      'easeFactor': easeFactor,
    };
  }

  // Créer depuis JSON pour charger
  factory QuizCard.fromJson(Map<String, dynamic> json) {
    return QuizCard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      explanation: json['explanation'] as String? ?? '',
      nextReview: json['nextReview'] != null
          ? DateTime.parse(json['nextReview'] as String)
          : null,
      interval: json['interval'] as int? ?? 0,
      repetitions: json['repetitions'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num? ?? 2.5).toDouble(),
    );
  }

  // Algorithme SM-2 simplifié pour la révision espacée
  QuizCard updateReview(int quality) {
    int nextInterval;
    int nextRepetitions;
    double nextEaseFactor;

    if (quality >= 3) {
      if (repetitions == 0) {
        nextInterval = 1;
      } else if (repetitions == 1) {
        nextInterval = 6;
      } else {
        nextInterval = (interval * easeFactor).round();
      }
      nextRepetitions = repetitions + 1;
      nextEaseFactor =
          easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    } else {
      nextRepetitions = 0;
      nextInterval = 1;
      nextEaseFactor = easeFactor;
    }

    if (nextEaseFactor < 1.3) nextEaseFactor = 1.3;

    return copyWith(
      nextReview: DateTime.now().add(Duration(days: nextInterval)),
      interval: nextInterval,
      repetitions: nextRepetitions,
      easeFactor: nextEaseFactor,
    );
  }

  // Calculer le niveau de maîtrise (0.0 à 1.0)
  double get masteryLevel {
    if (repetitions == 0) return 0.0;
    if (repetitions == 1) return 0.2;
    if (repetitions == 2) return 0.5;
    if (repetitions == 3) return 0.8;
    return 1.0;
  }

  static List<QuizCard> mockList() {
    return [
      QuizCard(
        id: '1',
        question: 'Quelle est la date du Krach boursier de 1929 ?',
        answer: 'Le "Black Thursday" a eu lieu le 24 octobre 1929.',
        explanation: 'C\'est le début de la Grande Dépression.',
      ),
      QuizCard(
        id: '2',
        question: 'Quelles sont les causes principales ?',
        answer: 'La spéculation boursière et la surproduction industrielle.',
        explanation:
            'Une bulle spéculative s\'était formée durant les années 20.',
      ),
    ];
  }
}
