import { z } from 'zod';
const environmentSchema = z.object({
    PORT: z.coerce.number().int().min(1).max(65535).default(8080),
    HOST: z.string().default('0.0.0.0'),
    CORS_ORIGIN: z.string().default('http://localhost:3000'),
    JWT_ISSUER: z.string().default('mamalik-alnard-server'),
    JWT_AUDIENCE: z.string().default('mamalik-alnard-android'),
    JWT_SECRET: z.string().min(32),
    ACCESS_TOKEN_TTL_SECONDS: z.coerce.number().int().min(60).max(3600).default(900),
    REFRESH_TOKEN_TTL_SECONDS: z.coerce.number().int().min(3600).max(31_536_000).default(2_592_000),
    GOOGLE_ANDROID_CLIENT_ID: z.string().min(1).optional(),
});
export function loadConfig(environment = process.env) {
    return environmentSchema.parse(environment);
}
