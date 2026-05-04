import db from '../utils/db.js';
import { WebSocketManager } from '../websocket/manager.js';

export class MessageStatusService {
  /**
   * Marks a single message as delivered for a user
   */
  static async markDelivered(messageId: string, userId: string) {
    await db.execute({
      sql: `UPDATE message_status SET status = 'delivered', updated_at = CURRENT_TIMESTAMP 
            WHERE message_id = ? AND user_id = ? AND status = 'sent'`,
      args: [messageId, userId],
    });

    await this.notifySender(messageId, 'delivered', userId);
  }

  /**
   * Marks a single message as read for a user
   */
  static async markRead(messageId: string, userId: string) {
    await db.execute({
      sql: `UPDATE message_status SET status = 'read', updated_at = CURRENT_TIMESTAMP 
            WHERE message_id = ? AND user_id = ? AND status != 'read'`,
      args: [messageId, userId],
    });

    await this.notifySender(messageId, 'read', userId);
  }

  /**
   * Batch marks all messages in a conversation as read for a user
   */
  static async markAllRead(conversationId: string, userId: string) {
    // 1. Get all unread message IDs in this conversation for this user
    const unreadMessages = await db.execute({
      sql: `SELECT m.id FROM messages m
            JOIN message_status ms ON m.id = ms.message_id
            WHERE m.conversation_id = ? AND ms.user_id = ? AND ms.status != 'read'`,
      args: [conversationId, userId],
    });

    if (unreadMessages.rows.length === 0) return;

    // 2. Update status to 'read'
    await db.execute({
      sql: `UPDATE message_status SET status = 'read', updated_at = CURRENT_TIMESTAMP 
            WHERE user_id = ? AND message_id IN (SELECT id FROM messages WHERE conversation_id = ?)`,
      args: [userId, conversationId],
    });

    // 3. Notify sender(s)
    // Note: In a real app, you might group these notifications to avoid socket spam.
    for (const row of unreadMessages.rows) {
      await this.notifySender(row.id as string, 'read', userId);
    }
  }

  /**
   * Notifies the sender of a message about a status change
   */
  private static async notifySender(messageId: string, status: string, updatedByUserId: string) {
    const result = await db.execute({
      sql: 'SELECT sender_id, conversation_id FROM messages WHERE id = ?',
      args: [messageId],
    });

    if (result.rows.length > 0) {
      const msg = result.rows[0] as any;
      WebSocketManager.sendToUser(msg.sender_id, 'message:status', {
        message_id: messageId,
        conversation_id: msg.conversation_id,
        user_id: updatedByUserId,
        status,
      });
    }
  }

  /**
   * Initializes status for all members when a new message is sent
   */
  static async initializeStatus(messageId: string, conversationId: string, senderId: string) {
    const members = await db.execute({
      sql: 'SELECT user_id FROM conversation_members WHERE conversation_id = ? AND user_id != ?',
      args: [conversationId, senderId],
    });

    for (const member of members.rows) {
      await db.execute({
        sql: 'INSERT INTO message_status (message_id, user_id, status) VALUES (?, ?, ?)',
        args: [messageId, (member as any).user_id, 'sent'],
      });
    }
  }
}
