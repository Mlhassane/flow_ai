import 'package:flow/models/quiz_card.dart';

enum ExamLevel { def, bepc, bac }

enum Country { mali, burkina, niger }

class ExamSimulation {
  final String id;
  final String subject;
  final ExamLevel level;
  final Country country;
  final List<QuizCard> questions;
  final Duration timeLimit;
  final DateTime createdAt;

  bool isCompleted;
  int? score;
  Duration? timeTaken;

  ExamSimulation({
    required this.id,
    required this.subject,
    required this.level,
    required this.country,
    required this.questions,
    required this.timeLimit,
    required this.createdAt,
    this.isCompleted = false,
    this.score,
    this.timeTaken,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'level': level.index,
      'country': country.index,
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeLimit': timeLimit.inSeconds,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'score': score,
      'timeTaken': timeTaken?.inSeconds,
    };
  }

  factory ExamSimulation.fromJson(Map<String, dynamic> json) {
    return ExamSimulation(
      id: json['id'],
      subject: json['subject'],
      level: ExamLevel.values[json['level']],
      country: Country.values[json['country']],
      questions: (json['questions'] as List)
          .map((q) => QuizCard.fromJson(q))
          .toList(),
      timeLimit: Duration(seconds: json['timeLimit']),
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      score: json['score'],
      timeTaken: json['timeTaken'] != null
          ? Duration(seconds: json['timeTaken'])
          : null,
    );
  }
}
