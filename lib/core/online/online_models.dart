class OnlineUser {
  const OnlineUser({required this.id, required this.displayName, required this.provider});

  final String id;
  final String displayName;
  final String provider;

  factory OnlineUser.fromJson(Map<String, dynamic> json) => OnlineUser(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        provider: json['provider'] as String,
      );
}

class OnlineSession {
  const OnlineSession({required this.user, required this.accessToken, required this.refreshToken, required this.accessExpiresAtMilliseconds});

  final OnlineUser user;
  final String accessToken;
  final String refreshToken;
  final int accessExpiresAtMilliseconds;

  Map<String, String> toStorage() => <String, String>{
        'userId': user.id,
        'displayName': user.displayName,
        'provider': user.provider,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'accessExpiresAt': '$accessExpiresAtMilliseconds',
      };

  factory OnlineSession.fromStorage(Map<String, String> values) => OnlineSession(
        user: OnlineUser(id: values['userId']!, displayName: values['displayName']!, provider: values['provider']!),
        accessToken: values['accessToken']!,
        refreshToken: values['refreshToken']!,
        accessExpiresAtMilliseconds: int.parse(values['accessExpiresAt']!),
      );
}

class OnlineRoom {
  const OnlineRoom({required this.id, required this.code, required this.status, required this.playerIds, required this.matchId});

  final String id;
  final String code;
  final String status;
  final List<String> playerIds;
  final String? matchId;

  factory OnlineRoom.fromJson(Map<String, dynamic> json) => OnlineRoom(
        id: json['id'] as String,
        code: json['code'] as String,
        status: json['status'] as String,
        playerIds: (json['playerIds'] as List<dynamic>).cast<String>(),
        matchId: json['matchId'] as String?,
      );
}
