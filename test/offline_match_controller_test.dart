import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mamalik_alnard/core/models/match_models.dart';
import 'package:mamalik_alnard/features/offline_game/offline_match_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('وضع التدريب يعيد الحالة السابقة عند التراجع', () {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final OfflineMatchController controller = container.read(offlineMatchProvider.notifier);

    controller.newMatch(config: const MatchConfig(mode: GameMode.training));
    final MatchState beforeRoll = container.read(offlineMatchProvider);
    controller.rollDice();

    expect(controller.canUndo, isTrue);
    controller.undoTrainingStep();
    final MatchState restored = container.read(offlineMatchProvider);

    expect(restored.currentPlayer, beforeRoll.currentPlayer);
    expect(restored.phase, beforeRoll.phase);
    expect(restored.dice, beforeRoll.dice);
    expect(restored.message, contains('التراجع'));
  });
}
