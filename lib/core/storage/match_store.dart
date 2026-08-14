import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_models.dart';

class MatchStore {
  static const String _key = 'mamalik_offline_match_v1';

  Future<void> save(MatchState state) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode(_toMap(state)));
  }

  Future<MatchState?> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_key);
    if (raw == null) return null;
    try {
      return _fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await preferences.remove(_key);
      return null;
    }
  }

  Future<bool> exists() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.containsKey(_key);
  }

  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }

  Map<String, dynamic> _toMap(MatchState state) => <String, dynamic>{
        'currentPlayer': state.currentPlayer,
        'phase': state.phase.index,
        'dice': state.dice,
        'winner': state.winner?.index,
        'paused': state.isPaused,
        'message': state.message,
        'config': <String, dynamic>{
          'mode': state.config.mode.index,
          'humans': state.config.humanPlayers,
          'difficulty': state.config.aiDifficulty.index,
        },
        'players': state.players
            .map((Player player) => <String, dynamic>{
                  'color': player.color.index,
                  'human': player.isHuman,
                  'pawns': player.pawns
                      .map((Pawn pawn) => <String, dynamic>{'id': pawn.id, 'progress': pawn.progress})
                      .toList(),
                })
            .toList(),
      };

  MatchState _fromMap(Map<String, dynamic> raw) {
    final Map<String, dynamic> configMap = raw['config'] as Map<String, dynamic>;
    final MatchConfig config = MatchConfig(
      mode: GameMode.values[configMap['mode'] as int],
      humanPlayers: configMap['humans'] as int,
      aiDifficulty: AiDifficulty.values[configMap['difficulty'] as int],
    );
    final List<Player> players = (raw['players'] as List<dynamic>).map((dynamic entry) {
      final Map<String, dynamic> playerMap = entry as Map<String, dynamic>;
      final PlayerColor color = PlayerColor.values[playerMap['color'] as int];
      final List<Pawn> pawns = (playerMap['pawns'] as List<dynamic>).map((dynamic pawnEntry) {
        final Map<String, dynamic> pawnMap = pawnEntry as Map<String, dynamic>;
        return Pawn(id: pawnMap['id'] as String, color: color, progress: pawnMap['progress'] as int);
      }).toList();
      return Player(color: color, pawns: pawns, isHuman: playerMap['human'] as bool);
    }).toList();
    return MatchState(
      players: players,
      currentPlayer: raw['currentPlayer'] as int,
      phase: MatchPhase.values[raw['phase'] as int],
      dice: raw['dice'] as int?,
      winner: raw['winner'] == null ? null : PlayerColor.values[raw['winner'] as int],
      isPaused: raw['paused'] as bool? ?? false,
      config: config,
      message: raw['message'] as String? ?? 'تمت استعادة المباراة.',
    );
  }
}
