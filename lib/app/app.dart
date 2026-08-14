import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/content/cosmetics.dart';
import '../core/models/match_models.dart';
import '../core/settings/game_settings.dart';
import '../features/online/online_lobby_page.dart';
import '../features/offline_game/collection_page.dart';
import '../features/offline_game/game_page.dart';
import '../features/offline_game/settings_page.dart';
import '../features/onboarding/startup_page.dart';
import '../features/progression/challenges_page.dart';
import '../features/progression/match_history_page.dart';
import '../features/progression/match_result_page.dart';
import '../features/profile/profile_page.dart';

class MamalikApp extends ConsumerStatefulWidget {
  const MamalikApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const StartupPage(),
      ),
      GoRoute(
        path: '/offline-match',
        builder: (BuildContext context, GoRouterState state) => const GamePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/collection',
        builder: (BuildContext context, GoRouterState state) => CollectionPage(
          initialLoadout: state.extra as GameLoadout? ?? const GameLoadout(),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/challenges',
        builder: (BuildContext context, GoRouterState state) => const ChallengesPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (BuildContext context, GoRouterState state) => const MatchHistoryPage(),
      ),
      GoRoute(
        path: '/result',
        builder: (BuildContext context, GoRouterState state) => MatchResultPage(match: state.extra! as MatchState),
      ),
      GoRoute(
        path: '/online',
        builder: (BuildContext context, GoRouterState state) => const OnlineLobbyPage(),
      ),
    ],
  );

  @override
  ConsumerState<MamalikApp> createState() => _MamalikAppState();
}

class _MamalikAppState extends ConsumerState<MamalikApp> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => ref.read(gameSettingsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final GameSettings settings = ref.watch(gameSettingsProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ممالك النرد',
      routerConfig: MamalikApp._router,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff44c0b0),
          brightness: Brightness.dark,
          surface: const Color(0xff10213d),
        ),
        scaffoldBackgroundColor: const Color(0xff071226),
      ),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(settings.textScale),
              disableAnimations: settings.reduceMotion,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
