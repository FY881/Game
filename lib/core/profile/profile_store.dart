import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'player_profile.dart';

class ProfileStore {
  static const String _key = 'mamalik_local_profile_v1';

  Future<PlayerProfile?> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_key);
    if (raw == null) return null;
    try {
      return PlayerProfile.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await preferences.remove(_key);
      return null;
    }
  }

  Future<void> save(PlayerProfile profile) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode(profile.toMap()));
  }

  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
