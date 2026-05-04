import { FastifyInstance } from 'fastify';
import { v4 as uuidv4 } from 'uuid';
import db from '../utils/db.js';
import { authMiddleware } from '../middlewares/auth.js';
import { WebSocketManager } from '../websocket/manager.js';

export default async function conversationRoutes(fastify: FastifyInstance) {
  fastify.addHook('preHandler', authMiddleware);

  /**
   * POST /api/v1/conversations
   * Create a new group or channel
   */
  fastify.post('/', async (request, reply) => {
    const { type, name, description, memberIds } = request.body as any;
    const creator_id = request.user.id;

    if (!['group', 'channel'].includes(type)) {
      return reply.status(400).send({ success: false, error: 'Invalid conversation type' });
    }

    if (!name) {
      return reply.status(400).send({ success: false, error: 'Name is required' });
    }

    const conversationId = uuidv4();

    try {
      // 1. Create conversation
      await db.execute({
        sql: `INSERT INTO conversations (id, type, name, description, creator_id)
              VALUES (?, ?, ?, ?, ?)`,
        args: [conversationId, type, name, description || null, creator_id],
      });

      // 2. Add creator as owner
      await db.execute({
        sql: `INSERT INTO conversation_members (conversation_id, user_id, role)
              VALUES (?, ?, 'owner')`,
        args: [conversationId, creator_id],
      });

      // 3. Add initial members if provided (only for groups)
      if (type === 'group' && Array.isArray(memberIds)) {
        for (const userId of memberIds) {
          if (userId === creator_id) continue;
          await db.execute({
            sql: `INSERT INTO conversation_members (conversation_id, user_id, role)
                  VALUES (?, ?, 'member')`,
            args: [conversationId, userId],
          });
        }
      }

      return reply.send({ success: true, conversationId });
    } catch (error: any) {
      return reply.status(500).send({ success: false, error: error.message });
    }
  });

  /**
   * PUT /api/v1/conversations/:id
   * Update group/channel info (Admins only)
   */
  fastify.put('/:id', async (request, reply) => {
    const { id } = request.params as any;
    const { name, description, avatar_url } = request.body as any;
    const userId = request.user.id;

    // Check permissions
    const member = await db.execute({
      sql: 'SELECT role FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
      args: [id, userId],
    });

    if (member.rows.length === 0 || !['owner', 'admin'].includes((member.rows[0] as any).role)) {
      return reply.status(403).send({ success: false, error: 'Unauthorized: Admins only' });
    }

    await db.execute({
      sql: `UPDATE conversations 
            SET name = COALESCE(?, name), 
                description = COALESCE(?, description), 
                avatar_url = COALESCE(?, avatar_url),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ?`,
      args: [name || null, description || null, avatar_url || null, id],
    });

    return reply.send({ success: true });
  });

  /**
   * POST /api/v1/conversations/:id/members
   * Add a member to group (Admins only)
   */
  fastify.post('/:id/members', async (request, reply) => {
    const { id } = request.params as any;
    const { userId } = request.body as any;
    const adminId = request.user.id;

    // 1. Check if caller is admin/owner
    const caller = await db.execute({
      sql: 'SELECT role FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
      args: [id, adminId],
    });

    if (caller.rows.length === 0 || !['owner', 'admin'].includes((caller.rows[0] as any).role)) {
      return reply.status(403).send({ success: false, error: 'Unauthorized' });
    }

    // 2. Add member
    try {
      await db.execute({
        sql: 'INSERT INTO conversation_members (conversation_id, user_id, role) VALUES (?, ?, ?)',
        args: [id, userId, 'member'],
      });
      return reply.send({ success: true });
    } catch (error: any) {
      return reply.status(400).send({ success: false, error: 'User already in conversation or invalid ID' });
    }
  });

  /**
   * DELETE /api/v1/conversations/:id/members/:userId
   * Remove member or leave (Admin only to remove others)
   */
  fastify.delete('/:id/members/:userId', async (request, reply) => {
    const { id, userId } = request.params as any;
    const callerId = request.user.id;

    if (callerId !== userId) {
      // Attempting to remove someone else - check admin status
      const caller = await db.execute({
        sql: 'SELECT role FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
        args: [id, callerId],
      });

      if (caller.rows.length === 0 || !['owner', 'admin'].includes((caller.rows[0] as any).role)) {
        return reply.status(403).send({ success: false, error: 'Unauthorized' });
      }
    }

    await db.execute({
      sql: 'DELETE FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
      args: [id, userId],
    });

    return reply.send({ success: true });
  });

  /**
   * PUT /api/v1/conversations/:id/members/:userId/role
   * Update member role (Owner only)
   */
  fastify.put('/:id/members/:userId/role', async (request, reply) => {
    const { id, userId } = request.params as any;
    const { role } = request.body as any; // 'admin' | 'member'
    const ownerId = request.user.id;

    if (!['admin', 'member'].includes(role)) {
      return reply.status(400).send({ success: false, error: 'Invalid role' });
    }

    // Check if caller is owner
    const caller = await db.execute({
      sql: 'SELECT role FROM conversation_members WHERE conversation_id = ? AND user_id = ?',
      args: [id, ownerId],
    });

    if (caller.rows.length === 0 || (caller.rows[0] as any).role !== 'owner') {
      return reply.status(403).send({ success: false, error: 'Only owners can manage roles' });
    }

    await db.execute({
      sql: 'UPDATE conversation_members SET role = ? WHERE conversation_id = ? AND user_id = ?',
      args: [role, id, userId],
    });

    return reply.send({ success: true });
  });
}
