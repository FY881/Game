import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/settings/game_settings.dart';
import 'package:mamalik_alnard/core/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('يحفظ إعدادات الإتاحة المحلية ويستعيدها', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SettingsStore store = SettingsStore();
    const GameSettings expected = GameSettings(
      textScale: 1.15,
      reduceMotion: true,
      pace: GamePace.calm,
      soundEnabled: false,
      vibrationEnabled: false,
      colorVisionMode: ColorVisionMode.deuteranopia,
      performanceMode: PerformanceMode.batterySaver,
    );

    await store.save(expected);
    final GameSettings restored = await store.load();

    expect(restored.textScale, 1.15);
    expect(restored.reduceMotion, isTrue);
    expect(restored.pace, GamePace.calm);
    expect(restored.soundEnabled, isFalse);
    expect(restored.vibrationEnabled, isFalse);
    expect(restored.colorVisionMode, ColorVisionMode.deuteranopia);
    expect(restored.performanceMode, PerformanceMode.batterySaver);
  });
}
