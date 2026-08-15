import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/online/online_config.dart';
import '../../core/profile/player_profile_controller.dart';
import 'online_session_controller.dart';

class OnlineLobbyPage extends ConsumerWidget {
  const OnlineLobbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!OnlineConfig.isAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text('اللعب الأونلاين')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('الأونلاين غير مفعل في هذا الإصدار. يتطلب خادمًا دائمًا موثوقًا وعنوانًا آمنًا قبل فتح الغرف للاعبين.', textAlign: TextAlign.center),
          ),
        ),
      );
    }
    final AsyncValue session = ref.watch(onlineSessionProvider);
    final AsyncValue profile = ref.watch(playerProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('اللعب الأونلاين')),
      body: session.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(child: Text('تعذّر إعداد الجلسة: $error')),
        data: (dynamic onlineSession) {
          if (onlineSession == null) {
            final String displayName = profile.valueOrNull?.displayName as String? ?? 'ضيف_الممالك';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.public_outlined, size: 56),
                    const SizedBox(height: 16),
                    const Text('أنشئ جلسة ضيف للأونلاين'),
                    const SizedBox(height: 8),
                    Text('سيستخدم الخادم اسمك المحلي «$displayName» لإنشاء حساب ضيف منفصل قابل للترقية إلى Google لاحقًا.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.read(onlineSessionProvider.notifier).createGuest(displayName),
                      child: const Text('إنشاء جلسة أونلاين'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              ListTile(leading: const Icon(Icons.verified_user_outlined), title: Text(onlineSession.user.displayName as String), subtitle: Text('الهوية: ${onlineSession.user.provider}')),
              const SizedBox(height: 12),
              if (onlineSession.user.provider != 'google') ...<Widget>[
                const Text('اربط Google لحماية التقدم واستعادته على جهاز جديد.'),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: OnlineConfig.isGoogleSignInAvailable
                      ? () => ref.read(onlineSessionProvider.notifier).linkGoogleWithDevice(displayName: onlineSession.user.displayName as String)
                      : null,
                  icon: const Icon(Icons.account_circle_outlined),
                  label: const Text('ربط حساب Google'),
                ),
                if (!OnlineConfig.isGoogleSignInAvailable)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('يتطلب زر Google إصدار تجربة يمرر عنوان الخادم ومعرّف عميل الويب الموثقين.', textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 12),
              ],
              const Text('اتصال الغرف وWebSocket محكومان بعقد الخادم. واجهة إنشاء الغرف النهائية ستفتح بعد نشر الخادم الدائم وإضافة التخزين الخادمي.'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.read(onlineSessionProvider.notifier).signOutOnline(),
                child: const Text('تسجيل الخروج من جلسة الأونلاين'),
              ),
            ],
          );
        },
      ),
    );
  }
}
