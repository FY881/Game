import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ludo_ai.dart';
import '../../core/models/match_models.dart';
import '../../core/rules/classic_ludo_rules.dart';
import '../../core/storage/match_store.dart';

final NotifierProvider<OfflineMatchController, MatchState> offlineMatchProvider =
    NotifierProvider<OfflineMatchController, MatchState>(OfflineMatchController.new);

class OfflineMatchController extends Notifier<MatchState> {
  final Random _random = Random();
  final MatchStore _store = MatchStore();
  bool _stateTouched = false;

  @override
  MatchState build() => ClassicLudoRules.initialState();

  void newMatch({MatchConfig config = const MatchConfig()}) {
    _stateTouched = true;
    _set(ClassicLudoRules.initialState(config: config));
  }

  void rollDice() {
    _stateTouched = true;
    _set(ClassicLudoRules.roll(state, _random.nextInt(6) + 1));
  }

  void movePawn(String pawnId) {
    _stateTouched = true;
    _set(ClassicLudoRules.move(state, pawnId));
  }

  void playAiTurn() {
    if (state.isPaused || state.phase != MatchPhase.rolling || state.activePlayer.isHuman || state.winner != null) return;
    _set(ClassicLudoRules.roll(state, _random.nextInt(6) + 1));
    final String? pawnId = LudoAi.choosePawn(state, difficulty: state.config.aiDifficulty, random: _random);
    if (pawnId != null) _set(ClassicLudoRules.move(state, pawnId));
  }

  void togglePause() {
    _stateTouched = true;
    _set(state.copyWith(isPaused: !state.isPaused, message: state.isPaused ? 'استؤنفت المباراة.' : 'المباراة متوقفة مؤقتًا.'));
  }

  Future<bool> restoreLastMatch() async {
    final MatchState? restored = await _store.load();
    if (restored == null || _stateTouched) return false;
    state = restored;
    return true;
  }

  Future<bool> hasSavedMatch() => _store.exists();

  Future<void> clearSavedMatch() => _store.clear();

  void _set(MatchState next) {
    state = next;
    unawaited(_store.save(next));
  }
}
