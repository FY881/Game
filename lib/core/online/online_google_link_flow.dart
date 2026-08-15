import 'online_api.dart';
import 'online_models.dart';

class OnlineGoogleLinkFlow {
  const OnlineGoogleLinkFlow({required OnlineAuthGateway api, required Future<String> Function() requestIdToken})
      : _api = api,
        _requestIdToken = requestIdToken;

  final OnlineAuthGateway _api;
  final Future<String> Function() _requestIdToken;

  Future<OnlineSession> link({
    required OnlineSession? currentSession,
    required String displayName,
    required Future<void> Function(OnlineSession session) saveSession,
  }) async {
    final OnlineSession current = currentSession ?? await _api.createGuest(displayName);
    if (currentSession == null) await saveSession(current);
    final String idToken = await _requestIdToken();
    final OnlineSession linked = await _api.linkGoogle(current.accessToken, idToken);
    await saveSession(linked);
    return linked;
  }
}
