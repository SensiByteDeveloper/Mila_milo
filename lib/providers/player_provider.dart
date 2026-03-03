import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player_profile.dart';
import '../services/player_storage_service.dart';

final playerStorageProvider = Provider<PlayerStorageService>((ref) {
  return PlayerStorageService();
});

final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfile?>((ref) {
  final storage = ref.watch(playerStorageProvider);
  return PlayerProfileNotifier(storage);
});

class PlayerProfileNotifier extends StateNotifier<PlayerProfile?> {
  PlayerProfileNotifier(this._storage) : super(null) {
    _load();
  }

  final PlayerStorageService _storage;

  Future<void> _load() async {
    state = await _storage.load();
  }

  Future<void> setProfile(PlayerProfile profile) async {
    state = profile;
    await _storage.save(profile);
  }

  Future<void> clear() async {
    state = null;
    await _storage.clear();
  }
}
