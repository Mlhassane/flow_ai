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
Génère un quiz FLASH de $numQuestions questions.

CONSIGNES DE LISIBILITÉ (CRITIQUE) :
1. PAS DE LATEX : N'utilise JAMAIS de balises comme \\begin{cases}, \\end{cases}, \\frac, \\left, \\right.
2. NOTATION HUMAINE : Pour les systèmes d'équations, utilise une présentation simple. 
   Exemple : 
   (1) 2x + 3y = 4
   (2) x - y = 2
3. RÉPONSES COURTES : Va droit à l'essentiel.
4. EXPLICATIONS FLASH : Maximum 2 phrases.

FORMAT JSON :
[
  {
    "question": "Texte sans code",
    "answer": "Réponse directe",
    "explanation": "Explication simple"
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
          'task': 'quiz',
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

      if (parsedJson is List) {
        jsonList = parsedJson;
      } else if (parsedJson is Map &&
          (parsedJson.containsKey('quiz') ||
              parsedJson.containsKey('questions'))) {
        jsonList = parsedJson['quiz'] ?? parsedJson['questions'];
      } else {
        throw Exception('Format JSON inattendu');
      }

      print('--- [AIService] ${jsonList.length} questions trouvées ---');

      return jsonList.map((item) {
        String q = item['question']?.toString() ?? 'Question illisible';
        String a = item['answer']?.toString() ?? 'Réponse non trouvée';
        String e = item['explanation']?.toString() ?? '';

        // Nettoyage final des restes de LaTeX
        String clean(String text) {
          return text
              .replaceAll(RegExp(r'\\begin\{.*\}|\\end\{.*\}'), '')
              .replaceAll(RegExp(r'\\left\{|\\right\.'), '')
              .replaceAll(RegExp(r'\\array\{.*\}'), '')
              .replaceAll(
                RegExp(r'\\(text|frac|sqrt|left|right|begin|end|cases)\b'),
                '',
              )
              .replaceAll(RegExp(r'[\\{}]+'), ' ')
              .trim();
        }

        return QuizCard(
          id:
              item['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          question: clean(q),
          answer: clean(a),
          explanation: clean(e),
        );
      }).toList();
    } catch (e) {
      print('--- [AIService] ERREUR API PRIVÉE : $e ---');
      rethrow;
    }
  }
}
