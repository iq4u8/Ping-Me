import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import db from '../utils/db.js';
import { env } from '../config/env.js';

export interface User {
  id: string;
  username: string;
  display_name: string;
  email?: string;
  phone?: string;
}

export interface AuthResponse {
  user: User;
  accessToken: string;
  refreshToken: string;
}

export class AuthService {
  static async generateTokens(user: { id: string; username: string }) {
    const accessToken = jwt.sign(
      { id: user.id, username: user.username },
      env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    const refreshToken = jwt.sign(
      { id: user.id, username: user.username },
      env.JWT_SECRET,
      { expiresIn: '30d' }
    );
    return { accessToken, refreshToken };
  }

  static async register(data: {
    username: string;
    display_name: string;
    email?: string;
    phone?: string;
  }): Promise<AuthResponse> {
    const id = uuidv4();
    const username = data.username.toLowerCase();

    // Check if username taken
    const existing = await db.execute({
      sql: 'SELECT id FROM users WHERE username = ?',
      args: [username],
    });

    if (existing.rows.length > 0) {
      throw new Error('Username already taken');
    }

    await db.execute({
      sql: `INSERT INTO users (id, username, display_name, email, phone)
            VALUES (?, ?, ?, ?, ?)`,
      args: [id, username, data.display_name, data.email || null, data.phone || null],
    });

    const user: User = { id, username, display_name: data.display_name, email: data.email, phone: data.phone };
    const tokens = await this.generateTokens(user);

    return { user, ...tokens };
  }

  static async createSession(userId: string, deviceInfo: string, ipAddress: string) {
    const sessionId = uuidv4();
    await db.execute({
      sql: `INSERT INTO sessions (id, user_id, device_info, ip_address, is_active)
            VALUES (?, ?, ?, ?, 1)`,
      args: [sessionId, userId, deviceInfo, ipAddress],
    });
    return sessionId;
  }

  static async getUserByUsernameOrIdentifier(identifier: string): Promise<User | null> {
    const result = await db.execute({
      sql: 'SELECT * FROM users WHERE username = ? OR email = ? OR phone = ?',
      args: [identifier, identifier, identifier],
    });

    if (result.rows.length === 0) return null;
    const row = result.rows[0] as any;
    return {
      id: row.id,
      username: row.username,
      display_name: row.display_name,
      email: row.email,
      phone: row.phone,
    };
  }

  static async logout(userId: string) {
    await db.execute({
      sql: 'UPDATE sessions SET is_active = 0 WHERE user_id = ?',
      args: [userId],
    });
  }

  static async getActiveSessions(userId: string) {
    const result = await db.execute({
      sql: 'SELECT id, device_info, ip_address, created_at, last_active FROM sessions WHERE user_id = ? AND is_active = 1',
      args: [userId],
    });
    return result.rows;
  }

  static async revokeSession(userId: string, sessionId: string) {
    await db.execute({
      sql: 'UPDATE sessions SET is_active = 0 WHERE id = ? AND user_id = ?',
      args: [sessionId, userId],
    });
  }

  static async updateFcmToken(userId: string, ipAddress: string, fcmToken: string) {
    // Update the most recent active session for this user and IP
    await db.execute({
      sql: `UPDATE sessions SET fcm_token = ? 
            WHERE user_id = ? AND ip_address = ? AND is_active = 1
            ORDER BY created_at DESC LIMIT 1`,
      args: [fcmToken, userId, ipAddress],
    });
  }
}
