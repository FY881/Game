import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/heroes.dart';
import '../../core/content/maps.dart';
import '../../core/models/match_models.dart';
import '../../core/progression/local_progress.dart';

class MatchHistoryPage extends ConsumerWidget {
  const MatchHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LocalProgressState> progress = ref.watch(localProgressProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('سجل النتائج المحلي')),
      body: progress.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذّر تحميل السجل المحلي.')),
        data: (LocalProgressState state) {
          if (state.records.isEmpty) {
            return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('لم تُسجّل أي مباراة مكتملة بعد. أكمل مباراة أو تحديًا فرديًا لتظهر نتيجته هنا.', textAlign: TextAlign.center)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final MatchRecord record = state.records[index];
              final DateTime date = DateTime.fromMillisecondsSinceEpoch(record.playedAtMilliseconds).toLocal();
              return Card(
                child: ListTile(
                  leading: Icon(record.isLocalWin ? Icons.emoji_events_outlined : Icons.history_outlined, color: record.isLocalWin ? const Color(0xffd8b16d) : null),
                  title: Text(record.isLocalWin ? 'فوز محلي — ${record.mode.label}' : 'مباراة محلية — ${record.mode.label}'),
                  subtitle: Text('البطل: ${Heroes.byId(record.heroId).name} · الخريطة: ${BoardMaps.byId(record.mapId).name}\n${date.day}/${date.month}/${date.year}'),
                  isThreeLine: true,
                  trailing: Text('+${record.experience} XP\n+${record.gold} ذهب', textAlign: TextAlign.end),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
