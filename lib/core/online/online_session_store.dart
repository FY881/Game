import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'online_models.dart';

class OnlineSessionStore {
  static const String _prefix = 'mamalik.online.';
  final FlutterSecureStorage _storage;

  OnlineSessionStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<OnlineSession?> load() async {
    final Map<String, String> values = <String, String>{};
    for (final String key in <String>['userId', 'displayName', 'provider', 'accessToken', 'refreshToken', 'accessExpiresAt']) {
      final String? value = await _storage.read(key: '$_prefix$key');
      if (value == null) return null;
      values[key] = value;
    }
    try {
      return OnlineSession.fromStorage(values);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> save(OnlineSession session) async {
    for (final MapEntry<String, String> entry in session.toStorage().entries) {
      await _storage.write(key: '$_prefix${entry.key}', value: entry.value);
    }
  }

  Future<void> clear() async {
    for (final String key in <String>['userId', 'displayName', 'provider', 'accessToken', 'refreshToken', 'accessExpiresAt']) {
      await _storage.delete(key: '$_prefix$key');
    }
  }
}
