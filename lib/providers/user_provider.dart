import 'package:flutter/material.dart';
import 'package:flow/models/user.dart';
import 'package:flow/services/storage_service.dart';

class UserProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;

  // Coûts des services en Cauris
  static const int costQuiz = 20;
  static const int costCorrection = 50;
  static const int costTutor = 5;

  UserProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    _user = await _storageService.getUser();
    _isLoading = false;
    notifyListeners();
  }

  /// Vérifie si l'utilisateur a assez de cauris
  bool hasEnoughCauris(int amount) {
    if (_user == null) return false;
    return _user!.coins >= amount;
  }

  /// Dépense des cauris pour un service
  Future<bool> spendCauris(int amount) async {
    if (_user == null || !hasEnoughCauris(amount)) return false;

    _user = _user!.copyWith(coins: _user!.coins - amount);
    await _storageService.saveUser(_user!);
    notifyListeners();
    return true;
  }

  /// Gagne des cauris (ex: après un quiz réussi ou un bonus quotidien)
  Future<void> addCauris(int amount) async {
    if (_user == null) return;

    _user = _user!.copyWith(coins: _user!.coins + amount);
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  /// Met à jour les statistiques de l'utilisateur
  Future<void> updateStats({int? addFlashcards, int? addQuizzes}) async {
    if (_user == null) return;

    _user = _user!.copyWith(
      totalFlashcards: _user!.totalFlashcards + (addFlashcards ?? 0),
      totalQuizzes: _user!.totalQuizzes + (addQuizzes ?? 0),
    );
    await _storageService.saveUser(_user!);
    notifyListeners();
  }
}
