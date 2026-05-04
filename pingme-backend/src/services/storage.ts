import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { env } from '../config/env.js';

export class StorageService {
  /**
   * Uploads a file to a specific S3/R2 bucket
   */
  static async uploadFile(
    client: S3Client,
    bucket: string,
    buffer: Buffer,
    key: string,
    mimeType: string
  ): Promise<string> {
    const command = new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: buffer,
      ContentType: mimeType,
    });

    await client.send(command);
    return key;
  }

  /**
   * Generates a signed URL for temporary access
   */
  static async getFileUrl(
    client: S3Client,
    bucket: string,
    key: string,
    expiresIn: number = 3600
  ): Promise<string> {
    const command = new GetObjectCommand({
      Bucket: bucket,
      Key: key,
    });

    return await getSignedUrl(client, command, { expiresIn });
  }

  /**
   * Deletes a file from bucket
   */
  static async deleteFile(
    client: S3Client,
    bucket: string,
    key: string
  ): Promise<void> {
    const command = new DeleteObjectCommand({
      Bucket: bucket,
      Key: key,
    });

    await client.send(command);
  }
}
