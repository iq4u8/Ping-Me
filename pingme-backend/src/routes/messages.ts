import { FastifyInstance } from 'fastify';
import { v4 as uuidv4 } from 'uuid';
import db from '../utils/db.js';
import { authMiddleware } from '../middlewares/auth.js';
import { WebSocketManager } from '../websocket/manager.js';
import { MessageStatusService } from '../services/messageStatusService.js';
import { NotificationService } from '../services/notificationService.js';

export default async function messageRoutes(fastify: FastifyInstance) {
  fastify.addHook('preHandler', authMiddleware);

  // POST /api/v1/messages - Send a message
  fastify.post('/', async (request, reply) => {
    const { conversation_id, type, encrypted_content, reply_to_id } = request.body as any;
    const sender_id = request.user.id;

    // 1. Verify membership and permissions
    const membership = await db.execute({
      sql: 'SELECT role FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
      args: [conversation_id, sender_id],
    });

    if (membership.rows.length === 0) {
      return reply.status(403).send({ success: false, error: 'Not a member of this conversation' });
    }

    const memberRole = (membership.rows[0] as any).role;

    // Check if it's a channel and if user is allowed to post
    const conversation = await db.execute({
      sql: 'SELECT type FROM conversations WHERE id = ?',
      args: [conversation_id],
    });

    if (conversation.rows.length > 0 && (conversation.rows[0] as any).type === 'channel') {
      if (!['owner', 'admin'].includes(memberRole)) {
        return reply.status(403).send({ success: false, error: 'Only admins can post to this channel' });
      }
    }

    const messageId = uuidv4();

    try {
      // 2. Insert message
      await db.execute({
        sql: `INSERT INTO messages (id, conversation_id, sender_id, type, encrypted_content, reply_to_id)
              VALUES (?, ?, ?, ?, ?, ?)`,
        args: [messageId, conversation_id, sender_id, type, encrypted_content, reply_to_id || null],
      });

      // 3. Initialize message status for all members
      await MessageStatusService.initializeStatus(messageId, conversation_id, sender_id);

      // 4. Get all members to notify
      const members = await db.execute({
        sql: 'SELECT user_id FROM conversation_members WHERE conversation_id = ?',
        args: [conversation_id],
      });

      const messageData = {
        id: messageId,
        conversation_id,
        sender_id,
        type,
        encrypted_content,
        reply_to_id,
        created_at: new Date().toISOString(),
      };

      // 5. Broadcast via WebSocket and send Push to offline users
      members.rows.forEach((row: any) => {
        const recipientId = row.user_id;
        
        // Always send via WebSocket (manager handles if they are connected)
        WebSocketManager.sendToUser(recipientId, 'message:new', messageData);

        // If user is offline and not the sender, send Push Notification
        if (recipientId !== sender_id && !WebSocketManager.isUserOnline(recipientId)) {
          // Fetch sender name for the notification
          db.execute({
            sql: 'SELECT display_name FROM users WHERE id = ?',
            args: [sender_id]
          }).then(userResult => {
            const senderName = userResult.rows.length > 0 ? (userResult.rows[0] as any).display_name : 'New Message';
            NotificationService.sendToUser(
              recipientId, 
              senderName, 
              'New encrypted message',
              { conversation_id, message_id: messageId }
            );
          }).catch(err => console.error('Error fetching sender for notification:', err));
        }
      });

      return reply.send({ success: true, message: messageData });
    } catch (error: any) {
      return reply.status(500).send({ success: false, error: error.message });
    }
  });

  // POST /api/v1/messages/:id/status - Update message status (delivered/read)
  fastify.post('/:id/status', async (request, reply) => {
    const { id } = request.params as any;
    const { status } = request.body as any; // 'delivered' | 'read'
    const userId = request.user.id;

    if (status === 'delivered') {
      await MessageStatusService.markDelivered(id, userId);
    } else if (status === 'read') {
      await MessageStatusService.markRead(id, userId);
    } else {
      return reply.status(400).send({ success: false, error: 'Invalid status' });
    }

    return reply.send({ success: true });
  });

  // POST /api/v1/messages/read-all - Mark all messages in conversation as read
  fastify.post('/read-all', async (request, reply) => {
    const { conversation_id } = request.body as any;
    const userId = request.user.id;

    await MessageStatusService.markAllRead(conversation_id, userId);

    return reply.send({ success: true });
  });

  // GET /api/v1/messages/:convId - Get message history
  fastify.get('/:convId', async (request, reply) => {
    const { convId } = request.params as any;
    const { limit = 50, before } = request.query as any;
    const userId = request.user.id;

    // Verify membership
    const membership = await db.execute({
      sql: 'SELECT 1 FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
      args: [convId, userId],
    });

    if (membership.rows.length === 0) {
      return reply.status(403).send({ success: false, error: 'Access denied' });
    }

    let query = `SELECT * FROM messages WHERE conversation_id = ?`;
    let args: any[] = [convId];

    if (before) {
      query += ` AND created_at < (SELECT created_at FROM messages WHERE id = ?)`;
      args.push(before);
    }

    query += ` ORDER BY created_at DESC LIMIT ?`;
    args.push(parseInt(limit));

    const result = await db.execute({ sql: query, args });
    return reply.send({ success: true, messages: result.rows });
  });

  // PUT /api/v1/messages/:id - Edit message (5 min window)
  fastify.put('/:id', async (request, reply) => {
    const { id } = request.params as any;
    const { encrypted_content } = request.body as any;
    const userId = request.user.id;

    const message = await db.execute({
      sql: 'SELECT * FROM messages WHERE id = ? AND sender_id = ?',
      args: [id, userId],
    });

    if (message.rows.length === 0) {
      return reply.status(404).send({ success: false, error: 'Message not found or unauthorized' });
    }

    const msg = message.rows[0] as any;
    const createdAt = new Date(msg.created_at);
    const diffMinutes = (Date.now() - createdAt.getTime()) / 60000;

    if (diffMinutes > 5) {
      return reply.status(400).send({ success: false, error: 'Edit window (5 mins) expired' });
    }

    await db.execute({
      sql: 'UPDATE messages SET encrypted_content = ?, is_edited = 1, edited_at = CURRENT_TIMESTAMP WHERE id = ?',
      args: [encrypted_content, id],
    });

    // Broadcast edit
    const members = await db.execute({
      sql: 'SELECT user_id FROM conversation_members WHERE conversation_id = ?',
      args: [msg.conversation_id],
    });

    members.rows.forEach((row: any) => {
      WebSocketManager.sendToUser(row.user_id, 'message:edited', { id, encrypted_content });
    });

    return reply.send({ success: true });
  });

  // DELETE /api/v1/messages/:id - Delete message
  fastify.delete('/:id', async (request, reply) => {
    const { id } = request.params as any;
    const { deleteForEveryone } = request.query as any;
    const userId = request.user.id;

    const message = await db.execute({
      sql: 'SELECT * FROM messages WHERE id = ?',
      args: [id],
    });

    if (message.rows.length === 0) {
      return reply.status(404).send({ success: false, error: 'Message not found' });
    }

    const msg = message.rows[0] as any;

    if (deleteForEveryone === 'true') {
      if (msg.sender_id !== userId) {
        return reply.status(403).send({ success: false, error: 'Only sender can delete for everyone' });
      }

      await db.execute({
        sql: 'UPDATE messages SET deleted_for_everyone = 1 WHERE id = ?',
        args: [id],
      });

      const members = await db.execute({
        sql: 'SELECT user_id FROM conversation_members WHERE conversation_id = ?',
        args: [msg.conversation_id],
      });

      members.rows.forEach((row: any) => {
        WebSocketManager.sendToUser(row.user_id, 'message:deleted', { id, deleteForEveryone: true });
      });
    } else {
      // Delete for self (we'd typically use a junction table or a status table for this)
      // For MVP, we'll mark it in message_status if it exists, or just return success
      return reply.send({ success: true, message: 'Deleted for self' });
    }

    return reply.send({ success: true });
  });
}
