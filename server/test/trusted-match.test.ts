import { describe, expect, it } from 'vitest';

import { MatchFailure, TrustedMatch } from '../src/game/trusted-match.js';
import { RoomFailure, RoomService } from '../src/rooms/room-service.js';

describe('TrustedMatch', () => {
  it('يولد النرد على الخادم ويمنع اللاعب غير النشط من الرمي', () => {
    const match = new TrustedMatch('room-1', ['user-a', 'user-b'], { mode: 'classic' }, () => 6);

    const rolled = match.requestRoll('user-a');

    expect(rolled.dice).toBe(6);
    expect(rolled.phase).toBe('selectingPawn');
    expect(() => match.requestRoll('user-b')).toThrow('NOT_YOUR_TURN');
  });

  it('يتحقق من الحجر القانوني ويحتفظ بالدور بعد رمية ستة', () => {
    const match = new TrustedMatch('room-1', ['user-a', 'user-b'], { mode: 'classic' }, () => 6);
    match.requestRoll('user-a');

    const moved = match.requestMove('user-a', 'coral-0');

    expect(moved.players[0].pawns[0].progress).toBe(0);
    expect(moved.currentPlayerIndex).toBe(0);
    expect(moved.phase).toBe('rolling');
    expect(() => match.requestMove('user-a', 'coral-1')).toThrow('MOVE_NOT_ALLOWED');
  });
});

describe('RoomService', () => {
  it('يتطلب مضيفًا ولاعبين اثنين قبل بدء غرفة خاصة', () => {
    const rooms = new RoomService();
    const room = rooms.createRoom('user-a', 2, { mode: 'classic' });

    expect(() => rooms.startRoom('user-a', room.code)).toThrow('ROOM_NEEDS_PLAYERS');
    rooms.joinRoom('user-b', room.code);
    expect(() => rooms.startRoom('user-b', room.code)).toThrow('ONLY_HOST_CAN_START');

    const started = rooms.startRoom('user-a', room.code, () => 5);
    expect(started.room.status).toBe('playing');
    expect(started.match.players).toHaveLength(2);
  });
});
