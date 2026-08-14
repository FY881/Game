import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/online/online_api.dart';
import '../../core/online/online_config.dart';
import '../../core/online/online_models.dart';
import '../../core/online/online_session_store.dart';

final AsyncNotifierProvider<OnlineSessionController, OnlineSession?> onlineSessionProvider =
    AsyncNotifierProvider<OnlineSessionController, OnlineSession?>(OnlineSessionController.new);

class OnlineSessionController extends AsyncNotifier<OnlineSession?> {
  final OnlineSessionStore _store = OnlineSessionStore();
  final OnlineApi _api = OnlineApi();

  @override
  Future<OnlineSession?> build() async {
    if (!OnlineConfig.isAvailable) return null;
    final OnlineSession? stored = await _store.load();
    if (stored == null) return null;
    try {
      final OnlineSession refreshed = await _api.refresh(stored.refreshToken, stored.user);
      await _store.save(refreshed);
      return refreshed;
    } catch (_) {
      await _store.clear();
      return null;
    }
  }

  Future<void> createGuest(String displayName) async {
    if (!OnlineConfig.isAvailable) throw const OnlineApiFailure('ONLINE_NOT_CONFIGURED');
    state = const AsyncLoading<OnlineSession?>();
    final OnlineSession session = await _api.createGuest(displayName);
    await _store.save(session);
    state = AsyncData<OnlineSession?>(session);
  }

  Future<void> linkGoogle(String idToken) async {
    final OnlineSession? current = state.valueOrNull;
    if (current == null) throw const OnlineApiFailure('ONLINE_SESSION_MISSING');
    final OnlineSession linked = await _api.linkGoogle(current.accessToken, idToken);
    await _store.save(linked);
    state = AsyncData<OnlineSession?>(linked);
  }

  Future<void> signOutOnline() async {
    await _store.clear();
    state = const AsyncData<OnlineSession?>(null);
  }
}
