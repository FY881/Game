import { describe, expect, it } from 'vitest';

import { AuthFailure, AuthService } from '../src/auth/auth-service.js';
import type { GoogleIdentity, GoogleIdentityVerifier } from '../src/auth/types.js';
import type { ServerConfig } from '../src/config.js';

const config: ServerConfig = {
  PORT: 8080,
  HOST: '127.0.0.1',
  CORS_ORIGIN: 'http://localhost:3000',
  JWT_ISSUER: 'test-issuer',
  JWT_AUDIENCE: 'test-audience',
  JWT_SECRET: 'a-test-secret-that-is-longer-than-thirty-two-characters',
  ACCESS_TOKEN_TTL_SECONDS: 900,
  REFRESH_TOKEN_TTL_SECONDS: 3600,
};

class FakeGoogleVerifier implements GoogleIdentityVerifier {
  constructor(private readonly identity: GoogleIdentity) {}

  async verify(): Promise<GoogleIdentity> {
    return this.identity;
  }
}

describe('AuthService', () => {
  it('ينشئ حساب ضيف ويقبل رمز الوصول الصادر عنه', async () => {
    const service = new AuthService(config, new FakeGoogleVerifier({ subject: 'sub', emailVerified: true }));
    const created = await service.createGuest('فارس_النرد');

    const user = await service.verifyAccessToken(created.tokens.accessToken);

    expect(user.id).toBe(created.user.id);
    expect(user.provider).toBe('guest');
  });

  it('يدور رمز التحديث ويرفض استعماله للمرة الثانية', async () => {
    const service = new AuthService(config, new FakeGoogleVerifier({ subject: 'sub', emailVerified: true }));
    const created = await service.createGuest('لاعب_واحد');
    const refreshed = await service.refresh(created.tokens.refreshToken);

    expect(refreshed.refreshToken).not.toBe(created.tokens.refreshToken);
    await expect(service.refresh(created.tokens.refreshToken)).rejects.toMatchObject<AuthFailure>({ code: 'REFRESH_TOKEN_INVALID' });
  });

  it('يربط Google بحساب الضيف بعد تحقق الخادم من الهوية', async () => {
    const service = new AuthService(
      config,
      new FakeGoogleVerifier({ subject: 'google-subject-1', email: 'player@example.com', emailVerified: true }),
    );
    const created = await service.createGuest('فارس_جوجل');

    const linked = await service.linkGoogle(created.user.id, 'trusted-id-token-from-client');

    expect(linked.user.provider).toBe('google');
    expect(linked.user.googleSubject).toBe('google-subject-1');
  });
});
