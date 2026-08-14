import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_store.dart';

enum GamePace { calm, standard, swift }

extension GamePaceX on GamePace {
  String get label => switch (this) {
        GamePace.calm => 'هادئة',
        GamePace.standard => 'متوازنة',
        GamePace.swift => 'سريعة',
      };

  Duration get aiTurnDelay => switch (this) {
        GamePace.calm => const Duration(milliseconds: 1250),
        GamePace.standard => const Duration(milliseconds: 850),
        GamePace.swift => const Duration(milliseconds: 450),
      };
}

enum ColorVisionMode { standard, deuteranopia, highContrast }

extension ColorVisionModeX on ColorVisionMode {
  String get label => switch (this) {
        ColorVisionMode.standard => 'الألوان القياسية',
        ColorVisionMode.deuteranopia => 'ألوان ميسرة لتمييز الأحمر والأخضر',
        ColorVisionMode.highContrast => 'تباين مرتفع',
      };
}

enum PerformanceMode { standard, batterySaver }

extension PerformanceModeX on PerformanceMode {
  String get label => switch (this) {
        PerformanceMode.standard => '60 إطارًا مستهدفًا',
        PerformanceMode.batterySaver => 'توفير البطارية (30 إطارًا مستهدفًا)',
      };
}

class GameSettings {
  const GameSettings({
    this.textScale = 1,
    this.reduceMotion = false,
    this.pace = GamePace.standard,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.colorVisionMode = ColorVisionMode.standard,
    this.performanceMode = PerformanceMode.standard,
  });

  final double textScale;
  final bool reduceMotion;
  final GamePace pace;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final ColorVisionMode colorVisionMode;
  final PerformanceMode performanceMode;

  Duration get aiTurnDelay => reduceMotion ? Duration.zero : pace.aiTurnDelay;
  bool get batterySaverEnabled => performanceMode == PerformanceMode.batterySaver;

  GameSettings copyWith({
    double? textScale,
    bool? reduceMotion,
    GamePace? pace,
    bool? soundEnabled,
    bool? vibrationEnabled,
    ColorVisionMode? colorVisionMode,
    PerformanceMode? performanceMode,
  }) =>
      GameSettings(
        textScale: textScale ?? this.textScale,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        pace: pace ?? this.pace,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
        colorVisionMode: colorVisionMode ?? this.colorVisionMode,
        performanceMode: performanceMode ?? this.performanceMode,
      );
}

final NotifierProvider<GameSettingsController, GameSettings> gameSettingsProvider =
    NotifierProvider<GameSettingsController, GameSettings>(GameSettingsController.new);

class GameSettingsController extends Notifier<GameSettings> {
  final SettingsStore _store = SettingsStore();
  bool _loaded = false;

  @override
  GameSettings build() => const GameSettings();

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    state = await _store.load();
  }

  void update(GameSettings next) {
    state = next;
    _store.save(next);
  }
}

extension GameSettingsContext on BuildContext {
  bool get reducedMotion => MediaQuery.maybeOf(this)?.disableAnimations ?? false;
}
