import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/match_models.dart';
import '../../core/ai/ludo_ai.dart';
import '../../core/rules/classic_ludo_rules.dart';

final NotifierProvider<OfflineMatchController, MatchState> offlineMatchProvider =
    NotifierProvider<OfflineMatchController, MatchState>(OfflineMatchController.new);

class OfflineMatchController extends Notifier<MatchState> {
  final Random _random = Random();

  @override
  MatchState build() => ClassicLudoRules.initialState();

  void newMatch({int humanPlayers = 1}) {
    state = ClassicLudoRules.initialState(humanPlayers: humanPlayers);
  }

  void rollDice() {
    state = ClassicLudoRules.roll(state, _random.nextInt(6) + 1);
  }

  void movePawn(String pawnId) {
    state = ClassicLudoRules.move(state, pawnId);
  }

  void playAiTurn({AiDifficulty difficulty = AiDifficulty.medium}) {
    if (state.phase != MatchPhase.rolling || state.activePlayer.isHuman || state.winner != null) return;
    state = ClassicLudoRules.roll(state, _random.nextInt(6) + 1);
    final String? pawnId = LudoAi.choosePawn(state, difficulty: difficulty, random: _random);
    if (pawnId != null) state = ClassicLudoRules.move(state, pawnId);
  }
}
