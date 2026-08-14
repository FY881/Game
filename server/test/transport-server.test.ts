import { afterEach, describe, expect, it } from 'vitest';
import { io, type Socket } from 'socket.io-client';

import { AuthService } from '../src/auth/auth-service.js';
import type { GoogleIdentityVerifier } from '../src/auth/types.js';
import type { ServerConfig } from '../src/config.js';
import { createTrustedServer, type TrustedServerRuntime } from '../src/transport/server.js';

const config: ServerConfig = {
  PORT: 8080,
  HOST: '127.0.0.1',
  CORS_ORIGIN: 'http://localhost:3000',
  JWT_ISSUER: 'transport-test',
  JWT_AUDIENCE: 'transport-test-client',
  JWT_SECRET: 'a-very-long-transport-test-secret-for-verified-tokens',
  ACCESS_TOKEN_TTL_SECONDS: 900,
  REFRESH_TOKEN_TTL_SECONDS: 3600,
};

const disabledGoogle: GoogleIdentityVerifier = { verify: async () => { throw new Error('GOOGLE_SIGN_IN_DISABLED'); } };
let runtime: TrustedServerRuntime | undefined;

afterEach(async () => {
  if (runtime) {
    await runtime.close();
    runtime = undefined;
  }
});

function connectSocket(baseUrl: string, token: string): Promise<Socket> {
  return new Promise<Socket>((resolve, reject) => {
    const socket = io(baseUrl, { auth: { token }, transports: ['websocket'], forceNew: true });
    socket.once('connect', () => resolve(socket));
    socket.once('connect_error', (error) => reject(error));
  });
}

function emitAck(socket: Socket, event: string, payload: unknown): Promise<{ ok: boolean; data?: any; error?: { code: string } }> {
  return new Promise((resolve) => socket.emit(event, payload, resolve));
}

describe('واجهة النقل الموثوقة', () => {
  it('تنشئ حساب ضيف وتسمح بتدوير جلسة التحديث', async () => {
    const auth = new AuthService(config, disabledGoogle);
    runtime = createTrustedServer(config, auth);
    await new Promise<void>((resolve) => runtime!.httpServer.listen(0, '127.0.0.1', () => resolve()));
    const address = runtime.httpServer.address();
    if (!address || typeof address === 'string') throw new Error('TEST_SERVER_ADDRESS_MISSING');
    const baseUrl = `http://127.0.0.1:${address.port}`;

    const guestResponse = await fetch(`${baseUrl}/v1/auth/guest`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ displayName: 'ضيف_موثوق' }),
    });
    const guest = (await guestResponse.json()) as { user: { id: string }; tokens: { refreshToken: string } };
    expect(guestResponse.status).toBe(201);
    expect(guest.user.id).toMatch(/^usr_/);

    const refreshResponse = await fetch(`${baseUrl}/v1/auth/refresh`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ refreshToken: guest.tokens.refreshToken }),
    });
    expect(refreshResponse.status).toBe(200);
  });

  it('يرفض WebSocket رمية لاعب ليس دوره ويبث حالة الغرفة المعتمدة', async () => {
    const auth = new AuthService(config, disabledGoogle);
    const first = await auth.createGuest('لاعب_أول');
    const second = await auth.createGuest('لاعب_ثان');
    runtime = createTrustedServer(config, auth);
    await new Promise<void>((resolve) => runtime!.httpServer.listen(0, '127.0.0.1', () => resolve()));
    const address = runtime.httpServer.address();
    if (!address || typeof address === 'string') throw new Error('TEST_SERVER_ADDRESS_MISSING');
    const baseUrl = `http://127.0.0.1:${address.port}`;
    const firstSocket = await connectSocket(baseUrl, first.tokens.accessToken);
    const secondSocket = await connectSocket(baseUrl, second.tokens.accessToken);

    try {
      const created = await emitAck(firstSocket, 'room:create', { maxPlayers: 2, mode: 'classic' });
      expect(created.ok).toBe(true);
      const code = created.data.code as string;
      expect((await emitAck(secondSocket, 'room:join', { code })).ok).toBe(true);
      const started = await emitAck(firstSocket, 'room:start', { code });
      expect(started.ok).toBe(true);
      const matchId = started.data.match.id as string;

      const rejected = await emitAck(secondSocket, 'match:roll', { matchId });
      expect(rejected).toMatchObject({ ok: false, error: { code: 'NOT_YOUR_TURN' } });

      const rolled = await emitAck(firstSocket, 'match:roll', { matchId });
      expect(rolled.ok).toBe(true);
      expect(rolled.data.revision).toBeGreaterThan(1);
    } finally {
      firstSocket.disconnect();
      secondSocket.disconnect();
    }
  });
});
