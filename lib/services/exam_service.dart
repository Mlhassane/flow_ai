import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flow/models/exam.dart';
import 'package:flow/models/quiz_card.dart';

class ExamService {
  final String _apiUrl = 'https://mahamanelawaly-mon-api-ia.hf.space/generate';
  final String _apiKey = 'flow_secure_2024';

  Future<ExamSimulation> generateMockExam({
    required String subject,
    required ExamLevel level,
    required Country country,
  }) async {
    final String levelStr = level.toString().split('.').last.toUpperCase();
    final String countryStr = country.toString().split('.').last.toUpperCase();

    final prompt =
        """
AGIS EN TANT QU'EXPERT DES EXAMENS NATIONAUX DE L'AES.
Génère un EXAMEN BLANC complet pour le sujet suivant : $subject.
Niveau : $levelStr
Pays : $countryStr

CONSIGNES :
1. L'examen doit comporter exactement 10 questions représentatives du programme de ce pays.
2. Pour chaque question, fournis une réponse détaillée et une explication pédagogique.
3. Le ton doit être formel, comme un vrai sujet d'examen.
4. PAS DE LATEX. Utilise une notation humaine simple.

FORMAT JSON (uniquement un tableau) :
[
  {
    "question": "Libellé de la question d'examen",
    "answer": "Réponse type attendue",
    "explanation": "Barème ou explication des points clés"
  }
]
""";

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({
          'prompt': prompt,
          'task':
              'quiz', // On utilise le réglage quiz (temp basse) pour la précision
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final String content = data['response'];

        // Extraction du JSON
        final start = content.indexOf('[');
        final end = content.lastIndexOf(']');
        final jsonRaw = content.substring(start, end + 1);
        final List<dynamic> jsonList = jsonDecode(jsonRaw);

        final List<QuizCard> questions = jsonList.map((item) {
          return QuizCard(
            id:
                DateTime.now().microsecondsSinceEpoch.toString() +
                jsonList.indexOf(item).toString(),
            question: item['question'],
            answer: item['answer'],
            explanation: item['explanation'] ?? '',
          );
        }).toList();

        return ExamSimulation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          subject: subject,
          level: level,
          country: country,
          questions: questions,
          timeLimit: const Duration(
            minutes: 30,
          ), // Par défaut 30 min pour le simulateur
          createdAt: DateTime.now(),
        );
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur ExamService: $e');
      rethrow;
    }
  }
}
