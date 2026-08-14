import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/profile/player_profile_controller.dart';
import '../offline_game/home_page.dart';
import 'welcome_page.dart';

class StartupPage extends ConsumerWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue profile = ref.watch(playerProfileProvider);
    return profile.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(playerProfileProvider),
            child: const Text('أعد المحاولة'),
          ),
        ),
      ),
      data: (dynamic player) => player == null ? const WelcomePage() : const HomePage(),
    );
  }
}
