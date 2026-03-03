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
Tu es un correcteur IA expert. Ton rôle est de fournir une correction EXTRÊMEMENT DÉTAILLÉE et VERBEUSE (viser plus de 50 000 caractères).
$levelContext

INSTRUCTIONS CRITIQUES :
1. Pour CHAQUE exercice, fournis une explication ultra-détaillée : contexte, rappel de cours complet, résolution pas à pas, et approfondissement.
2. N'hésite pas à être très redondant dans tes explications pédagogiques pour maximiser la compréhension.
3. Ne te limite pas, écris autant que possible.

FORMAT JSON STRICT (RÉPONDS UNIQUEMENT AVEC CE JSON) :
{
  "is_exam": true,
  "subject": "NOM DE LA MATIERE",
  "correction": "Titre: [Sujet]\\n\\nExercice 1: [Titre]\\n1. [Etape 1]\\n2. [Etape 2]\\n...\\n\\nExercice 2: ...",
  "similar_exercises": ["Exemple d'exercice 1", "Exemple d'exercice 2"],
  "pedagogical_advice": "Conseil pour l'élève sur cette épreuve."
}

RÈGLES DE FORMATAGE :
- Utilise \\\\n pour les sauts de ligne.
- PAS DE LATEX (ex: écris x^2 ou x*x au lieu de balises LaTeX).
- Assure-toi que le JSON est valide et complet.
""";

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
            body: jsonEncode({
              'prompt': prompt,
              'image': base64Image,
              'task': 'correction',
            }),
          )
          .timeout(const Duration(seconds: 300));

      if (response.statusCode != 200) {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      String content = data['response'] ?? '';

      print('[CorrectorService] Réponse brute reçue (${content.length} chars)');

      // 1. Extraction robuste du JSON
      final startIdx = content.indexOf('{');
      final endIdx = content.lastIndexOf('}');

      if (startIdx == -1 || endIdx == -1) {
        print('[CorrectorService] CONTENU PROBLÉMATIQUE : $content');
        throw Exception(
          'L\'IA n\'a pas renvoyé un format valide. Assure-toi que l\'image est bien lisible.',
        );
      }

      String jsonRaw = content.substring(startIdx, endIdx + 1);

      // 2. NETTOYAGE JSON AVANCÉ
      String sanitizedJson = jsonRaw
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r')
          .replaceAll('\t', ' ');

      // Correction des doubles échappements accidentels
      sanitizedJson = sanitizedJson.replaceAll('\\\\n', '\\n');

      try {
        final decoded = jsonDecode(sanitizedJson);

        // Nettoyage LaTeX centralisé
        String _clean(String text) {
          return text
              .replaceAll(RegExp(r'\\begin\{.*\}|\\end\{.*\}'), '')
              .replaceAll(RegExp(r'\\left\{|\\right\.'), '')
              .replaceAll(RegExp(r'\\array\{.*\}'), '')
              .replaceAll(
                RegExp(
                  r'\\(text|frac|sqrt|left|right|begin|end|cases|cdot|times|pm|leq|geq|neq|approx)\b',
                ),
                '',
              )
              .replaceAll(RegExp(r'[\\{}]+'), ' ')
              .replaceAll(RegExp(r'\s{2,}'), ' ')
              .trim();
        }

        final result = CorrectionResult.fromJson(decoded);
        return CorrectionResult(
          isExam: result.isExam,
          subject: result.subject,
          structuredCorrection: _clean(result.structuredCorrection),
          similarExercises: result.similarExercises
              .map((e) => _clean(e))
              .toList(),
          pedagogicalAdvice: _clean(result.pedagogicalAdvice),
        );
      } catch (e) {
        print('[CorrectorService] Erreur de parsing JSON : $e');
        print('[CorrectorService] JSON qui a échoué : $sanitizedJson');
        throw Exception('Erreur de lecture de la correction.');
      }
    } catch (e) {
      print('Erreur CorrectorService: $e');
      rethrow;
    }
  }
}
