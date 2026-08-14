import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/match_models.dart';
import '../../core/profile/player_profile.dart';
import '../../core/profile/player_profile_controller.dart';
import '../offline_game/offline_match_controller.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  final TextEditingController _nameController = TextEditingController();
  String _avatarId = PlayerProfile.safeAvatars.first.id;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createGuestAndStartTraining() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final String? error = await ref.read(playerProfileProvider.notifier).createGuest(
          displayName: _nameController.text,
          avatarId: _avatarId,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _error = error;
        _saving = false;
      });
      return;
    }
    ref.read(offlineMatchProvider.notifier).newMatch(
          config: const MatchConfig(mode: GameMode.training, humanPlayers: 1, aiDifficulty: AiDifficulty.easy),
        );
    context.go('/offline-match');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              const SizedBox(height: 36),
              const Icon(Icons.castle_outlined, size: 84, color: Color(0xffd8b16d)),
              const SizedBox(height: 16),
              Text('مرحبًا بك في ممالك النرد', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text('أنشئ ملفًا ضيفًا محليًا على هذا الجهاز. لا نطلب بريدًا أو رقم هاتف، وستبدأ بتدريب قصير وآمن.', textAlign: TextAlign.center),
              const SizedBox(height: 28),
              TextField(
                controller: _nameController,
                maxLength: 14,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'اسم اللاعب',
                  hintText: 'مثال: فارس_النرد',
                  errorText: _error,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('اختر صورة رمزية آمنة', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: PlayerProfile.safeAvatars
                    .map(
                      (SafeAvatar avatar) => ChoiceChip(
                        selected: _avatarId == avatar.id,
                        onSelected: (_) => setState(() => _avatarId = avatar.id),
                        avatar: Icon(avatar.icon, color: avatar.color),
                        label: Text(avatar.label),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _createGuestAndStartTraining,
                icon: const Icon(Icons.school_outlined),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(_saving ? 'جارٍ إنشاء الملف...' : 'أنشئ ملفي وابدأ التدريب'),
                ),
              ),
              const SizedBox(height: 12),
              const Text('يمكن ربط هذا الملف بحساب Google لاحقًا عند بناء نظام الحسابات والمزامنة. لا توجد دردشة حرة أو مشتريات في الإصدار المحلي.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
