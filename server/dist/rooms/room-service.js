import { randomBytes, randomUUID } from 'node:crypto';
import { MatchFailure, TrustedMatch } from '../game/trusted-match.js';
export class RoomFailure extends Error {
    code;
    constructor(code) {
        super(code);
        this.code = code;
    }
}
export class RoomService {
    rooms = new Map();
    roomsByCode = new Map();
    matches = new Map();
    createRoom(hostUserId, maxPlayers, config) {
        const code = this.newRoomCode();
        const room = {
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
    joinRoom(userId, code) {
        const room = this.lookupRoomByCode(code);
        if (room.status !== 'waiting')
            throw new RoomFailure('ROOM_NOT_JOINABLE');
        if (room.playerIds.includes(userId))
            return structuredClone(room);
        if (room.playerIds.length >= room.maxPlayers)
            throw new RoomFailure('ROOM_FULL');
        room.playerIds.push(userId);
        return structuredClone(room);
    }
    startRoom(userId, code, rollDie) {
        const room = this.lookupRoomByCode(code);
        if (room.hostUserId !== userId)
            throw new RoomFailure('ONLY_HOST_CAN_START');
        if (room.status !== 'waiting' || room.playerIds.length < 2)
            throw new RoomFailure('ROOM_NEEDS_PLAYERS');
        const match = new TrustedMatch(room.id, room.playerIds, room.config, rollDie);
        room.status = 'playing';
        room.matchId = match.state.id;
        this.matches.set(match.state.id, match);
        return { room: structuredClone(room), match: match.state };
    }
    getRoomByCode(code) {
        return structuredClone(this.lookupRoomByCode(code));
    }
    getMatchState(matchId) {
        return this.lookupMatch(matchId).state;
    }
    roll(matchId, userId) {
        const match = this.lookupMatch(matchId);
        try {
            return match.requestRoll(userId);
        }
        catch (error) {
            if (error instanceof MatchFailure)
                throw new RoomFailure(error.code);
            throw error;
        }
    }
    move(matchId, userId, pawnId) {
        const match = this.lookupMatch(matchId);
        try {
            const state = match.requestMove(userId, pawnId);
            if (state.winner) {
                const room = this.rooms.get(state.roomId);
                if (room)
                    room.status = 'finished';
            }
            return state;
        }
        catch (error) {
            if (error instanceof MatchFailure)
                throw new RoomFailure(error.code);
            throw error;
        }
    }
    lookupRoomByCode(code) {
        const roomId = this.roomsByCode.get(code.trim().toUpperCase());
        const room = roomId ? this.rooms.get(roomId) : undefined;
        if (!room)
            throw new RoomFailure('ROOM_NOT_FOUND');
        return room;
    }
    lookupMatch(matchId) {
        const match = this.matches.get(matchId);
        if (!match)
            throw new RoomFailure('MATCH_NOT_FOUND');
        return match;
    }
    newRoomCode() {
        let code = '';
        do {
            code = randomBytes(4).toString('hex').toUpperCase().slice(0, 6);
        } while (this.roomsByCode.has(code));
        return code;
    }
}
