import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'online_config.dart';
import 'online_models.dart';

class OnlineRoomClient {
  io.Socket? _socket;
  final StreamController<OnlineRoom> _rooms = StreamController<OnlineRoom>.broadcast();
  final StreamController<Map<String, dynamic>> _matches = StreamController<Map<String, dynamic>>.broadcast();

  Stream<OnlineRoom> get roomStates => _rooms.stream;
  Stream<Map<String, dynamic>> get matchStates => _matches.stream;

  Future<void> connect(String accessToken) async {
    if (!OnlineConfig.isAvailable) throw StateError('ONLINE_NOT_CONFIGURED');
    await disconnect();
    final io.Socket socket = io.io(
      OnlineConfig.serverUrl,
      io.OptionBuilder().setTransports(<String>['websocket']).disableAutoConnect().setAuth(<String, dynamic>{'token': accessToken}).build(),
    );
    _socket = socket;
    socket.on('room:state', (dynamic payload) => _rooms.add(OnlineRoom.fromJson((payload as Map).cast<String, dynamic>())));
    socket.on('match:state', (dynamic payload) => _matches.add((payload as Map).cast<String, dynamic>()));
    await _waitForConnection(socket);
  }

  Future<OnlineRoom> createRoom({required int maxPlayers, required String mode}) async {
    final Map<String, dynamic> response = await _emitAck('room:create', <String, dynamic>{'maxPlayers': maxPlayers, 'mode': mode});
    return OnlineRoom.fromJson((response['data'] as Map).cast<String, dynamic>());
  }

  Future<OnlineRoom> joinRoom(String code) async {
    final Map<String, dynamic> response = await _emitAck('room:join', <String, dynamic>{'code': code});
    return OnlineRoom.fromJson((response['data'] as Map).cast<String, dynamic>());
  }

  Future<Map<String, dynamic>> startRoom(String code) async => _emitAck('room:start', <String, dynamic>{'code': code});

  Future<Map<String, dynamic>> syncRoom(String code) async => _emitAck('room:sync', <String, dynamic>{'code': code});

  Future<Map<String, dynamic>> roll(String matchId) async => _emitAck('match:roll', <String, dynamic>{'matchId': matchId});

  Future<Map<String, dynamic>> move(String matchId, String pawnId) async => _emitAck('match:move', <String, dynamic>{'matchId': matchId, 'pawnId': pawnId});

  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _rooms.close();
    await _matches.close();
  }

  Future<void> _waitForConnection(io.Socket socket) {
    final Completer<void> completer = Completer<void>();
    socket.once('connect', (_) => completer.complete());
    socket.once('connect_error', (dynamic error) => completer.completeError(StateError('$error')));
    socket.connect();
    return completer.future.timeout(const Duration(seconds: 10));
  }

  Future<Map<String, dynamic>> _emitAck(String event, Map<String, dynamic> payload) {
    final io.Socket? socket = _socket;
    if (socket == null || !socket.connected) throw StateError('ONLINE_SOCKET_DISCONNECTED');
    final Completer<Map<String, dynamic>> completer = Completer<Map<String, dynamic>>();
    socket.emitWithAck(event, payload, ack: (dynamic response) {
      final Map<String, dynamic> parsed = (response as Map).cast<String, dynamic>();
      if (parsed['ok'] != true) {
        final Map<String, dynamic> error = (parsed['error'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
        completer.completeError(StateError(error['code'] as String? ?? 'ONLINE_REQUEST_REJECTED'));
        return;
      }
      completer.complete(parsed);
    });
    return completer.future.timeout(const Duration(seconds: 10));
  }
}
