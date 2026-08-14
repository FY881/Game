import '../models/match_models.dart';

class ClassicLudoRules {
  static const int trackLength = 52;
  static const int homeProgress = 57;
  static const Set<int> safeTrackIndices = <int>{0, 8, 13, 21, 26, 34, 39, 47};
  static const List<int> _startOffsets = <int>[0, 13, 26, 39];

  static MatchState initialState({MatchConfig? config, int? humanPlayers}) {
    final MatchConfig effectiveConfig = config ?? MatchConfig(humanPlayers: humanPlayers ?? 1);
    final List<Player> players = PlayerColor.values.map((PlayerColor color) {
      final int playerIndex = color.index;
      return Player(
        color: color,
        isHuman: playerIndex < effectiveConfig.humanPlayers,
        pawns: List<Pawn>.generate(
          effectiveConfig.pawnsPerPlayer,
          (int index) => Pawn(id: '${color.name}-$index', color: color, progress: -1),
        ),
      );
    }).toList();
    return MatchState(players: players, currentPlayer: 0, phase: MatchPhase.rolling, config: effectiveConfig);
  }

  static int trackIndex(PlayerColor color, int progress) {
    assert(progress >= 0 && progress < trackLength);
    return (_startOffsets[color.index] + progress) % trackLength;
  }

  static List<String> legalPawnIds(MatchState state) {
    final int? dice = state.dice;
    if (state.phase != MatchPhase.selectingPawn || dice == null) return <String>[];
    return state.activePlayer.pawns
        .where((Pawn pawn) => (pawn.progress == -1 && state.config.canEnterWith(dice)) ||
            (pawn.progress >= 0 && pawn.progress + dice <= state.config.homeProgress))
        .map((Pawn pawn) => pawn.id)
        .toList();
  }

  static MatchState roll(MatchState state, int value) {
    if (state.isPaused || state.phase != MatchPhase.rolling || value < 1 || value > 6) return state;
    final MatchState rolled = state.copyWith(
      dice: value,
      phase: MatchPhase.selectingPawn,
      message: 'ظهرت $value. اختر حجرًا للتحريك.',
    );
    if (legalPawnIds(rolled).isNotEmpty) return rolled;
    return _finishTurn(rolled, 'لا توجد حركة قانونية لهذه الرمية.');
  }

  static MatchState move(MatchState state, String pawnId) {
    if (state.isPaused || !legalPawnIds(state).contains(pawnId)) return state;
    final int dice = state.dice!;
    final List<Player> players = state.players.map((Player player) => player.copyWith(pawns: List<Pawn>.from(player.pawns))).toList();
    final Player active = players[state.currentPlayer];
    final int pawnIndex = active.pawns.indexWhere((Pawn pawn) => pawn.id == pawnId);
    final Pawn selected = active.pawns[pawnIndex];
    final int nextProgress = selected.progress == -1 ? 0 : selected.progress + dice;
    active.pawns[pawnIndex] = selected.copyWith(progress: nextProgress);

    String message = 'تحرك الحجر $dice خانات.';
    if (nextProgress < trackLength) {
      final int destination = trackIndex(active.color, nextProgress);
      if (!safeTrackIndices.contains(destination)) {
        for (int playerIndex = 0; playerIndex < players.length; playerIndex++) {
          if (playerIndex == state.currentPlayer) continue;
          final Player opponent = players[playerIndex];
          for (int index = 0; index < opponent.pawns.length; index++) {
            final Pawn pawn = opponent.pawns[index];
            if (pawn.progress >= 0 && pawn.progress < trackLength && trackIndex(opponent.color, pawn.progress) == destination) {
              opponent.pawns[index] = pawn.copyWith(progress: -1);
              message = 'تمت إعادة حجر الخصم إلى القاعدة.';
            }
          }
        }
      }
    }

    final bool won = active.pawns.every((Pawn pawn) => pawn.progress == state.config.homeProgress);
    if (won) {
      return state.copyWith(
        players: players,
        phase: MatchPhase.finished,
        winner: active.color,
        message: '${active.color.label} وصل بكل الأحجار إلى القصر!',
      );
    }
    return _finishTurn(state.copyWith(players: players), message);
  }

  static MatchState _finishTurn(MatchState state, String message) {
    final bool bonusTurn = state.dice == 6;
    final int nextPlayer = bonusTurn ? state.currentPlayer : (state.currentPlayer + 1) % state.players.length;
    return state.copyWith(
      currentPlayer: nextPlayer,
      phase: MatchPhase.rolling,
      clearDice: true,
      message: bonusTurn ? '$message لك رمية إضافية.' : message,
    );
  }

  static int? previewProgress(MatchState state, String pawnId) {
    if (!legalPawnIds(state).contains(pawnId)) return null;
    final Pawn pawn = state.activePlayer.pawns.firstWhere((Pawn item) => item.id == pawnId);
    return pawn.progress == -1 ? 0 : pawn.progress + state.dice!;
  }
}
