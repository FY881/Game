import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/ai/ludo_ai.dart';
import 'package:mamalik_alnard/core/models/match_models.dart';
import 'package:mamalik_alnard/core/rules/classic_ludo_rules.dart';

void main() {
  test('الذكاء المتوسط يفضل حركة التقاط قانونية عندما تكون متاحة', () {
    final MatchState base = ClassicLudoRules.initialState(humanPlayers: 0);
    final List<Player> players = base.players.map((Player player) => player.copyWith()).toList();
    players[0] = players[0].copyWith(
      pawns: <Pawn>[
        const Pawn(id: 'coral-capture', color: PlayerColor.coral, progress: 0),
        const Pawn(id: 'coral-other', color: PlayerColor.coral, progress: 2),
        ...players[0].pawns.skip(2),
      ],
    );
    players[1] = players[1].copyWith(
      pawns: <Pawn>[const Pawn(id: 'sapphire-target', color: PlayerColor.sapphire, progress: 40), ...players[1].pawns.skip(1)],
    );
    final MatchState state = MatchState(players: players, currentPlayer: 0, phase: MatchPhase.selectingPawn, dice: 1);

    final String? choice = LudoAi.choosePawn(state, difficulty: AiDifficulty.medium, random: Random(1));

    expect(choice, 'coral-capture');
  });
}
