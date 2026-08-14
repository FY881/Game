import { OAuth2Client } from 'google-auth-library';
export class DisabledGoogleIdentityVerifier {
    async verify() {
        throw new Error('GOOGLE_SIGN_IN_DISABLED');
    }
}
export class GoogleIdTokenVerifier {
    audience;
    client = new OAuth2Client();
    constructor(audience) {
        this.audience = audience;
    }
    async verify(idToken) {
        const ticket = await this.client.verifyIdToken({ idToken, audience: this.audience });
        const payload = ticket.getPayload();
        if (!payload?.sub)
            throw new Error('GOOGLE_ID_TOKEN_INVALID');
        return {
            subject: payload.sub,
            email: payload.email,
            emailVerified: payload.email_verified === true,
        };
    }
}
