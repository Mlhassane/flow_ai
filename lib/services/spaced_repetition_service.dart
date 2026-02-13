import 'package:flow/models/quiz_card.dart';

enum ReviewQuality {
  forgot, // 0 - Oublié
  hard, // 3 - Difficile
  good, // 4 - Bien
  easy, // 5 - Facile
}

class SpacedRepetitionService {
  /// Algorithme SM-2 simplifié
  static QuizCard calculateNextReview(QuizCard card, ReviewQuality quality) {
    int q = _qualityToInt(quality);

    int repetitions = card.repetitions;
    double easeFactor = card.easeFactor;
    int interval = card.interval;

    if (q >= 3) {
      // Réponse correcte
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 4; // Version courte pour MVP
      } else {
        interval = (interval * easeFactor).round();
      }
      repetitions++;
    } else {
      // Réponse oubliée
      repetitions = 0;
      interval = 1;
    }

    // Mise à jour du facteur de facilité (Ease Factor)
    easeFactor = easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (easeFactor < 1.3) easeFactor = 1.3;

    return card.copyWith(
      repetitions: repetitions,
      easeFactor: easeFactor,
      interval: interval,
      nextReview: DateTime.now().add(Duration(days: interval)),
    );
  }

  static int _qualityToInt(ReviewQuality quality) {
    switch (quality) {
      case ReviewQuality.forgot:
        return 0;
      case ReviewQuality.hard:
        return 3;
      case ReviewQuality.good:
        return 4;
      case ReviewQuality.easy:
        return 5;
    }
  }
}
