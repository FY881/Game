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

class GameSettings {
  const GameSettings({
    this.textScale = 1,
    this.reduceMotion = false,
    this.pace = GamePace.standard,
    this.soundEnabled = true,
  });

  final double textScale;
  final bool reduceMotion;
  final GamePace pace;
  final bool soundEnabled;

  Duration get aiTurnDelay => reduceMotion ? Duration.zero : pace.aiTurnDelay;

  GameSettings copyWith({double? textScale, bool? reduceMotion, GamePace? pace, bool? soundEnabled}) => GameSettings(
        textScale: textScale ?? this.textScale,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        pace: pace ?? this.pace,
        soundEnabled: soundEnabled ?? this.soundEnabled,
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
