import 'dart:convert';
import 'dart:io';
import 'package:flow/models/correction.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class CorrectorService {
  final String _apiUrl = 'https://mahamanelawaly-mon-api-ia.hf.space/generate';
  final String _apiKey = 'flow_secure_2024';

  Future<CorrectionResult> correctExam(File image, {String? userLevel}) async {
    // 1. Compression de l'image
    final bytes = await image.readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) throw Exception('Impossible de lire l\'image');

    if (decodedImage.width > 1024) {
      decodedImage = img.copyResize(decodedImage, width: 1024);
    }
    final compressedBytes = img.encodeJpg(decodedImage, quality: 70);
    final base64Image = base64Encode(compressedBytes);

    final String levelContext = userLevel != null
        ? "L'élève est en classe de : $userLevel."
        : "";

    final prompt =
        """
Tu es un correcteur IA expert. Analyse cette épreuve et fournis une correction CONCISE.
$levelContext

RÈGLES STRICTES :
1. Correction en 3-5 étapes numérotées maximum
2. Chaque étape = 1 phrase courte et claire
3. PAS de Markdown complexe (pas de #, ##, *, -)
4. Utilise le format : Étape 1:, Étape 2:, etc.
5. Maximum 200 mots pour la correction totale
6. PAS DE LATEX : Écris les maths comme un humain (ex: 2x + 5 = 15)

EXEMPLE DE RÉPONSE ATTENDUE :
{
  "is_exam": true,
  "subject": "Mathématiques",
  "correction": "Étape 1: On identifie l'équation 2x + 5 = 15. Étape 2: On soustrait 5 des deux côtés pour obtenir 2x = 10. Étape 3: On divise par 2 pour trouver x = 5. Étape 4: Vérification en remplaçant x par 5 dans l'équation originale.",
  "similar_exercises": ["Résoudre 3x + 7 = 22", "Résoudre x - 4 = 10"],
  "pedagogical_advice": "Vérifie toujours ta solution en la remplaçant dans l'équation de départ."
}

FORMAT JSON (STRICT) - RÉPONDS UNIQUEMENT AVEC CE JSON :
{
  "is_exam": true ou false,
  "subject": "MATIERE",
  "correction": "Étape 1: ... Étape 2: ... Étape 3: ...",
  "similar_exercises": ["Exercice 1", "Exercice 2"],
  "pedagogical_advice": "Conseil court et pratique."
}
""";

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({
          'prompt': prompt,
          'image': base64Image,
          'task': 'correction',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      String content = data['response'] ?? '';

      print('--- [CorrectorService] Réponse brute reçue ---');

      // 1. Extraction de la zone JSON
      int startIdx = content.indexOf('{');
      int endIdx = content.lastIndexOf('}');
      if (startIdx == -1 || endIdx == -1)
        throw Exception('Réponse JSON non trouvée');
      String jsonRaw = content.substring(startIdx, endIdx + 1);

      // 2. ALGORITHME DE SUTURE JSON (Échappement des backslashes)
      final StringBuffer buffer = StringBuffer();
      for (int i = 0; i < jsonRaw.length; i++) {
        final char = jsonRaw[i];
        if (char == '\\') {
          if (i + 1 < jsonRaw.length) {
            final next = jsonRaw[i + 1];
            // Si c'est un échappement JSON valide, on le garde
            if ('nrt"fb/\\'.contains(next)) {
              buffer.write('\\');
              buffer.write(next);
              i++;
              continue;
            }
            // Support unicode
            if (next == 'u' && i + 5 < jsonRaw.length) {
              buffer.write(jsonRaw.substring(i, i + 6));
              i += 5;
              continue;
            }
          }
          // Sinon, c'est un antislash LaTeX "nu", on le double pour le JSON
          buffer.write('\\\\');
        } else {
          buffer.write(char);
        }
      }

      final String sanitizedJson = buffer.toString();

      try {
        final decoded = jsonDecode(sanitizedJson);
        if (decoded is List) {
          return CorrectionResult(
            isExam: true,
            subject: "Général",
            structuredCorrection: "Erreur de formatage IA.",
            similarExercises: [],
            pedagogicalAdvice: "Veuillez réessayer.",
          );
        }

        // Nettoyage final du texte pour enlever tout reste de LaTeX
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

        final result = CorrectionResult.fromJson(decoded);
        return CorrectionResult(
          isExam: result.isExam,
          subject: result.subject,
          structuredCorrection: clean(result.structuredCorrection),
          similarExercises: result.similarExercises
              .map((e) => clean(e))
              .toList(),
          pedagogicalAdvice: clean(result.pedagogicalAdvice),
        );
      } catch (e) {
        print('--- [CorrectorService] Échec final du parsing : $e ---');
        print('--- [CorrectorService] JSON Sanitisé : $sanitizedJson ---');
        throw Exception('Format de réponse invalide.');
      }
    } catch (e) {
      print('Erreur CorrectorService: $e');
      rethrow;
    }
  }
}
