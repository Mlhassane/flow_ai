import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow/models/quiz_deck.dart';
import 'package:flow/models/quiz_card.dart';

class StorageService {
  static const String _keyDecks = 'quiz_decks';

  // Sauvegarder un nouveau deck
  Future<void> saveDeck(QuizDeck deck) async {
    final prefs = await SharedPreferences.getInstance();
    final decks = await getDecks();

    // On l'ajoute au début de la liste
    decks.insert(0, deck);

    final String encodedData = jsonEncode(
      decks.map((d) => d.toJson()).toList(),
    );

    await prefs.setString(_keyDecks, encodedData);
  }

  // Récupérer tous les decks sauvegardés
  Future<List<QuizDeck>> getDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_keyDecks);

    if (encodedData == null) return [];

    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((item) => QuizDeck.fromJson(item)).toList();
  }

  // Supprimer un deck
  Future<void> deleteDeck(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final decks = await getDecks();

    decks.removeWhere((d) => d.id == id);

    final String encodedData = jsonEncode(
      decks.map((d) => d.toJson()).toList(),
    );

    await prefs.setString(_keyDecks, encodedData);
  }

  // Récupérer toutes les cartes à réviser aujourd'hui
  Future<List<QuizCard>> getDueCards() async {
    final decks = await getDecks();
    final now = DateTime.now();
    List<QuizCard> dueCards = [];

    for (var deck in decks) {
      for (var card in deck.cards) {
        if (card.nextReview.isBefore(now)) {
          dueCards.add(card);
        }
      }
    }
    return dueCards;
  }

  // Mettre à jour une carte spécifique dans son deck
  Future<void> updateCard(QuizCard updatedCard) async {
    final decks = await getDecks();
    bool found = false;

    for (int i = 0; i < decks.length; i++) {
      final cards = decks[i].cards;
      for (int j = 0; j < cards.length; j++) {
        if (cards[j].id == updatedCard.id) {
          cards[j] = updatedCard;
          found = true;
          break;
        }
      }
      if (found) break;
    }

    if (found) {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(
        decks.map((d) => d.toJson()).toList(),
      );
      await prefs.setString(_keyDecks, encodedData);
    }
  }
}
