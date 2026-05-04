import { FastifyInstance } from 'fastify';
import { v4 as uuidv4 } from 'uuid';
import path from 'path';
import { env } from '../config/env.js';
import db from '../utils/db.js';
import { authMiddleware } from '../middlewares/auth.js';
import { StorageRouter } from '../services/storage_router.js';
import { StorageService } from '../services/storage.js';
import { ThumbnailService } from '../services/thumbnailService.js';

export default async function mediaRoutes(fastify: FastifyInstance) {
  fastify.addHook('preHandler', authMiddleware);

  /**
   * POST /api/v1/media/upload
   * Handles multipart file upload
   */
  fastify.post('/upload', async (request, reply) => {
    const data = await request.file({
      limits: {
        fileSize: 50 * 1024 * 1024, // Max 50MB for videos
      }
    });

    if (!data) {
      return reply.status(400).send({ success: false, error: 'No file uploaded' });
    }

    const buffer = await data.toBuffer();
    const mimeType = data.mimetype;
    const fileSize = buffer.length;
    const fileName = data.filename;
    const extension = path.extname(fileName);

    // Step 63: Validate file size limits
    const limits: Record<string, number> = {
      image: 10 * 1024 * 1024,
      video: 50 * 1024 * 1024,
      audio: 15 * 1024 * 1024,
      file: 25 * 1024 * 1024,
    };

    let fileType = 'file';
    if (mimeType.startsWith('image/')) fileType = 'image';
    else if (mimeType.startsWith('video/')) fileType = 'video';
    else if (mimeType.startsWith('audio/')) fileType = 'audio';

    if (fileSize > (limits[fileType] || limits.file)) {
      return reply.status(413).send({ success: false, error: `File too large for type ${fileType}` });
    }

    // Step 56: Pick storage account and upload
    const account = await StorageRouter.selectStorageAccount();
    const client = StorageRouter.getClient(account);
    const fileId = uuidv4();
    const bucketKey = `${fileType}s/${fileId}${extension}`;

    try {
      // 1. Upload original file
      await StorageService.uploadFile(client, account.bucket_name, buffer, bucketKey, mimeType);

      // Step 59: Generate and upload thumbnail if image
      let thumbKey = null;
      if (fileType === 'image') {
        const thumbBuffer = await ThumbnailService.generateThumbnail(buffer);
        thumbKey = `${fileType}s/${fileId}_thumb.webp`;
        await StorageService.uploadFile(client, account.bucket_name, thumbBuffer, thumbKey, 'image/webp');
      }

      // 2. Insert into files table
      await db.execute({
        sql: `INSERT INTO files (id, storage_account_id, bucket_key, file_type, file_size, mime_type, uploader_id)
              VALUES (?, ?, ?, ?, ?, ?, ?)`,
        args: [fileId, account.id, bucketKey, fileType, fileSize, mimeType, request.user.id],
      });

      // 3. Update storage usage
      await StorageRouter.updateUsage(account.id, fileSize + (thumbKey ? 5000 : 0)); // Approx 5kb for thumb

      return reply.send({
        success: true,
        fileId,
        url: await StorageService.getFileUrl(client, account.bucket_name, bucketKey),
        thumbUrl: thumbKey ? await StorageService.getFileUrl(client, account.bucket_name, thumbKey) : null
      });

    } catch (error: any) {
      return reply.status(500).send({ success: false, error: error.message });
    }
  });

  /**
   * GET /api/v1/media/:fileId
   * Returns a signed URL for the file
   */
  fastify.get('/:fileId', async (request, reply) => {
    const { fileId } = request.params as any;
    const { thumb } = request.query as any;

    const result = await db.execute({
      sql: 'SELECT f.*, sa.endpoint, sa.access_key, sa.secret_key, sa.bucket_name FROM files f JOIN storage_accounts sa ON f.storage_account_id = sa.id WHERE f.id = ?',
      args: [fileId],
    });

    // Fallback for files using 'default' account not in DB
    let fileInfo: any;
    if (result.rows.length === 0) {
      const fallbackResult = await db.execute({
        sql: 'SELECT * FROM files WHERE id = ?',
        args: [fileId],
      });
      if (fallbackResult.rows.length === 0) {
        return reply.status(404).send({ success: false, error: 'File not found' });
      }
      fileInfo = fallbackResult.rows[0];
      // Use env for default account
      fileInfo.endpoint = env.R2_ENDPOINT;
      fileInfo.access_key = env.R2_ACCESS_KEY;
      fileInfo.secret_key = env.R2_SECRET_KEY;
      fileInfo.bucket_name = env.R2_BUCKET_NAME;
    } else {
      fileInfo = result.rows[0];
    }

    const client = StorageRouter.getClient({
      endpoint: fileInfo.endpoint,
      access_key: fileInfo.access_key,
      secret_key: fileInfo.secret_key,
    } as any);

    const key = (thumb === 'true' && fileInfo.file_type === 'image') 
      ? fileInfo.bucket_key.replace(/(\.[^.]+)$/, '_thumb.webp')
      : fileInfo.bucket_key;

    const url = await StorageService.getFileUrl(client, fileInfo.bucket_name, key);
    return reply.send({ success: true, url });
  });
}
