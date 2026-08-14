import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/game/ludo_board_game.dart';
import '../../core/models/match_models.dart';
import '../../core/rules/classic_ludo_rules.dart';
import 'offline_match_controller.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  Timer? _aiTimer;

  @override
  void initState() {
    super.initState();
    _aiTimer = Timer.periodic(const Duration(milliseconds: 850), (Timer timer) {
      final MatchState state = ref.read(offlineMatchProvider);
      if (state.winner == null && !state.isPaused && !state.activePlayer.isHuman && state.phase == MatchPhase.rolling) {
        ref.read(offlineMatchProvider.notifier).playAiTurn();
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
    final OfflineMatchController controller = ref.read(offlineMatchProvider.notifier);
    final List<String> legal = ClassicLudoRules.legalPawnIds(state);
    return Scaffold(
      appBar: AppBar(
        title: Text('مباراة ${state.config.mode.label}'),
        centerTitle: true,
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
                      child: GameWidget<LudoBoardGame>(game: LudoBoardGame(state)),
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
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.activePlayer.isHuman ? 'دور ${state.activePlayer.color.label}' : 'يفكر خصم ${state.activePlayer.color.label}…',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(state.message),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.activePlayer.pawns.map((Pawn pawn) {
                          final bool isLegal = legal.contains(pawn.id);
                          final int? destination = ClassicLudoRules.previewProgress(state, pawn.id);
                          return OutlinedButton(
                            onPressed: isLegal && state.activePlayer.isHuman ? () => controller.movePawn(pawn.id) : null,
                            child: Text(destination == null ? 'حجر ${pawn.id.split('-').last}' : 'حجر ${pawn.id.split('-').last} ← إلى $destination'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: state.phase == MatchPhase.rolling && state.activePlayer.isHuman && !state.isPaused ? controller.rollDice : null,
                        icon: const Icon(Icons.casino),
                        label: Text(state.dice == null ? 'ارمِ النرد' : 'النتيجة ${state.dice}'),
                      ),
                      if (state.winner != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: FilledButton.tonal(
                            onPressed: () => controller.newMatch(config: state.config),
                            child: const Text('مباراة جديدة بنفس الإعدادات'),
                          ),
                        ),
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
