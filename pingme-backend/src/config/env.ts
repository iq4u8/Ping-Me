import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load .env file
dotenv.config({ path: path.join(__dirname, '../../.env') });

const requiredEnvVars = [
  'DATABASE_URL',
  'DATABASE_AUTH_TOKEN',
  'JWT_SECRET',
  'R2_ACCESS_KEY',
  'R2_SECRET_KEY',
  'R2_BUCKET_NAME',
  'R2_ENDPOINT',
  'INFISICAL_TOKEN',
  'FCM_SERVER_KEY',
  'SMTP_HOST',
  'SMTP_USER',
  'SMTP_PASS',
] as const;

export const env = {
  DATABASE_URL: process.env.DATABASE_URL!,
  DATABASE_AUTH_TOKEN: process.env.DATABASE_AUTH_TOKEN!,
  JWT_SECRET: process.env.JWT_SECRET!,
  R2_ACCESS_KEY: process.env.R2_ACCESS_KEY!,
  R2_SECRET_KEY: process.env.R2_SECRET_KEY!,
  R2_BUCKET_NAME: process.env.R2_BUCKET_NAME!,
  R2_ENDPOINT: process.env.R2_ENDPOINT!,
  INFISICAL_TOKEN: process.env.INFISICAL_TOKEN!,
  FCM_SERVER_KEY: process.env.FCM_SERVER_KEY!,
  SMTP_HOST: process.env.SMTP_HOST!,
  SMTP_USER: process.env.SMTP_USER!,
  SMTP_PASS: process.env.SMTP_PASS!,
  PORT: process.env.PORT || '3000',
};

// Validation: throw error if any required key is missing
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    throw new Error(`Environment variable ${envVar} is missing from .env file`);
  }
}
