import 'package:shared_preferences/shared_preferences.dart';

import 'game_settings.dart';

class SettingsStore {
  static const String _textScaleKey = 'settings.textScale';
  static const String _reduceMotionKey = 'settings.reduceMotion';
  static const String _paceKey = 'settings.pace';
  static const String _soundEnabledKey = 'settings.soundEnabled';

  Future<GameSettings> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? paceName = preferences.getString(_paceKey);
    final GamePace pace = GamePace.values.where((GamePace item) => item.name == paceName).firstOrNull ?? GamePace.standard;
    return GameSettings(
      textScale: preferences.getDouble(_textScaleKey) ?? 1,
      reduceMotion: preferences.getBool(_reduceMotionKey) ?? false,
      pace: pace,
      soundEnabled: preferences.getBool(_soundEnabledKey) ?? true,
    );
  }

  Future<void> save(GameSettings settings) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_textScaleKey, settings.textScale);
    await preferences.setBool(_reduceMotionKey, settings.reduceMotion);
    await preferences.setString(_paceKey, settings.pace.name);
    await preferences.setBool(_soundEnabledKey, settings.soundEnabled);
  }
}
