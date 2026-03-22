import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flow/models/quiz_card.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flow/services/storage_service.dart';

class TutorService {
  final String _apiUrl = 'https://mahamanelawaly-mon-api-ia.hf.space/generate';

  Future<String> sendMessage(
    String message, {
    String? userLevel,
    String? country,
    String? examType,
    String? series,
    List<QuizCard>? cards,
    File? image,
    String? userName,
  }) async {
    final String levelContext = userLevel != null
        ? "L'élève est en classe de $userLevel${series != null && series.isNotEmpty ? ' ($series)' : ''}."
        : "";
    
    final String regionContext = country != null 
        ? "Pays : ${country == 'ML' ? 'Mali' : country == 'BF' ? 'Burkina Faso' : 'Niger'}. Examen préparé : ${examType ?? 'BAC'}."
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
### RÔLE : TU ES UN TUTEUR IA EXPERT ET BIENVEILLANT (SYSTÈME AES).
Tu t'adresses à ${userName ?? "l'élève"}.
Ton objectif est de transformer l'élève en acteur de sa propre réussite.
$levelContext
$regionContext
$cardsContext

### PROTOCOLE DE GUIDAGE STRATÉGIQUE :
1. ANALYSE DES CONTRAINTES : Si l'exercice demande une méthode précise (ex: substitution, combinaison, graphique), tu DOIS t'y tenir et le rappeler à l'élève.
2. CHOIX DU CHEMIN ÉCONOMIQUE : Aide l'élève à trouver la variable la plus simple à isoler ou le calcul le moins risqué.
3. MÉTHODE SOCRATIQUE : Ne donne JAMAIS la solution finale. Pose des questions progressives (ex: "Quelle lettre semble la plus facile à isoler ici ?").
4. NOTATION SIMPLIFIÉE : Écris les maths de manière lisible sans LaTeX complexe (ex: "système { 2x + 3y = -1 ; x - 2y = 3 }").

### STYLE DE RÉPONSE (L'APPROCHE FLOW) :
Commence toujours par valider ce que tu vois sur l'image ou dans le message, puis rappelle la contrainte de l'exercice, et termine par une question ouverte pour faire réfléchir l'élève.

Exemple : "Je vois que tu attaques l'exercice sur les systèmes ! La consigne impose la méthode par substitution. Te souviens-tu du principe de cette méthode avant de commencer ?"

### RÈGLES DE RÉPONSE (STRICTES) :
- INTERDICTION DE LATEX (Pas de \begin, \frac, sqrt). Utilise des mots ou des symboles claviers (/, ^2, sqrt).
- Réponse courte (max 3-4 phrases), percutante et pédagogique.
- Si une image est fournie, nomme l'exercice ou la question détectée.

### MESSAGE / IMAGE DE L'ÉLÈVE :
$message
""";

    String? base64Image;
    if (image != null) {
      base64Image = await _compressAndEncodeImage(image);
    }

    try {
      final storage = StorageService();
      final user = await storage.getUser();
      final userId = user?.id ?? 'guest';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'flow_secure_2024',
          'x-user-id': userId,
        },
        body: jsonEncode({
          'prompt': fullPrompt,
          'image': base64Image,
          'task': 'chat',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String content =
            data['response']?.toString() ??
            "Désolé, je n'ai pas pu formuler de réponse.";

        return _clean(content); // On nettoie la réponse avant de la renvoyer
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur TutorService: $e');
      return "Désolé, je n'arrive pas à réfléchir pour le moment. Vérifie ta connexion internet.";
    }
  }

  /// Nettoyage robuste pour supprimer les restes de LaTeX que l'IA pourrait envoyer
  String _clean(String text) {
    return text
        .replaceAll(RegExp(r'\\begin\{.*\}|\\end\{.*\}'), '')
        .replaceAll(RegExp(r'\\left\{|\\right\.'), '')
        .replaceAll(RegExp(r'\\array\{.*\}'), '')
        .replaceAll(
          RegExp(
            r'\\(text|frac|sqrt|left|right|begin|end|cases|cdot|times|pm|leq|geq|neq|approx|alpha|beta|gamma|delta|theta|pi|sigma|omega|lambda)\b',
          ),
          '',
        )
        .replaceAll(RegExp(r'[\\{}]+'), ' ')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  Future<String> _compressAndEncodeImage(File image) async {
    final bytes = await image.readAsBytes();
    img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) return "";

    if (decoded.width > 1024) {
      decoded = img.copyResize(decoded, width: 1024);
    }
    final compressed = img.encodeJpg(decoded, quality: 70);
    return base64Encode(compressed);
  }
}
