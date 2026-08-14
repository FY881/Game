export type AuthProvider = 'guest' | 'google';

export interface ServerUser {
  id: string;
  displayName: string;
  provider: AuthProvider;
  createdAtMilliseconds: number;
  googleSubject?: string;
  googleEmail?: string;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  accessExpiresAtMilliseconds: number;
}

export interface GoogleIdentity {
  subject: string;
  email?: string;
  emailVerified: boolean;
}

export interface GoogleIdentityVerifier {
  verify(idToken: string): Promise<GoogleIdentity>;
}
