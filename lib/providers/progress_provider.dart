import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_progress.dart';
import '../services/progress_service.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

final gameProgressProvider =
    StateNotifierProvider<GameProgressNotifier, GameProgress>(
  (ref) => GameProgressNotifier(ref.read(progressServiceProvider)),
);

class GameProgressNotifier extends StateNotifier<GameProgress> {
  GameProgressNotifier(this._service) : super(const GameProgress()) {
    _load();
  }

  final ProgressService _service;

  Future<void> _load() async {
    state = await _service.load();
  }

  Future<void> addVoltooidWoord() async {
    final next = state.voltooideWoorden + 1;
    state = state.copyWith(voltooideWoorden: next);
    await _service.save(state);
  }

  Future<void> addRekenGoedeBeurt() async {
    final next = state.rekenGoedeBeurten + 1;
    state = state.copyWith(rekenGoedeBeurten: next);
    await _service.save(state);
  }

  Future<void> addSpecialeBonus() async {
    state = state.copyWith(specialeBonussen: state.specialeBonussen + 1);
    await _service.save(state);
  }

  Future<void> reset() async {
    await _service.clear();
    state = const GameProgress();
  }

  /// Reset voortgang na promotie naar hoger niveau (0/20).
  Future<void> resetVoorPromotie() async {
    state = const GameProgress();
    await _service.save(state);
  }
}
