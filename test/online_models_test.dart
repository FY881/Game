import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/online/online_models.dart';

void main() {
  test('OnlineRoom reads lobby readiness and revision from the trusted server', () {
    final OnlineRoom room = OnlineRoom.fromJson(<String, dynamic>{
      'id': 'room-1',
      'code': 'KING12',
      'status': 'waiting',
      'playerIds': <String>['a', 'b'],
      'readyUserIds': <String>['a'],
      'revision': 3,
      'matchId': null,
    });
    expect(room.readyUserIds, <String>['a']);
    expect(room.revision, 3);
  });

  test('OnlineProgress keeps server-issued resources numeric and explicit', () {
    final OnlineProgress progress = OnlineProgress.fromJson(<String, dynamic>{
      'experience': 35,
      'gold': 10,
      'gems': 0,
      'seasonPoints': 12,
    });
    expect(progress.gems, 0);
    expect(progress.seasonPoints, 12);
  });
}
