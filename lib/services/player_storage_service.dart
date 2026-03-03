import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_profile.dart';

/// Persisteert het PlayerProfile lokaal.
class PlayerStorageService {
  static const String _key = 'mila_milo_player_profile';

  Future<void> save(PlayerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<PlayerProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    try {
      return PlayerProfile.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
