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
      if (state.winner == null && !state.activePlayer.isHuman && state.phase == MatchPhase.rolling) {
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
      appBar: AppBar(title: const Text('مباراة أوفلاين'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GameWidget<LudoBoardGame>(game: LudoBoardGame(state)),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        state.activePlayer.isHuman ? 'دورك: ${state.activePlayer.color.label}' : 'يفكر خصم ${state.activePlayer.color.label}…',
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
                          return OutlinedButton(
                            onPressed: isLegal ? () => controller.movePawn(pawn.id) : null,
                            child: Text('حجر ${pawn.id.split('-').last}'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: state.phase == MatchPhase.rolling && state.activePlayer.isHuman ? controller.rollDice : null,
                        icon: const Icon(Icons.casino),
                        label: Text(state.dice == null ? 'ارمِ النرد' : 'النتيجة ${state.dice}'),
                      ),
                      if (state.winner != null) Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: FilledButton.tonal(onPressed: controller.newMatch, child: const Text('مباراة جديدة')),
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
