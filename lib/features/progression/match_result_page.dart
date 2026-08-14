import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/match_models.dart';
import '../../core/progression/local_progress.dart';
import '../offline_game/offline_match_controller.dart';

class MatchResultPage extends ConsumerWidget {
  const MatchResultPage({super.key, required this.match});

  final MatchState match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MatchReward reward = LocalProgressController.rewardFor(match);
    final SoloChallenge? challenge = SoloChallenges.byConfig(match.config);
    final String winner = match.winner?.label ?? 'لا أحد';
    return Scaffold(
      appBar: AppBar(title: const Text('نتيجة المباراة'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Icon(reward.isLocalWin ? Icons.emoji_events_outlined : Icons.handshake_outlined, size: 84, color: reward.isLocalWin ? const Color(0xffd8b16d) : null),
                const SizedBox(height: 12),
                Text(reward.isLocalWin ? 'أحسنت! فزت بالمباراة' : 'اكتملت المباراة', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('الفائز: $winner', textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        Text('مكافأة محلية عادلة', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        Text('+${reward.experience} خبرة'),
                        Text('+${reward.gold} ذهب'),
                        if (challenge != null && reward.isLocalWin) ...<Widget>[
                          const SizedBox(height: 8),
                          Text('قد تحصل على مكافأة التحدي الإضافية عند إكماله للمرة الأولى: ${challenge.rewardExperience} خبرة و${challenge.rewardGold} ذهب.'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(offlineMatchProvider.notifier).newMatch(config: match.config);
                    context.go('/offline-match');
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('مباراة جديدة بنفس الإعدادات'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.go('/history'),
                  icon: const Icon(Icons.history),
                  label: const Text('عرض سجل النتائج'),
                ),
                const SizedBox(height: 10),
                TextButton(onPressed: () => context.go('/'), child: const Text('العودة إلى الرئيسية')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
