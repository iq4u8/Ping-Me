import { FastifyInstance } from 'fastify';
import db from '../utils/db.js';
import { authMiddleware } from '../middlewares/auth.js';
import { StorageRouter } from '../services/storage_router.js';
import { StorageService } from '../services/storage.js';
import { ThumbnailService } from '../services/thumbnailService.js';
import { PrivacyService } from '../services/privacyService.js';
import { v4 as uuidv4 } from 'uuid';
import path from 'path';

export default async function userRoutes(fastify: FastifyInstance) {
  fastify.addHook('preHandler', authMiddleware);

  /**
   * GET /api/v1/users/me
   * Get own profile
   */
  fastify.get('/me', async (request, reply) => {
    const user = await db.execute({
      sql: `SELECT id, username, display_name, email, phone, avatar_url, bio, 
            last_seen_privacy, profile_photo_privacy, phone_visible, 
            read_receipts_enabled, notifications_enabled, created_at 
            FROM users WHERE id = ?`,
      args: [request.user.id],
    });

    if (user.rows.length === 0) {
      return reply.status(404).send({ success: false, error: 'User not found' });
    }

    return reply.send({ success: true, user: user.rows[0] });
  });

  /**
   * PUT /api/v1/users/me
   * Update own profile
   */
  fastify.put('/me', async (request, reply) => {
    const { display_name, bio } = request.body as any;
    const userId = request.user.id;

    await db.execute({
      sql: 'UPDATE users SET display_name = COALESCE(?, display_name), bio = COALESCE(?, bio), updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      args: [display_name || null, bio || null, userId],
    });

    return reply.send({ success: true });
  });

  /**
   * POST /api/v1/users/me/avatar
   * Upload and set profile avatar
   */
  fastify.post('/me/avatar', async (request, reply) => {
    const data = await request.file();
    if (!data) {
      return reply.status(400).send({ success: false, error: 'No file uploaded' });
    }

    const buffer = await data.toBuffer();
    const mimeType = data.mimetype;
    
    if (!ThumbnailService.isImage(mimeType)) {
      return reply.status(400).send({ success: false, error: 'Only images allowed for avatars' });
    }

    const account = await StorageRouter.selectStorageAccount();
    const client = StorageRouter.getClient(account);
    const fileId = uuidv4();
    const extension = path.extname(data.filename) || '.jpg';
    const bucketKey = `avatars/${fileId}${extension}`;

    try {
      // Upload avatar
      await StorageService.uploadFile(client, account.bucket_name, buffer, bucketKey, mimeType);
      
      // Get signed URL (or use a public one if configured)
      const avatarUrl = await StorageService.getFileUrl(client, account.bucket_name, bucketKey);

      // Update user record
      await db.execute({
        sql: 'UPDATE users SET avatar_url = ? WHERE id = ?',
        args: [bucketKey, request.user.id],
      });

      return reply.send({ success: true, avatarUrl });
    } catch (error: any) {
      return reply.status(500).send({ success: false, error: error.message });
    }
  });

  /**
   * PUT /api/v1/users/me/settings
   * Update privacy and notification settings
   */
  fastify.put('/me/settings', async (request, reply) => {
    const { 
      last_seen_privacy, 
      profile_photo_privacy, 
      phone_visible, 
      read_receipts_enabled, 
      notifications_enabled 
    } = request.body as any;
    const userId = request.user.id;

    await db.execute({
      sql: `UPDATE users SET 
            last_seen_privacy = COALESCE(?, last_seen_privacy),
            profile_photo_privacy = COALESCE(?, profile_photo_privacy),
            phone_visible = COALESCE(?, phone_visible),
            read_receipts_enabled = COALESCE(?, read_receipts_enabled),
            notifications_enabled = COALESCE(?, notifications_enabled),
            updated_at = CURRENT_TIMESTAMP
            WHERE id = ?`,
      args: [
        last_seen_privacy || null,
        profile_photo_privacy || null,
        phone_visible ?? null,
        read_receipts_enabled ?? null,
        notifications_enabled ?? null,
        userId
      ],
    });

    return reply.send({ success: true });
  });

  /**
   * POST /api/v1/users/block/:id
   * Block a user
   */
  fastify.post('/block/:id', async (request, reply) => {
    const { id } = request.params as any;
    const userId = request.user.id;

    if (id === userId) {
      return reply.status(400).send({ success: false, error: 'You cannot block yourself' });
    }

    try {
      await db.execute({
        sql: 'INSERT INTO blocked_users (user_id, blocked_user_id) VALUES (?, ?)',
        args: [userId, id],
      });
      return reply.send({ success: true });
    } catch (error: any) {
      return reply.send({ success: true, message: 'User already blocked' });
    }
  });

  /**
   * DELETE /api/v1/users/block/:id
   * Unblock a user
   */
  fastify.delete('/block/:id', async (request, reply) => {
    const { id } = request.params as any;
    const userId = request.user.id;

    await db.execute({
      sql: 'DELETE FROM blocked_users WHERE user_id = ? AND blocked_user_id = ?',
      args: [userId, id],
    });

    return reply.send({ success: true });
  });

  /**
   * GET /api/v1/users/blocked
   * List blocked users
   */
  fastify.get('/blocked', async (request, reply) => {
    const userId = request.user.id;

    const result = await db.execute({
      sql: `SELECT u.id, u.username, u.display_name, u.avatar_url 
            FROM users u 
            JOIN blocked_users b ON u.id = b.blocked_user_id 
            WHERE b.user_id = ?`,
      args: [userId],
    });

    return reply.send({ success: true, users: result.rows });
  });

  /**
   * POST /api/v1/users/contacts/discover
   * Find users by phone numbers
   */
  fastify.post('/contacts/discover', async (request, reply) => {
    const { phoneNumbers } = request.body as any; // Array of phone numbers

    if (!Array.isArray(phoneNumbers) || phoneNumbers.length === 0) {
      return reply.status(400).send({ success: false, error: 'Phone numbers array required' });
    }

    // Filter users who have phone_visible = 1
    const placeholders = phoneNumbers.map(() => '?').join(',');
    const result = await db.execute({
      sql: `SELECT id, username, display_name, avatar_url, phone 
            FROM users 
            WHERE phone IN (${placeholders}) AND phone_visible = 1`,
      args: phoneNumbers,
    });

    return reply.send({ success: true, users: result.rows });
  });

  /**
   * GET /api/v1/users/search
   * Search users by username
   */
  fastify.get('/search', async (request, reply) => {
    const { q } = request.query as any;
    if (!q || q.length < 3) {
      return reply.status(400).send({ success: false, error: 'Search query must be at least 3 characters' });
    }

    const result = await db.execute({
      sql: 'SELECT id, username, display_name, avatar_url FROM users WHERE username LIKE ? LIMIT 20',
      args: [`%${q.toLowerCase()}%`],
    });

    return reply.send({ success: true, users: result.rows });
  });

  /**
   * DELETE /api/v1/users/me
   * Schedule account deletion (7-day grace period)
   */
  fastify.delete('/me', async (request, reply) => {
    const userId = request.user.id;
    const gracePeriodEnd = new Date();
    gracePeriodEnd.setDate(gracePeriodEnd.getDate() + 7);

    await db.execute({
      sql: 'UPDATE users SET deletion_scheduled_at = ? WHERE id = ?',
      args: [gracePeriodEnd.toISOString(), userId],
    });

    return reply.send({ 
      success: true, 
      message: 'Account deletion scheduled for 7 days from now. Login again to cancel.' 
    });
  });

  /**
   * GET /api/v1/users/:id
   * View other user profile
   */
  fastify.get('/:id', async (request, reply) => {
    const { id } = request.params as any;
    const requestingUserId = request.user.id;

    // Find user ID first if username is provided
    let targetUserId = id;
    if (id.length < 32) { // Rough check for UUID
      const userResult = await db.execute({
        sql: 'SELECT id FROM users WHERE username = ?',
        args: [id],
      });
      if (userResult.rows.length === 0) {
        return reply.status(404).send({ success: false, error: 'User not found' });
      }
      targetUserId = (userResult.rows[0] as any).id;
    }

    const filteredProfile = await PrivacyService.filterProfile(targetUserId, requestingUserId);

    if (!filteredProfile) {
      return reply.status(404).send({ success: false, error: 'User not found' });
    }

    return reply.send({ success: true, user: filteredProfile });
  });
}
