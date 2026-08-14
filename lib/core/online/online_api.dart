import 'dart:convert';

import 'package:http/http.dart' as http;

import 'online_config.dart';
import 'online_models.dart';

class OnlineApiFailure implements Exception {
  const OnlineApiFailure(this.code);

  final String code;

  @override
  String toString() => code;
}

class OnlineApi {
  OnlineApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    if (!OnlineConfig.isAvailable) throw const OnlineApiFailure('ONLINE_NOT_CONFIGURED');
    return Uri.parse('${OnlineConfig.serverUrl}$path');
  }

  Future<OnlineSession> createGuest(String displayName) async {
    final http.Response response = await _client.post(
      _uri('/v1/auth/guest'),
      headers: const <String, String>{'content-type': 'application/json'},
      body: jsonEncode(<String, dynamic>{'displayName': displayName}),
    );
    return _parseSession(response);
  }

  Future<OnlineSession> refresh(String refreshToken, OnlineUser user) async {
    final http.Response response = await _client.post(
      _uri('/v1/auth/refresh'),
      headers: const <String, String>{'content-type': 'application/json'},
      body: jsonEncode(<String, dynamic>{'refreshToken': refreshToken}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) throw OnlineApiFailure(_errorCode(response));
    final Map<String, dynamic> tokens = jsonDecode(response.body) as Map<String, dynamic>;
    return OnlineSession(
      user: user,
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
      accessExpiresAtMilliseconds: tokens['accessExpiresAtMilliseconds'] as int,
    );
  }

  Future<OnlineSession> linkGoogle(String accessToken, String idToken) async {
    final http.Response response = await _client.post(
      _uri('/v1/auth/google/link'),
      headers: <String, String>{'content-type': 'application/json', 'authorization': 'Bearer $accessToken'},
      body: jsonEncode(<String, dynamic>{'idToken': idToken}),
    );
    return _parseSession(response);
  }

  OnlineSession _parseSession(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) throw OnlineApiFailure(_errorCode(response));
    final Map<String, dynamic> payload = jsonDecode(response.body) as Map<String, dynamic>;
    final Map<String, dynamic> tokens = payload['tokens'] as Map<String, dynamic>;
    return OnlineSession(
      user: OnlineUser.fromJson(payload['user'] as Map<String, dynamic>),
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
      accessExpiresAtMilliseconds: tokens['accessExpiresAtMilliseconds'] as int,
    );
  }

  String _errorCode(http.Response response) {
    try {
      return ((jsonDecode(response.body) as Map<String, dynamic>)['error'] as Map<String, dynamic>)['code'] as String;
    } catch (_) {
      return 'ONLINE_REQUEST_FAILED';
    }
  }
}
