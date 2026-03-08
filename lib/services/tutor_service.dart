import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flow/models/quiz_card.dart';

class TutorService {
  final String _apiUrl = 'https://mahamanelawaly-mon-api-ia.hf.space/generate';

  Future<String> sendMessage(
    String message, {
    String? userLevel,
    List<QuizCard>? cards,
  }) async {
    final String levelContext = userLevel != null
        ? "L'élève est en classe de $userLevel."
        : "";

    // Construction du contexte basé sur les cartes si elles sont fournies
    String cardsContext = "";
    if (cards != null && cards.isNotEmpty) {
      cardsContext =
          "\nVoici le contenu du cours sur lequel l'élève travaille :\n";
      for (var card in cards) {
        cardsContext +=
            "- Question : ${card.question}\n  Réponse attendue : ${card.answer}\n";
      }
    }

    final String fullPrompt =
        """
### RÔLE : TU ES UN TUTEUR IA EXPERT ET BIENVEILLANT (SYSTÈME AES : MALI, BF, NIGER).
$levelContext
$cardsContext

### MISSION :
Ton but est d'accompagner l'élève dans sa compréhension. 
1. Ne donne PAS la réponse directement si l'élève pose une question sur un exercice présent dans le contexte.
2. Pose des questions pour le guider (méthode socratique).
3. Utilise des exemples concrets et simples, adaptés au contexte sahélien si possible.
4. Si l'élève semble perdu, décompose le concept en petites étapes.

### QUESTION DE L'ÉLÈVE :
$message
""";

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'flow_secure_2024',
        },
        body: jsonEncode({
          'prompt': fullPrompt,
          'task': 'chat', // Utilise la config 'chat' de l'API (temp 0.7)
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['response']?.toString() ??
            "Désolé, je n'ai pas pu formuler de réponse.";
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur TutorService: $e');
      return "Désolé, je n'arrive pas à réfléchir pour le moment. Vérifie ta connexion internet.";
    }
  }
}
