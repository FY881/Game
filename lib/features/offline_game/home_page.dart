import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/match_models.dart';
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
  bool _hasSavedMatch = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_checkSavedMatch);
  }

  Future<void> _checkSavedMatch() async {
    final bool exists = await ref.read(offlineMatchProvider.notifier).hasSavedMatch();
    if (mounted) setState(() => _hasSavedMatch = exists);
  }

  Future<void> _resumeMatch() async {
    final bool restored = await ref.read(offlineMatchProvider.notifier).restoreLastMatch();
    if (restored && mounted) context.go('/offline-match');
  }

  void _startMatch() {
    ref.read(offlineMatchProvider.notifier).newMatch(
          config: MatchConfig(mode: _mode, humanPlayers: _humanPlayers, aiDifficulty: _difficulty),
        );
    context.go('/offline-match');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            const SizedBox(height: 24),
            const Icon(Icons.casino_outlined, size: 72, color: Color(0xffd8b16d)),
            const SizedBox(height: 18),
            Text('ممالك النرد', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text('لعبة سباق أحجار عربية أصلية. اضبط نمط المباراة ثم ابدأ اللعب على جهاز واحد أو ضد خصوم محليين.', textAlign: TextAlign.center),
            const SizedBox(height: 28),
            _Section(
              title: 'نمط اللعب',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GameMode.values
                    .map((GameMode mode) => ChoiceChip(
                          label: Text('${mode.label}\n${mode.description}'),
                          selected: _mode == mode,
                          onSelected: (_) => setState(() => _mode = mode),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'اللاعبون على الجهاز',
              child: Wrap(
                spacing: 8,
                children: List<Widget>.generate(4, (int index) {
                  final int count = index + 1;
                  return ChoiceChip(
                    label: Text('$count ${count == 1 ? 'لاعب' : 'لاعبين+'}'),
                    selected: _humanPlayers == count,
                    onSelected: (_) => setState(() => _humanPlayers = count),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'صعوبة الخصوم',
              child: Wrap(
                spacing: 8,
                children: AiDifficulty.values
                    .map((AiDifficulty difficulty) => ChoiceChip(
                          label: Text(switch (difficulty) {
                            AiDifficulty.easy => 'سهل',
                            AiDifficulty.medium => 'متوسط',
                            AiDifficulty.expert => 'محترف',
                          }),
                          selected: _difficulty == difficulty,
                          onSelected: _humanPlayers == 4 ? null : (_) => setState(() => _difficulty = difficulty),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _startMatch,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('ابدأ المباراة')),
            ),
            if (_hasSavedMatch) ...<Widget>[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _resumeMatch,
                icon: const Icon(Icons.restore),
                label: const Text('استكمل آخر مباراة محفوظة'),
              ),
            ],
            const SizedBox(height: 14),
            Text('الإصدار المحلي لا يحتوي على مشتريات أو إعلانات أو نتائج نرد مدفوعة. الأونلاين لا يبدأ قبل بناء خادم يتحقق من كل رمية وحركة.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ]),
        ),
      );
}
