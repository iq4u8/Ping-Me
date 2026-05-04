import bcrypt from 'bcryptjs';
import db from '../utils/db.js';

export class OtpService {
  private static OTP_EXPIRY_MINUTES = 5;

  /**
   * Generates a 6-digit numeric OTP
   */
  static generateOtp(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  /**
   * Checks rate limiting for an identifier
   * Returns null if allowed, or an error message if locked
   */
  static async checkRateLimit(identifier: string): Promise<string | null> {
    const result = await db.execute({
      sql: 'SELECT * FROM otp_attempts WHERE identifier = ?',
      args: [identifier],
    });

    if (result.rows.length === 0) return null;

    const attempt = result.rows[0] as any;
    
    if (attempt.lock_until) {
      const lockUntil = new Date(attempt.lock_until);
      if (lockUntil > new Date()) {
        const remaining = Math.ceil((lockUntil.getTime() - Date.now()) / 60000);
        return `Too many attempts. Locked for ${remaining} minutes.`;
      }
    }

    return null;
  }

  /**
   * Records a failed attempt and applies tiered locking if necessary
   */
  static async recordFailedAttempt(identifier: string) {
    const result = await db.execute({
      sql: 'SELECT * FROM otp_attempts WHERE identifier = ?',
      args: [identifier],
    });

    let attemptCount = 1;
    let tier = 0;

    if (result.rows.length > 0) {
      const row = result.rows[0] as any;
      attemptCount = row.attempt_count + 1;
      tier = row.tier;
    }

    let lockUntil: Date | null = null;

    // tiered rate limiting: 3 attempts -> 1hr lock -> next 3 -> 4hr -> next 3 -> 24hr
    if (attemptCount % 3 === 0) {
      tier = (tier + 1) > 3 ? 3 : tier + 1;
      const hours = tier === 1 ? 1 : tier === 2 ? 4 : 24;
      lockUntil = new Date();
      lockUntil.setHours(lockUntil.getHours() + hours);
    }

    await db.execute({
      sql: `INSERT INTO otp_attempts (identifier, attempt_count, last_attempt_at, lock_until, tier)
            VALUES (?, ?, CURRENT_TIMESTAMP, ?, ?)
            ON CONFLICT(identifier) DO UPDATE SET
            attempt_count = excluded.attempt_count,
            last_attempt_at = CURRENT_TIMESTAMP,
            lock_until = excluded.lock_until,
            tier = excluded.tier`,
      args: [identifier, attemptCount, lockUntil?.toISOString() || null, tier],
    });
  }

  /**
   * Resets attempts on successful verification
   */
  static async resetAttempts(identifier: string) {
    await db.execute({
      sql: 'DELETE FROM otp_attempts WHERE identifier = ?',
      args: [identifier],
    });
  }

  /**
   * Stores a hashed OTP for an identifier
   */
  static async storeOtp(identifier: string, otp: string) {
    const hashedOtp = await bcrypt.hash(otp, 10);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + this.OTP_EXPIRY_MINUTES);

    await db.execute({
      sql: `INSERT INTO otps (identifier, hashed_otp, expires_at)
            VALUES (?, ?, ?)
            ON CONFLICT(identifier) DO UPDATE SET
            hashed_otp = excluded.hashed_otp,
            expires_at = excluded.expires_at`,
      args: [identifier, hashedOtp, expiresAt.toISOString()],
    });
  }

  /**
   * Verifies an OTP
   */
  static async verifyOtp(identifier: string, otp: string): Promise<boolean> {
    const result = await db.execute({
      sql: 'SELECT * FROM otps WHERE identifier = ?',
      args: [identifier],
    });

    if (result.rows.length === 0) return false;

    const row = result.rows[0] as any;
    const expiresAt = new Date(row.expires_at);

    if (expiresAt < new Date()) {
      await this.deleteOtp(identifier);
      return false;
    }

    const isValid = await bcrypt.compare(otp, row.hashed_otp);
    
    if (isValid) {
      await this.deleteOtp(identifier);
    }

    return isValid;
  }

  static async deleteOtp(identifier: string) {
    await db.execute({
      sql: 'DELETE FROM otps WHERE identifier = ?',
      args: [identifier],
    });
  }
}
