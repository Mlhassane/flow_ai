import 'dart:convert';
import 'package:http/http.dart' as http;

class TutorService {
  final String _apiUrl = 'https://mahamanelawaly-mon-api-ia.hf.space/generate';

  Future<String> sendMessage(String message, {String? userLevel}) async {
    final String levelContext = userLevel != null
        ? "Tu parles à un élève de classe de $userLevel."
        : "";
    final String fullPrompt =
        """
### PERSONA : TU ES UN TUTEUR IA BIENVEILLANT ET PÉDAGOGUE.
$levelContext
Ton but est d'expliquer les concepts simplement, sans donner directement la réponse si possible, mais en guidant l'élève par le raisonnement.

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
        body: jsonEncode({'prompt': fullPrompt}),
      );

      if (response.statusCode == 200) {
        // Utilisation de utf8.decode pour gérer correctement les accents
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['response']?.toString() ?? "Pas de réponse.";
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur TutorService: $e');
      return "Désolé, je n'arrive pas à réfléchir pour le moment. Vérifie ta connexion.";
    }
  }
}
