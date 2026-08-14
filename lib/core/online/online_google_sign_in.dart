import 'package:google_sign_in/google_sign_in.dart';

import 'online_config.dart';

class OnlineGoogleSignIn {
  OnlineGoogleSignIn._();

  static final OnlineGoogleSignIn instance = OnlineGoogleSignIn._();
  bool _initialized = false;

  Future<String> requestIdToken() async {
    if (!OnlineConfig.isGoogleSignInAvailable) {
      throw StateError('GOOGLE_SIGN_IN_NOT_CONFIGURED');
    }
    if (!_initialized) {
      await GoogleSignIn.instance.initialize(serverClientId: OnlineConfig.googleWebClientId);
      _initialized = true;
    }
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw StateError('GOOGLE_SIGN_IN_UNSUPPORTED');
    }
    final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
    final String? idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('GOOGLE_ID_TOKEN_MISSING');
    }
    return idToken;
  }
}
