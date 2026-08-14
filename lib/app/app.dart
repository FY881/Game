import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/offline_game/game_page.dart';
import '../features/offline_game/home_page.dart';

class MamalikApp extends StatelessWidget {
  const MamalikApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const HomePage(),
      ),
      GoRoute(
        path: '/offline-match',
        builder: (BuildContext context, GoRouterState state) => const GamePage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ممالك النرد',
      routerConfig: _router,
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
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
