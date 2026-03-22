import 'package:flutter/foundation.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flow/models/quiz_card.dart';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as img;

// class AIService {
//   // URL de ton API privée Hugging Face
//   final String _apiUrl = 'https://mahamanelawaly-mon-api-ia.hf.space/generate';
//   final String _apiKey = 'flow_secure_2024';

//   Future<List<QuizCard>> generateQuizFromImage(
//     File image, {
//     int numQuestions = 5,
//     String? userLevel,
//   }) async {
//     final url = Uri.parse(_apiUrl);
//     final String levelContext = userLevel != null
//         ? "Niveau de l'élève : $userLevel."
//         : "";

//     final prompt =
//         """
// AGIS EN TANT QU'EXPERT PÉDAGOGIQUE. $levelContext
// Génère un quiz FLASH de $numQuestions questions.

// CONSIGNES DE LISIBILITÉ (CRITIQUE) :
// 1. PAS DE LATEX : N'utilise JAMAIS de balises comme \\begin{cases}, \\end{cases}, \\frac, \\left, \\right.
// 2. NOTATION HUMAINE : Pour les systèmes d'équations, utilise une présentation simple. 
//    Exemple : 
//    (1) 2x + 3y = 4
//    (2) x - y = 2
// 3. RÉPONSES COURTES : Va droit à l'essentiel.
// 4. EXPLICATIONS FLASH : Maximum 2 phrases.

// FORMAT JSON :
// [
//   {
//     "question": "Texte sans code",
//     "answer": "Réponse directe",
//     "explanation": "Explication simple"
//   }
// ]
// """;

//     debugPrint('--- [AIService] Traitement et compression de l\'image... ---');

//     // 1. Compression de l'image pour optimiser l'envoi
//     final bytes = await image.readAsBytes();
//     img.Image? decodedImage = img.decodeImage(bytes);

//     if (decodedImage == null) {
//       throw Exception('Impossible de lire l\'image');
//     }

//     // Redimensionner si l'image est trop grande (max 1024px de large)
//     if (decodedImage.width > 1024) {
//       decodedImage = img.copyResize(decodedImage, width: 1024);
//     }

//     // Encoder en JPG qualité 70
//     final compressedBytes = img.encodeJpg(decodedImage, quality: 70);
//     final base64Image = base64Encode(compressedBytes);

//     debugPrint('--- [AIService] Image compressée. Envoi vers $_apiUrl ---');

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'x-api-key': _apiKey, // Sécurité ajoutée
//         },
//         body: jsonEncode({
//           'prompt': prompt,
//           'image': base64Image,
//           'num_questions': numQuestions,
//           'task': 'quiz',
//         }),
//       );

//       debugPrint('--- [AIService] Code statut API: ${response.statusCode} ---');

//       if (response.statusCode != 200) {
//         throw Exception('Erreur API Privée: ${response.body}');
//       }

//       // Décoder la réponse de notre API (qui contient un champ "response")
//       final data = jsonDecode(utf8.decode(response.bodyBytes));

//       if (data.containsKey('error')) {
//         throw Exception('Erreur renvoyée par le modèle: ${data['error']}');
//       }

//       String content = data['response'];

//       debugPrint('--- [AIService] Réponse brute reçue ---');

//       // 1. Extraction de la zone JSON (Tableau [])
//       int startIdx = content.indexOf('[');
//       int endIdx = content.lastIndexOf(']');
//       if (startIdx == -1 || endIdx == -1)
//         throw Exception('Réponse JSON non trouvée');
//       String jsonRaw = content.substring(startIdx, endIdx + 1);

//       // 2. ALGORITHME DE SUTURE JSON (Réparation des antislashs LaTeX)
//       final StringBuffer buffer = StringBuffer();
//       for (int i = 0; i < jsonRaw.length; i++) {
//         final char = jsonRaw[i];
//         if (char == '\\') {
//           if (i + 1 < jsonRaw.length) {
//             final next = jsonRaw[i + 1];
//             if ('nrt"fb/\\'.contains(next)) {
//               buffer.write('\\');
//               buffer.write(next);
//               i++;
//               continue;
//             }
//             if (next == 'u' && i + 5 < jsonRaw.length) {
//               buffer.write(jsonRaw.substring(i, i + 6));
//               i += 5;
//               continue;
//             }
//           }
//           buffer.write('\\\\');
//         } else {
//           buffer.write(char);
//         }
//       }

//       String jsonString = buffer.toString();

//       debugPrint('--- [AIService] JSON nettoyé à parser: $jsonString ---');

//       dynamic parsedJson = jsonDecode(jsonString);
//       List<dynamic> jsonList;

//       if (parsedJson is List) {
//         jsonList = parsedJson;
//       } else if (parsedJson is Map &&
//           (parsedJson.containsKey('quiz') ||
//               parsedJson.containsKey('questions'))) {
//         jsonList = parsedJson['quiz'] ?? parsedJson['questions'];
//       } else {
//         throw Exception('Format JSON inattendu');
//       }

//       debugPrint('--- [AIService] ${jsonList.length} questions trouvées ---');

//       return jsonList.map((item) {
//         String q = item['question']?.toString() ?? 'Question illisible';
//         String a = item['answer']?.toString() ?? 'Réponse non trouvée';
//         String e = item['explanation']?.toString() ?? '';

//         // Nettoyage final des restes de LaTeX
//         String clean(String text) {
//           return text
//               .replaceAll(RegExp(r'\\begin\{.*\}|\\end\{.*\}'), '')
//               .replaceAll(RegExp(r'\\left\{|\\right\.'), '')
//               .replaceAll(RegExp(r'\\array\{.*\}'), '')
//               .replaceAll(
//                 RegExp(r'\\(text|frac|sqrt|left|right|begin|end|cases)\b'),
//                 '',
//               )
//               .replaceAll(RegExp(r'[\\{}]+'), ' ')
//               .trim();
//         }

//         return QuizCard(
//           id:
//               item['id']?.toString() ??
//               DateTime.now().millisecondsSinceEpoch.toString(),
//           question: clean(q),
//           answer: clean(a),
//           explanation: clean(e),
//         );
//       }).toList();
//     } catch (e) {
//       debugPrint('--- [AIService] ERREUR API PRIVÉE : $e ---');
//       rethrow;
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flow/models/quiz_card.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flow/services/storage_service.dart';

class AIService {
  // ✅ SÉCURITÉ : Ne jamais hardcoder la clé API côté client.
  // Utilise un backend intermédiaire qui détient la clé,
  // ou charge-la via flutter_dotenv / dart-define.
  //
  // Exemple avec --dart-define :
  //   flutter run --dart-define=API_KEY=flow_secure_2024
  //
  // Puis ici :
  //   static const _apiKey = String.fromEnvironment('API_KEY');
  //
  // Pour l'instant on garde la constante mais on la sort de la classe
  // pour faciliter le remplacement.
  static const String _apiUrl =
      'https://mahamanelawaly-mon-api-ia.hf.space/generate';
  static const String _apiKey = String.fromEnvironment(
    'FLOW_API_KEY',
    defaultValue: 'flow_secure_2024', // Remplacer par --dart-define en prod
  );

  // ─── Paramètres de retry ───────────────────────────────────────────────────
  static const int _maxRetries = 3;
  static const Duration _requestTimeout = Duration(seconds: 45);
  static const int _maxImageWidth = 1024;
  static const int _jpgQuality = 70;
  static const int _maxBase64Mb = 2; // Limite de taille avant envoi

  // ─── Point d'entrée principal ──────────────────────────────────────────────
  Future<List<QuizCard>> generateQuizFromImage(
    File image, {
    int numQuestions = 5,
    String? userLevel,
    String? country,
    String? examType,
  }) async {
    final String levelContext =
        userLevel != null ? "Niveau de l'élève : $userLevel." : "";

    final String regionContext = country != null
        ? "Pays : ${country == 'ML' ? 'Mali' : country == 'BF' ? 'Burkina Faso' : 'Niger'}. Système scolaire AES. Examen préparé : ${examType ?? 'BAC'}."
        : "";

    final prompt = _buildPrompt(numQuestions, "$levelContext $regionContext");

    debugPrint('[AIService] Compression de l\'image...');
    final base64Image = await _compressAndEncodeImage(image);

    // ✅ Vérification de taille avant envoi
    final sizeKb = (base64Image.length * 3 / 4) / 1024;
    if (sizeKb > _maxBase64Mb * 1024) {
      throw Exception(
        'Image trop volumineuse après compression (${sizeKb.toStringAsFixed(0)} KB). '
        'Max : ${_maxBase64Mb * 1024} KB.',
      );
    }

    debugPrint('[AIService] Envoi vers $_apiUrl (${sizeKb.toStringAsFixed(0)} KB)');

    final responseBody = await _postWithRetry(
      prompt: prompt,
      base64Image: base64Image,
      numQuestions: numQuestions,
    );

    return _parseQuizResponse(responseBody);
  }

  // ─── Construction du prompt ────────────────────────────────────────────────
  String _buildPrompt(int numQuestions, String levelContext) {
    return """
AGIS EN TANT QU'EXPERT PÉDAGOGIQUE. $levelContext
Génère un quiz FLASH de $numQuestions questions.

CONSIGNES DE LISIBILITÉ (CRITIQUE) :
1. PAS DE LATEX : N'utilise JAMAIS \\begin{cases}, \\end{cases}, \\frac, \\left, \\right.
2. NOTATION HUMAINE : Pour les systèmes d'équations, utilise :
   (1) 2x + 3y = 4
   (2) x - y = 2
3. RÉPONSES COURTES : Va droit à l'essentiel.
4. EXPLICATIONS FLASH : Maximum 2 phrases.

FORMAT JSON (tableau uniquement, sans texte avant ou après) :
[
  {
    "question": "Texte sans LaTeX",
    "answer": "Réponse directe",
    "explanation": "Explication simple"
  }
]
""";
  }

  // ─── Compression image ─────────────────────────────────────────────────────
  Future<String> _compressAndEncodeImage(File image) async {
    final bytes = await image.readAsBytes();
    img.Image? decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('Impossible de décoder l\'image. Format non supporté.');
    }

    if (decoded.width > _maxImageWidth) {
      decoded = img.copyResize(decoded, width: _maxImageWidth);
    }

    final compressed = img.encodeJpg(decoded, quality: _jpgQuality);
    return base64Encode(compressed);
  }

  // ─── HTTP POST avec retry exponentiel ─────────────────────────────────────
  Future<Map<String, dynamic>> _postWithRetry({
    required String prompt,
    required String base64Image,
    required int numQuestions,
  }) async {
    final url = Uri.parse(_apiUrl);
    final body = jsonEncode({
      'prompt': prompt,
      'image': base64Image,
      'num_questions': numQuestions,
      'task': 'quiz',
    });
    final storage = StorageService();
    final user = await storage.getUser();
    final userId = user?.id ?? 'guest';

    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': _apiKey,
      'x-user-id': userId,
    };

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('[AIService] Tentative $attempt/$_maxRetries...');

        final response = await http
            .post(url, headers: headers, body: body)
            .timeout(_requestTimeout);

        debugPrint('[AIService] Statut HTTP : ${response.statusCode}');

        // ✅ Gestion explicite des codes HTTP d'erreur
        if (response.statusCode == 401) {
          throw Exception('Clé API invalide ou expirée (401).');
        }
        if (response.statusCode == 429) {
          final retryAfter = attempt * 5;
          debugPrint('[AIService] Rate limit (429). Attente ${retryAfter}s...');
          await Future.delayed(Duration(seconds: retryAfter));
          continue;
        }
        if (response.statusCode >= 500) {
          throw Exception('Erreur serveur (${response.statusCode}).');
        }
        if (response.statusCode != 200) {
          throw Exception(
            'Réponse inattendue (${response.statusCode}) : ${response.body}',
          );
        }

        final data = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;

        // ✅ Le backend peut renvoyer {"error": "..."} même en 200
        if (data.containsKey('error')) {
          throw Exception('Erreur modèle : ${data['error']}');
        }

        return data;
      } on SocketException {
        if (attempt == _maxRetries) {
          throw Exception(
            'Connexion impossible. Vérifie ta connexion internet.',
          );
        }
        await _exponentialDelay(attempt);
      } on HttpException catch (e) {
        if (attempt == _maxRetries) rethrow;
        debugPrint('[AIService] HttpException : $e. Nouvelle tentative...');
        await _exponentialDelay(attempt);
      } on Exception {
        rethrow; // Ne pas réessayer sur erreurs logiques (401, format, etc.)
      }
    }

    throw Exception('Échec après $_maxRetries tentatives.');
  }

  Future<void> _exponentialDelay(int attempt) async {
    final delay = Duration(seconds: 2 * attempt);
    debugPrint('[AIService] Attente ${delay.inSeconds}s avant nouvelle tentative...');
    await Future.delayed(delay);
  }

  // ─── Parsing & nettoyage de la réponse ────────────────────────────────────
  List<QuizCard> _parseQuizResponse(Map<String, dynamic> data) {
    final String content = data['response'] as String? ?? '';
    debugPrint('[AIService] Réponse brute reçue (${content.length} chars)');

    final String jsonRaw = _extractJsonArray(content);
    final String jsonFixed = _repairJsonBackslashes(jsonRaw);

    debugPrint('[AIService] JSON nettoyé, parsing...');

    dynamic parsed;
    try {
      parsed = jsonDecode(jsonFixed);
    } catch (e) {
      throw Exception('Impossible de parser la réponse JSON : $e\n\n$jsonFixed');
    }

    final List<dynamic> jsonList = _normalizeJsonList(parsed);
    debugPrint('[AIService] ${jsonList.length} questions trouvées.');

    return jsonList.map((item) => _itemToQuizCard(item)).toList();
  }

  String _extractJsonArray(String content) {
    final start = content.indexOf('[');
    final end = content.lastIndexOf(']');
    if (start == -1 || end == -1 || end <= start) {
      throw Exception(
        'Aucun tableau JSON trouvé dans la réponse du modèle.\n'
        'Réponse reçue :\n$content',
      );
    }
    return content.substring(start, end + 1);
  }

  /// ✅ Réparation des antislashs LaTeX mal échappés dans le JSON
  String _repairJsonBackslashes(String raw) {
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final char = raw[i];
      if (char != '\\') {
        buffer.write(char);
        continue;
      }
      if (i + 1 < raw.length) {
        final next = raw[i + 1];
        // Séquences d'échappement JSON valides — on les conserve
        if ('nrt"fb/\\'.contains(next)) {
          buffer.write('\\$next');
          i++;
          continue;
        }
        // Séquence Unicode \uXXXX — on la conserve
        if (next == 'u' && i + 5 < raw.length) {
          buffer.write(raw.substring(i, i + 6));
          i += 5;
          continue;
        }
      }
      // Antislash LaTeX non valide en JSON → on l'échappe
      buffer.write('\\\\');
    }
    return buffer.toString();
  }

  List<dynamic> _normalizeJsonList(dynamic parsed) {
    if (parsed is List) return parsed;
    if (parsed is Map) {
      final list = parsed['quiz'] ?? parsed['questions'] ?? parsed['data'];
      if (list is List) return list;
    }
    throw Exception('Format JSON inattendu : ${parsed.runtimeType}');
  }

  QuizCard _itemToQuizCard(dynamic item) {
    final String q = _clean(item['question']?.toString() ?? 'Question illisible');
    final String a = _clean(item['answer']?.toString() ?? 'Réponse non trouvée');
    final String e = _clean(item['explanation']?.toString() ?? '');

    return QuizCard(
      id: item['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      question: q,
      answer: a,
      explanation: e,
    );
  }

  // ✅ Nettoyage LaTeX centralisé (une seule fonction, logique claire)
  String _clean(String text) {
    return text
        // Blocs LaTeX structurels
        .replaceAll(RegExp(r'\\begin\{[^}]*\}'), '')
        .replaceAll(RegExp(r'\\end\{[^}]*\}'), '')
        // Commandes LaTeX courantes
        .replaceAll(
          RegExp(
            r'\\(text|frac|sqrt|left|right|begin|end|cases|array|cdot|times|pm|leq|geq|neq|approx)\b',
          ),
          '',
        )
        // Accolades et antislashs résiduels
        .replaceAll(RegExp(r'\\[a-zA-Z]+'), '') // toute commande restante
        .replaceAll(RegExp(r'[{}]'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ') // espaces multiples
        .trim();
  }
}