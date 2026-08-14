import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/models/match_models.dart';
import 'package:mamalik_alnard/core/rules/classic_ludo_rules.dart';

void main() {
  group('ClassicLudoRules', () {
    test('لا يخرج حجر من القاعدة إلا عند رمية ستة', () {
      final MatchState started = ClassicLudoRules.initialState();
      final MatchState rolled = ClassicLudoRules.roll(started, 5);

      expect(rolled.phase, MatchPhase.rolling);
      expect(rolled.currentPlayer, 1);
      expect(rolled.activePlayer.pawns.every((Pawn pawn) => pawn.progress == -1), isTrue);
    });

    test('تخرج رمية ستة حجرًا وتمنح رمية إضافية', () {
      final MatchState started = ClassicLudoRules.initialState();
      final MatchState rolled = ClassicLudoRules.roll(started, 6);
      final String pawnId = ClassicLudoRules.legalPawnIds(rolled).first;
      final MatchState moved = ClassicLudoRules.move(rolled, pawnId);

      expect(moved.players.first.pawns.first.progress, 0);
      expect(moved.currentPlayer, 0);
      expect(moved.phase, MatchPhase.rolling);
    });

    test('يعيد حجر الخصم عند الالتقاء في خانة غير آمنة', () {
      final MatchState base = ClassicLudoRules.initialState();
      final List<Player> players = base.players.map((Player player) => player.copyWith()).toList();
      players[0] = players[0].copyWith(pawns: <Pawn>[Pawn(id: 'coral-0', color: PlayerColor.coral, progress: 0), ...players[0].pawns.skip(1)]);
      players[1] = players[1].copyWith(pawns: <Pawn>[Pawn(id: 'sapphire-0', color: PlayerColor.sapphire, progress: 40), ...players[1].pawns.skip(1)]);
      final MatchState state = MatchState(players: players, currentPlayer: 0, phase: MatchPhase.selectingPawn, dice: 1);

      final MatchState moved = ClassicLudoRules.move(state, 'coral-0');

      expect(moved.players[1].pawns.first.progress, -1);
    });

    test('يرفض تجاوز الرقم المطلوب للوصول إلى القصر', () {
      final MatchState base = ClassicLudoRules.initialState();
      final List<Player> players = base.players.map((Player player) => player.copyWith()).toList();
      players[0] = players[0].copyWith(pawns: <Pawn>[Pawn(id: 'coral-0', color: PlayerColor.coral, progress: 56), ...players[0].pawns.skip(1)]);
      final MatchState state = MatchState(players: players, currentPlayer: 0, phase: MatchPhase.selectingPawn, dice: 2);

      expect(ClassicLudoRules.legalPawnIds(state), isEmpty);
    });

    test('الوضع السريع يستخدم ثلاثة أحجار ويقبل الدخول برمية خمسة', () {
      final MatchState state = ClassicLudoRules.initialState(config: const MatchConfig(mode: GameMode.quick));
      final MatchState rolled = ClassicLudoRules.roll(state, 5);

      expect(rolled.activePlayer.pawns, hasLength(3));
      expect(ClassicLudoRules.legalPawnIds(rolled), isNotEmpty);
    });
  });
}
