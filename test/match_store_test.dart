import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/models/match_models.dart';
import 'package:mamalik_alnard/core/rules/classic_ludo_rules.dart';
import 'package:mamalik_alnard/core/storage/match_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('يحفظ MatchStore إعدادات الوضع السريع وحالة الإيقاف ويستعيدها', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final MatchStore store = MatchStore();
    final MatchState initial = ClassicLudoRules.initialState(
      config: const MatchConfig(mode: GameMode.quick, humanPlayers: 2, aiDifficulty: AiDifficulty.expert),
    );
    final MatchState paused = initial.copyWith(isPaused: true, message: 'اختبار الحفظ');

    await store.save(paused);
    final MatchState? restored = await store.load();

    expect(restored, isNotNull);
    expect(restored!.config.mode, GameMode.quick);
    expect(restored.config.humanPlayers, 2);
    expect(restored.config.aiDifficulty, AiDifficulty.expert);
    expect(restored.isPaused, isTrue);
    expect(restored.message, 'اختبار الحفظ');
  });
}
