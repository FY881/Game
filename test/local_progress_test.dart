import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/models/match_models.dart';
import 'package:mamalik_alnard/core/progression/local_progress.dart';
import 'package:mamalik_alnard/core/rules/classic_ludo_rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('تحتسب مكافأة محلية ثابتة وعادلة لفوز اللاعب البشري', () {
    final MatchState state = ClassicLudoRules.initialState().copyWith(phase: MatchPhase.finished, winner: PlayerColor.coral);

    final MatchReward reward = LocalProgressController.rewardFor(state);

    expect(reward.isLocalWin, isTrue);
    expect(reward.experience, 40);
    expect(reward.gold, 25);
  });

  test('يحفظ سجل النتائج والتحديات المكتملة محليًا', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final LocalProgressStore store = LocalProgressStore();
    const MatchRecord record = MatchRecord(
      id: 'result-1',
      playedAtMilliseconds: 1,
      mode: GameMode.quick,
      winner: PlayerColor.coral,
      isLocalWin: true,
      experience: 30,
      gold: 20,
      heroId: 'knight',
      mapId: 'royal_harbor',
    );

    await store.save(const LocalProgressState(records: <MatchRecord>[record], completedChallengeIds: <String>{'quick_route'}));
    final LocalProgressState restored = await store.load();

    expect(restored.records, hasLength(1));
    expect(restored.records.single.mode, GameMode.quick);
    expect(restored.completedChallengeIds, contains('quick_route'));
  });

  test('تطابق التحديات إعداد المباراة المقصود فقط', () {
    const MatchConfig config = MatchConfig(mode: GameMode.quick, humanPlayers: 1, aiDifficulty: AiDifficulty.medium, mapId: 'royal_harbor');

    expect(SoloChallenges.byConfig(config)?.id, 'quick_route');
    expect(SoloChallenges.byConfig(const MatchConfig(mode: GameMode.quick, aiDifficulty: AiDifficulty.easy)), isNull);
  });
}
