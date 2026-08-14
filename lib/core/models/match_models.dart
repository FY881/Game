import 'package:flutter/material.dart';

enum PlayerColor { coral, sapphire, jade, gold }

enum MatchPhase { rolling, selectingPawn, finished }

enum AiDifficulty { easy, medium, expert }

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
    this.dice,
    this.winner,
    this.message = 'ارمِ النرد لبدء المباراة.',
  });

  final List<Player> players;
  final int currentPlayer;
  final MatchPhase phase;
  final int? dice;
  final PlayerColor? winner;
  final String message;

  Player get activePlayer => players[currentPlayer];

  MatchState copyWith({
    List<Player>? players,
    int? currentPlayer,
    MatchPhase? phase,
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
        dice: clearDice ? null : (dice ?? this.dice),
        winner: clearWinner ? null : (winner ?? this.winner),
        message: message ?? this.message,
      );
}
