class OnlineConfig {
  const OnlineConfig._();

  static const bool enabled = bool.fromEnvironment('MAMALIK_ONLINE_ENABLED', defaultValue: false);
  static const String serverUrl = String.fromEnvironment('MAMALIK_SERVER_URL', defaultValue: '');
  static const String googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');

  static bool get isAvailable => enabled && Uri.tryParse(serverUrl)?.hasScheme == true;
  static bool get isGoogleSignInAvailable => isAvailable && googleWebClientId.endsWith('.apps.googleusercontent.com');
}
