import { createServer as createHttpServer } from 'node:http';

import cors from 'cors';
import express, { type NextFunction, type Request, type Response } from 'express';
import { Server as SocketServer, type Socket } from 'socket.io';
import { z } from 'zod';

import type { AuthService, AuthFailure } from '../auth/auth-service.js';
import type { ServerUser } from '../auth/types.js';
import type { ServerConfig } from '../config.js';
import type { TrustedMatchConfig } from '../game/types.js';
import { RoomFailure, RoomService } from '../rooms/room-service.js';

const guestSchema = z.object({ displayName: z.string().min(1).max(64) });
const refreshSchema = z.object({ refreshToken: z.string().min(20) });
const googleLinkSchema = z.object({ idToken: z.string().min(20) });
const roomCreateSchema = z.object({ maxPlayers: z.union([z.literal(2), z.literal(3), z.literal(4)]), mode: z.union([z.literal('classic'), z.literal('quick')]) });
const roomCodeSchema = z.object({ code: z.string().trim().min(6).max(12) });
const moveSchema = z.object({ matchId: z.string().min(1), pawnId: z.string().min(1).max(32) });
const rollSchema = z.object({ matchId: z.string().min(1) });
const syncSchema = z.object({ code: z.string().trim().min(6).max(12), matchId: z.string().min(1).optional() });

interface SocketContext {
  user: ServerUser;
}

type EventAck = (payload: { ok: boolean; data?: unknown; error?: { code: string } }) => void;

export interface TrustedServerRuntime {
  app: express.Express;
  httpServer: ReturnType<typeof createHttpServer>;
  io: SocketServer;
  close(): Promise<void>;
}

export function createTrustedServer(config: ServerConfig, auth: AuthService, rooms = new RoomService()): TrustedServerRuntime {
  const app = express();
  app.use(cors({ origin: config.CORS_ORIGIN, methods: ['GET', 'POST'] }));
  app.use(express.json({ limit: '32kb' }));
  app.get('/health', (_request, response) => response.status(200).json({ ok: true, service: 'mamalik-alnard-server' }));

  app.post('/v1/auth/guest', async (request, response) => {
    try {
      const input = guestSchema.parse(request.body);
      const result = await auth.createGuest(input.displayName);
      response.status(201).json(result);
    } catch (error) {
      sendFailure(response, error);
    }
  });

  app.post('/v1/auth/refresh', async (request, response) => {
    try {
      const input = refreshSchema.parse(request.body);
      response.status(200).json(await auth.refresh(input.refreshToken));
    } catch (error) {
      sendFailure(response, error);
    }
  });

  app.post('/v1/auth/google/link', requireUser(auth), async (request, response) => {
    try {
      const input = googleLinkSchema.parse(request.body);
      response.status(200).json(await auth.linkGoogle(request.user!.id, input.idToken));
    } catch (error) {
      sendFailure(response, error);
    }
  });

  const httpServer = createHttpServer(app);
  const io = new SocketServer(httpServer, { cors: { origin: config.CORS_ORIGIN, methods: ['GET', 'POST'] } });
  io.use(async (socket, next) => {
    try {
      const token = typeof socket.handshake.auth.token === 'string' ? socket.handshake.auth.token : '';
      const user = await auth.verifyAccessToken(token);
      socket.data.context = { user } satisfies SocketContext;
      next();
    } catch {
      next(new Error('ACCESS_TOKEN_INVALID'));
    }
  });

  io.on('connection', (socket) => registerSocketHandlers(socket, rooms, io));

  return {
    app,
    httpServer,
    io,
    close: async () => {
      await new Promise<void>((resolve) => io.close(() => resolve()));
      if (!httpServer.listening) return;
      await new Promise<void>((resolve, reject) => httpServer.close((error) => (error ? reject(error) : resolve())));
    },
  };
}

function requireUser(auth: AuthService) {
  return async (request: Request, response: Response, next: NextFunction) => {
    try {
      const header = request.header('authorization');
      if (!header?.startsWith('Bearer ')) throw new Error('ACCESS_TOKEN_INVALID');
      request.user = await auth.verifyAccessToken(header.slice('Bearer '.length));
      next();
    } catch (error) {
      sendFailure(response, error);
    }
  };
}

function registerSocketHandlers(socket: Socket, rooms: RoomService, io: SocketServer): void {
  const user = (socket.data.context as SocketContext).user;
  socket.emit('server:ready', { userId: user.id });

  socket.on('room:create', (raw: unknown, ack: EventAck = () => undefined) => {
    try {
      const input = roomCreateSchema.parse(raw);
      const room = rooms.createRoom(user.id, input.maxPlayers, { mode: input.mode } satisfies TrustedMatchConfig);
      socket.join(room.code);
      emitAck(ack, room);
      io.to(room.code).emit('room:state', room);
    } catch (error) {
      emitSocketFailure(socket, ack, error);
    }
  });

  socket.on('room:join', (raw: unknown, ack: EventAck = () => undefined) => {
    try {
      const input = roomCodeSchema.parse(raw);
      const room = rooms.joinRoom(user.id, input.code);
      socket.join(room.code);
      emitAck(ack, room);
      io.to(room.code).emit('room:state', room);
    } catch (error) {
      emitSocketFailure(socket, ack, error);
    }
  });

  socket.on('room:start', (raw: unknown, ack: EventAck = () => undefined) => {
    try {
      const input = roomCodeSchema.parse(raw);
      const started = rooms.startRoom(user.id, input.code);
      emitAck(ack, started);
      io.to(started.room.code).emit('room:state', started.room);
      io.to(started.room.code).emit('match:state', started.match);
    } catch (error) {
      emitSocketFailure(socket, ack, error);
    }
  });

  socket.on('room:sync', (raw: unknown, ack: EventAck = () => undefined) => {
    try {
      const input = syncSchema.parse(raw);
      const room = rooms.getRoomByCode(input.code);
      if (!room.playerIds.includes(user.id)) throw new RoomFailure('ROOM_ACCESS_DENIED');
      socket.join(room.code);
      const match = room.matchId ? rooms.getMatchState(room.matchId) : null;
      emitAck(ack, { room, match });
      socket.emit('room:state', room);
      if (match) socket.emit('match:state', match);
    } catch (error) {
      emitSocketFailure(socket, ack, error);
    }
  });

  socket.on('match:roll', (raw: unknown, ack: EventAck = () => undefined) => {
    try {
      const input = rollSchema.parse(raw);
      const match = rooms.roll(input.matchId, user.id);
      emitAck(ack, match);
      io.to(match.roomId).emit('match:state', match);
    } catch (error) {
      emitSocketFailure(socket, ack, error);
    }
  });

  socket.on('match:move', (raw: unknown, ack: EventAck = () => undefined) => {
    try {
      const input = moveSchema.parse(raw);
      const match = rooms.move(input.matchId, user.id, input.pawnId);
      emitAck(ack, match);
      io.to(match.roomId).emit('match:state', match);
    } catch (error) {
      emitSocketFailure(socket, ack, error);
    }
  });
}

function emitAck(ack: EventAck, data: unknown): void {
  ack({ ok: true, data });
}

function emitSocketFailure(socket: Socket, ack: EventAck, error: unknown): void {
  const code = failureCode(error);
  const payload = { ok: false, error: { code } };
  ack(payload);
  socket.emit('server:error', payload.error);
}

function sendFailure(response: Response, error: unknown): void {
  const code = failureCode(error);
  const status = code.includes('TOKEN') || code.includes('GOOGLE') || code === 'USER_NOT_FOUND' ? 401 : 400;
  response.status(status).json({ error: { code } });
}

function failureCode(error: unknown): string {
  if (error instanceof RoomFailure) return error.code;
  if (error instanceof Error && 'code' in error && typeof (error as AuthFailure).code === 'string') return (error as AuthFailure).code;
  if (error instanceof z.ZodError) return 'REQUEST_INVALID';
  return 'REQUEST_REJECTED';
}

declare global {
  namespace Express {
    interface Request {
      user?: ServerUser;
    }
  }
}
