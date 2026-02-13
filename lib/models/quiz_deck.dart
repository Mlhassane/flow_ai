import 'package:flow/models/quiz_card.dart';

class QuizDeck {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<QuizCard> cards;

  QuizDeck({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.cards,
  });

  double get masteryProgress {
    if (cards.isEmpty) return 0.0;
    double total = 0;
    for (var card in cards) {
      total += card.masteryLevel;
    }
    return total / cards.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'cards': cards.map((card) => card.toJson()).toList(),
    };
  }

  factory QuizDeck.fromJson(Map<String, dynamic> json) {
    return QuizDeck(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      cards: (json['cards'] as List<dynamic>)
          .map((e) => QuizCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
