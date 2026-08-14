import 'dart:math';

import '../models/match_models.dart';
import '../rules/classic_ludo_rules.dart';

class LudoAi {
  const LudoAi._();

  static String? choosePawn(
    MatchState state, {
    required AiDifficulty difficulty,
    Random? random,
  }) {
    final List<String> legal = ClassicLudoRules.legalPawnIds(state);
    if (legal.isEmpty) return null;
    final Random source = random ?? Random();
    if (difficulty == AiDifficulty.easy) return legal[source.nextInt(legal.length)];

    final Player player = state.activePlayer;
    final Map<String, int> scores = <String, int>{
      for (final String id in legal) id: _scoreMove(state, player.pawns.firstWhere((Pawn pawn) => pawn.id == id), difficulty),
    };
    final int best = scores.values.reduce(max);
    final List<String> bestIds = scores.entries.where((MapEntry<String, int> entry) => entry.value == best).map((MapEntry<String, int> entry) => entry.key).toList();
    return bestIds[source.nextInt(bestIds.length)];
  }

  static int _scoreMove(MatchState state, Pawn pawn, AiDifficulty difficulty) {
    final int dice = state.dice!;
    final int progress = pawn.progress == -1 ? 0 : pawn.progress + dice;
    int score = progress * 2;
    if (pawn.progress == -1) score += 14;
    if (progress == ClassicLudoRules.homeProgress) score += 180;
    if (progress < ClassicLudoRules.trackLength) {
      final int destination = ClassicLudoRules.trackIndex(pawn.color, progress);
      if (ClassicLudoRules.safeTrackIndices.contains(destination)) score += 24;
      for (final Player opponent in state.players.where((Player player) => player.color != pawn.color)) {
        final bool captures = opponent.pawns.any((Pawn other) =>
            other.progress >= 0 &&
            other.progress < ClassicLudoRules.trackLength &&
            ClassicLudoRules.trackIndex(opponent.color, other.progress) == destination);
        if (captures && !ClassicLudoRules.safeTrackIndices.contains(destination)) score += 90;
      }
      if (difficulty == AiDifficulty.expert && !ClassicLudoRules.safeTrackIndices.contains(destination)) {
        score -= _exposurePenalty(state, pawn.color, destination);
      }
    }
    return score;
  }

  static int _exposurePenalty(MatchState state, PlayerColor color, int destination) {
    int penalty = 0;
    for (final Player opponent in state.players.where((Player player) => player.color != color)) {
      for (final Pawn pawn in opponent.pawns) {
        if (pawn.progress < 0 || pawn.progress >= ClassicLudoRules.trackLength) continue;
        final int distance = (destination - ClassicLudoRules.trackIndex(opponent.color, pawn.progress) + ClassicLudoRules.trackLength) % ClassicLudoRules.trackLength;
        if (distance >= 1 && distance <= 6) penalty += 11;
      }
    }
    return penalty;
  }
}
