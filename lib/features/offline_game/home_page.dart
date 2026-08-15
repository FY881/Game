import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/cosmetics.dart';
import '../../core/content/heroes.dart';
import '../../core/content/maps.dart';
import '../../core/models/match_models.dart';
import '../../core/online/online_config.dart';
import 'offline_match_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  GameMode _mode = GameMode.classic;
  int _humanPlayers = 1;
  AiDifficulty _difficulty = AiDifficulty.medium;
  GameLoadout _loadout = const GameLoadout();
  bool _hasSavedMatch = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_checkSavedMatch);
  }

  Future<void> _checkSavedMatch() async {
    final bool exists =
        await ref.read(offlineMatchProvider.notifier).hasSavedMatch();
    if (mounted) setState(() => _hasSavedMatch = exists);
  }

  Future<void> _resumeMatch() async {
    final bool restored =
        await ref.read(offlineMatchProvider.notifier).restoreLastMatch();
    if (restored && mounted) context.go('/offline-match');
  }

  Future<void> _openCollection() async {
    final GameLoadout? updated =
        await context.push<GameLoadout>('/collection', extra: _loadout);
    if (updated != null && mounted) setState(() => _loadout = updated);
  }

  void _startMatch() {
    ref.read(offlineMatchProvider.notifier).newMatch(
          config: MatchConfig(
            mode: _mode,
            humanPlayers: _humanPlayers,
            aiDifficulty: _difficulty,
            heroId: _loadout.heroId,
            mapId: _loadout.mapId,
            pawnStyleId: _loadout.pawnStyleId,
            diceStyleId: _loadout.diceStyleId,
          ),
        );
    context.go('/offline-match');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xff172d51),
              Color(0xff07101f),
              Color(0xff030914)
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: <Widget>[
              Row(
                children: <Widget>[
                  const _CrestMark(),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text('ممالك النرد',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900))),
                  IconButton(
                      tooltip: 'ملف اللاعب',
                      onPressed: () => context.push('/profile'),
                      icon: const Icon(Icons.person_outline)),
                  IconButton(
                      tooltip: 'إعدادات اللعب',
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings_outlined)),
                ],
              ),
              const SizedBox(height: 24),
              _HeroArena(
                heroName: Heroes.byId(_loadout.heroId).name,
                mapName: BoardMaps.byId(_loadout.mapId).name,
                heroIcon: Heroes.byId(_loadout.heroId).icon,
                onCollection: _openCollection,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _startMatch,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('ابدأ مواجهة الآن'),
              ),
              if (_hasSavedMatch) ...<Widget>[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                    onPressed: _resumeMatch,
                    icon: const Icon(Icons.restore),
                    label: const Text('تابع المواجهة المحفوظة')),
              ],
              const SizedBox(height: 22),
              Text('إعداد المواجهة',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              _ArenaSettings(
                mode: _mode,
                players: _humanPlayers,
                difficulty: _difficulty,
                onMode: (GameMode value) => setState(() => _mode = value),
                onPlayers: (int value) => setState(() => _humanPlayers = value),
                onDifficulty: (AiDifficulty value) =>
                    setState(() => _difficulty = value),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _QuickGate(
                      icon: Icons.flag_outlined,
                      label: 'التحديات',
                      onTap: () => context.push('/challenges')),
                  _QuickGate(
                      icon: Icons.style_outlined,
                      label: 'الخزانة',
                      onTap: _openCollection),
                  _QuickGate(
                      icon: Icons.history,
                      label: 'السجل',
                      onTap: () => context.push('/history')),
                  _QuickGate(
                      icon: OnlineConfig.isAvailable
                          ? Icons.public
                          : Icons.lock_outline,
                      label: OnlineConfig.isAvailable ? 'الأونلاين' : 'قريبًا',
                      onTap: () => context.push('/online')),
                ],
              ),
              const SizedBox(height: 22),
              Text('لعب عادل: لا إعلانات، ولا قوة تُشترى، ولا رمية نرد مدفوعة.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: const Color(0xffb9c5da))),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrestMark extends StatelessWidget {
  const _CrestMark();

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
              colors: <Color>[Color(0xffffd77f), Color(0xffb97926)]),
          border: Border.all(color: const Color(0xffffe8ae)),
        ),
        child: const Icon(Icons.casino_rounded, color: Color(0xff372000)),
      );
}

class _HeroArena extends StatelessWidget {
  const _HeroArena(
      {required this.heroName,
      required this.mapName,
      required this.heroIcon,
      required this.onCollection});

  final String heroName;
  final String mapName;
  final IconData heroIcon;
  final VoidCallback onCollection;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: <Color>[
                Color(0xff2f5a86),
                Color(0xff192a4b),
                Color(0xff101a30)
              ]),
          border: Border.all(color: const Color(0xff5f8fc1)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Color(0x55000000), blurRadius: 28, offset: Offset(0, 16))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xfff6c967).withValues(alpha: .14),
                    border: Border.all(color: const Color(0xfff6c967))),
                child: Icon(heroIcon, color: const Color(0xffffda84), size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    const Text('ساحة الليلة',
                        style: TextStyle(color: Color(0xffb9c9e8))),
                    Text(mapName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900)),
                  ])),
            ]),
            const SizedBox(height: 34),
            Text('قد مملكتك إلى المركز',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
                'اختر البطل، حدّد الساحة، ثم ابدأ سباقًا عادلًا بالنرد. بطلك الحالي: $heroName.',
                style: const TextStyle(height: 1.5, color: Color(0xffd8e1f2))),
            const SizedBox(height: 16),
            TextButton.icon(
                onPressed: onCollection,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('غيّر بطلَك وساحتَك')),
          ],
        ),
      );
}

class _ArenaSettings extends StatelessWidget {
  const _ArenaSettings(
      {required this.mode,
      required this.players,
      required this.difficulty,
      required this.onMode,
      required this.onPlayers,
      required this.onDifficulty});

  final GameMode mode;
  final int players;
  final AiDifficulty difficulty;
  final ValueChanged<GameMode> onMode;
  final ValueChanged<int> onPlayers;
  final ValueChanged<AiDifficulty> onDifficulty;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('نمط اللعب'),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GameMode.values
                        .map((GameMode value) => ChoiceChip(
                            label: Text(value.label),
                            selected: mode == value,
                            onSelected: (_) => onMode(value)))
                        .toList()),
                const SizedBox(height: 16),
                const Text('اللاعبون على الجهاز'),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    children: List<Widget>.generate(4, (int index) {
                      final int value = index + 1;
                      return ChoiceChip(
                          label: Text('$value لاعب${value == 1 ? '' : ''}'),
                          selected: players == value,
                          onSelected: (_) => onPlayers(value));
                    })),
                const SizedBox(height: 16),
                const Text('مهارة الخصم'),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    children: AiDifficulty.values
                        .map((AiDifficulty value) => ChoiceChip(
                            label: Text(switch (value) {
                              AiDifficulty.easy => 'سهل',
                              AiDifficulty.medium => 'متوسط',
                              AiDifficulty.expert => 'محترف'
                            }),
                            selected: difficulty == value,
                            onSelected: players == 4
                                ? null
                                : (_) => onDifficulty(value)))
                        .toList()),
              ]),
        ),
      );
}

class _QuickGate extends StatelessWidget {
  const _QuickGate(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 112,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
                color: const Color(0xff142440),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xff304a73))),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Icon(icon, color: const Color(0xfff6c967)),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center)
            ]),
          ),
        ),
      );
}
