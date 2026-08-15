import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/online/online_api.dart';
import 'package:mamalik_alnard/core/online/online_google_link_flow.dart';
import 'package:mamalik_alnard/core/online/online_models.dart';

class _FakeAuthGateway implements OnlineAuthGateway {
  final List<String> calls = <String>[];
  final OnlineSession guest;
  final OnlineSession linked;

  _FakeAuthGateway({required this.guest, required this.linked});

  @override
  Future<OnlineSession> createGuest(String displayName) async {
    calls.add('guest:$displayName');
    return guest;
  }

  @override
  Future<OnlineSession> linkGoogle(String accessToken, String idToken) async {
    calls.add('link:$accessToken:$idToken');
    return linked;
  }
}

OnlineSession _session({required String provider, required String accessToken}) => OnlineSession(
      user: OnlineUser(id: 'player-1', displayName: 'لاعب_اختبار', provider: provider),
      accessToken: accessToken,
      refreshToken: '$accessToken-refresh',
      accessExpiresAtMilliseconds: 1700000000000,
    );

void main() {
  test('ينشئ ضيفًا عند الحاجة ثم يمرر رمز Google ويحفظ الجلسة المحدثة', () async {
    final OnlineSession guest = _session(provider: 'guest', accessToken: 'guest-access');
    final OnlineSession linked = _session(provider: 'google', accessToken: 'google-access');
    final _FakeAuthGateway api = _FakeAuthGateway(guest: guest, linked: linked);
    final List<OnlineSession> saved = <OnlineSession>[];
    final OnlineGoogleLinkFlow flow = OnlineGoogleLinkFlow(
      api: api,
      requestIdToken: () async => 'device-id-token',
    );

    final OnlineSession result = await flow.link(
      currentSession: null,
      displayName: 'لاعب_اختبار',
      saveSession: (OnlineSession session) async => saved.add(session),
    );

    expect(api.calls, <String>['guest:لاعب_اختبار', 'link:guest-access:device-id-token']);
    expect(saved, <OnlineSession>[guest, linked]);
    expect(result.user.provider, 'google');
    expect(result.accessToken, 'google-access');
  });
}
