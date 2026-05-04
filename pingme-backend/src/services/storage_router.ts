import db from '../utils/db.js';
import { env } from '../config/env.js';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';

export interface StorageAccount {
  id: string;
  name: string;
  endpoint: string;
  access_key: string;
  secret_key: string;
  bucket_name: string;
  priority: number;
  used_bytes: number;
  is_active: number;
}

export class StorageRouter {
  /**
   * Selects the best storage account based on priority and usage.
   * If DB is empty, falls back to the default account from env.
   */
  static async selectStorageAccount(): Promise<StorageAccount> {
    const result = await db.execute({
      sql: 'SELECT * FROM storage_accounts WHERE is_active = 1 ORDER BY priority DESC, used_bytes ASC LIMIT 1',
      args: [],
    });

    if (result.rows.length > 0) {
      return result.rows[0] as unknown as StorageAccount;
    }

    // Fallback to default from .env
    return {
      id: 'default',
      name: 'Default R2',
      endpoint: env.R2_ENDPOINT,
      access_key: env.R2_ACCESS_KEY,
      secret_key: env.R2_SECRET_KEY,
      bucket_name: env.R2_BUCKET_NAME,
      priority: 1,
      used_bytes: 0,
      is_active: 1,
    };
  }

  /**
   * Updates usage for a storage account.
   */
  static async updateUsage(accountId: string, bytes: number) {
    if (accountId === 'default') return;

    await db.execute({
      sql: 'UPDATE storage_accounts SET used_bytes = used_bytes + ? WHERE id = ?',
      args: [bytes, accountId],
    });
  }

  /**
   * Helper to create an S3 client for a specific account.
   */
  static getClient(account: StorageAccount): S3Client {
    return new S3Client({
      region: 'auto',
      endpoint: account.endpoint,
      credentials: {
        accessKeyId: account.access_key,
        secretAccessKey: account.secret_key,
      },
    });
  }
}
