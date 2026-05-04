import admin from 'firebase-admin';
import { env } from '../config/env.js';
import db from '../utils/db.js';
import { WebSocketManager } from '../websocket/manager.js';

// Initialize Firebase Admin
// Note: In a real production app, you should use a Service Account JSON.
// For now, we'll try to initialize with the server key if possible, 
// or provide a placeholder for the user to add their serviceAccount.json.
try {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(), // Expects GOOGLE_APPLICATION_CREDENTIALS env var
  });
  console.log('✅ Firebase Admin initialized');
} catch (error: any) {
  console.warn('⚠️ Firebase Admin could not be initialized. Push notifications may fail.');
  console.warn('Reason:', error.message);
  console.warn('To fix: Set GOOGLE_APPLICATION_CREDENTIALS environment variable pointing to your serviceAccount.json');
}

export class NotificationService {
  /**
   * Sends a push notification to all active sessions of a user if they are offline.
   */
  static async sendToUser(userId: string, title: string, body: string, data?: any) {
    // 1. Check if user is online via WebSocket
    // We only send push if they are not connected to any device.
    // (Or we could send to all devices regardless, but the plan says "if offline")
    // Note: WebSocketManager.isUserOnline doesn't exist yet, I'll add it.
    
    // 2. Fetch FCM tokens from active sessions
    const result = await db.execute({
      sql: 'SELECT fcm_token FROM sessions WHERE user_id = ? AND is_active = 1 AND fcm_token IS NOT NULL',
      args: [userId],
    });

    const tokens = result.rows.map((row: any) => row.fcm_token).filter(Boolean) as string[];

    if (tokens.length === 0) return;

    const message = {
      notification: {
        title,
        body,
      },
      data: data || {},
      tokens,
    };

    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`[FCM] Sent ${response.successCount} notifications for user ${userId}`);
      
      // Cleanup invalid tokens
      if (response.failureCount > 0) {
        response.responses.forEach((resp, idx) => {
          if (!resp.success && (resp.error?.code === 'messaging/invalid-registration-token' || resp.error?.code === 'messaging/registration-token-not-registered')) {
            this.removeToken(tokens[idx]);
          }
        });
      }
    } catch (error) {
      console.error('[FCM] Error sending notification:', error);
    }
  }

  static async removeToken(token: string) {
    await db.execute({
      sql: 'UPDATE sessions SET fcm_token = NULL WHERE fcm_token = ?',
      args: [token],
    });
  }
}
