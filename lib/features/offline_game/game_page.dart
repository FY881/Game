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
  late final LudoBoardGame _boardGame;

  @override
  void initState() {
    super.initState();
    final GameSettings settings = ref.read(gameSettingsProvider);
    _boardGame = LudoBoardGame(
      ref.read(offlineMatchProvider),
      colorVisionMode: settings.colorVisionMode,
      batterySaver: settings.batterySaverEnabled,
      onPawnSelected: _movePawnFromBoard,
    );
    _aiTimer = Timer.periodic(const Duration(milliseconds: 150), (Timer timer) {
      final MatchState state = ref.read(offlineMatchProvider);
      final GameSettings settings = ref.read(gameSettingsProvider);
      final bool waitComplete =
          DateTime.now().difference(_lastAiAction) >= settings.aiTurnDelay;
      if (waitComplete &&
          state.winner == null &&
          !state.isPaused &&
          !state.activePlayer.isHuman &&
          state.phase == MatchPhase.rolling) {
        ref.read(offlineMatchProvider.notifier).playAiTurn();
        _lastAiAction = DateTime.now();
      }
    });
  }

  void _movePawnFromBoard(String pawnId) {
    final MatchState state = ref.read(offlineMatchProvider);
    final GameSettings settings = ref.read(gameSettingsProvider);
    if (!state.activePlayer.isHuman ||
        state.phase != MatchPhase.selectingPawn ||
        !ClassicLudoRules.legalPawnIds(state).contains(pawnId)) {
      return;
    }
    if (settings.vibrationEnabled) {
      unawaited(HapticFeedback.selectionClick());
    }
    ref.read(offlineMatchProvider.notifier).movePawn(pawnId);
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
    ref.listen<MatchState>(offlineMatchProvider,
        (MatchState? previous, MatchState next) {
      if (previous?.winner == null && next.winner != null && mounted) {
        unawaited(
            ref.read(localProgressProvider.notifier).recordFinishedMatch(next));
        context.go('/result', extra: next);
      }
    });
    final OfflineMatchController controller =
        ref.read(offlineMatchProvider.notifier);
    final List<String> legal = ClassicLudoRules.legalPawnIds(state);
    _boardGame.syncState(
      state,
      nextColorVisionMode: settings.colorVisionMode,
      nextBatterySaver: settings.batterySaverEnabled,
    );
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
                        game: _boardGame,
                      ),
                    ),
                    if (state.isPaused)
                      ColoredBox(
                        color: Colors.black45,
                        child: Center(
                            child: Text('المباراة متوقفة',
                                style:
                                    Theme.of(context).textTheme.headlineSmall)),
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
                      _TurnBanner(state: state),
                      const SizedBox(height: 10),
                      Text(state.message, textAlign: TextAlign.center),
                      if (state.config.mode == GameMode.training) ...<Widget>[
                        const SizedBox(height: 10),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.school_outlined)),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        TrainingCoach.instructionFor(state))),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (state.phase == MatchPhase.selectingPawn &&
                          state.activePlayer.isHuman)
                        Text(
                          legal.isEmpty
                              ? 'لا توجد حركة قانونية لهذا الدور.'
                              : 'المس الحجر المتوهج على اللوحة لتحريكه.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: const Color(0xffffd46d)),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 12),
                      _DiceCommand(
                        dice: state.dice,
                        enabled: state.phase == MatchPhase.rolling &&
                            state.activePlayer.isHuman &&
                            !state.isPaused,
                        diceIcon:
                            Cosmetics.diceById(state.config.diceStyleId).icon,
                        accent:
                            Cosmetics.diceById(state.config.diceStyleId).accent,
                        onPressed: () {
                          if (settings.vibrationEnabled) {
                            unawaited(HapticFeedback.lightImpact());
                          }
                          controller.rollDice();
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: _MatchFact(
                                  icon: Heroes.byId(state.config.heroId).icon,
                                  label:
                                      Heroes.byId(state.config.heroId).name)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _MatchFact(
                                  icon: BoardMaps.byId(state.config.mapId).icon,
                                  label:
                                      BoardMaps.byId(state.config.mapId).name)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _MatchFact(
                                  icon: Icons.groups_2_outlined,
                                  label: '${state.config.humanPlayers} محلي')),
                        ],
                      ),
                      if (state.config.canUndo) ...<Widget>[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: controller.canUndo
                              ? controller.undoTrainingStep
                              : null,
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

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.state});

  final MatchState state;

  @override
  Widget build(BuildContext context) {
    final Color color = state.activePlayer.color.color;
    final bool human = state.activePlayer.isHuman;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .8)),
      ),
      child: Row(children: <Widget>[
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: color.withValues(alpha: .65), blurRadius: 12)
                ])),
        const SizedBox(width: 10),
        Expanded(
            child: Text(
                human
                    ? 'دور مملكتك: ${state.activePlayer.color.label}'
                    : 'الخصم ${state.activePlayer.color.label} يخطط لحركته',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w900))),
        Icon(human ? Icons.touch_app_outlined : Icons.psychology_alt_outlined,
            color: color),
      ]),
    );
  }
}

class _DiceCommand extends StatelessWidget {
  const _DiceCommand(
      {required this.dice,
      required this.enabled,
      required this.diceIcon,
      required this.accent,
      required this.onPressed});

  final int? dice;
  final bool enabled;
  final IconData diceIcon;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 62,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: const Color(0xff10141f)),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Color(0x33ffffff), shape: BoxShape.circle),
                    child: Icon(diceIcon)),
                const SizedBox(width: 12),
                Text(dice == null ? 'ارمِ نرد المملكة' : 'نتيجة النرد: $dice'),
              ]),
        ),
      );
}

class _MatchFact extends StatelessWidget {
  const _MatchFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
            color: const Color(0xff101d33),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xff2b4166))),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(icon, size: 18, color: const Color(0xfff6c967)),
          const SizedBox(height: 4),
          Text(label,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall)
        ]),
      );
}
