import 'dotenv/config';

import { AuthService } from './auth/auth-service.js';
import { DisabledGoogleIdentityVerifier, GoogleIdTokenVerifier } from './auth/google-identity-verifier.js';
import { loadConfig } from './config.js';
import { createTrustedServer } from './transport/server.js';

const config = loadConfig();
const googleVerifier = config.GOOGLE_ANDROID_CLIENT_ID
  ? new GoogleIdTokenVerifier(config.GOOGLE_ANDROID_CLIENT_ID)
  : new DisabledGoogleIdentityVerifier();
const auth = new AuthService(config, googleVerifier);
const runtime = createTrustedServer(config, auth);

runtime.httpServer.listen(config.PORT, config.HOST, () => {
  console.log(`Trusted server listening on http://${config.HOST}:${config.PORT}`);
});
