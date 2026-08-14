import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_models.dart';
import '../profile/player_profile_controller.dart';

class SoloChallenge {
  const SoloChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.config,
    required this.rewardExperience,
    required this.rewardGold,
  });

  final String id;
  final String title;
  final String description;
  final MatchConfig config;
  final int rewardExperience;
  final int rewardGold;
}

class SoloChallenges {
  const SoloChallenges._();

  static const List<SoloChallenge> all = <SoloChallenge>[
    SoloChallenge(
      id: 'first_steps',
      title: 'خطوات أولى',
      description: 'أكمل مباراة تدريب ضد خصم سهل وتعلّم الدخول إلى المسار.',
      config: MatchConfig(mode: GameMode.training, humanPlayers: 1, aiDifficulty: AiDifficulty.easy),
      rewardExperience: 15,
      rewardGold: 10,
    ),
    SoloChallenge(
      id: 'quick_route',
      title: 'طريق القوافل',
      description: 'انتصر في مباراة سريعة بثلاثة أحجار ضد خصم متوسط.',
      config: MatchConfig(mode: GameMode.quick, humanPlayers: 1, aiDifficulty: AiDifficulty.medium, mapId: 'royal_harbor'),
      rewardExperience: 25,
      rewardGold: 20,
    ),
    SoloChallenge(
      id: 'palace_guard',
      title: 'حارس القصر',
      description: 'واجه خصمًا محترفًا في القواعد الكلاسيكية.',
      config: MatchConfig(mode: GameMode.classic, humanPlayers: 1, aiDifficulty: AiDifficulty.expert, heroId: 'knight'),
      rewardExperience: 35,
      rewardGold: 30,
    ),
  ];

  static SoloChallenge? byConfig(MatchConfig config) {
    for (final SoloChallenge item in all) {
      if (item.config.mode == config.mode && item.config.aiDifficulty == config.aiDifficulty && item.config.mapId == config.mapId) return item;
    }
    return null;
  }
}

class MatchReward {
  const MatchReward({required this.experience, required this.gold, required this.isLocalWin});

  final int experience;
  final int gold;
  final bool isLocalWin;
}

class MatchRecord {
  const MatchRecord({
    required this.id,
    required this.playedAtMilliseconds,
    required this.mode,
    required this.winner,
    required this.isLocalWin,
    required this.experience,
    required this.gold,
    required this.heroId,
    required this.mapId,
  });

  final String id;
  final int playedAtMilliseconds;
  final GameMode mode;
  final PlayerColor winner;
  final bool isLocalWin;
  final int experience;
  final int gold;
  final String heroId;
  final String mapId;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'playedAt': playedAtMilliseconds,
        'mode': mode.name,
        'winner': winner.name,
        'localWin': isLocalWin,
        'experience': experience,
        'gold': gold,
        'heroId': heroId,
        'mapId': mapId,
      };

  factory MatchRecord.fromMap(Map<String, dynamic> map) => MatchRecord(
        id: map['id'] as String,
        playedAtMilliseconds: map['playedAt'] as int,
        mode: GameMode.values.byName(map['mode'] as String),
        winner: PlayerColor.values.byName(map['winner'] as String),
        isLocalWin: map['localWin'] as bool,
        experience: map['experience'] as int,
        gold: map['gold'] as int,
        heroId: map['heroId'] as String,
        mapId: map['mapId'] as String,
      );
}

class LocalProgressState {
  const LocalProgressState({this.records = const <MatchRecord>[], this.completedChallengeIds = const <String>{}});

  final List<MatchRecord> records;
  final Set<String> completedChallengeIds;

  LocalProgressState copyWith({List<MatchRecord>? records, Set<String>? completedChallengeIds}) => LocalProgressState(
        records: records ?? this.records,
        completedChallengeIds: completedChallengeIds ?? this.completedChallengeIds,
      );
}

class LocalProgressStore {
  static const String _key = 'mamalik_local_progress_v1';

  Future<LocalProgressState> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_key);
    if (raw == null) return const LocalProgressState();
    try {
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      return LocalProgressState(
        records: (map['records'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic item) => MatchRecord.fromMap(item as Map<String, dynamic>))
            .toList(),
        completedChallengeIds: (map['completedChallenges'] as List<dynamic>? ?? <dynamic>[]).cast<String>().toSet(),
      );
    } catch (_) {
      await preferences.remove(_key);
      return const LocalProgressState();
    }
  }

  Future<void> save(LocalProgressState state) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'records': state.records.map((MatchRecord item) => item.toMap()).toList(),
        'completedChallenges': state.completedChallengeIds.toList(),
      }),
    );
  }
}

final AsyncNotifierProvider<LocalProgressController, LocalProgressState> localProgressProvider =
    AsyncNotifierProvider<LocalProgressController, LocalProgressState>(LocalProgressController.new);

class LocalProgressController extends AsyncNotifier<LocalProgressState> {
  final LocalProgressStore _store = LocalProgressStore();

  @override
  Future<LocalProgressState> build() => _store.load();

  static MatchReward rewardFor(MatchState state) {
    final bool isLocalWin = state.players.firstWhere((Player player) => player.color == state.winner).isHuman;
    final int baseExperience = switch (state.config.mode) {
      GameMode.training => 10,
      GameMode.quick => 20,
      GameMode.classic => 30,
    };
    final int baseGold = switch (state.config.mode) {
      GameMode.training => 5,
      GameMode.quick => 10,
      GameMode.classic => 15,
    };
    return MatchReward(
      experience: baseExperience + (isLocalWin ? 10 : 3),
      gold: baseGold + (isLocalWin ? 10 : 0),
      isLocalWin: isLocalWin,
    );
  }

  Future<void> recordFinishedMatch(MatchState match) async {
    if (match.winner == null) return;
    final LocalProgressState current = await _store.load();
    final MatchReward reward = rewardFor(match);
    final SoloChallenge? challenge = SoloChallenges.byConfig(match.config);
    final bool challengeCompleted = reward.isLocalWin && challenge != null && !current.completedChallengeIds.contains(challenge.id);
    final int experience = reward.experience + (challengeCompleted ? challenge.rewardExperience : 0);
    final int gold = reward.gold + (challengeCompleted ? challenge.rewardGold : 0);
    final MatchRecord record = MatchRecord(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      playedAtMilliseconds: DateTime.now().millisecondsSinceEpoch,
      mode: match.config.mode,
      winner: match.winner!,
      isLocalWin: reward.isLocalWin,
      experience: experience,
      gold: gold,
      heroId: match.config.heroId,
      mapId: match.config.mapId,
    );
    final Set<String> completed = <String>{...current.completedChallengeIds};
    if (challengeCompleted) completed.add(challenge.id);
    final LocalProgressState updated = current.copyWith(records: <MatchRecord>[record, ...current.records], completedChallengeIds: completed);
    state = AsyncData<LocalProgressState>(updated);
    await _store.save(updated);
    await ref.read(playerProfileProvider.notifier).applyMatchReward(
          experience: experience,
          gold: gold,
          isWin: reward.isLocalWin,
        );
  }
}
