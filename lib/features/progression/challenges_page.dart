import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/progression/local_progress.dart';
import '../offline_game/offline_match_controller.dart';

class ChallengesPage extends ConsumerWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LocalProgressState> progress = ref.watch(localProgressProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('التحديات الفردية')),
      body: progress.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذّر تحميل التقدم المحلي.')),
        data: (LocalProgressState state) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: SoloChallenges.all.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return const Text('هذه التحديات تعمل دون إنترنت وتمنح خبرة وذهبًا محليين فقط. لا توجد عملات مدفوعة أو احتمالات نرد مختلفة.', textAlign: TextAlign.center);
            }
            final SoloChallenge challenge = SoloChallenges.all[index - 1];
            final bool completed = state.completedChallengeIds.contains(challenge.id);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(completed ? Icons.verified_outlined : Icons.flag_outlined, color: completed ? Colors.greenAccent : null),
                        const SizedBox(width: 8),
                        Expanded(child: Text(challenge.title, style: Theme.of(context).textTheme.titleMedium)),
                        if (completed) const Chip(label: Text('مكتمل')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(challenge.description),
                    const SizedBox(height: 10),
                    Text('المكافأة عند أول فوز: ${challenge.rewardExperience} خبرة و${challenge.rewardGold} ذهب.'),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        ref.read(offlineMatchProvider.notifier).newMatch(config: challenge.config);
                        context.go('/offline-match');
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: Text(completed ? 'أعد التجربة' : 'ابدأ التحدي'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
