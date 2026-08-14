import { OAuth2Client } from 'google-auth-library';

import type { GoogleIdentity, GoogleIdentityVerifier } from './types.js';

export class DisabledGoogleIdentityVerifier implements GoogleIdentityVerifier {
  async verify(): Promise<GoogleIdentity> {
    throw new Error('GOOGLE_SIGN_IN_DISABLED');
  }
}

export class GoogleIdTokenVerifier implements GoogleIdentityVerifier {
  private readonly client = new OAuth2Client();

  constructor(private readonly audience: string) {}

  async verify(idToken: string): Promise<GoogleIdentity> {
    const ticket = await this.client.verifyIdToken({ idToken, audience: this.audience });
    const payload = ticket.getPayload();
    if (!payload?.sub) throw new Error('GOOGLE_ID_TOKEN_INVALID');
    return {
      subject: payload.sub,
      email: payload.email,
      emailVerified: payload.email_verified === true,
    };
  }
}
