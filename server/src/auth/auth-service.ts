import { createHash, randomBytes, randomUUID } from 'node:crypto';

import { jwtVerify, SignJWT } from 'jose';

import type { ServerConfig } from '../config.js';
import type { GoogleIdentityVerifier, ServerUser, TokenPair } from './types.js';

interface RefreshSession {
  userId: string;
  expiresAtMilliseconds: number;
}

export class AuthFailure extends Error {
  constructor(public readonly code: string) {
    super(code);
  }
}

export class AuthService {
  private readonly users = new Map<string, ServerUser>();
  private readonly refreshSessions = new Map<string, RefreshSession>();
  private readonly usersByGoogleSubject = new Map<string, string>();
  private readonly jwtKey: Uint8Array;

  constructor(
    private readonly config: ServerConfig,
    private readonly googleVerifier: GoogleIdentityVerifier,
    private readonly now: () => number = () => Date.now(),
  ) {
    this.jwtKey = new TextEncoder().encode(config.JWT_SECRET);
  }

  async createGuest(displayName: string): Promise<{ user: ServerUser; tokens: TokenPair }> {
    const normalizedName = this.normalizeDisplayName(displayName);
    const user: ServerUser = {
      id: `usr_${randomUUID()}`,
      displayName: normalizedName,
      provider: 'guest',
      createdAtMilliseconds: this.now(),
    };
    this.users.set(user.id, user);
    return { user, tokens: await this.issueTokens(user) };
  }

  async verifyAccessToken(token: string): Promise<ServerUser> {
    try {
      const { payload } = await jwtVerify(token, this.jwtKey, {
        issuer: this.config.JWT_ISSUER,
        audience: this.config.JWT_AUDIENCE,
      });
      const userId = payload.sub;
      if (!userId || typeof userId !== 'string') throw new AuthFailure('ACCESS_TOKEN_INVALID');
      const user = this.users.get(userId);
      if (!user) throw new AuthFailure('USER_NOT_FOUND');
      return user;
    } catch (error) {
      if (error instanceof AuthFailure) throw error;
      throw new AuthFailure('ACCESS_TOKEN_INVALID');
    }
  }

  async refresh(refreshToken: string): Promise<TokenPair> {
    const tokenHash = this.hash(refreshToken);
    const session = this.refreshSessions.get(tokenHash);
    if (!session || session.expiresAtMilliseconds <= this.now()) {
      this.refreshSessions.delete(tokenHash);
      throw new AuthFailure('REFRESH_TOKEN_INVALID');
    }
    this.refreshSessions.delete(tokenHash);
    const user = this.users.get(session.userId);
    if (!user) throw new AuthFailure('USER_NOT_FOUND');
    return this.issueTokens(user);
  }

  async linkGoogle(userId: string, idToken: string): Promise<{ user: ServerUser; tokens: TokenPair }> {
    const user = this.users.get(userId);
    if (!user) throw new AuthFailure('USER_NOT_FOUND');
    const identity = await this.googleVerifier.verify(idToken);
    if (!identity.emailVerified) throw new AuthFailure('GOOGLE_EMAIL_NOT_VERIFIED');
    const linkedUserId = this.usersByGoogleSubject.get(identity.subject);
    if (linkedUserId && linkedUserId !== user.id) throw new AuthFailure('GOOGLE_ACCOUNT_ALREADY_LINKED');
    const upgraded: ServerUser = {
      ...user,
      provider: 'google',
      googleSubject: identity.subject,
      googleEmail: identity.email,
    };
    this.users.set(upgraded.id, upgraded);
    this.usersByGoogleSubject.set(identity.subject, upgraded.id);
    return { user: upgraded, tokens: await this.issueTokens(upgraded) };
  }

  getUser(userId: string): ServerUser | undefined {
    return this.users.get(userId);
  }

  private async issueTokens(user: ServerUser): Promise<TokenPair> {
    const issuedAtMilliseconds = this.now();
    const accessExpiresAtMilliseconds = issuedAtMilliseconds + this.config.ACCESS_TOKEN_TTL_SECONDS * 1000;
    const accessToken = await new SignJWT({ provider: user.provider })
      .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
      .setSubject(user.id)
      .setIssuer(this.config.JWT_ISSUER)
      .setAudience(this.config.JWT_AUDIENCE)
      .setIssuedAt(Math.floor(issuedAtMilliseconds / 1000))
      .setExpirationTime(Math.floor(accessExpiresAtMilliseconds / 1000))
      .sign(this.jwtKey);
    const refreshToken = randomBytes(48).toString('base64url');
    this.refreshSessions.set(this.hash(refreshToken), {
      userId: user.id,
      expiresAtMilliseconds: issuedAtMilliseconds + this.config.REFRESH_TOKEN_TTL_SECONDS * 1000,
    });
    return { accessToken, refreshToken, accessExpiresAtMilliseconds };
  }

  private normalizeDisplayName(displayName: string): string {
    const value = displayName.trim();
    if (!/^[\u0621-\u064Aa-zA-Z0-9_ ]{3,14}$/.test(value)) throw new AuthFailure('DISPLAY_NAME_INVALID');
    return value;
  }

  private hash(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }
}
