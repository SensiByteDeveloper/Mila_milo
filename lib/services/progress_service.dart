import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_progress.dart';

/// Persisteert GameProgress lokaal.
class ProgressService {
  static const String _key = 'mila_milo_game_progress';

  Future<void> save(GameProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(progress.toJson()));
  }

  Future<GameProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return const GameProgress();
    try {
      return GameProgress.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (_) {
      return const GameProgress();
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
