import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/cosmetics.dart';
import '../../core/content/heroes.dart';
import '../../core/content/maps.dart';
import '../../core/game/ludo_board_game.dart';
import '../../core/models/match_models.dart';
import '../../core/progression/local_progress.dart';
import '../../core/rules/classic_ludo_rules.dart';
import '../../core/settings/game_settings.dart';
import 'offline_match_controller.dart';
import 'training_coach.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  Timer? _aiTimer;
  DateTime _lastAiAction = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _aiTimer = Timer.periodic(const Duration(milliseconds: 150), (Timer timer) {
      final MatchState state = ref.read(offlineMatchProvider);
      final GameSettings settings = ref.read(gameSettingsProvider);
      final bool waitComplete = DateTime.now().difference(_lastAiAction) >= settings.aiTurnDelay;
      if (waitComplete && state.winner == null && !state.isPaused && !state.activePlayer.isHuman && state.phase == MatchPhase.rolling) {
        ref.read(offlineMatchProvider.notifier).playAiTurn();
        _lastAiAction = DateTime.now();
      }
    });
  }

  @override
  void dispose() {
    _aiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MatchState state = ref.watch(offlineMatchProvider);
    final GameSettings settings = ref.watch(gameSettingsProvider);
    ref.listen<MatchState>(offlineMatchProvider, (MatchState? previous, MatchState next) {
      if (previous?.winner == null && next.winner != null && mounted) {
        unawaited(ref.read(localProgressProvider.notifier).recordFinishedMatch(next));
        context.go('/result', extra: next);
      }
    });
    final OfflineMatchController controller = ref.read(offlineMatchProvider.notifier);
    final List<String> legal = ClassicLudoRules.legalPawnIds(state);
    return Scaffold(
      appBar: AppBar(
        title: Text('مباراة ${state.config.mode.label}'),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'الرئيسية',
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.home_outlined),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: state.isPaused ? 'استئناف' : 'إيقاف مؤقت',
            onPressed: state.winner == null ? controller.togglePause : null,
            icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: GameWidget<LudoBoardGame>(
                        game: LudoBoardGame(
                          state,
                          colorVisionMode: settings.colorVisionMode,
                          batterySaver: settings.batterySaverEnabled,
                        ),
                      ),
                    ),
                    if (state.isPaused)
                      ColoredBox(
                        color: Colors.black45,
                        child: Center(child: Text('المباراة متوقفة', style: Theme.of(context).textTheme.headlineSmall)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: <Widget>[
                          Chip(label: Text(state.config.mode.label)),
                          Chip(label: Text('${state.config.humanPlayers} محلي')), 
                          Chip(label: Text(switch (state.config.aiDifficulty) { AiDifficulty.easy => 'AI سهل', AiDifficulty.medium => 'AI متوسط', AiDifficulty.expert => 'AI محترف' })),
                          Chip(avatar: Icon(Heroes.byId(state.config.heroId).icon, size: 18), label: Text(Heroes.byId(state.config.heroId).name)),
                          Chip(avatar: Icon(BoardMaps.byId(state.config.mapId).icon, size: 18), label: Text(BoardMaps.byId(state.config.mapId).name)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.activePlayer.isHuman ? 'دور ${state.activePlayer.color.label}' : 'يفكر خصم ${state.activePlayer.color.label}…',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(state.message),
                      if (state.config.mode == GameMode.training) ...<Widget>[
                        const SizedBox(height: 10),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.school_outlined)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(TrainingCoach.instructionFor(state))),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.activePlayer.pawns.map((Pawn pawn) {
                          final bool isLegal = legal.contains(pawn.id);
                          final int? destination = ClassicLudoRules.previewProgress(state, pawn.id);
                          return OutlinedButton(
                            onPressed: isLegal && state.activePlayer.isHuman
                                ? () {
                                    if (settings.vibrationEnabled) unawaited(HapticFeedback.selectionClick());
                                    controller.movePawn(pawn.id);
                                  }
                                : null,
                            child: Text(destination == null ? 'حجر ${pawn.id.split('-').last}' : 'حجر ${pawn.id.split('-').last} ← إلى $destination'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: state.phase == MatchPhase.rolling && state.activePlayer.isHuman && !state.isPaused
                            ? () {
                                if (settings.vibrationEnabled) unawaited(HapticFeedback.lightImpact());
                                controller.rollDice();
                              }
                            : null,
                        icon: Icon(Cosmetics.diceById(state.config.diceStyleId).icon, color: Cosmetics.diceById(state.config.diceStyleId).accent),
                        label: Text(state.dice == null ? 'ارمِ النرد' : 'النتيجة ${state.dice}'),
                      ),
                      if (state.config.canUndo) ...<Widget>[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: controller.canUndo ? controller.undoTrainingStep : null,
                          icon: const Icon(Icons.undo),
                          label: const Text('تراجع عن آخر خطوة'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
