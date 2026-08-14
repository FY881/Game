import { randomBytes, randomUUID } from 'node:crypto';

import { MatchFailure, TrustedMatch } from '../game/trusted-match.js';
import type { TrustedMatchConfig, TrustedMatchState, TrustedRoom } from '../game/types.js';

export class RoomFailure extends Error {
  constructor(public readonly code: string) {
    super(code);
  }
}

export class RoomService {
  private readonly rooms = new Map<string, TrustedRoom>();
  private readonly roomsByCode = new Map<string, string>();
  private readonly matches = new Map<string, TrustedMatch>();

  createRoom(hostUserId: string, maxPlayers: 2 | 3 | 4, config: TrustedMatchConfig): TrustedRoom {
    const code = this.newRoomCode();
    const room: TrustedRoom = {
      id: `room_${randomUUID()}`,
      code,
      hostUserId,
      maxPlayers,
      config,
      playerIds: [hostUserId],
      status: 'waiting',
      matchId: null,
    };
    this.rooms.set(room.id, room);
    this.roomsByCode.set(room.code, room.id);
    return structuredClone(room);
  }

  joinRoom(userId: string, code: string): TrustedRoom {
    const room = this.lookupRoomByCode(code);
    if (room.status !== 'waiting') throw new RoomFailure('ROOM_NOT_JOINABLE');
    if (room.playerIds.includes(userId)) return structuredClone(room);
    if (room.playerIds.length >= room.maxPlayers) throw new RoomFailure('ROOM_FULL');
    room.playerIds.push(userId);
    return structuredClone(room);
  }

  startRoom(userId: string, code: string, rollDie?: () => number): { room: TrustedRoom; match: TrustedMatchState } {
    const room = this.lookupRoomByCode(code);
    if (room.hostUserId !== userId) throw new RoomFailure('ONLY_HOST_CAN_START');
    if (room.status !== 'waiting' || room.playerIds.length < 2) throw new RoomFailure('ROOM_NEEDS_PLAYERS');
    const match = new TrustedMatch(room.id, room.playerIds, room.config, rollDie);
    room.status = 'playing';
    room.matchId = match.state.id;
    this.matches.set(match.state.id, match);
    return { room: structuredClone(room), match: match.state };
  }

  getRoomByCode(code: string): TrustedRoom {
    return structuredClone(this.lookupRoomByCode(code));
  }

  getMatchState(matchId: string): TrustedMatchState {
    return this.lookupMatch(matchId).state;
  }

  roll(matchId: string, userId: string): TrustedMatchState {
    const match = this.lookupMatch(matchId);
    try {
      return match.requestRoll(userId);
    } catch (error) {
      if (error instanceof MatchFailure) throw new RoomFailure(error.code);
      throw error;
    }
  }

  move(matchId: string, userId: string, pawnId: string): TrustedMatchState {
    const match = this.lookupMatch(matchId);
    try {
      const state = match.requestMove(userId, pawnId);
      if (state.winner) {
        const room = this.rooms.get(state.roomId);
        if (room) room.status = 'finished';
      }
      return state;
    } catch (error) {
      if (error instanceof MatchFailure) throw new RoomFailure(error.code);
      throw error;
    }
  }

  private lookupRoomByCode(code: string): TrustedRoom {
    const roomId = this.roomsByCode.get(code.trim().toUpperCase());
    const room = roomId ? this.rooms.get(roomId) : undefined;
    if (!room) throw new RoomFailure('ROOM_NOT_FOUND');
    return room;
  }

  private lookupMatch(matchId: string): TrustedMatch {
    const match = this.matches.get(matchId);
    if (!match) throw new RoomFailure('MATCH_NOT_FOUND');
    return match;
  }

  private newRoomCode(): string {
    let code = '';
    do {
      code = randomBytes(4).toString('hex').toUpperCase().slice(0, 6);
    } while (this.roomsByCode.has(code));
    return code;
  }
}
