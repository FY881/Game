import 'package:shared_preferences/shared_preferences.dart';

import 'game_settings.dart';

class SettingsStore {
  static const String _textScaleKey = 'settings.textScale';
  static const String _reduceMotionKey = 'settings.reduceMotion';
  static const String _paceKey = 'settings.pace';
  static const String _soundEnabledKey = 'settings.soundEnabled';
  static const String _vibrationEnabledKey = 'settings.vibrationEnabled';
  static const String _colorVisionModeKey = 'settings.colorVisionMode';
  static const String _performanceModeKey = 'settings.performanceMode';

  Future<GameSettings> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? paceName = preferences.getString(_paceKey);
    final String? colorVisionName = preferences.getString(_colorVisionModeKey);
    final String? performanceName = preferences.getString(_performanceModeKey);
    final GamePace pace = GamePace.values.where((GamePace item) => item.name == paceName).firstOrNull ?? GamePace.standard;
    final ColorVisionMode colorVisionMode = ColorVisionMode.values.where((ColorVisionMode item) => item.name == colorVisionName).firstOrNull ?? ColorVisionMode.standard;
    final PerformanceMode performanceMode = PerformanceMode.values.where((PerformanceMode item) => item.name == performanceName).firstOrNull ?? PerformanceMode.standard;
    return GameSettings(
      textScale: preferences.getDouble(_textScaleKey) ?? 1,
      reduceMotion: preferences.getBool(_reduceMotionKey) ?? false,
      pace: pace,
      soundEnabled: preferences.getBool(_soundEnabledKey) ?? true,
      vibrationEnabled: preferences.getBool(_vibrationEnabledKey) ?? true,
      colorVisionMode: colorVisionMode,
      performanceMode: performanceMode,
    );
  }

  Future<void> save(GameSettings settings) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_textScaleKey, settings.textScale);
    await preferences.setBool(_reduceMotionKey, settings.reduceMotion);
    await preferences.setString(_paceKey, settings.pace.name);
    await preferences.setBool(_soundEnabledKey, settings.soundEnabled);
    await preferences.setBool(_vibrationEnabledKey, settings.vibrationEnabled);
    await preferences.setString(_colorVisionModeKey, settings.colorVisionMode.name);
    await preferences.setString(_performanceModeKey, settings.performanceMode.name);
  }
}
