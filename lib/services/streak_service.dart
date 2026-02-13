import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const String _keyLastAppOpen = 'last_app_open';
  static const String _keyCurrentStreak = 'current_streak';

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentStreak) ?? 0;
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastOpenStr = prefs.getString(_keyLastAppOpen);

    if (lastOpenStr == null) {
      // Premier jour
      await prefs.setInt(_keyCurrentStreak, 1);
      await prefs.setString(_keyLastAppOpen, today.toIso8601String());
      return;
    }

    final lastOpen = DateTime.parse(lastOpenStr);
    final difference = today.difference(lastOpen).inDays;

    if (difference == 1) {
      // Jour consécutif
      int currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
      await prefs.setInt(_keyCurrentStreak, currentStreak + 1);
      await prefs.setString(_keyLastAppOpen, today.toIso8601String());
    } else if (difference > 1) {
      // Streak brisé
      await prefs.setInt(_keyCurrentStreak, 1);
      await prefs.setString(_keyLastAppOpen, today.toIso8601String());
    }
    // Si difference == 0, on ne fait rien (déjà ouvert aujourd'hui)
  }

  // Vérifier si le streak est "actif" aujourd'hui
  Future<bool> isStreakMaintainedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastOpenStr = prefs.getString(_keyLastAppOpen);

    if (lastOpenStr == null) return false;
    final lastOpen = DateTime.parse(lastOpenStr);
    return today.isAtSameMomentAs(lastOpen);
  }
}
