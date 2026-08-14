class OnlineConfig {
  const OnlineConfig._();

  static const bool enabled = bool.fromEnvironment('MAMALIK_ONLINE_ENABLED', defaultValue: false);
  static const String serverUrl = String.fromEnvironment('MAMALIK_SERVER_URL', defaultValue: '');

  static bool get isAvailable => enabled && Uri.tryParse(serverUrl)?.hasScheme == true;
}
