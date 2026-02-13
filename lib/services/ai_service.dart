import 'dart:convert';
import 'dart:io';
import 'package:flow/models/quiz_card.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class AIService {
  // URL de ton API privée Hugging Face
  final String _apiUrl = 'https://mahamanelawaly-mon-api-ia.hf.space/generate';
  final String _apiKey = 'flow_secure_2024';

  Future<List<QuizCard>> generateQuizFromImage(
    File image, {
    int numQuestions = 5,
    String? userLevel,
  }) async {
    final url = Uri.parse(_apiUrl);
    final String levelContext = userLevel != null
        ? "Niveau de l'élève : $userLevel."
        : "";

    final prompt =
        """
AGIS EN TANT QU'EXPERT PÉDAGOGIQUE. $levelContext
Analyse cette image de cours et génère un quiz de $numQuestions questions.

CONSIGNES :
1. Questions adaptées au niveau.
2. Réponse claire et explication pédagogique pour chaque question.
3. Utilise le LaTeX NORMALEMENT (ex: \\frac, \\begin{cases}).
4. Ne réponds QUE par le JSON.

FORMAT JSON ATTENDU :
[
  {
    "question": "Texte",
    "answer": "Réponse",
    "explanation": "Explication"
  }
]
""";

    print('--- [AIService] Traitement et compression de l\'image... ---');

    // 1. Compression de l'image pour optimiser l'envoi
    final bytes = await image.readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) {
      throw Exception('Impossible de lire l\'image');
    }

    // Redimensionner si l'image est trop grande (max 1024px de large)
    if (decodedImage.width > 1024) {
      decodedImage = img.copyResize(decodedImage, width: 1024);
    }

    // Encoder en JPG qualité 70
    final compressedBytes = img.encodeJpg(decodedImage, quality: 70);
    final base64Image = base64Encode(compressedBytes);

    print('--- [AIService] Image compressée. Envoi vers $_apiUrl ---');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey, // Sécurité ajoutée
        },
        body: jsonEncode({
          'prompt': prompt,
          'image': base64Image,
          'num_questions': numQuestions,
        }),
      );

      print('--- [AIService] Code statut API: ${response.statusCode} ---');

      if (response.statusCode != 200) {
        throw Exception('Erreur API Privée: ${response.body}');
      }

      // Décoder la réponse de notre API (qui contient un champ "response")
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data.containsKey('error')) {
        throw Exception('Erreur renvoyée par le modèle: ${data['error']}');
      }

      String content = data['response'];

      print('--- [AIService] Réponse brute reçue ---');

      // 1. Extraction de la zone JSON (Tableau [])
      int startIdx = content.indexOf('[');
      int endIdx = content.lastIndexOf(']');
      if (startIdx == -1 || endIdx == -1)
        throw Exception('Réponse JSON non trouvée');
      String jsonRaw = content.substring(startIdx, endIdx + 1);

      // 2. ALGORITHME DE SUTURE JSON (Réparation des antislashs LaTeX)
      final StringBuffer buffer = StringBuffer();
      for (int i = 0; i < jsonRaw.length; i++) {
        final char = jsonRaw[i];
        if (char == '\\') {
          if (i + 1 < jsonRaw.length) {
            final next = jsonRaw[i + 1];
            if ('nrt"fb/\\'.contains(next)) {
              buffer.write('\\');
              buffer.write(next);
              i++;
              continue;
            }
            if (next == 'u' && i + 5 < jsonRaw.length) {
              buffer.write(jsonRaw.substring(i, i + 6));
              i += 5;
              continue;
            }
          }
          buffer.write('\\\\');
        } else {
          buffer.write(char);
        }
      }

      String jsonString = buffer.toString();

      print('--- [AIService] JSON nettoyé à parser: $jsonString ---');

      dynamic parsedJson = jsonDecode(jsonString);
      List<dynamic> jsonList;

      if (parsedJson is Map && parsedJson.containsKey('quiz')) {
        jsonList = parsedJson['quiz'];
      } else if (parsedJson is Map && parsedJson.containsKey('questions')) {
        jsonList = parsedJson['questions'];
      } else if (parsedJson is List) {
        jsonList = parsedJson;
      } else {
        if (parsedJson is Map &&
            parsedJson.values.isNotEmpty &&
            parsedJson.values.first is List) {
          jsonList = parsedJson.values.first;
        } else {
          throw Exception('Format JSON inattendu : $parsedJson');
        }
      }

      print('--- [AIService] ${jsonList.length} questions trouvées ---');

      return jsonList.map((item) {
        return QuizCard(
          id:
              item['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          question: item['question']?.toString() ?? 'Question illisible',
          answer: item['answer']?.toString() ?? 'Réponse non trouvée',
          explanation: item['explanation']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      print('--- [AIService] ERREUR API PRIVÉE : $e ---');
      rethrow;
    }
  }
}
