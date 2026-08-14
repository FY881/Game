import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/models/match_models.dart';
import 'package:mamalik_alnard/core/rules/classic_ludo_rules.dart';
import 'package:mamalik_alnard/features/offline_game/training_coach.dart';

void main() {
  test('يعرض مرشد التدريب خطوة رمي النرد في بداية المباراة', () {
    final MatchState state = ClassicLudoRules.initialState(config: const MatchConfig(mode: GameMode.training));

    expect(TrainingCoach.instructionFor(state), contains('الخطوة 1'));
    expect(TrainingCoach.instructionFor(state), contains('6'));
  });

  test('يعرض مرشد التدريب خطوة اختيار الحجر بعد رمية قانونية', () {
    final MatchState state = ClassicLudoRules.roll(
      ClassicLudoRules.initialState(config: const MatchConfig(mode: GameMode.training)),
      6,
    );

    expect(TrainingCoach.instructionFor(state), contains('الخطوة 2'));
  });
}
