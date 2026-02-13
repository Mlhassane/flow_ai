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
### PERSONA : TU ES UN PROFESSEUR EXPERT ET PASSIONNÉ AU TABLEAU.
$levelContext

### TA MISSION :
Analyse l'image. S'il s'agit d'une épreuve, corrige-la au tableau avec pédagogie.

### RÈGLES DE RÉDACTION :
1. **Matière** : Précise la matière.
2. **Style** : Décompose les calculs, cite les formules, écris les équations chimiques.
3. **LaTeX** : Utilise le LaTeX NORMALEMENT (ex: \\frac{a}{b}, \\begin{cases}). Ne t'inquiète pas du JSON, je m'en occupe.
4. **Format** : Sois structuré et clair.

### FORMAT JSON (STRICT) :
{
  "is_exam": true,
  "subject": "MATIERE",
  "correction": "# TITRE\\n\\n## Analyse\\n...\\n## Résolution\\n...",
  "similar_exercises": ["Exo 1", "Exo 2"],
  "pedagogical_advice": "Conseil."
}
""";

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        body: jsonEncode({
          'prompt': prompt,
          'image': base64Image,
          'type': 'correction',
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

      // 2. ALGORITHME DE SUTURE JSON (Réparation des antislashs LaTeX)
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
        return CorrectionResult.fromJson(decoded);
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
