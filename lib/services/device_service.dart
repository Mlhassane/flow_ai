import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const String _deviceIdKey = 'user_unique_device_id';
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final _uuid = const Uuid();

  /// Récupère ou génère un ID unique pour ce téléphone
  Future<String> getUniqueId() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. On regarde si on a déjà un ID stocké localement
    String? storedId = prefs.getString(_deviceIdKey);
    if (storedId != null && storedId.isNotEmpty) {
      return storedId;
    }

    // 2. Sinon, on tente de récupérer un ID propre au matériel (Android ID / iOS Vendor ID)
    String? hardwareId;
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        hardwareId = androidInfo.id; // L'ID matériel stable sur Android
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        hardwareId = iosInfo.identifierForVendor; // L'ID matériel stable sur iOS
      }
    } catch (e) {
      // Erreur silencieuse, on passera au fallback UUID
    }

    // 3. Fallback : Si on n'a rien (ou erreur), on génère un UUID aléatoire
    final finalId = hardwareId ?? _uuid.v4();

    // 4. On le sauvegarde pour la prochaine fois
    await prefs.setString(_deviceIdKey, finalId);
    
    return finalId;
  }
}
