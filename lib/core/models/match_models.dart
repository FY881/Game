import 'package:flutter/material.dart';

enum PlayerColor { coral, sapphire, jade, gold }

enum MatchPhase { rolling, selectingPawn, finished }

enum AiDifficulty { easy, medium, expert }

enum GameMode { classic, quick, training }

extension GameModeX on GameMode {
  String get label => switch (this) {
        GameMode.classic => 'كلاسيكي',
        GameMode.quick => 'سريع',
        GameMode.training => 'تدريب',
      };

  String get description => switch (this) {
        GameMode.classic => '4 أحجار ومسار كامل',
        GameMode.quick => '3 أحجار وقواعد دخول مرنة',
        GameMode.training => 'تعلم الخطوات دون ضغط',
      };
}

class MatchConfig {
  const MatchConfig({
    this.mode = GameMode.classic,
    this.humanPlayers = 1,
    this.aiDifficulty = AiDifficulty.medium,
    this.heroId = 'knight',
    this.mapId = 'sand_palace',
    this.pawnStyleId = 'royal_orb',
    this.diceStyleId = 'brass_dice',
  });

  final GameMode mode;
  final int humanPlayers;
  final AiDifficulty aiDifficulty;
  final String heroId;
  final String mapId;
  final String pawnStyleId;
  final String diceStyleId;

  int get pawnsPerPlayer => mode == GameMode.quick ? 3 : 4;
  int get homeProgress => mode == GameMode.quick ? 46 : 57;
  bool get canUndo => mode == GameMode.training;
  bool canEnterWith(int dice) => mode == GameMode.quick ? dice == 5 || dice == 6 : dice == 6;

  MatchConfig copyWith({GameMode? mode, int? humanPlayers, AiDifficulty? aiDifficulty, String? heroId, String? mapId, String? pawnStyleId, String? diceStyleId}) => MatchConfig(
        mode: mode ?? this.mode,
        humanPlayers: humanPlayers ?? this.humanPlayers,
        aiDifficulty: aiDifficulty ?? this.aiDifficulty,
        heroId: heroId ?? this.heroId,
        mapId: mapId ?? this.mapId,
        pawnStyleId: pawnStyleId ?? this.pawnStyleId,
        diceStyleId: diceStyleId ?? this.diceStyleId,
      );
}

extension PlayerColorX on PlayerColor {
  Color get color => switch (this) {
        PlayerColor.coral => const Color(0xffd8704c),
        PlayerColor.sapphire => const Color(0xff478bd0),
        PlayerColor.jade => const Color(0xff45b98b),
        PlayerColor.gold => const Color(0xffd1a444),
      };

  String get label => switch (this) {
        PlayerColor.coral => 'المرجاني',
        PlayerColor.sapphire => 'الأزرق',
        PlayerColor.jade => 'الزمردي',
        PlayerColor.gold => 'الذهبي',
      };
}

class Pawn {
  const Pawn({required this.id, required this.color, required this.progress});

  final String id;
  final PlayerColor color;
  final int progress;

  Pawn copyWith({int? progress}) => Pawn(
        id: id,
        color: color,
        progress: progress ?? this.progress,
      );
}

class Player {
  const Player({required this.color, required this.pawns, required this.isHuman});

  final PlayerColor color;
  final List<Pawn> pawns;
  final bool isHuman;

  Player copyWith({List<Pawn>? pawns}) => Player(
        color: color,
        pawns: pawns ?? this.pawns,
        isHuman: isHuman,
      );
}

class MatchState {
  const MatchState({
    required this.players,
    required this.currentPlayer,
    required this.phase,
    this.config = const MatchConfig(),
    this.isPaused = false,
    this.dice,
    this.winner,
    this.message = 'ارمِ النرد لبدء المباراة.',
  });

  final List<Player> players;
  final int currentPlayer;
  final MatchPhase phase;
  final MatchConfig config;
  final bool isPaused;
  final int? dice;
  final PlayerColor? winner;
  final String message;

  Player get activePlayer => players[currentPlayer];

  MatchState copyWith({
    List<Player>? players,
    int? currentPlayer,
    MatchPhase? phase,
    MatchConfig? config,
    bool? isPaused,
    int? dice,
    bool clearDice = false,
    PlayerColor? winner,
    bool clearWinner = false,
    String? message,
  }) =>
      MatchState(
        players: players ?? this.players,
        currentPlayer: currentPlayer ?? this.currentPlayer,
        phase: phase ?? this.phase,
        config: config ?? this.config,
        isPaused: isPaused ?? this.isPaused,
        dice: clearDice ? null : (dice ?? this.dice),
        winner: clearWinner ? null : (winner ?? this.winner),
        message: message ?? this.message,
      );
}
