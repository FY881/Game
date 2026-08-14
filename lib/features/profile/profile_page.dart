import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/profile/player_profile.dart';
import '../../core/profile/player_profile_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PlayerProfile?> profileState = ref.watch(playerProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ملف اللاعب')),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذّر تحميل الملف المحلي.')),
        data: (PlayerProfile? profile) {
          if (profile == null) return const Center(child: Text('لم يُنشأ ملف لاعب بعد.'));
          return ListView(
            padding: const EdgeInsets.all(18),
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: profile.avatar.color.withValues(alpha: .26),
                  child: Icon(profile.avatar.icon, size: 44, color: profile.avatar.color),
                ),
              ),
              const SizedBox(height: 12),
              Text(profile.displayName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              Text('ملف ضيف محلي', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[Text('المستوى ${profile.level}'), Text('${profile.experience % 100} / 100 خبرة')],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: profile.progressToNextLevel),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(leading: const Icon(Icons.monetization_on_outlined), title: const Text('الذهب المحلي'), trailing: Text('${profile.gold}')),
                    const Divider(height: 1),
                    ListTile(leading: const Icon(Icons.sports_esports_outlined), title: const Text('المباريات'), trailing: Text('${profile.totalMatches}')),
                    const Divider(height: 1),
                    ListTile(leading: const Icon(Icons.emoji_events_outlined), title: const Text('الانتصارات'), trailing: Text('${profile.totalWins}')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => _showEditDialog(context, ref, profile),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('تعديل الاسم والصورة'),
              ),
              const SizedBox(height: 12),
              const Text('هذا الملف محفوظ على الجهاز ولا يتصل بحساب خارجي. ستأتي مزامنة Google وحذف الحساب وتنزيل البيانات في مرحلة الحسابات والخادم.', textAlign: TextAlign.center),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, PlayerProfile profile) async {
    final TextEditingController nameController = TextEditingController(text: profile.displayName);
    String selectedAvatar = profile.avatarId;
    String? error;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
          title: const Text('تعديل الملف المحلي'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(controller: nameController, maxLength: 14, decoration: InputDecoration(labelText: 'اسم اللاعب', errorText: error)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: PlayerProfile.safeAvatars
                      .map((SafeAvatar avatar) => ChoiceChip(
                            selected: selectedAvatar == avatar.id,
                            onSelected: (_) => setDialogState(() => selectedAvatar = avatar.id),
                            avatar: Icon(avatar.icon, color: avatar.color),
                            label: Text(avatar.label),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () async {
                final String? result = await ref.read(playerProfileProvider.notifier).updateProfile(
                      displayName: nameController.text,
                      avatarId: selectedAvatar,
                    );
                if (!dialogContext.mounted) return;
                if (result != null) {
                  setDialogState(() => error = result);
                  return;
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
  }
}
